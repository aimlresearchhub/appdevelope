import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/news_provider.dart';
import '../providers/theme_provider.dart';
import 'food_menu_screen.dart';
import 'news_list_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final news = context.watch<NewsProvider>();
    final theme = context.watch<ThemeProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(_tab == 0 ? 'Food menu' : 'News reader'),
        actions: [
          IconButton(
            tooltip: theme.isDark
                ? 'Switch to light theme'
                : 'Switch to dark theme',
            onPressed: theme.toggle,
            icon: Icon(
              theme.isDark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Badge(
                label: Text('${news.favoritesCount}'),
                child: const Icon(Icons.favorite_border),
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              const DrawerHeader(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.restaurant_menu, size: 44),
                      SizedBox(height: 8),
                      Text('Food & Stories'),
                    ],
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Profile'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ProfileScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Log out'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await context.read<AuthProvider>().logout();
                },
              ),
            ],
          ),
        ),
      ),
      body: IndexedStack(
        index: _tab,
        children: const [FoodMenuScreen(), NewsListScreen()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) => setState(() => _tab = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.restaurant), label: 'Food'),
          NavigationDestination(
            icon: Icon(Icons.article_outlined),
            label: 'Stories',
          ),
        ],
      ),
    );
  }
}
