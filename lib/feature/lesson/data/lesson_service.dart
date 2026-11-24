import 'dart:convert';

import 'package:http/http.dart' as http;

class TranslationService {
  TranslationService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static final Map<String, String> _cache = {};

  Future<String?> translate(
    String text, {
    required String from,
    required String to,
  }) async {
    final key = '$from|$to|$text';
    final cached = _cache[key];
    if (cached != null) return cached;

    try {
      final uri = Uri.https('api.mymemory.translated.net', '/get', {
        'q': text,
        'langpair': '$from|$to',
      });
      final response = await _client.get(uri).timeout(
            const Duration(seconds: 6),
          );
      if (response.statusCode != 200) return null;

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final status = int.tryParse('${body['responseStatus']}');
      if (status != 200) return null;

      final raw = body['responseData']?['translatedText'];
      if (raw is! String) return null;

      final translated = _unescape(raw).trim();
      if (translated.isEmpty ||
          translated.toUpperCase().contains('MYMEMORY WARNING') ||
          translated.toLowerCase() == text.toLowerCase()) {
        return null;
      }

      _cache[key] = translated;
      return translated;
    } catch (_) {
      return null;
    }
  }

  String _unescape(String s) => s
      .replaceAll('&#39;', "'")
      .replaceAll('&quot;', '"')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&amp;', '&');
}