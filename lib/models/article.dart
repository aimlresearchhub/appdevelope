class Article {
  const Article({
    required this.id,
    required this.title,
    required this.body,
    this.summary = '',
    this.imageUrl = '',
    this.isFavorite = false,
    this.favoritesCount = 0,
  });

  final Object id;
  final String title;
  final String body;
  final String summary;
  final String imageUrl;
  final bool isFavorite;
  final int favoritesCount;

  factory Article.fromJson(Map<String, dynamic> json) => Article(
    id: json['id'] ?? json['pk'] ?? '',
    title: '${json['title'] ?? 'Untitled article'}',
    body: '${json['body'] ?? json['content'] ?? json['text'] ?? ''}',
    summary: '${json['summary'] ?? json['excerpt'] ?? ''}',
    imageUrl: '${json['image_url'] ?? json['image'] ?? ''}',
    isFavorite: json['is_favorite'] == true || json['favorited'] == true,
    favoritesCount: _integer(json['favorites_count'] ?? json['favorite_count']),
  );

  Article copyWith({bool? isFavorite, int? favoritesCount}) => Article(
    id: id,
    title: title,
    body: body,
    summary: summary,
    imageUrl: imageUrl,
    isFavorite: isFavorite ?? this.isFavorite,
    favoritesCount: favoritesCount ?? this.favoritesCount,
  );

  static int _integer(Object? value) =>
      value is num ? value.toInt() : int.tryParse('$value') ?? 0;
}
