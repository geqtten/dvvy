import 'dart:js' as js;

class TelegramService {
  static final TelegramService _instance = TelegramService._internal();
  factory TelegramService() => _instance;
  TelegramService._internal();

  Map<String, dynamic>? _initData;

  void initialize() {
    try {
      if (js.context.hasProperty('Telegram')) {
        final telegram = js.context['Telegram'];
        if (telegram != null && telegram.hasProperty('WebApp')) {
          final webApp = telegram['WebApp'];

          webApp.callMethod('expand', []);

          _initData = _parseInitData();

          print('Telegram WebApp initialized');
          print('User ID: ${getUserId()}');
          print('Username: ${getUsername()}');
        }
      } else {
        print('Telegram WebApp API not available (running in browser)');
      }
    } catch (e) {
      print('Error initializing Telegram WebApp: $e');
    }
  }

  Map<String, dynamic> _parseInitData() {
    try {
      final telegram = js.context['Telegram'];
      final webApp = telegram['WebApp'];
      final initDataUnsafe = webApp['initDataUnsafe'];

      if (initDataUnsafe != null) {
        final user = initDataUnsafe['user'];
        if (user != null) {
          return {
            'id': user['id']?.toString(),
            'first_name': user['first_name'],
            'last_name': user['last_name'],
            'username': user['username'],
            'language_code': user['language_code'],
          };
        }
      }
    } catch (e) {
      print('Error parsing init data: $e');
    }
    return {};
  }

  String? getUserId() {
    return _initData?['id']?.toString();
  }

  String? getUsername() {
    final firstName = _initData?['first_name'] ?? '';
    final lastName = _initData?['last_name'] ?? '';
    return '$firstName $lastName'.trim();
  }

  String? getTelegramUsername() {
    return _initData?['username'];
  }

  bool isRunningInTelegram() {
    return _initData != null && _initData!.isNotEmpty;
  }

  void close() {
    try {
      final telegram = js.context['Telegram'];
      final webApp = telegram['WebApp'];
      webApp.callMethod('close', []);
    } catch (e) {
      print('Error closing WebApp: $e');
    }
  }

  void showMainButton(String text, Function() onClick) {
    try {
      final telegram = js.context['Telegram'];
      final webApp = telegram['WebApp'];
      final mainButton = webApp['MainButton'];

      mainButton.callMethod('setText', [text]);
      mainButton.callMethod('show', []);
      mainButton.callMethod('onClick', [js.allowInterop(onClick)]);
    } catch (e) {
      print('Error showing main button: $e');
    }
  }
}
