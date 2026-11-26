//mengubah tanggal menjadi kunci 'yyyy-MM-dd' berdasarkan waktu lokal.
String dayKey(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

// tanggal kemarin dari (date) (aman terhadap pergantian bulan/tahun).
DateTime previousDay(DateTime date) =>
    DateTime(date.year, date.month, date.day - 1);

class StreakUpdate {
  const StreakUpdate({
    required this.streak,
    required this.longest,
    required this.extendedToday,
  });

  final int streak;
  final int longest;

  // true jika streak bertambah/mulai hari ini (belum belajar sebelumnya hari ini).
  final bool extendedToday;
}

// Menghitung streak baru ketika pengguna menyelesaikan lesson pada [now].
//
//  sudah belajar hari ini  = streak tetap
//  terakhir belajar kemarin = streak + 1
//  lebih lama dari itu    = streak mulai lagi dari 1
StreakUpdate nextStreak({
  required int current,
  required int longest,
  required String? lastActive,
  required DateTime now,
}) {
  final today = dayKey(now);
  final yesterday = dayKey(previousDay(now));

  late final int updated;
  var extended = true;

  if (lastActive == today) {
    updated = current < 1 ? 1 : current;
    extended = false;
  } else if (lastActive == yesterday) {
    updated = current + 1;
  } else {
    updated = 1;
  }

  return StreakUpdate(
    streak: updated,
    longest: updated > longest ? updated : longest,
    extendedToday: extended,
  );
}

// streak yang boleh ditampilkan jika sudah bolos lebih dari sehari,streak putus dan ditampilkan 0
int displayStreak({
  required int stored,
  required String? lastActive,
  required DateTime now,
}) {
  if (lastActive == null) return 0;
  final today = dayKey(now);
  final yesterday = dayKey(previousDay(now));
  return (lastActive == today || lastActive == yesterday) ? stored : 0;
}