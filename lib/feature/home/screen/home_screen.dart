import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/shared_prefs_provider.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../../progress/providers/progress_provider.dart';
import '../../languages/language_select/models/language.dart';
import '../../languages/language_select/providers/language_provider.dart';
import '../../onboarding/{screens,providers}/onboarding_provider.dart';
import '../widgets/stats_header.dart';
import '../widgets/learning_path.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = languageByCode(ref.watch(selectedLanguageProvider));
    final progress = ref.watch(progressProvider).value;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            StatsHeader(
              leading: _LanguageMenu(language: language),
              xp: progress?.xp ?? 0,
              hearts: progress?.hearts ?? 0,
              level: progress?.level ?? 1,
            ),
            const Divider(height: 1, color: AppColors.border),
            const Expanded(child: LearningPath()),
          ],
        ),
      ),
    );
  }
}

class _LanguageMenu extends ConsumerWidget {
  const _LanguageMenu({required this.language});

  final Language? language;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).value;

    return PopupMenuButton<String>(
      tooltip: 'Menu',
      onSelected: (value) async {
        if (value == 'change') {
          context.go(AppRoutes.language);
        } else if (value == 'logout') {
          await ref.read(authProvider.notifier).logout();
          if (context.mounted) context.go(AppRoutes.login);
        } else if (value == 'reset') {
          await ref.read(sharedPrefsProvider).clear();
          ref.invalidate(selectedLanguageProvider);
          ref.invalidate(onboardingDoneProvider);
          ref.invalidate(authProvider);
          if (context.mounted) context.go(AppRoutes.splash);
        }
      },
      itemBuilder: (context) => [
        if (user != null)
          PopupMenuItem<String>(
            enabled: false,
            child: Text('Signed in as ${user.username}'),
          ),
        const PopupMenuItem<String>(
          value: 'change',
          child: Text('Change language'),
        ),
        const PopupMenuItem<String>(value: 'logout', child: Text('Log out')),
        // again, delete later, not now
        const PopupMenuItem<String>(
          value: 'reset',
          child: Text('Reset data (debug)'),
        ),
      ],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(language?.flag ?? '🌍', style: const TextStyle(fontSize: 28)),
          const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
