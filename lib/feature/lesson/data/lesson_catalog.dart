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

// Setiap lesson berisi 10 kata. Setiap unit punya 3 lesson + 1 review.
// Soal review diambil acak dari seluruh kata di unit tersebut.
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
          VocabWord('Good evening', 'こんばんは', 'Selamat malam'),
          VocabWord('Good night', 'おやすみなさい', 'Selamat tidur'),
          VocabWord('Thank you', 'ありがとう', 'Terima kasih'),
          VocabWord('Please', 'お願いします', 'Tolong'),
          VocabWord('Excuse me', 'すみません', 'Permisi'),
          VocabWord('See you later', 'またね', 'Sampai jumpa lagi'),
          VocabWord('Welcome', 'ようこそ', 'Selamat datang'),
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
          VocabWord('What is your name?', 'お名前は何ですか？', 'Siapa namamu?'),
          VocabWord('I am a student', '私は学生です', 'Saya seorang pelajar'),
          VocabWord('I am from Indonesia', 'インドネシアから来ました', 'Saya berasal dari Indonesia'),
          VocabWord('I do not understand', 'わかりません', 'Saya tidak mengerti'),
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
          VocabWord('Six', '六', 'Enam'),
          VocabWord('Seven', '七', 'Tujuh'),
          VocabWord('Eight', '八', 'Delapan'),
          VocabWord('Nine', '九', 'Sembilan'),
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
          VocabWord('Beef', '牛肉', 'Daging sapi'),
          VocabWord('Noodles', '麺', 'Mi'),
          VocabWord('Vegetable', '野菜', 'Sayur'),
          VocabWord('Banana', 'バナナ', 'Pisang'),
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
          VocabWord('Cup', 'コップ', 'Gelas'),
          VocabWord('Hot', '熱い', 'Panas'),
          VocabWord('Cold', '冷たい', 'Dingin'),
          VocabWord('Sweet', '甘い', 'Manis'),
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
          VocabWord('The bill, please', 'お会計をお願いします', 'Tolong tagihannya'),
          VocabWord('Fork', 'フォーク', 'Garpu'),
          VocabWord('Plate', 'お皿', 'Piring'),
          VocabWord('Chopsticks', '箸', 'Sumpit'),
          VocabWord('Breakfast', '朝ごはん', 'Sarapan'),
        ],
      ),
      LessonDef(id: '2-4', title: 'Review', isReview: true),
    ],
  ),
  UnitDef(
    title: 'Unit 3',
    description: 'Family and people',
    lessons: [
      LessonDef(
        id: '3-1',
        title: 'Family',
        words: [
          VocabWord('Mother', '母', 'Ibu'),
          VocabWord('Father', '父', 'Ayah'),
          VocabWord('Older brother', '兄', 'Kakak laki-laki'),
          VocabWord('Older sister', '姉', 'Kakak perempuan'),
          VocabWord('Younger brother', '弟', 'Adik laki-laki'),
          VocabWord('Younger sister', '妹', 'Adik perempuan'),
          VocabWord('Grandmother', '祖母', 'Nenek'),
          VocabWord('Grandfather', '祖父', 'Kakek'),
          VocabWord('Family', '家族', 'Keluarga'),
          VocabWord('Parents', '両親', 'Orang tua'),
        ],
      ),
      LessonDef(
        id: '3-2',
        title: 'People',
        words: [
          VocabWord('Friend', '友達', 'Teman'),
          VocabWord('Teacher', '先生', 'Guru'),
          VocabWord('Student', '学生', 'Pelajar'),
          VocabWord('Boy', '男の子', 'Anak laki-laki'),
          VocabWord('Girl', '女の子', 'Anak perempuan'),
          VocabWord('Man', '男の人', 'Pria'),
          VocabWord('Woman', '女の人', 'Wanita'),
          VocabWord('Baby', '赤ちゃん', 'Bayi'),
          VocabWord('Child', '子供', 'Anak'),
          VocabWord('Doctor', '医者', 'Dokter'),
        ],
      ),
      LessonDef(
        id: '3-3',
        title: 'Describing people',
        words: [
          VocabWord('Happy', '嬉しい', 'Senang'),
          VocabWord('Sad', '悲しい', 'Sedih'),
          VocabWord('Kind', '優しい', 'Baik hati'),
          VocabWord('Beautiful', '美しい', 'Cantik'),
          VocabWord('Funny', '面白い', 'Lucu'),
          VocabWord('Smart', '賢い', 'Pintar'),
          VocabWord('Strong', '強い', 'Kuat'),
          VocabWord('Tall', '背が高い', 'Tinggi'),
          VocabWord('Short', '背が低い', 'Pendek'),
          VocabWord('Young', '若い', 'Muda'),
        ],
      ),
      LessonDef(id: '3-4', title: 'Review', isReview: true),
    ],
  ),
  UnitDef(
    title: 'Unit 4',
    description: 'Animals and nature',
    lessons: [
      LessonDef(
        id: '4-1',
        title: 'Animals',
        words: [
          VocabWord('Dog', '犬', 'Anjing'),
          VocabWord('Cat', '猫', 'Kucing'),
          VocabWord('Bird', '鳥', 'Burung'),
          VocabWord('Horse', '馬', 'Kuda'),
          VocabWord('Cow', '牛', 'Sapi'),
          VocabWord('Goat', '山羊', 'Kambing'),
          VocabWord('Rabbit', 'うさぎ', 'Kelinci'),
          VocabWord('Monkey', '猿', 'Monyet'),
          VocabWord('Elephant', '象', 'Gajah'),
          VocabWord('Tiger', '虎', 'Harimau'),
        ],
      ),
      LessonDef(
        id: '4-2',
        title: 'Nature',
        words: [
          VocabWord('Sun', '太陽', 'Matahari'),
          VocabWord('Moon', '月', 'Bulan'),
          VocabWord('Star', '星', 'Bintang'),
          VocabWord('Sky', '空', 'Langit'),
          VocabWord('Mountain', '山', 'Gunung'),
          VocabWord('River', '川', 'Sungai'),
          VocabWord('Sea', '海', 'Laut'),
          VocabWord('Tree', '木', 'Pohon'),
          VocabWord('Flower', '花', 'Bunga'),
          VocabWord('Rain', '雨', 'Hujan'),
        ],
      ),
      LessonDef(
        id: '4-3',
        title: 'Weather and seasons',
        words: [
          VocabWord('Weather', '天気', 'Cuaca'),
          VocabWord('Sunny', '晴れ', 'Cerah'),
          VocabWord('Cloudy', '曇り', 'Berawan'),
          VocabWord('Wind', '風', 'Angin'),
          VocabWord('Snow', '雪', 'Salju'),
          VocabWord('Storm', '嵐', 'Badai'),
          VocabWord('Spring', '春', 'Musim semi'),
          VocabWord('Summer', '夏', 'Musim panas'),
          VocabWord('Autumn', '秋', 'Musim gugur'),
          VocabWord('Winter', '冬', 'Musim dingin'),
        ],
      ),
      LessonDef(id: '4-4', title: 'Review', isReview: true),
    ],
  ),
  UnitDef(
    title: 'Unit 5',
    description: 'Colors and home',
    lessons: [
      LessonDef(
        id: '5-1',
        title: 'Colors',
        words: [
          VocabWord('Red', '赤', 'Merah'),
          VocabWord('Blue', '青', 'Biru'),
          VocabWord('Green', '緑', 'Hijau'),
          VocabWord('Yellow', '黄色', 'Kuning'),
          VocabWord('Black', '黒', 'Hitam'),
          VocabWord('White', '白', 'Putih'),
          VocabWord('Orange', 'オレンジ', 'Oranye'),
          VocabWord('Pink', 'ピンク', 'Merah muda'),
          VocabWord('Brown', '茶色', 'Cokelat'),
          VocabWord('Purple', '紫', 'Ungu'),
        ],
      ),
      LessonDef(
        id: '5-2',
        title: 'Around the house',
        words: [
          VocabWord('House', '家', 'Rumah'),
          VocabWord('Room', '部屋', 'Kamar'),
          VocabWord('Door', 'ドア', 'Pintu'),
          VocabWord('Window', '窓', 'Jendela'),
          VocabWord('Bed', 'ベッド', 'Tempat tidur'),
          VocabWord('Chair', '椅子', 'Kursi'),
          VocabWord('Kitchen', '台所', 'Dapur'),
          VocabWord('Bathroom', 'お風呂', 'Kamar mandi'),
          VocabWord('Key', '鍵', 'Kunci'),
          VocabWord('Lamp', 'ランプ', 'Lampu'),
        ],
      ),
      LessonDef(
        id: '5-3',
        title: 'Everyday objects',
        words: [
          VocabWord('Book', '本', 'Buku'),
          VocabWord('Pen', 'ペン', 'Pena'),
          VocabWord('Bag', 'かばん', 'Tas'),
          VocabWord('Phone', '電話', 'Telepon'),
          VocabWord('Computer', 'パソコン', 'Komputer'),
          VocabWord('Clock', '時計', 'Jam'),
          VocabWord('Umbrella', '傘', 'Payung'),
          VocabWord('Glasses', '眼鏡', 'Kacamata'),
          VocabWord('Money', 'お金', 'Uang'),
          VocabWord('Newspaper', '新聞', 'Koran'),
        ],
      ),
      LessonDef(id: '5-4', title: 'Review', isReview: true),
    ],
  ),
  UnitDef(
    title: 'Unit 6',
    description: 'Travel and places',
    lessons: [
      LessonDef(
        id: '6-1',
        title: 'Places',
        words: [
          VocabWord('School', '学校', 'Sekolah'),
          VocabWord('Hospital', '病院', 'Rumah sakit'),
          VocabWord('Station', '駅', 'Stasiun'),
          VocabWord('Airport', '空港', 'Bandara'),
          VocabWord('Market', '市場', 'Pasar'),
          VocabWord('Park', '公園', 'Taman'),
          VocabWord('Library', '図書館', 'Perpustakaan'),
          VocabWord('Restaurant', 'レストラン', 'Restoran'),
          VocabWord('Shop', '店', 'Toko'),
          VocabWord('Post office', '郵便局', 'Kantor pos'),
        ],
      ),
      LessonDef(
        id: '6-2',
        title: 'Transportation',
        words: [
          VocabWord('Car', '車', 'Mobil'),
          VocabWord('Train', '電車', 'Kereta api'),
          VocabWord('Bicycle', '自転車', 'Sepeda'),
          VocabWord('Motorcycle', 'バイク', 'Sepeda motor'),
          VocabWord('Airplane', '飛行機', 'Pesawat'),
          VocabWord('Ship', '船', 'Kapal'),
          VocabWord('Taxi', 'タクシー', 'Taksi'),
          VocabWord('Ticket', '切符', 'Tiket'),
          VocabWord('Road', '道', 'Jalan'),
          VocabWord('Bridge', '橋', 'Jembatan'),
        ],
      ),
      LessonDef(
        id: '6-3',
        title: 'Directions',
        words: [
          VocabWord('Left', '左', 'Kiri'),
          VocabWord('Right', '右', 'Kanan'),
          VocabWord('Straight', 'まっすぐ', 'Lurus'),
          VocabWord('Near', '近い', 'Dekat'),
          VocabWord('Far', '遠い', 'Jauh'),
          VocabWord('Where is the station?', '駅はどこですか？', 'Di mana stasiun?'),
          VocabWord('Turn left', '左に曲がってください', 'Belok kiri'),
          VocabWord('Turn right', '右に曲がってください', 'Belok kanan'),
          VocabWord('Stop', '止まる', 'Berhenti'),
          VocabWord('Map', '地図', 'Peta'),
        ],
      ),
      LessonDef(id: '6-4', title: 'Review', isReview: true),
    ],
  ),
  UnitDef(
    title: 'Unit 7',
    description: 'Time and daily activities',
    lessons: [
      LessonDef(
        id: '7-1',
        title: 'Days of the week',
        words: [
          VocabWord('Monday', '月曜日', 'Senin'),
          VocabWord('Tuesday', '火曜日', 'Selasa'),
          VocabWord('Wednesday', '水曜日', 'Rabu'),
          VocabWord('Thursday', '木曜日', 'Kamis'),
          VocabWord('Friday', '金曜日', 'Jumat'),
          VocabWord('Saturday', '土曜日', 'Sabtu'),
          VocabWord('Sunday', '日曜日', 'Minggu'),
          VocabWord('Today', '今日', 'Hari ini'),
          VocabWord('Tomorrow', '明日', 'Besok'),
          VocabWord('Yesterday', '昨日', 'Kemarin'),
        ],
      ),
      LessonDef(
        id: '7-2',
        title: 'Time',
        words: [
          VocabWord('Morning', '朝', 'Pagi'),
          VocabWord('Afternoon', '午後', 'Siang'),
          VocabWord('Evening', '夕方', 'Sore'),
          VocabWord('Night', '夜', 'Malam'),
          VocabWord('Day', '日', 'Hari'),
          VocabWord('Month', '月', 'Bulan'),
          VocabWord('Year', '年', 'Tahun'),
          VocabWord('Now', '今', 'Sekarang'),
          VocabWord('Always', 'いつも', 'Selalu'),
          VocabWord('Sometimes', '時々', 'Kadang-kadang'),
        ],
      ),
      LessonDef(
        id: '7-3',
        title: 'Daily activities',
        words: [
          VocabWord('Eat', '食べる', 'Makan'),
          VocabWord('Drink', '飲む', 'Minum'),
          VocabWord('Sleep', '寝る', 'Tidur'),
          VocabWord('Wake up', '起きる', 'Bangun'),
          VocabWord('Go', '行く', 'Pergi'),
          VocabWord('Come', '来る', 'Datang'),
          VocabWord('Read', '読む', 'Membaca'),
          VocabWord('Write', '書く', 'Menulis'),
          VocabWord('Study', '勉強する', 'Belajar'),
          VocabWord('Work', '働く', 'Bekerja'),
        ],
      ),
      LessonDef(id: '7-4', title: 'Review', isReview: true),
    ],
  ),
  UnitDef(
    title: 'Unit 8',
    description: 'Shopping and useful phrases',
    lessons: [
      LessonDef(
        id: '8-1',
        title: 'Shopping',
        words: [
          VocabWord('Buy', '買う', 'Membeli'),
          VocabWord('Sell', '売る', 'Menjual'),
          VocabWord('Price', '値段', 'Harga'),
          VocabWord('Cheap', '安い', 'Murah'),
          VocabWord('Expensive', '高い', 'Mahal'),
          VocabWord('How much is this?', 'いくらですか？', 'Berapa harganya?'),
          VocabWord('Discount', '割引', 'Diskon'),
          VocabWord('Cash', '現金', 'Tunai'),
          VocabWord('Shirt', 'シャツ', 'Kemeja'),
          VocabWord('Shoes', '靴', 'Sepatu'),
        ],
      ),
      LessonDef(
        id: '8-2',
        title: 'Body parts',
        words: [
          VocabWord('Head', '頭', 'Kepala'),
          VocabWord('Eye', '目', 'Mata'),
          VocabWord('Ear', '耳', 'Telinga'),
          VocabWord('Nose', '鼻', 'Hidung'),
          VocabWord('Mouth', '口', 'Mulut'),
          VocabWord('Hand', '手', 'Tangan'),
          VocabWord('Foot', '足', 'Kaki'),
          VocabWord('Heart', '心', 'Hati'),
          VocabWord('Hair', '髪', 'Rambut'),
          VocabWord('Tooth', '歯', 'Gigi'),
        ],
      ),
      LessonDef(
        id: '8-3',
        title: 'Useful phrases',
        words: [
          VocabWord('I like it', '好きです', 'Saya suka'),
          VocabWord('I love you', '愛しています', 'Aku cinta kamu'),
          VocabWord('Help me', '助けてください', 'Tolong bantu saya'),
          VocabWord('Wait a moment', 'ちょっと待ってください', 'Tunggu sebentar'),
          VocabWord('Let us go', '行きましょう', 'Ayo pergi'),
          VocabWord('Congratulations', 'おめでとう', 'Selamat'),
          VocabWord('Good luck', '頑張って', 'Semoga berhasil'),
          VocabWord('I am tired', '疲れました', 'Saya lelah'),
          VocabWord('I am sick', '病気です', 'Saya sakit'),
          VocabWord('Do you speak English?', '英語を話せますか？', 'Apakah kamu bisa berbahasa Inggris?'),
        ],
      ),
      LessonDef(id: '8-4', title: 'Review', isReview: true),
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