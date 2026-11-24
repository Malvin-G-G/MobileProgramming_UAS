import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../languages/language_select/providers/language_provider.dart';
import '../data/lesson_service.dart';

// Menyediakan layanan terjemahan.
final translationServiceProvider = Provider<TranslationService>((ref) {
  return TranslationService();
});

// Mengambil dan membuat soal kuis berdasarkan ID lesson.
// Soal akan diacak kembali saat halaman lesson dibuka ulang.
final lessonQuizProvider = FutureProvider.autoDispose
    .family<List<QuizQuestion>, String>((ref, lessonId) async {
      // Mengambil bahasa yang dipilih pengguna.
      final language = ref.read(selectedLanguageProvider) ?? 'en';

      // Membuat soal menggunakan layanan terjemahan.
      final builder = QuizBuilder(ref.read(translationServiceProvider));

      // Mengembalikan daftar soal untuk lesson.
      return builder.build(lessonId: lessonId, languageCode: language);
    });
