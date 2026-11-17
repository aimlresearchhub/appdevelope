import 'package:flutter/foundation.dart';

import '../config.dart';
import '../models/article.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class NewsProvider extends ChangeNotifier {
  NewsProvider(this._api, this._storage);

  final ApiService _api;
  final StorageService _storage;
  List<Article> _articles = [];
  Set<String> _favoriteIds = {};
  String _query = '';
  String? error;
  bool isLoading = false;
  final Set<String> _pendingFavorites = {};

  List<Article> get articles {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _articles;
    return _articles
        .where((article) => article.title.toLowerCase().contains(query))
        .toList();
  }

  int get favoritesCount => _favoriteIds.length;
  String get query => _query;
  bool isToggling(Object id) => _pendingFavorites.contains('$id');

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  Future<void> load(String token) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      _favoriteIds = await _storage.readFavorites();
      _articles = token == AppConfig.demoToken && AppConfig.demoLoginEnabled
          ? const [
              Article(
                id: 101,
                title: 'A slower morning starts at the table',
                summary: 'Small rituals that make breakfast feel special.',
                body:
                    'A good breakfast does not need to be complicated. Choose fresh ingredients, take a little time, and enjoy the first meal of the day without rushing.',
              ),
              Article(
                id: 102,
                title: 'Five ways to make seasonal vegetables shine',
                summary: 'Simple ideas for cooking what is fresh right now.',
                body:
                    'Roast vegetables to concentrate their flavor, add a bright dressing, and finish with fresh herbs. Seasonal ingredients often need very little extra.',
              ),
              Article(
                id: 103,
                title: 'The joy of sharing a home-cooked meal',
                summary: 'Why gathering around the table still matters.',
                body:
                    'Meals bring people together. A simple dish shared with friends can become a memory worth keeping.',
              ),
            ]
          : await _api.fetchArticles(token);
      _articles = _articles
          .map(
            (article) => article.copyWith(
              isFavorite:
                  article.isFavorite || _favoriteIds.contains('${article.id}'),
            ),
          )
          .toList();
      _favoriteIds.addAll(
        _articles
            .where((article) => article.isFavorite)
            .map((article) => '${article.id}'),
      );
      await _storage.saveFavorites(_favoriteIds);
    } on ApiException catch (exception) {
      error = exception.message;
    } catch (exception) {
      error = 'Could not load articles: $exception';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(String token, Object id) async {
    final key = '$id';
    if (_pendingFavorites.contains(key)) return;
    final index = _articles.indexWhere((article) => '${article.id}' == key);
    if (index < 0) return;
    _pendingFavorites.add(key);
    final old = _articles[index];
    final desired = !old.isFavorite;
    _articles[index] = old.copyWith(
      isFavorite: desired,
      favoritesCount: (old.favoritesCount + (desired ? 1 : -1))
          .clamp(0, 1 << 30)
          .toInt(),
    );
    if (desired) {
      _favoriteIds.add(key);
    } else {
      _favoriteIds.remove(key);
    }
    notifyListeners();
    try {
      final response = token == AppConfig.demoToken && AppConfig.demoLoginEnabled
          ? const <String, dynamic>{}
          : await _api.toggleFavorite(token, id);
      final serverFavorite = response['is_favorite'] ?? response['favorited'];
      final serverCount =
          response['favorites_count'] ?? response['favorite_count'];
      final updated = _articles[index].copyWith(
        isFavorite: serverFavorite is bool ? serverFavorite : desired,
        favoritesCount: serverCount is num ? serverCount.toInt() : null,
      );
      _articles[index] = updated;
      if (updated.isFavorite) {
        _favoriteIds.add(key);
      } else {
        _favoriteIds.remove(key);
      }
      await _storage.saveFavorites(_favoriteIds);
    } catch (exception) {
      _articles[index] = old;
      if (old.isFavorite) {
        _favoriteIds.add(key);
      } else {
        _favoriteIds.remove(key);
      }
      error = exception is ApiException
          ? exception.message
          : 'Could not update favorite: $exception';
      rethrow;
    } finally {
      _pendingFavorites.remove(key);
      notifyListeners();
    }
  }
}
