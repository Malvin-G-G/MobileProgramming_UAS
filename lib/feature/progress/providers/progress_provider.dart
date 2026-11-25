import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../auth/providers/auth_provider.dart';
import '../../languages/language_select/providers/language_provider.dart';
import '../data/progress_repository.dart';

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return ProgressRepository(ref.watch(appDatabaseProvider));
});

/// XP, HP, dan lesson yang selesai milik user yang sedang login,
/// untuk bahasa yang sedang dipelajari.
class ProgressNotifier extends AsyncNotifier<ProgressState> {
  @override
  Future<ProgressState> build() async {
    final user = await ref.watch(authProvider.future);
    final language = ref.watch(selectedLanguageProvider);
    if (user == null) return ProgressState.initial();
    return ref.read(progressRepositoryProvider).load(user.id, language ?? '');
  }

  /// Muat ulang dari database (sekalian menghitung regenerasi HP).
  Future<ProgressState> reload() async {
    final user = ref.read(authProvider).value;
    if (user == null) return ProgressState.initial();
    final language = ref.read(selectedLanguageProvider) ?? '';
    final fresh = await ref
        .read(progressRepositoryProvider)
        .load(user.id, language);
    state = AsyncData(fresh);
    return fresh;
  }

  /// Kurangi 1 HP. Mengembalikan sisa HP.
  Future<int> loseHeart() async {
    final user = ref.read(authProvider).value;
    if (user == null) return 0;
    final current = state.value ?? ProgressState.initial();
    final result = await ref
        .read(progressRepositoryProvider)
        .loseHeart(user.id);
    state = AsyncData(
      current.copyWith(
        hearts: result.hearts,
        heartsUpdatedAt: result.updatedAt,
      ),
    );
    return result.hearts;
  }

  /// Tandai lesson selesai, tambah XP, lalu muat ulang state.
  Future<void> completeLesson({
    required String lessonId,
    required int xpGained,
    required int score,
  }) async {
    final user = ref.read(authProvider).value;
    if (user == null) return;
    final language = ref.read(selectedLanguageProvider) ?? '';
    final repo = ref.read(progressRepositoryProvider);
    await repo.completeLesson(
      userId: user.id,
      languageCode: language,
      lessonId: lessonId,
      xpGained: xpGained,
      score: score,
    );
    state = AsyncData(await repo.load(user.id, language));
  }
}

final progressProvider = AsyncNotifierProvider<ProgressNotifier, ProgressState>(
  ProgressNotifier.new,
);
