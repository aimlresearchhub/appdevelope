import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _tokenKey = 'auth_token';
  static const _themeKey = 'dark_theme';
  static const _favoritesKey = 'favorite_article_ids';
  static const _profilePhotoKey = 'profile_photo_path';

  Future<String?> readToken() async =>
      (await SharedPreferences.getInstance()).getString(_tokenKey);

  Future<void> saveToken(String token) async =>
      (await SharedPreferences.getInstance()).setString(_tokenKey, token);

  Future<void> clearToken() async =>
      (await SharedPreferences.getInstance()).remove(_tokenKey);

  Future<bool> readDarkTheme() async =>
      (await SharedPreferences.getInstance()).getBool(_themeKey) ?? false;

  Future<void> saveDarkTheme(bool dark) async =>
      (await SharedPreferences.getInstance()).setBool(_themeKey, dark);

  Future<Set<String>> readFavorites() async =>
      (await SharedPreferences.getInstance())
          .getStringList(_favoritesKey)
          ?.toSet() ??
      <String>{};

  Future<void> saveFavorites(Set<String> ids) async =>
      (await SharedPreferences.getInstance()).setStringList(
        _favoritesKey,
        ids.toList(),
      );

  Future<String?> readProfilePhoto() async =>
      (await SharedPreferences.getInstance()).getString(_profilePhotoKey);

  Future<void> saveProfilePhoto(String path) async =>
      (await SharedPreferences.getInstance()).setString(_profilePhotoKey, path);
}
