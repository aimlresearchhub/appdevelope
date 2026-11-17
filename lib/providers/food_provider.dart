import 'package:flutter/foundation.dart';

import '../config.dart';
import '../models/food_item.dart';
import '../services/api_service.dart';

class FoodProvider extends ChangeNotifier {
  FoodProvider(this._api);

  final ApiService _api;
  List<FoodItem> items = [];
  bool isLoading = false;
  String? error;

  Future<void> load({String? token}) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      items = token == AppConfig.demoToken && AppConfig.demoLoginEnabled
          ? const [
              FoodItem(
                id: 1,
                name: 'Garden avocado toast',
                price: 8.50,
                rating: 4.8,
                description: 'Sourdough, avocado, herbs',
                imageUrl:
                    'https://images.unsplash.com/photo-1525351484163-7529414344d8?auto=format&fit=crop&w=800&q=85',
              ),
              FoodItem(
                id: 2,
                name: 'Roasted tomato pasta',
                price: 13.25,
                rating: 4.7,
                description: 'Slow-roasted tomatoes and basil',
                imageUrl:
                    'https://images.unsplash.com/photo-1473093295043-cdd812d0e601?auto=format&fit=crop&w=800&q=85',
              ),
              FoodItem(
                id: 3,
                name: 'Berry breakfast bowl',
                price: 7.95,
                rating: 4.9,
                description: 'Seasonal berries, oats, honey',
                imageUrl:
                    'https://images.unsplash.com/photo-1490645935967-10de6ba17061?auto=format&fit=crop&w=800&q=85',
              ),
            ]
          : await _api.fetchFoods();
    } on ApiException catch (exception) {
      error = exception.message;
    } catch (exception) {
      error = 'Could not load foods: $exception';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
