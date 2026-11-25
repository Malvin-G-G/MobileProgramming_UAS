import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/providers/auth_provider.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../languages/language_select/providers/language_provider.dart';
import '../../onboarding/{screens,providers}/onboarding_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _goNext();
  }

  Future<void> _goNext() async {
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;

    final onboardingDone = ref.read(onboardingDoneProvider);
    final language = ref.read(selectedLanguageProvider);
    final user = await ref.read(authProvider.future);
    if (!mounted) return;

    if (!onboardingDone) {
      context.go(AppRoutes.onboarding);
    } else if (user == null) {
      context.go(AppRoutes.login);
    } else if (language == null) {
      context.go(AppRoutes.language);
    } else {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.6, end: 1.0),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value.clamp(0.0, 1.0),
                  child: Transform.scale(scale: value, child: child),
                );
              },
              child: const _Logo(),
            ),
            const SizedBox(height: 24),
            const Text(
              'Multilingo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'A language learning app',
              style: TextStyle(color: AppColors.accent, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: Image.asset(
        'assets/image/logo.png',
        width: 160,
        height: 160,
        filterQuality: FilterQuality.none,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Logo failed to load: $error');
          return const SizedBox(
            width: 160,
            height: 160,
            child: Icon(Icons.translate, size: 96, color: Colors.white),
          );
        },
      ),
    );
  }
}