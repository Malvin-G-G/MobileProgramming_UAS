import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:uas_duolingo/core/theme/app_colors.dart';
import 'package:uas_duolingo/feature/home/screen/extra_screens.dart';
import 'package:uas_duolingo/feature/home/widgets/learning_path.dart';
import 'package:uas_duolingo/feature/home/widgets/stats_header.dart';
import 'package:uas_duolingo/feature/languages/language_select/models/language.dart';
import 'package:uas_duolingo/feature/languages/language_select/providers/language_provider.dart';
import 'package:uas_duolingo/feature/progress/providers/progress_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _tab = 0;
  @override
  Widget build(BuildContext context) {
    final language = languageByCode(ref.watch(selectedLanguageProvider));
    final progress = ref.watch(progressProvider).value;
    final pages = [
      Column(children: [
        StatsHeader(leading: _LanguageBadge(language: language), xp: progress?.xp ?? 0, hearts: progress?.hearts ?? 0, level: progress?.level ?? 1),
        const Divider(height: 1, color: AppColors.border),
        const Expanded(child: LearningPath()),
      ]),
      const VocabularyScreen(),
      const StatisticsScreen(),
      const ProfileScreen(),
    ];
    return Scaffold(
      body: SafeArea(child: IndexedStack(index: _tab, children: pages)),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) => setState(() => _tab = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Belajar'),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: 'Kamus'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'Statistik'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

class _LanguageBadge extends StatelessWidget {
  const _LanguageBadge({required this.language});
  final Language? language;
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Text(language?.flag ?? '🌍', style: const TextStyle(fontSize: 28)),
    const SizedBox(width: 5),
    Text(language?.name ?? 'Bahasa', style: const TextStyle(fontWeight: FontWeight.bold)),
  ]);
}
