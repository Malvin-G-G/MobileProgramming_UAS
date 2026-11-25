import 'package:go_router/go_router.dart';

import 'package:uas_duolingo/feature/home/screen/home_screen.dart';
import 'package:uas_duolingo/feature/languages/language_select/screens/screen.dart';
import 'package:uas_duolingo/feature/onboarding/{screens,providers}/onboarding_screen.dart';
import 'package:uas_duolingo/feature/auth/screens/login_screen.dart';
import 'package:uas_duolingo/feature/auth/screens/register_screen.dart';
import 'package:uas_duolingo/feature/splash/screens/splash_screen.dart';
import 'package:uas_duolingo/feature/lesson/screens/lesson_screen.dart';
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
    GoRoute(
      path: AppRoutes.lesson,
      builder: (context, state) =>
          LessonScreen(lessonId: state.pathParameters['id']!),
    ),
  ],
);
