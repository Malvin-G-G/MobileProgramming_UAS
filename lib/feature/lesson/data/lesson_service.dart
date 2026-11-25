import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import 'lesson_catalog.dart';

class TranslationService {
  TranslationService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static final Map<String, String> _cache = {};

  Future<String?> translate(
    String text, {
    required String from,
    required String to,
  }) async {
    final key = '$from|$to|$text';
    final cached = _cache[key];
    if (cached != null) return cached;

    try {
      final uri = Uri.https('api.mymemory.translated.net', '/get', {
        'q': text,
        'langpair': '$from|$to',
      });
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 6));
      if (response.statusCode != 200) return null;

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final status = int.tryParse('${body['responseStatus']}');
      if (status != 200) return null;

      final raw = body['responseData']?['translatedText'];
      if (raw is! String) return null;

      final translated = _unescape(raw).trim();
      if (translated.isEmpty ||
          translated.toUpperCase().contains('MYMEMORY WARNING') ||
          translated.toLowerCase() == text.toLowerCase()) {
        return null;
      }

      _cache[key] = translated;
      return translated;
    } catch (_) {
      return null;
    }
  }

  String _unescape(String s) => s
      .replaceAll('&#39;', "'")
      .replaceAll('&quot;', '"')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&amp;', '&');
}

class QuizQuestion {
  const QuizQuestion({
    required this.instruction,
    required this.prompt,
    required this.correct,
    required this.options,
  });

  final String instruction;
  final String prompt;
  final String correct;
  final List<String> options;
}

class QuizBuilder {
  QuizBuilder(this._translator);

  final TranslationService _translator;
  final Random _random = Random();

  static const int _questionsPerLesson = 6;

  // Membuat soal kuis untuk satu lesson
  // Untuk bahasa english/inggris menggunakan bahasa Indonesia
  // Dan untuk bahasa japanese/jepang menggunakan bahasa Inggris
  Future<List<QuizQuestion>> build({
    required String lessonId,
    required String languageCode,
  }) async {
    // Mengambil daftar kosakata dari lesson
    var words = List<VocabWord>.of(wordsForLesson(lessonId));
    if (words.length < 4) return const [];

    // Mengacak 6 kata jika lesson adalah review
    if (lessonById(lessonId)?.isReview ?? false) {
      words.shuffle(_random);
      words = words.take(_questionsPerLesson).toList();
    }

    // Untuk menentukan bahasa yang ingin dipelajari
    final learningEnglish = languageCode == 'en';
    final apiLang = learningEnglish ? 'id' : 'ja';
    final targetName = learningEnglish ? 'English' : 'Japanese';
    final knownName = learningEnglish ? 'Indonesian' : 'English';

    // Menerjemahkan semua kata menggunakan API
    final translated = await Future.wait(
      words.map((w) async {
        final fromApi = await _translator.translate(
          w.en,
          from: 'en',
          to: apiLang,
        );
        // Jika API gagal akan menggunakan terjemahan cadangan
        return fromApi ?? (learningEnglish ? w.ind : w.ja);
      }),
    );

    // Menyiapkan daftar kata sesuai bahasa
    final englishList = words.map((w) => w.en).toList();
    final known = learningEnglish ? translated : englishList;
    final target = learningEnglish ? englishList : translated;

    // Menyiapkan daftar pertanyaan
    final questions = <QuizQuestion>[];
    for (var i = 0; i < words.length; i++) {
      // Mengganti arah pertanyaan secara bergantian
      final toTarget = i.isEven;
      final prompt = toTarget ? known[i] : target[i];
      final correct = toTarget ? target[i] : known[i];
      final pool = toTarget ? target : known;

      // Mengambil pilihan jawaban yang salah
      final others = [
        for (var j = 0; j < pool.length; j++)
          if (j != i) pool[j],
      ]..shuffle(_random);

      final distractors = <String>{};
      for (final candidate in others) {
        if (candidate != correct) distractors.add(candidate);
        if (distractors.length == 3) break;
      }

      // Menggabungkan dan mengacak pilihan jawaban
      final options = [correct, ...distractors]..shuffle(_random);

      // Menyimpan pertanyaan ke dalam daftar
      questions.add(
        QuizQuestion(
          instruction: toTarget
              ? 'How do you say this in $targetName?'
              : 'What does this mean in $knownName?',
          prompt: prompt,
          correct: correct,
          options: options,
        ),
      );
    }

    // Mengacak urutan semua pertanyaan
    questions.shuffle(_random);
    return questions;
  }
}
