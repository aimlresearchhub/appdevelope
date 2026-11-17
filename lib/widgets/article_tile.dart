import 'package:flutter/material.dart';

import '../models/article.dart';

class ArticleTile extends StatelessWidget {
  const ArticleTile({
    super.key,
    required this.article,
    required this.onTap,
    required this.onFavorite,
    this.favoritePending = false,
  });

  final Article article;
  final VoidCallback onTap;
  final VoidCallback onFavorite;
  final bool favoritePending;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              if (article.imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    article.imageUrl,
                    width: 86,
                    height: 86,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) =>
                        progress == null
                        ? child
                        : const SizedBox(
                            width: 86,
                            height: 86,
                            child: Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                    errorBuilder: (_, _, _) => _placeholder(colors),
                  ),
                )
              else
                _placeholder(colors),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      article.summary.isEmpty ? article.body : article.summary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: favoritePending ? null : onFavorite,
                tooltip: article.isFavorite
                    ? 'Remove favorite'
                    : 'Add favorite',
                icon: favoritePending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        article.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: article.isFavorite ? colors.error : null,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder(ColorScheme colors) => Container(
    width: 86,
    height: 86,
    decoration: BoxDecoration(
      color: colors.primaryContainer,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Icon(Icons.article_outlined, color: colors.onPrimaryContainer),
  );
}
