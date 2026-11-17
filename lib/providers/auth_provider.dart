import 'package:flutter/foundation.dart';

import '../config.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._api, this._storage);

  final ApiService _api;
  final StorageService _storage;
  String? _token;
  bool _isRestoring = true;
  bool _isBusy = false;

  String? get token => _token;
  bool get isRestoring => _isRestoring;
  bool get isBusy => _isBusy;
  bool get isAuthenticated => _token != null;

  Future<void> restoreSession() async {
    _token = await _storage.readToken();
    if (_token == AppConfig.demoToken && !AppConfig.demoLoginEnabled) {
      _token = null;
      await _storage.clearToken();
    }
    _isRestoring = false;
    notifyListeners();
  }

  Future<void> login(String username, String password) {
    if (AppConfig.demoLoginEnabled &&
        username == AppConfig.demoUsername &&
        password == AppConfig.demoPassword) {
      return _authenticate(() async => AppConfig.demoToken);
    }
    return _authenticate(() => _api.login(username, password));
  }

  Future<void> register(String username, String email, String password) =>
      _authenticate(() => _api.register(username, email, password));

  Future<void> _authenticate(Future<String> Function() request) async {
    _isBusy = true;
    notifyListeners();
    try {
      _token = await request();
      await _storage.saveToken(_token!);
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _token = null;
    await _storage.clearToken();
    notifyListeners();
  }
}
