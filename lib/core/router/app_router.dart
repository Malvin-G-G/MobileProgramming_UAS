import 'package:go_router/go_router.dart';

import '../../feature/home/screen/home_screen.dart';
import '../../feature/languages/language_select/screens/screen.dart';
import '../../feature/onboarding/{screens,providers}/onboarding_screen.dart';
import '../../feature/auth/screens/login_screen.dart';
import '../../feature/auth/screens/register_screen.dart';
import '../../feature/splash/screens/splash_screen.dart';
import 'app_routes.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: AppRoutes.language,
      builder: (context, state) => const LanguageSelectScreen(),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomeScreen(),
    ),
  ],
);
