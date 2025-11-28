import 'dart:convert';
import 'package:http/http.dart' as http;

class TelegramBotService {
  static const String botToken =
      "7846396440:AAHjfblykwZhTTGxNvOob-lCRyGg0hH65xo";

  String get _baseUrl => 'https://api.telegram.org/bot$botToken';
  String? _cachedBotUsername;

  Future<String?> _getBotUsername() async {
    if (_cachedBotUsername != null) {
      return _cachedBotUsername;
    }

    try {
      final response = await http.get(Uri.parse('$_baseUrl/getMe'));
      final result = jsonDecode(response.body);

      if (result['ok'] == true) {
        _cachedBotUsername = result['result']['username'];
        return _cachedBotUsername;
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Future<String?> buildInviteLink({required String groupId}) async {
    final username = await _getBotUsername();
    if (username == null) return null;

    final encodedGroupId = Uri.encodeComponent(groupId);
    return 'https://t.me/$username?startapp=$encodedGroupId';
  }

  Future<Map<String, dynamic>> sendLink({
    required String chatId,
    required String link,
    String? message,
  }) async {
    try {
      final text = message != null ? '$message\n$link' : link;

      final response = await http.post(
        Uri.parse('$_baseUrl/sendMessage'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'chat_id': chatId,
          'text': text,
          'parse_mode': 'HTML',
          'disable_web_page_preview': false,
        }),
      );

      final result = jsonDecode(response.body);

      if (result['ok'] == true) {
        return {'success': true, 'messageId': result['result']['message_id']};
      } else {
        throw Exception(result['description'] ?? 'Ошибка отправки');
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> sendLinkWithButton({
    required String chatId,
    required String link,
    required String buttonText,
    String? message,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/sendMessage'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'chat_id': chatId,
          'text': message ?? 'Нажмите на кнопку:',
          'reply_markup': {
            'inline_keyboard': [
              [
                {'text': buttonText, 'url': link},
              ],
            ],
          },
        }),
      );

      final result = jsonDecode(response.body);

      if (result['ok'] == true) {
        return {'success': true, 'messageId': result['result']['message_id']};
      } else {
        throw Exception(result['description'] ?? 'Ошибка отправки');
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}

class LinkSharingService {
  final String backendUrl;

  LinkSharingService({required this.backendUrl});

  Future<Map<String, dynamic>> sendLinkViaBackend({
    required String userId,
    required String link,
    String? message,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$backendUrl/send-link'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId, 'link': link, 'message': message}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Ошибка сервера: ${response.statusCode}');
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
