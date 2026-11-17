import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/shared_prefs_provider.dart';

/// Kode bahasa yang sedang dipelajari (null = belum memilih).
class SelectedLanguageNotifier extends Notifier<String?> {
  static const String _key = 'selected_language';

  @override
  String? build() => ref.watch(sharedPrefsProvider).getString(_key);

  Future<void> select(String code) async {
    state = code;
    await ref.read(sharedPrefsProvider).setString(_key, code);
  }
}

final selectedLanguageProvider =
    NotifierProvider<SelectedLanguageNotifier, String?>(
      SelectedLanguageNotifier.new,
    );
