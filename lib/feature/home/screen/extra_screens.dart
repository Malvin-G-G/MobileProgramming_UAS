import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/shared_prefs_provider.dart';
import '../../../core/router/app_routes.dart';
import '../../auth/providers/auth_provider.dart';
import '../../languages/language_select/providers/language_provider.dart';
import '../../lesson/data/lesson_catalog.dart';
import '../../progress/providers/progress_provider.dart';

class VocabularyScreen extends ConsumerStatefulWidget {
  const VocabularyScreen({super.key});
  @override
  ConsumerState<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends ConsumerState<VocabularyScreen> {
  String query = '';
  final Set<String> favorites = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final saved = ref.read(sharedPrefsProvider).getStringList('vocab_favorites') ?? [];
      if (mounted) setState(() => favorites.addAll(saved));
    });
  }

  @override
  Widget build(BuildContext context) {
    final code = ref.watch(selectedLanguageProvider) ?? 'en';
    final words = courseCatalog.expand((u) => u.lessons).where((l) => !l.isReview).expand((l) => l.words);
    final filtered = words.where((w) {
      final target = code == 'jp' ? w.ja : w.en;
      final meaning = code == 'jp' ? w.en : w.ind;
      return '$target $meaning'.toLowerCase().contains(query.toLowerCase());
    }).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Kamus kosakata')),
      body: Column(children: [
        Padding(padding: const EdgeInsets.all(16), child: TextField(
          decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: 'Cari kosakata...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(16))),
          onChanged: (v) => setState(() => query = v),
        )),
        Expanded(child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: filtered.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final w = filtered[i];
            final target = code == 'jp' ? w.ja : w.en;
            final meaning = code == 'jp' ? w.en : w.ind;
            final key = '$target|$meaning';
            final saved = favorites.contains(key);
            return ListTile(title: Text(target, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text(meaning), trailing: IconButton(
              icon: Icon(saved ? Icons.favorite : Icons.favorite_border, color: saved ? Colors.red : null),
              onPressed: () async {
                setState(() => saved ? favorites.remove(key) : favorites.add(key));
                await ref.read(sharedPrefsProvider).setStringList('vocab_favorites', favorites.toList());
              },
            ));
          },
        )),
      ]),
    );
  }
}

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(progressProvider).value;
    final xp = p?.xp ?? 0;
    final done = p?.completed.length ?? 0;
    return Scaffold(appBar: AppBar(title: const Text('Statistik belajar')), body: ListView(padding: const EdgeInsets.all(20), children: [
      Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Total XP'), Text('$xp XP', style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold)), const SizedBox(height: 8), LinearProgressIndicator(value: (xp % 100) / 100), Text('${xp % 100}/100 XP menuju level berikutnya')]))),
      const SizedBox(height: 12),
      Row(children: [Expanded(child: _Metric(icon: Icons.school, title: 'Lesson selesai', value: '$done')), const SizedBox(width: 12), Expanded(child: _Metric(icon: Icons.bolt, title: 'Level', value: '${p?.level ?? 1}'))]),
      const SizedBox(height: 20),
      const Text('Target belajar harian', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      const Text('Selesaikan minimal satu lesson setiap hari untuk menjaga konsistensi belajarmu.'),
    ]));
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.title, required this.value});
  final IconData icon; final String title; final String value;
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [Icon(icon, size: 28), const SizedBox(height: 8), Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)), Text(title)])));
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).value;
    final p = ref.watch(progressProvider).value;
    return Scaffold(appBar: AppBar(title: const Text('Profil')), body: ListView(padding: const EdgeInsets.all(20), children: [
      CircleAvatar(radius: 42, child: Text((user?.username.isNotEmpty ?? false) ? user!.username[0].toUpperCase() : '?', style: const TextStyle(fontSize: 32))),
      const SizedBox(height: 12), Center(child: Text(user?.username ?? 'Pengguna', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
      Center(child: Text(user?.email ?? '')),
      const SizedBox(height: 24),
      _Metric(icon: Icons.bolt, title: 'Total XP', value: '${p?.xp ?? 0}'),
      _Metric(icon: Icons.star, title: 'Level', value: '${p?.level ?? 1}'),
      _Metric(icon: Icons.menu_book, title: 'Lesson selesai', value: '${p?.completed.length ?? 0}'),
      const SizedBox(height: 16),
      ListTile(leading: const Icon(Icons.language), title: const Text('Ganti bahasa'), trailing: const Icon(Icons.chevron_right), onTap: () => context.go(AppRoutes.language)),
      ListTile(leading: const Icon(Icons.logout, color: Colors.red), title: const Text('Keluar akun'), onTap: () async { await ref.read(authProvider.notifier).logout(); if (context.mounted) context.go(AppRoutes.login); }),
    ]));
  }
}
