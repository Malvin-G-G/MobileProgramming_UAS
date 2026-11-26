import 'package:flutter_test/flutter_test.dart';
import 'package:uas_duolingo/feature/progress/domain/streak_logic.dart';

void main() {
  group('dayKey', () {
    test('memakai format yyyy-MM-dd dengan nol di depan', () {
      expect(dayKey(DateTime(2026, 3, 5)), '2026-03-05');
    });

    test('previousDay aman melewati pergantian tahun', () {
      expect(dayKey(previousDay(DateTime(2026, 1, 1))), '2025-12-31');
    });
  });

  group('nextStreak', () {
    final now = DateTime(2026, 11, 26, 10);

    test('lesson pertama memulai streak dari 1', () {
      final r = nextStreak(
        current: 0,
        longest: 0,
        lastActive: null,
        now: now,
      );
      expect(r.streak, 1);
      expect(r.longest, 1);
      expect(r.extendedToday, isTrue);
    });

    test('belajar kemarin lalu hari ini menambah streak', () {
      final r = nextStreak(
        current: 4,
        longest: 4,
        lastActive: '2026-11-25',
        now: now,
      );
      expect(r.streak, 5);
      expect(r.longest, 5);
      expect(r.extendedToday, isTrue);
    });

    test('lesson kedua di hari yang sama tidak menambah streak', () {
      final r = nextStreak(
        current: 5,
        longest: 9,
        lastActive: '2026-11-26',
        now: now,
      );
      expect(r.streak, 5);
      expect(r.longest, 9);
      expect(r.extendedToday, isFalse);
    });

    test('bolos lebih dari sehari mengulang streak dari 1', () {
      final r = nextStreak(
        current: 7,
        longest: 7,
        lastActive: '2026-11-20',
        now: now,
      );
      expect(r.streak, 1);
      expect(r.longest, 7);
    });
  });

  group('displayStreak', () {
    final now = DateTime(2026, 11, 26, 10);

    test('masih tampil jika terakhir belajar kemarin', () {
      expect(
        displayStreak(stored: 3, lastActive: '2026-11-25', now: now),
        3,
      );
    });

    test('jadi 0 jika sudah bolos', () {
      expect(
        displayStreak(stored: 3, lastActive: '2026-11-22', now: now),
        0,
      );
    });

    test('0 jika belum pernah belajar', () {
      expect(displayStreak(stored: 0, lastActive: null, now: now), 0);
    });
  });
}