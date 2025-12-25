import 'dart:convert';
import 'package:http/http.dart' as http;

class ConfigService {
  static final ConfigService _instance = ConfigService._internal();
  factory ConfigService() => _instance;
  ConfigService._internal();

  static const String _baseUrl = 'https://eur3-dvvy-eb34b.cloudfunctions.net';

  String? _cachedBotToken;
  String? _cachedBotUsername;

  Future<String?> getBotToken() async {
    if (_cachedBotToken != null) {
      return _cachedBotToken;
    }

    try {
      final response = await http.get(Uri.parse('$_baseUrl/getBotToken'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _cachedBotToken = data['token'] as String?;
        _cachedBotUsername = data['botUsername'] as String?;
        return _cachedBotToken;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<String?> getBotUsername() async {
    if (_cachedBotUsername != null) {
      return _cachedBotUsername;
    }

    await getBotToken();
    return _cachedBotUsername;
  }

  void clearCache() {
    _cachedBotToken = null;
    _cachedBotUsername = null;
  }
}
