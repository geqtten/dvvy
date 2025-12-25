import 'dart:js' as js;

class TelegramService {
  static final TelegramService _instance = TelegramService._internal();
  factory TelegramService() => _instance;
  TelegramService._internal();

  Map<String, dynamic>? _initData;
  String? _startParam;

  void initialize() {
    try {
      if (js.context.hasProperty('Telegram')) {
        final telegram = js.context['Telegram'];
        if (telegram != null && telegram.hasProperty('WebApp')) {
          final webApp = telegram['WebApp'];

          webApp.callMethod('expand', []);
          _initData = _parseInitData(webApp);
        }
      }
    } catch (e) {}
  }

  Map<String, dynamic> _parseInitData(dynamic webApp) {
    try {
      final initDataUnsafe = webApp['initDataUnsafe'];

      if (initDataUnsafe != null) {
        _startParam =
            initDataUnsafe['start_param'] ?? initDataUnsafe['startapp'];

        final user = initDataUnsafe['user'];
        if (user != null) {
          return {
            'id': user['id']?.toString(),
            'first_name': user['first_name'],
            'username': user['username'],
            'language_code': user['language_code'],
          };
        }
      }
    } catch (e) {}
    return {};
  }

  String? getUserId() {
    return _initData?['id']?.toString();
  }

  String? getFirstName() {
    return _initData?['first_name'];
  }

  String? getUsername() {
    return _initData?['username'];
  }

  String? getStartParam() {
    return _startParam;
  }

  bool isRunningInTelegram() {
    return _initData != null && _initData!.isNotEmpty;
  }

  bool openTelegramLink(String url) {
    try {
      final telegram = js.context['Telegram'];
      final webApp = telegram['WebApp'];
      webApp.callMethod('openTelegramLink', [url]);
      return true;
    } catch (e) {
      return false;
    }
  }

  void close() {
    try {
      final telegram = js.context['Telegram'];
      final webApp = telegram['WebApp'];
      webApp.callMethod('close', []);
    } catch (e) {}
  }

  void showMainButton(String text, Function() onClick) {
    try {
      final telegram = js.context['Telegram'];
      final webApp = telegram['WebApp'];
      final mainButton = webApp['MainButton'];

      mainButton.callMethod('setText', [text]);
      mainButton.callMethod('show', []);
      mainButton.callMethod('onClick', [js.allowInterop(onClick)]);
    } catch (e) {}
  }

  Future<List<Map<String, dynamic>>> getContacts() async {
    return [];
  }
}
