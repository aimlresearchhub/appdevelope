class AppConfig {
  static const demoLoginEnabled =
      bool.fromEnvironment('ENABLE_DEMO_LOGIN') &&
      !bool.fromEnvironment('dart.vm.product') &&
      !bool.fromEnvironment('dart.vm.profile');
  static const demoUsername = String.fromEnvironment(
    'DEMO_USERNAME',
    defaultValue: 'demo',
  );
  static const demoPassword = String.fromEnvironment(
    'DEMO_PASSWORD',
    defaultValue: 'demo1234',
  );
  static const demoToken = 'local-demo-session';

  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  static const foodsPath = '/api/foods/';
  static const articlesPath = '/api/articles/';
  static const loginPath = '/api/auth/login/';
  static const registerPath = '/api/auth/register/';

  static String favoriteTogglePath(Object id) =>
      '$articlesPath$id/toggle_favorite/';
}
