import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/article.dart';
import '../providers/auth_provider.dart';
import '../providers/news_provider.dart';

class NewsDetailScreen extends StatelessWidget {
  const NewsDetailScreen({super.key, required this.articleId});

  final Object articleId;

  @override
  Widget build(BuildContext context) {
    final article = context
        .watch<NewsProvider>()
        .articles
        .cast<Article?>()
        .firstWhere((item) => item?.id == articleId, orElse: () => null);
    if (article == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('This article is no longer available.')),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          article.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            tooltip: article.isFavorite ? 'Remove favorite' : 'Add favorite',
            onPressed: () async {
              final token = context.read<AuthProvider>().token;
              if (token == null) return;
              try {
                await context.read<NewsProvider>().toggleFavorite(
                  token,
                  article.id,
                );
              } catch (error) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(error.toString())));
                }
              }
            },
            icon: Icon(
              article.isFavorite ? Icons.favorite : Icons.favorite_border,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (article.imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                article.imageUrl,
                height: 220,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) => progress == null
                    ? child
                    : const SizedBox(
                        height: 220,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                errorBuilder: (_, _, _) => const SizedBox(
                  height: 180,
                  child: Center(
                    child: Icon(Icons.broken_image_outlined, size: 48),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 20),
          Text(article.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          Text(article.body, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
