import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/providers/shared_prefs_provider.dart';
import '../data/auth_repository.dart';

// Menyediakan data untuk proses login dan register.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(appDatabaseProvider));
});

// Mengatur status login pengguna.
// Jika null, berarti pengguna belum login.
class AuthNotifier extends AsyncNotifier<AppUser?> {
  static const String _key = 'current_user_id';

  // Mengecek apakah pengguna sudah pernah login.
  @override
  Future<AppUser?> build() async {
    final id = ref.read(sharedPrefsProvider).getInt(_key);
    if (id == null) return null;
    return ref.read(authRepositoryProvider).findById(id);
  }

  // Memproses login pengguna.
  Future<void> login(String email, String password) async {
    final user = await ref
        .read(authRepositoryProvider)
        .login(email: email, password: password);

    // Menyimpan ID pengguna agar tetap login.
    await ref.read(sharedPrefsProvider).setInt(_key, user.id);
    state = AsyncData(user);
  }

  // Mendaftarkan akun baru.
  Future<void> register(String username, String email, String password) async {
    final user = await ref
        .read(authRepositoryProvider)
        .register(username: username, email: email, password: password);

    // Menyimpan ID pengguna setelah berhasil daftar.
    await ref.read(sharedPrefsProvider).setInt(_key, user.id);
    state = AsyncData(user);
  }

  // Memproses logout pengguna.
  Future<void> logout() async {
    await ref.read(sharedPrefsProvider).remove(_key);
    state = const AsyncData(null);
  }
}

// Menyediakan status login untuk seluruh aplikasi.
final authProvider = AsyncNotifierProvider<AuthNotifier, AppUser?>(
  AuthNotifier.new,
);
