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

/// Placeholder. Learning path dibuat di fitur berikutnya.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = languageByCode(ref.watch(selectedLanguageProvider));

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(language?.flag ?? '🌍', style: const TextStyle(fontSize: 72)),
              const SizedBox(height: 16),
              Text(
                language == null
                    ? 'Language not selected'
                    : 'You are learning ${language.name}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Learning path will appear here (feature coming soon).',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                label: 'Change language',
                onPressed: () => context.go(AppRoutes.language),
              ),
              const SizedBox(height: 8),
              // Khusus testing, hapus sebelum rilis.
              TextButton(
                onPressed: () async {
                  await ref.read(sharedPrefsProvider).clear();
                  ref.invalidate(selectedLanguageProvider);
                  ref.invalidate(onboardingDoneProvider);
                  if (context.mounted) context.go(AppRoutes.splash);
                },
                child: const Text('Reset data (debug)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}