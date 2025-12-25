import 'package:divvy/core/services/bot_telegram_service.dart';
import 'package:divvy/core/services/firebase_service.dart';

class GroupExpenseService {
  final FirebaseService _firebaseService = FirebaseService();
  final TelegramBotService _botService = TelegramBotService();

  Future<void> createExpense({
    required String name,
    required double amount,
    required String expensesId,
    required String expensesName,
  }) async {
    await _firebaseService.createExpenses(
      name: name,
      id: expensesId,
      expense: expensesName,
      amount: amount.toString(),
    );
  }

  Future<void> updateExpense({
    required String id,
    required String name,
    required double amount,
  }) async {
    await _firebaseService.updateExpenses(id, name, amount);
  }

  Future<void> deleteExpense(String expenseId) async {
    await _firebaseService.deleteExpenses(expenseId);
  }

  double calculateTotalAmount(List<Map<String, dynamic>> expenses) {
    return expenses.fold<double>(0, (sum, expense) {
      final amountStr = expense['amount']?.toString() ?? '0';
      return sum + (double.tryParse(amountStr) ?? 0);
    });
  }

  Future<Map<String, int>> sendDebtNotifications({
    required String groupId,
    required String groupName,
    required List<Map<String, dynamic>> debts,
    required List<Map<String, dynamic>> members,
  }) async {
    final groupData = await _firebaseService.getGroupById(groupId);
    if (groupData == null) {
      throw Exception('Не удалось получить информацию о группе');
    }

    final ownerId = groupData['ownerId'] as String?;
    if (ownerId == null) {
      throw Exception('Не удалось определить создателя группы');
    }

    final owner = members.firstWhere(
      (m) => m['userId'] == ownerId || m['id'] == ownerId,
      orElse: () => {},
    );

    final ownerName = owner['firstName'] ?? 'Создателю группы';
    int successCount = 0;
    int failCount = 0;

    for (final debt in debts) {
      final memberId = debt['memberId'] as String;
      final amount = debt['amount'] as double;

      final member = members.firstWhere(
        (m) => m['id'] == memberId,
        orElse: () => {},
      );

      if (member['userId'] == ownerId || member['id'] == ownerId) {
        continue;
      }

      final userId = member['userId'] as String?;
      if (userId == null) {
        failCount++;
        continue;
      }

      final message =
          '''💰 <b>Разделение расходов</b>

Группа: <b>$groupName</b>

Вам нужно перевести <b>${amount.toStringAsFixed(0)} ₽</b> $ownerName.

Спасибо! 🙏''';

      final result = await _botService.sendLink(
        chatId: userId,
        link: '',
        message: message,
      );

      if (result['success'] == true) {
        successCount++;
      } else {
        failCount++;
      }
    }

    return {'success': successCount, 'failed': failCount};
  }
}
