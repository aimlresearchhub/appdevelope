import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config.dart';
import '../models/article.dart';
import '../models/food_item.dart';

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ApiService {
  ApiService({required this.baseUrl, http.Client? client})
    : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Map<String, String> _headers(String? token) => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    if (token != null && token.isNotEmpty) 'Authorization': 'Token $token',
  };

  Future<List<dynamic>> _getList(String path, {String? token}) async {
    final response = await _client.get(_uri(path), headers: _headers(token));
    final data = _decode(response);
    final list = data is List
        ? data
        : data is Map
        ? (data['results'] ?? data['items'])
        : null;
    if (list is! List) {
      throw const ApiException(
        'The server returned an unexpected list response.',
      );
    }
    return list;
  }

  Future<List<FoodItem>> fetchFoods() async =>
      (await _getList(AppConfig.foodsPath))
          .whereType<Map>()
          .map((item) => FoodItem.fromJson(Map<String, dynamic>.from(item)))
          .toList();

  Future<List<Article>> fetchArticles(String token) async =>
      (await _getList(AppConfig.articlesPath, token: token))
          .whereType<Map>()
          .map((item) => Article.fromJson(Map<String, dynamic>.from(item)))
          .toList();

  Future<String> login(String username, String password) async {
    final data = await _postJson(AppConfig.loginPath, {
      'username': username,
      'password': password,
    });
    return _tokenFrom(data);
  }

  Future<String> register(
    String username,
    String email,
    String password,
  ) async {
    final data = await _postJson(AppConfig.registerPath, {
      'username': username,
      'email': email,
      'password': password,
    });
    return _tokenFrom(data);
  }

  Future<Map<String, dynamic>> toggleFavorite(
    String token,
    Object articleId,
  ) async {
    final response = await _client.post(
      _uri(AppConfig.favoriteTogglePath(articleId)),
      headers: _headers(token),
    );
    final data = _decode(response);
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return const {};
  }

  Future<dynamic> _postJson(String path, Map<String, String> body) async {
    final response = await _client.post(
      _uri(path),
      headers: _headers(null),
      body: jsonEncode(body),
    );
    return _decode(response);
  }

  String _tokenFrom(dynamic data) {
    if (data is Map) {
      final token = data['token'] ?? data['key'] ?? data['access'];
      if (token is String && token.isNotEmpty) return token;
    }
    throw const ApiException('Authentication succeeded without a token.');
  }

  dynamic _decode(http.Response response) {
    dynamic data;
    try {
      data = response.body.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(response.body);
    } on FormatException {
      throw ApiException(
        'The server returned invalid JSON (${response.statusCode}).',
      );
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(_errorMessage(data, response.statusCode));
    }
    return data;
  }

  String _errorMessage(dynamic data, int statusCode) {
    if (data is Map) {
      final detail = data['detail'] ?? data['error'] ?? data['message'];
      if (detail != null) return '$detail';
      final messages = data.values.expand(
        (value) => value is List ? value : [value],
      );
      if (messages.isNotEmpty) return messages.first.toString();
    }
    switch (statusCode) {
      case 401:
        return 'Incorrect username or password.';
      case 403:
        return 'You do not have permission to do that.';
      case 404:
        return 'The requested API endpoint was not found.';
      default:
        return 'Server error ($statusCode). Please try again.';
    }
  }
}
