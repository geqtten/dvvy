import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:divvy/core/services/config_service.dart';

class TelegramBotService {
  final ConfigService _configService = ConfigService();

  Future<String?> _getBotToken() async {
    return await _configService.getBotToken();
  }

  Future<String?> _getBotUsername() async {
    final username = await _configService.getBotUsername();
    if (username != null) {
      return username;
    }

    final token = await _getBotToken();
    if (token == null) {
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse('https://api.telegram.org/bot$token/getMe'),
      );
      final result = jsonDecode(response.body);

      if (result['ok'] == true) {
        return result['result']['username'];
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Future<Map<String, dynamic>> _sendTelegramRequest({
    required String token,
    required Map<String, dynamic> body,
  }) async {
    try {
      final baseUrl = 'https://api.telegram.org/bot$token';
      final response = await http.post(
        Uri.parse('$baseUrl/sendMessage'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
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
    final token = await _getBotToken();
    if (token == null) {
      return {'success': false, 'error': 'Bot token not available'};
    }

    final text = message != null ? '$message\n$link' : link;
    return await _sendTelegramRequest(
      token: token,
      body: {
        'chat_id': chatId,
        'text': text,
        'parse_mode': 'HTML',
        'disable_web_page_preview': false,
      },
    );
  }

  Future<Map<String, dynamic>> sendLinkWithButton({
    required String chatId,
    required String link,
    required String buttonText,
    String? message,
  }) async {
    final token = await _getBotToken();
    if (token == null) {
      return {'success': false, 'error': 'Bot token not available'};
    }

    return await _sendTelegramRequest(
      token: token,
      body: {
        'chat_id': chatId,
        'text': message ?? 'Нажмите на кнопку:',
        'reply_markup': {
          'inline_keyboard': [
            [
              {'text': buttonText, 'url': link},
            ],
          ],
        },
      },
    );
  }
}
