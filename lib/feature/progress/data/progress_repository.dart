import 'dart:math';

import 'package:uas_duolingo/core/database/app_database.dart';

const int kMaxHearts = 5;
const Duration kHeartRegenInterval = Duration(minutes: 5);
const int kXpPerLevel = 100;

class ProgressState {
  const ProgressState({
    required this.xp,
    required this.hearts,
    required this.heartsUpdatedAt,
    required this.completed,
  });

  factory ProgressState.initial() => ProgressState(
        xp: 0,
        hearts: kMaxHearts,
        heartsUpdatedAt: DateTime.now(),
        completed: const {},
      );

  final int xp;
  final int hearts;
  final DateTime heartsUpdatedAt;
  final Set<String> completed; // id lesson yang sudah selesai

  // Level user dari total XP,tiap 100 xp naik 1 level
  int get level => xp ~/ kXpPerLevel + 1;

  ProgressState copyWith({
    int? xp,
    int? hearts,
    DateTime? heartsUpdatedAt,
    Set<String>? completed,
  }) {
    return ProgressState(
      xp: xp ?? this.xp,
      hearts: hearts ?? this.hearts,
      heartsUpdatedAt: heartsUpdatedAt ?? this.heartsUpdatedAt,
      completed: completed ?? this.completed,
    );
  }
}

class ProgressRepository {
  ProgressRepository(this._appDb);

  final AppDatabase _appDb;

  // Ambil XP,HP,dan lesson selesai HP otomatis bertambah 1 tiap 5 menit.
  Future<ProgressState> load(int userId, String languageCode) async {
    final db = await _appDb.database;
    final rows = await db.query(
      'users',
      columns: ['xp', 'hearts', 'hearts_updated_at'],
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (rows.isEmpty) return ProgressState.initial();

    final row = rows.first;
    var hearts = row['hearts'] as int;
    var updatedAt = DateTime.fromMillisecondsSinceEpoch(
      row['hearts_updated_at'] as int,
    );

    if (hearts < kMaxHearts) {
      final now = DateTime.now();
      final gained = now.difference(updatedAt).inMilliseconds ~/
          kHeartRegenInterval.inMilliseconds;
      if (gained > 0) {
        hearts = min(kMaxHearts, hearts + gained);
        updatedAt = hearts >= kMaxHearts
            ? now
            : updatedAt.add(kHeartRegenInterval * gained);
        await db.update(
          'users',
          {
            'hearts': hearts,
            'hearts_updated_at': updatedAt.millisecondsSinceEpoch,
          },
          where: 'id = ?',
          whereArgs: [userId],
        );
      }
    }

    final done = await db.query(
      'lesson_progress',
      columns: ['lesson_id'],
      where: 'user_id = ? AND language_code = ?',
      whereArgs: [userId, languageCode],
    );

    return ProgressState(
      xp: row['xp'] as int,
      hearts: hearts,
      heartsUpdatedAt: updatedAt,
      completed: {for (final r in done) r['lesson_id'] as String},
    );
  }

  // Kurangi 1 HP (dipanggil ketika jawaban salah)
  Future<({int hearts, DateTime updatedAt})> loseHeart(int userId) async {
    final db = await _appDb.database;
    final rows = await db.query(
      'users',
      columns: ['hearts', 'hearts_updated_at'],
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (rows.isEmpty) return (hearts: 0, updatedAt: DateTime.now());

    var hearts = rows.first['hearts'] as int;
    var updatedAt = DateTime.fromMillisecondsSinceEpoch(
      rows.first['hearts_updated_at'] as int,
    );

    // HP penuh = jam regenerasi baru mulai dari sekarang
    if (hearts >= kMaxHearts) updatedAt = DateTime.now();
    hearts = max(0, hearts - 1);

    await db.update(
      'users',
      {
        'hearts': hearts,
        'hearts_updated_at': updatedAt.millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [userId],
    );
    return (hearts: hearts, updatedAt: updatedAt);
  }

  // Simpan lesson selesai dan tambah XP dalam satu transaksi.
  Future<void> completeLesson({
    required int userId,
    required String languageCode,
    required String lessonId,
    required int xpGained,
    required int score,
  }) async {
    final db = await _appDb.database;
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.transaction((txn) async {
      final existing = await txn.query(
        'lesson_progress',
        columns: ['best_score'],
        where: 'user_id = ? AND language_code = ? AND lesson_id = ?',
        whereArgs: [userId, languageCode, lessonId],
        limit: 1,
      );

      if (existing.isEmpty) {
        await txn.insert('lesson_progress', {
          'user_id': userId,
          'language_code': languageCode,
          'lesson_id': lessonId,
          'best_score': score,
          'completed_at': now,
        });
      } else if (score > (existing.first['best_score'] as int)) {
        await txn.update(
          'lesson_progress',
          {'best_score': score, 'completed_at': now},
          where: 'user_id = ? AND language_code = ? AND lesson_id = ?',
          whereArgs: [userId, languageCode, lessonId],
        );
      }

      await txn.rawUpdate(
        'UPDATE users SET xp = xp + ? WHERE id = ?',
        [xpGained, userId],
      );
    });
  }
}