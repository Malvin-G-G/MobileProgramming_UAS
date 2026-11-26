import 'dart:math';

import 'package:uas_duolingo/core/database/app_database.dart';
import 'package:uas_duolingo/feature/progress/domain/streak_logic.dart';

const int kMaxHearts = 5;
const Duration kHeartRegenInterval = Duration(minutes: 5);
const int kXpPerLevel = 100;
const int kDefaultDailyGoal = 30;
const List<int> kDailyGoalOptions = [10, 20, 30, 50];

class ProgressState {
  const ProgressState({
    required this.xp,
    required this.hearts,
    required this.heartsUpdatedAt,
    required this.completed,
    this.streak = 0,
    this.longestStreak = 0,
    this.lastActiveDate,
    this.dailyGoal = kDefaultDailyGoal,
    this.xpByDay = const {},
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
  final Set<String> completed; 

  final int streak; 
  final int longestStreak;
  final String? lastActiveDate; 
  final int dailyGoal; 
  final Map<String, int> xpByDay; 

  int get level => xp ~/ kXpPerLevel + 1;

  int get currentStreak => displayStreak(
        stored: streak,
        lastActive: lastActiveDate,
        now: DateTime.now(),
      );

  bool get studiedToday => lastActiveDate == dayKey(DateTime.now());

  int get todayXp => xpByDay[dayKey(DateTime.now())] ?? 0;

  bool get goalReached => todayXp >= dailyGoal;

  double get goalProgress =>
      dailyGoal <= 0 ? 0 : (todayXp / dailyGoal).clamp(0.0, 1.0).toDouble();

  ProgressState copyWith({
    int? xp,
    int? hearts,
    DateTime? heartsUpdatedAt,
    Set<String>? completed,
    int? streak,
    int? longestStreak,
    String? lastActiveDate,
    int? dailyGoal,
    Map<String, int>? xpByDay,
  }) {
    return ProgressState(
      xp: xp ?? this.xp,
      hearts: hearts ?? this.hearts,
      heartsUpdatedAt: heartsUpdatedAt ?? this.heartsUpdatedAt,
      completed: completed ?? this.completed,
      streak: streak ?? this.streak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      xpByDay: xpByDay ?? this.xpByDay,
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
      columns: [
        'xp',
        'hearts',
        'hearts_updated_at',
        'streak',
        'longest_streak',
        'last_active_date',
        'daily_goal',
      ],
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

    // XP per hari untuk 7 hari terakhir (daily goal & statistik mingguan)
    final now = DateTime.now();
    final since = dayKey(DateTime(now.year, now.month, now.day - 6));
    final dailyRows = await db.query(
      'daily_xp',
      columns: ['day', 'xp'],
      where: 'user_id = ? AND day >= ?',
      whereArgs: [userId, since],
    );

    return ProgressState(
      xp: row['xp'] as int,
      hearts: hearts,
      heartsUpdatedAt: updatedAt,
      completed: {for (final r in done) r['lesson_id'] as String},
      streak: row['streak'] as int,
      longestStreak: row['longest_streak'] as int,
      lastActiveDate: row['last_active_date'] as String?,
      dailyGoal: row['daily_goal'] as int,
      xpByDay: {for (final r in dailyRows) r['day'] as String: r['xp'] as int},
    );
  }

  // Ubah target XP harian
  Future<void> setDailyGoal(int userId, int goal) async {
    final db = await _appDb.database;
    await db.update(
      'users',
      {'daily_goal': goal},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // Kurangi 1 HP (ketika jawaban salah)
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

      // Perbarui streak harian
      final userRow = await txn.query(
        'users',
        columns: ['streak', 'longest_streak', 'last_active_date'],
        where: 'id = ?',
        whereArgs: [userId],
        limit: 1,
      );
      final today = DateTime.now();
      final streak = nextStreak(
        current: userRow.first['streak'] as int,
        longest: userRow.first['longest_streak'] as int,
        lastActive: userRow.first['last_active_date'] as String?,
        now: today,
      );

      await txn.rawUpdate(
        'UPDATE users SET xp = xp + ?, streak = ?, longest_streak = ?, '
        'last_active_date = ? WHERE id = ?',
        [xpGained, streak.streak, streak.longest, dayKey(today), userId],
      );

      // Catat XP hari ini untuk daily goal
      final todayKey = dayKey(today);
      final dailyRow = await txn.query(
        'daily_xp',
        columns: ['xp'],
        where: 'user_id = ? AND day = ?',
        whereArgs: [userId, todayKey],
        limit: 1,
      );
      if (dailyRow.isEmpty) {
        await txn.insert('daily_xp', {
          'user_id': userId,
          'day': todayKey,
          'xp': xpGained,
        });
      } else {
        await txn.update(
          'daily_xp',
          {'xp': (dailyRow.first['xp'] as int) + xpGained},
          where: 'user_id = ? AND day = ?',
          whereArgs: [userId, todayKey],
        );
      }
    });
  }
}