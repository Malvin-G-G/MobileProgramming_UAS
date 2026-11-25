
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:uas_duolingo/feature/languages/language_select/providers/language_provider.dart';
import 'package:uas_duolingo/feature/lesson/data/lesson_service.dart';

final lessonQuizProvider = FutureProvider.autoDispose
    .family<List<QuizQuestion>, String>(
  (ref, lessonId) async {
    final language =
        ref.watch(selectedLanguageProvider) ?? 'en';

    final builder = QuizBuilder();

    return builder.build(
      lessonId: lessonId,
      languageCode: language,
    );
  },
);
