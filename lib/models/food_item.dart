class FoodItem {
  const FoodItem({
    required this.id,
    required this.name,
    required this.price,
    required this.rating,
    this.imageUrl = '',
    this.description = '',
  });

  final Object id;
  final String name;
  final double price;
  final double rating;
  final String imageUrl;
  final String description;

  factory FoodItem.fromJson(Map<String, dynamic> json) => FoodItem(
    id: json['id'] ?? json['pk'] ?? json['name'] ?? '',
    name: '${json['name'] ?? json['title'] ?? 'Untitled food'}',
    price: _number(json['price'] ?? json['cost']),
    rating: _number(json['rating'] ?? json['average_rating']),
    imageUrl: '${json['image_url'] ?? json['image'] ?? ''}',
    description: '${json['description'] ?? ''}',
  );

  static double _number(Object? value) =>
      value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
}
