import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

// Mengatur database SQLite untuk aplikasi
class AppDatabase {
  AppDatabase._();

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
      version: 1,

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
            created_at INTEGER NOT NULL
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
      },
    );
  }
}

// Menyediakan database agar bisa digunakan di seluruh aplikasi
final appDatabaseProvider = Provider<AppDatabase>(
  (ref) => AppDatabase.instance,
);
