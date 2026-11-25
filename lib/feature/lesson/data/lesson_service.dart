
import 'dart:math';

import 'lesson_catalog.dart';

enum QuestionType {
  multipleChoice,
  typeAnswer,
  matchPairs,
}

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
  final List<String> options;
  final List<MatchPair> pairs;

  bool check(String answer) {
    return normalize(answer) == normalize(correct);
  }

  static String normalize(String text) {
    return text
        .toLowerCase()
        .replaceAll(
          RegExp(r'[^\p{L}\p{M}\p{N}\s]', unicode: true),
          '',
        )
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}

class _Entry {
  const _Entry({
    required this.known,
    required this.target,
    required this.english,
  });

  final String known;
  final String target;
  final String english;
}

class QuizBuilder {
  final Random _random = Random();

  static const int _wordsPerLesson = 10;
  static const int _matchWords = 4;

  Future<List<QuizQuestion>> build({
    required String lessonId,
    required String languageCode,
  }) async {
    // Menggunakan kode bahasa yang sama dengan kamus.
    final learningJapanese = languageCode == 'jp';

    final targetLanguage =
        learningJapanese ? 'Japanese' : 'English';

    final knownLanguage =
        learningJapanese ? 'English' : 'Indonesian';

    // Mengambil kosakata langsung dari katalog lokal.
    final words = List<VocabWord>.of(
      wordsForLesson(lessonId),
    );

    if (words.isEmpty) return [];

    // Review mengambil kosakata secara acak.
    if (lessonById(lessonId)?.isReview ?? false) {
      words.shuffle(_random);
    }

    final entries = <_Entry>[];
    final usedKnown = <String>{};
    final usedTarget = <String>{};

    for (final word in words) {
      final known =
          learningJapanese ? word.en : word.ind;

      final target =
          learningJapanese ? word.ja : word.en;

      final knownKey = QuizQuestion.normalize(known);
      final targetKey = QuizQuestion.normalize(target);

      // Mencegah kosakata dan jawaban duplikat.
      if (knownKey.isEmpty || targetKey.isEmpty) {
        continue;
      }

      if (usedKnown.contains(knownKey) ||
          usedTarget.contains(targetKey)) {
        continue;
      }

      usedKnown.add(knownKey);
      usedTarget.add(targetKey);

      entries.add(
        _Entry(
          known: known,
          target: target,
          english: word.en,
        ),
      );

      if (entries.length == _wordsPerLesson) {
        break;
      }
    }

    if (entries.isEmpty) return [];

    entries.shuffle(_random);

    // Empat kata digunakan untuk matching pairs.
    final matchCount =
        entries.length >= 7 ? _matchWords : 0;

    final matchEntries =
        entries.take(matchCount).toList();

    final quizEntries =
        entries.skip(matchCount).toList();

    final questions = <QuizQuestion>[];

    int choiceCount = 0;

    for (int i = 0; i < quizEntries.length; i++) {
      final entry = quizEntries[i];

      // =====================================
      // 1. TYPE ANSWER
      // =====================================

      if (i % 3 == 1 || entries.length < 4) {
        questions.add(
          QuizQuestion(
            type: QuestionType.typeAnswer,
            instruction: 'Type this in English',
            prompt: learningJapanese
                ? entry.target
                : entry.known,
            correct: entry.english,
          ),
        );

        continue;
      }

      // =====================================
      // 2. MULTIPLE CHOICE
      // =====================================

      final toTarget = choiceCount.isEven;
      choiceCount++;

      final prompt = toTarget
          ? entry.known
          : entry.target;

      final correct = toTarget
          ? entry.target
          : entry.known;

      final candidates = [
        for (final other in entries)
          if (!identical(other, entry))
            toTarget ? other.target : other.known,
      ]..shuffle(_random);

      final options = <String>[correct];

      final usedOptions = <String>{
        QuizQuestion.normalize(correct),
      };

      for (final candidate in candidates) {
        final key = QuizQuestion.normalize(candidate);

        if (key.isEmpty || !usedOptions.add(key)) {
          continue;
        }

        options.add(candidate);

        if (options.length == 4) {
          break;
        }
      }

      options.shuffle(_random);

      questions.add(
        QuizQuestion(
          type: QuestionType.multipleChoice,
          instruction: toTarget
              ? 'How do you say this in $targetLanguage?'
              : 'What does this mean in $knownLanguage?',
          prompt: prompt,
          correct: correct,
          options: options,
        ),
      );
    }

    // Mengacak urutan pertanyaan.
    questions.shuffle(_random);

    // =====================================
    // 3. MATCHING PAIRS
    // =====================================

    if (matchEntries.length == _matchWords) {
      questions.insert(
        questions.length ~/ 2,
        QuizQuestion(
          type: QuestionType.matchPairs,
          instruction: 'Tap the matching pairs',
          prompt: '',
          correct: '',
          pairs: [
            for (final entry in matchEntries)
              MatchPair(entry.known, entry.target),
          ],
        ),
      );
    }

    return questions;
  }
}
