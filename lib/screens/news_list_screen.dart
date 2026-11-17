import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/news_provider.dart';
import '../widgets/article_tile.dart';
import 'news_detail_screen.dart';

class NewsListScreen extends StatefulWidget {
  const NewsListScreen({super.key});

  @override
  State<NewsListScreen> createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    final token = context.read<AuthProvider>().token;
    if (token != null) context.read<NewsProvider>().load(token);
  }

  @override
  Widget build(BuildContext context) {
    final news = context.watch<NewsProvider>();
    final token = context.watch<AuthProvider>().token;
    if (news.isLoading && news.articles.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (news.error != null && news.articles.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(news.error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            onChanged: news.setQuery,
            decoration: InputDecoration(
              hintText: 'Search stories',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: news.query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      onPressed: () => news.setQuery(''),
                      icon: const Icon(Icons.close),
                    ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ),
        if (news.error != null)
          MaterialBanner(
            content: Text(news.error!),
            actions: [TextButton(onPressed: _load, child: const Text('Retry'))],
          ),
        Expanded(
          child: news.articles.isEmpty
              ? Center(
                  child: Text(
                    news.query.isEmpty
                        ? 'No stories yet.'
                        : 'No stories match your search.',
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                  itemCount: news.articles.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final article = news.articles[index];
                    return ArticleTile(
                      article: article,
                      favoritePending: news.isToggling(article.id),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              NewsDetailScreen(articleId: article.id),
                        ),
                      ),
                      onFavorite: token == null
                          ? () {}
                          : () async {
                              try {
                                await news.toggleFavorite(token, article.id);
                              } catch (error) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(error.toString())),
                                  );
                                }
                              }
                            },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
