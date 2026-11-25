import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:uas_duolingo/core/router/app_routes.dart';
import 'package:uas_duolingo/core/theme/app_colors.dart';
import 'package:uas_duolingo/core/widgets/prime.button.dart';
import 'package:uas_duolingo/feature/languages/language_select/models/language.dart';
import '../providers/language_provider.dart';
import 'package:uas_duolingo/feature/languages/language_select/widgets/tile.dart';

class LanguageSelectScreen extends ConsumerStatefulWidget {
  const LanguageSelectScreen({super.key});

  @override
  ConsumerState<LanguageSelectScreen> createState() =>
      _LanguageSelectScreenState();
}

class _LanguageSelectScreenState extends ConsumerState<LanguageSelectScreen> {
  String? _selected;

  @override
  void initState() {
    super.initState();
    // kalau user datang dari "Ganti bahasa", pilihan lama langsung ter-highlight
    _selected = ref.read(selectedLanguageProvider);
  }

  Future<void> _continue() async {
    final code = _selected;
    if (code == null) return;
    await ref.read(selectedLanguageProvider.notifier).select(code);
    if (!mounted) return;
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Which language\nwould you like to learn?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'You can change it anytime.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.separated(
                  itemCount: supportedLanguages.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final language = supportedLanguages[index];
                    return LanguageTile(
                      language: language,
                      selected: _selected == language.code,
                      onTap: () => setState(() => _selected = language.code),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              PrimeButton(
                label: 'CONTINUE',
                onPressed: _selected == null ? null : _continue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
