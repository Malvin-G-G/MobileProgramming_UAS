import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

// Mengatur database SQLite untuk aplikasi
class AppDatabase {
  AppDatabase._();

  // Versi skema database. Naikkan setiap ada perubahan tabel.
  static const int _dbVersion = 2;

  // Membuat satu database yang digunakan seluruh aplikasi
  static final AppDatabase instance = AppDatabase._();

  Future<Database>? _opening;

  // Mengambil database atau membukanya jika belum tersedia
  Future<Database> get database => _opening ??= _open();

  // Membuka dan membuat database.
  Future<Database> _open() async {
    final path = p.join(await getDatabasesPath(), 'multilingo.db');

    return openDatabase(
      path,
      version: _dbVersion,

      // Mengaktifkan hubungan antar tabel
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),

      // Membuat tabel saat database pertama kali dibuat
      onCreate: (db, version) async {
        // Menyimpan data akun dan XP pengguna
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT NOT NULL UNIQUE,
            email TEXT NOT NULL UNIQUE,
            password_hash TEXT NOT NULL,
            salt TEXT NOT NULL,
            xp INTEGER NOT NULL DEFAULT 0,
            hearts INTEGER NOT NULL DEFAULT 5,
            hearts_updated_at INTEGER NOT NULL,
            created_at INTEGER NOT NULL,
            streak INTEGER NOT NULL DEFAULT 0,
            longest_streak INTEGER NOT NULL DEFAULT 0,
            last_active_date TEXT,
            daily_goal INTEGER NOT NULL DEFAULT 30
          )
        ''');

        // Menyimpan perkembangan lesson setiap pengguna
        await db.execute('''
          CREATE TABLE lesson_progress (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            language_code TEXT NOT NULL,
            lesson_id TEXT NOT NULL,
            best_score INTEGER NOT NULL DEFAULT 0,
            completed_at INTEGER NOT NULL,
            UNIQUE (user_id, language_code, lesson_id),
            FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
          )
        ''');

        await _createDailyXpTable(db);
      },

      // migrate dari versi lama tetapi tidak menghapus data pengguna
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE users ADD COLUMN streak INTEGER NOT NULL DEFAULT 0',
          );
          await db.execute(
            'ALTER TABLE users ADD COLUMN longest_streak INTEGER NOT NULL DEFAULT 0',
          );
          await db.execute(
            'ALTER TABLE users ADD COLUMN last_active_date TEXT',
          );
          await db.execute(
            'ALTER TABLE users ADD COLUMN daily_goal INTEGER NOT NULL DEFAULT 30',
          );
          await _createDailyXpTable(db);
        }
      },
    );
  }
}

// Menyimpan total XP yang didapat pengguna per hari (untuk daily goal)
Future<void> _createDailyXpTable(Database db) {
  return db.execute('''
    CREATE TABLE daily_xp (
      user_id INTEGER NOT NULL,
      day TEXT NOT NULL,
      xp INTEGER NOT NULL DEFAULT 0,
      PRIMARY KEY (user_id, day),
      FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
    )
  ''');
}

// Menyediakan database agar bisa digunakan di seluruh aplikasi
final appDatabaseProvider = Provider<AppDatabase>(
  (ref) => AppDatabase.instance,
);