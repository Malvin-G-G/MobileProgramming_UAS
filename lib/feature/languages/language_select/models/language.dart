class Language {
  const Language({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
    this.available = true,
  });

  final String code;
  final String name; // Displayed as
  final String nativeName; // bahasa Native
  final String flag;
  final bool available; // false = ada "coming soon"
}

/// Daftar bahasa yang ditampilkan. Untuk MVP cukup 2 bahasa yang aktif.
const List<Language> supportedLanguages = [
  Language(
    code: 'en',
    name: 'English',
    nativeName: 'English',
    flag: '🇬🇧'),
  Language(
    code: 'jp',
    name: 'Japanese',
    nativeName: '日本語',
    flag: '🇯🇵'),
  Language(
    code: 'kr',
    name: 'Korean',
    nativeName: '한국어',
    flag: '🇰🇷',
    available: false,
  ),
  Language(
    code: 'es',
    name: 'Spanish',
    nativeName: 'Español',
    flag: '🇪🇸',
    available: false,
  ),
];

Language? languageByCode(String? code) {
  if (code == null) return null;
  for (final language in supportedLanguages) {
    if (language.code == code) return language;
  }
  return null;
}