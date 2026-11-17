import 'package:flutter_test/flutter_test.dart';
import 'package:foodmenu/config.dart';
import 'package:foodmenu/models/article.dart';
import 'package:foodmenu/models/food_item.dart';
import 'package:foodmenu/providers/auth_provider.dart';
import 'package:foodmenu/services/api_service.dart';
import 'package:foodmenu/services/storage_service.dart';
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('Article parses Django article fields and favorite state', () {
    final article = Article.fromJson({
      'id': 12,
      'title': 'A story',
      'content': 'Full story text',
      'image': '/media/story.jpg',
      'is_favorite': true,
      'favorites_count': 4,
    });

    expect(article.id, 12);
    expect(article.body, 'Full story text');
    expect(article.imageUrl, '/media/story.jpg');
    expect(article.isFavorite, isTrue);
    expect(article.favoritesCount, 4);
  });

  test('Food item tolerates numeric strings and missing optional fields', () {
    final food = FoodItem.fromJson({
      'id': 2,
      'name': 'Soup',
      'price': '8.50',
      'rating': '4.7',
    });

    expect(food.price, 8.5);
    expect(food.rating, 4.7);
    expect(food.imageUrl, isEmpty);
  });

  if (AppConfig.demoLoginEnabled) {
    test(
      'demo credentials create a local session without an API request',
      () async {
        TestWidgetsFlutterBinding.ensureInitialized();
        SharedPreferences.setMockInitialValues({});
        final api = ApiService(
          baseUrl: 'http://unused',
          client: MockClient(
            (_) async => throw StateError('Unexpected API call'),
          ),
        );
        final storage = StorageService();
        final auth = AuthProvider(api, storage);

        await auth.login(AppConfig.demoUsername, AppConfig.demoPassword);

        expect(auth.token, AppConfig.demoToken);
        expect(await storage.readToken(), AppConfig.demoToken);
      },
    );
  } else {
    test('a demo session is discarded when demo login is disabled', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      final storage = StorageService();
      await storage.saveToken(AppConfig.demoToken);
      final auth = AuthProvider(
        ApiService(
          baseUrl: 'http://unused',
          client: MockClient(
            (_) async => throw StateError('Unexpected API call'),
          ),
        ),
        storage,
      );

      await auth.restoreSession();

      expect(auth.isAuthenticated, isFalse);
      expect(await storage.readToken(), isNull);
    });
  }
}
