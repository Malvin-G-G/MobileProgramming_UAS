import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

import '../../../core/database/app_database.dart';

class AppUser {
  const AppUser({
    required this.id,
    required this.username,
    required this.email,
  });

  final int id;
  final String username;
  final String email;
}

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

class AuthRepository {
  AuthRepository(this._appDb);

  final AppDatabase _appDb;

  Future<AppUser> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final db = await _appDb.database;
    final cleanEmail = email.trim().toLowerCase();
    final cleanName = username.trim();

    final emailTaken = await db.query(
      'users',
      columns: ['id'],
      where: 'email = ?',
      whereArgs: [cleanEmail],
      limit: 1,
    );
    if (emailTaken.isNotEmpty) {
      throw const AuthException('This email is already registered.');
    }

    final nameTaken = await db.query(
      'users',
      columns: ['id'],
      where: 'username = ? COLLATE NOCASE',
      whereArgs: [cleanName],
      limit: 1,
    );
    if (nameTaken.isNotEmpty) {
      throw const AuthException('This username is already taken.');
    }

    final salt = _generateSalt();
    final now = DateTime.now().millisecondsSinceEpoch;
    final id = await db.insert('users', {
      'username': cleanName,
      'email': cleanEmail,
      'password_hash': _hash(password, salt),
      'salt': salt,
      'xp': 0,
      'hearts': 5,
      'hearts_updated_at': now,
      'created_at': now,
    });

    return AppUser(id: id, username: cleanName, email: cleanEmail);
  }

  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    final db = await _appDb.database;
    final rows = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
      limit: 1,
    );
    if (rows.isEmpty) {
      throw const AuthException('Wrong email or password.');
    }

    final row = rows.first;
    final salt = row['salt'] as String;
    final storedHash = row['password_hash'] as String;
    if (_hash(password, salt) != storedHash) {
      throw const AuthException('Wrong email or password.');
    }

    return AppUser(
      id: row['id'] as int,
      username: row['username'] as String,
      email: row['email'] as String,
    );
  }

  Future<AppUser?> findById(int id) async {
    final db = await _appDb.database;
    final rows = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final row = rows.first;
    return AppUser(
      id: row['id'] as int,
      username: row['username'] as String,
      email: row['email'] as String,
    );
  }

  String _generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64UrlEncode(bytes);
  }

  String _hash(String password, String salt) {
    return sha256.convert(utf8.encode('$salt:$password')).toString();
  }
}
