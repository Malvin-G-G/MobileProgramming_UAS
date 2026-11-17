import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/shared_prefs_provider.dart';

class OnboardingDoneNotifier extends Notifier<bool> {
  static const String _key = 'onboarding_done';

  @override
  bool build() => ref.watch(sharedPrefsProvider).getBool(_key) ?? false;

  Future<void> complete() async {
    state = true;
    await ref.read(sharedPrefsProvider).setBool(_key, true);
  }
}

final onboardingDoneProvider =
    NotifierProvider<OnboardingDoneNotifier, bool>(OnboardingDoneNotifier.new);
