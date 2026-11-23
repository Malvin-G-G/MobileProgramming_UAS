import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/shared_prefs_provider.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/prime.button.dart';
import '../../languages/language_select/models/language.dart';
import '../../languages/language_select/providers/language_provider.dart';
import '../../onboarding/{screens,providers}/onboarding_provider.dart';
import '../widgets/stats_header.dart';


class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = languageByCode(ref.watch(selectedLanguageProvider));

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            StatsHeader(
              leading: _LanguageMenu(language: language),
              xp: 120,
              hearts: 5,
            ),
            const Divider(height: 1, color: AppColors.border),
            const Expanded(child: _PathPlaceholder()),
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
    return PopupMenuButton<String>(
      tooltip: 'Menu',
      onSelected: (value) async {
        if (value == 'change') {
          context.go(AppRoutes.language);
        } else if (value == 'reset') {
          await ref.read(sharedPrefsProvider).clear();
          ref.invalidate(selectedLanguageProvider);
          ref.invalidate(onboardingDoneProvider);
          if (context.mounted) context.go(AppRoutes.splash);
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem<String>(value: 'change', child: Text('Change language')),
        // For test stuff, REMEMBER, FOR TESTING, delete later
        PopupMenuItem<String>(value: 'reset', child: Text('Reset data (test)')),
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

// delete later
class _PathPlaceholder extends StatelessWidget {
  const _PathPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Your learning path will appear here.',
        style: TextStyle(color: AppColors.textSecondary),
      ),
    );
  }
}