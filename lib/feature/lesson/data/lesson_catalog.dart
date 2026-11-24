class VocabWord {
  const VocabWord(this.en, this.ja, this.ind);

  final String en; // English
  final String ja; // Jepang
  final String ind; // Indonesian 
}

class LessonDef {
  const LessonDef({
    required this.id,
    required this.title,
    this.words = const [],
    this.isReview = false,
  });

  final String id;
  final String title;
  final List<VocabWord> words;
  final bool isReview; // true = soal diambil dari semua lesson di unit itu
}

class UnitDef {
  const UnitDef({
    required this.title,
    required this.description,
    required this.lessons,
  });

  final String title;
  final String description;
  final List<LessonDef> lessons;
}

const List<UnitDef> courseCatalog = [
  UnitDef(
    title: 'Unit 1',
    description: 'Greetings and introductions',
    lessons: [
      LessonDef(
        id: '1-1',
        title: 'Hello',
        words: [
          VocabWord('Hello', 'こんにちは', 'Halo'),
          VocabWord('Goodbye', 'さようなら', 'Selamat tinggal'),
          VocabWord('Good morning', 'おはようございます', 'Selamat pagi'),
          VocabWord('Good night', 'おやすみなさい', 'Selamat malam'),
          VocabWord('Thank you', 'ありがとう', 'Terima kasih'),
          VocabWord('Please', 'お願いします', 'Tolong'),
        ],
      ),
      LessonDef(
        id: '1-2',
        title: 'Introductions',
        words: [
          VocabWord('Nice to meet you', 'はじめまして', 'Senang bertemu denganmu'),
          VocabWord('How are you?', 'お元気ですか？', 'Apa kabar?'),
          VocabWord('I am fine', '元気です', 'Saya baik-baik saja'),
          VocabWord('Yes', 'はい', 'Ya'),
          VocabWord('No', 'いいえ', 'Tidak'),
          VocabWord('Sorry', 'ごめんなさい', 'Maaf'),
        ],
      ),
      LessonDef(
        id: '1-3',
        title: 'Basic numbers',
        words: [
          VocabWord('One', '一', 'Satu'),
          VocabWord('Two', '二', 'Dua'),
          VocabWord('Three', '三', 'Tiga'),
          VocabWord('Four', '四', 'Empat'),
          VocabWord('Five', '五', 'Lima'),
          VocabWord('Ten', '十', 'Sepuluh'),
        ],
      ),
      LessonDef(id: '1-4', title: 'Review', isReview: true),
    ],
  ),
  UnitDef(
    title: 'Unit 2',
    description: 'Food and drinks',
    lessons: [
      LessonDef(
        id: '2-1',
        title: 'Food',
        words: [
          VocabWord('Rice', 'ご飯', 'Nasi'),
          VocabWord('Bread', 'パン', 'Roti'),
          VocabWord('Egg', '卵', 'Telur'),
          VocabWord('Chicken', '鶏肉', 'Ayam'),
          VocabWord('Fish', '魚', 'Ikan'),
          VocabWord('Apple', 'りんご', 'Apel'),
        ],
      ),
      LessonDef(
        id: '2-2',
        title: 'Drinks',
        words: [
          VocabWord('Water', '水', 'Air'),
          VocabWord('Milk', '牛乳', 'Susu'),
          VocabWord('Coffee', 'コーヒー', 'Kopi'),
          VocabWord('Tea', 'お茶', 'Teh'),
          VocabWord('Juice', 'ジュース', 'Jus'),
          VocabWord('Ice', '氷', 'Es'),
        ],
      ),
      LessonDef(
        id: '2-3',
        title: 'At the restaurant',
        words: [
          VocabWord('Spoon', 'スプーン', 'Sendok'),
          VocabWord('Table', 'テーブル', 'Meja'),
          VocabWord('Delicious', 'おいしい', 'Enak'),
          VocabWord('I am hungry', 'お腹が空きました', 'Saya lapar'),
          VocabWord('I am thirsty', '喉が渇きました', 'Saya haus'),
          VocabWord(
            'The bill, please',
            'お会計をお願いします',
            'Tolong tagihannya',
          ),
        ],
      ),
      LessonDef(id: '2-4', title: 'Review', isReview: true),
    ],
  ),
];

LessonDef? lessonById(String id) {
  for (final unit in courseCatalog) {
    for (final lesson in unit.lessons) {
      if (lesson.id == id) return lesson;
    }
  }
  return null;
}

// Kosakata untuk satu lesson,lesson lain di unit yang sama
List<VocabWord> wordsForLesson(String id) {
  for (final unit in courseCatalog) {
    for (final lesson in unit.lessons) {
      if (lesson.id != id) continue;
      if (!lesson.isReview) return lesson.words;
      return [
        for (final l in unit.lessons) ...l.words,
      ];
    }
  }
  return const [];
}