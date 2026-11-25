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

// Jenis soal yang didukung
enum QuestionType {
  multipleChoice, // pilih satu jawaban dari beberapa opsi
  typeAnswer, // ketik jawaban sendiri
  matchPairs, // cocokkan pasangan kata
}

// Satu pasangan untuk soal mencocokkan (kiri = bahasa yang diketahui,
// kanan = bahasa yang dipelajari)
class MatchPair {
  const MatchPair(this.left, this.right);

  final String left;
  final String right;
}

class QuizQuestion {
  const QuizQuestion({
    this.type = QuestionType.multipleChoice,
    required this.instruction,
    required this.prompt,
    required this.correct,
    this.options = const [],
    this.pairs = const [],
  });

  final QuestionType type;
  final String instruction;
  final String prompt;
  final String correct;
  final List<String> options; // dipakai multipleChoice
  final List<MatchPair> pairs; // dipakai matchPairs

  // Mengecek jawaban ketikan: huruf besar/kecil, tanda baca, dan spasi
  // berlebih diabaikan.
  bool check(String answer) => normalize(answer) == normalize(correct);

  static String normalize(String s) => s
      .toLowerCase()
      .replaceAll(RegExp(r'[^\p{L}\p{N}\s]', unicode: true), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

// Satu kata yang sudah siap dipakai untuk soal
class _Entry {
  const _Entry(this.english, this.known, this.target);

  final String english; // kata Inggris (dari katalog)
  final String known; // bahasa yang sudah dikuasai user
  final String target; // bahasa yang sedang dipelajari
}

class QuizBuilder {
  QuizBuilder(this._translator);

  final TranslationService _translator;
  final Random _random = Random();

  // Jumlah kata yang dipakai dalam satu lesson
  static const int _wordsPerLesson = 10;

  // Jumlah kata untuk soal mencocokkan pasangan
  static const int _matchWords = 4;

  // Membuat soal kuis untuk satu lesson.
  //
  // Aturan: SETIAP KATA HANYA MUNCUL SEKALI dalam satu lesson.
  // - 4 kata dipakai untuk 1 soal mencocokkan pasangan
  // - kata sisanya dipakai untuk soal pilihan ganda / mengetik jawaban
  //   (masing-masing kata jadi tepat 1 soal)
  //
  // Untuk bahasa english/inggris menggunakan bahasa Indonesia
  // Dan untuk bahasa japanese/jepang menggunakan bahasa Inggris
  Future<List<QuizQuestion>> build({
    required String lessonId,
    required String languageCode,
  }) async {
    // Mengambil kosakata lesson, kata yang kembar dibuang
    var words = _uniqueWords(wordsForLesson(lessonId));
    if (words.length < 4) return const [];

    // Lesson review: kata diacak, lalu diambil sebagian dari seluruh unit
    if (lessonById(lessonId)?.isReview ?? false) words.shuffle(_random);
    words = words.take(_wordsPerLesson).toList();

    // Untuk menentukan bahasa yang ingin dipelajari
    final learningEnglish = languageCode == 'en';
    final apiLang = learningEnglish ? 'id' : 'ja';

    // Menerjemahkan semua kata menggunakan API
    final fromApi = await Future.wait(
      words.map((w) => _translator.translate(w.en, from: 'en', to: apiLang)),
    );

    // Menyusun daftar kata. Terjemahan dari API dipakai jika tidak bentrok
    // dengan kata lain, jika bentrok dipakai terjemahan cadangan dari katalog.
    // Kata yang tetap bentrok dibuang supaya tidak ada soal/jawaban kembar.
    final englishKeys = {for (final w in words) QuizQuestion.normalize(w.en)};
    final usedTranslations = <String>{};
    final entries = <_Entry>[];
    for (var i = 0; i < words.length; i++) {
      final fallback = learningEnglish ? words[i].ind : words[i].ja;

      String? translation;
      for (final candidate in [fromApi[i], fallback]) {
        if (candidate == null) continue;
        final key = QuizQuestion.normalize(candidate);
        if (key.isEmpty ||
            englishKeys.contains(key) ||
            usedTranslations.contains(key)) {
          continue;
        }
        translation = candidate;
        usedTranslations.add(key);
        break;
      }
      if (translation == null) continue;

      entries.add(
        _Entry(
          words[i].en,
          learningEnglish ? translation : words[i].en,
          learningEnglish ? words[i].en : translation,
        ),
      );
    }
    if (entries.length < 4) return const [];

    // Membagi kata: sebagian untuk soal mencocokkan, sisanya untuk soal biasa.
    // Tidak ada kata yang dipakai di dua soal.
    final order = List<int>.generate(entries.length, (i) => i)
      ..shuffle(_random);
    final matchCount = entries.length >= _matchWords + 3 ? _matchWords : 0;
    final matchEntries = [for (final i in order.take(matchCount)) entries[i]];
    final quizEntries = [for (final i in order.skip(matchCount)) entries[i]];

    // Menyiapkan daftar pertanyaan (1 kata = 1 soal)
    final questions = <QuizQuestion>[];
    var choiceCount = 0;
    for (var j = 0; j < quizEntries.length; j++) {
      final entry = quizEntries[j];

      // Setiap soal ke-2, ke-5, dst. berupa soal mengetik jawaban
      // (dalam bahasa Inggris, karena huruf Jepang sulit diketik pemula)
      if (j % 3 == 1) {
        questions.add(
          QuizQuestion(
            type: QuestionType.typeAnswer,
            instruction: 'Type this in English',
            prompt: learningEnglish ? entry.known : entry.target,
            correct: entry.english,
          ),
        );
        continue;
      }

      // Soal pilihan ganda, arah pertanyaan bergantian
      final toTarget = choiceCount.isEven;
      choiceCount++;
      final prompt = toTarget ? entry.known : entry.target;
      final correct = toTarget ? entry.target : entry.known;

      // Pilihan jawaban salah diambil dari kata lain di lesson ini
      final others = [
        for (final e in entries)
          if (!identical(e, entry)) toTarget ? e.target : e.known,
      ]..shuffle(_random);
      final distractors = <String>{};
      for (final candidate in others) {
        if (candidate != correct) distractors.add(candidate);
        if (distractors.length == 3) break;
      }

      questions.add(
        QuizQuestion(
          instruction: toTarget
              ? 'How do you say this in ${learningEnglish ? 'English' : 'Japanese'}?'
              : 'What does this mean in ${learningEnglish ? 'Indonesian' : 'English'}?',
          prompt: prompt,
          correct: correct,
          options: [correct, ...distractors]..shuffle(_random),
        ),
      );
    }

    // Jaring pengaman: buang soal yang teksnya sama dengan soal sebelumnya
    final seenPrompts = <String>{};
    questions.removeWhere((q) => !seenPrompts.add(QuizQuestion.normalize(q.prompt)));

    // Mengacak urutan semua pertanyaan
    questions.shuffle(_random);

    // Menambahkan 1 soal mencocokkan pasangan, ditaruh di tengah lesson
    if (matchEntries.length >= 4) {
      questions.insert(
        questions.length ~/ 2,
        QuizQuestion(
          type: QuestionType.matchPairs,
          instruction: 'Tap the matching pairs',
          prompt: '',
          correct: '',
          pairs: [for (final e in matchEntries) MatchPair(e.known, e.target)],
        ),
      );
    }

    return questions;
  }

  // Membuang kata yang kembar (berdasarkan teks Inggris)
  List<VocabWord> _uniqueWords(List<VocabWord> source) {
    final seen = <String>{};
    return [
      for (final w in source)
        if (seen.add(QuizQuestion.normalize(w.en))) w,
    ];
  }
}
