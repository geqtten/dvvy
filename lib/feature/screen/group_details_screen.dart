import 'package:divvy/core/services/bot_telegram_service.dart';
import 'package:divvy/core/services/firebase_service.dart';
import 'package:divvy/core/services/group_expense_service.dart';
import 'package:divvy/core/services/telegram_service.dart';
import 'package:divvy/core/theme/constants/color.dart';
import 'package:divvy/core/widgets/card_decoration.dart';
import 'package:divvy/core/widgets/confirm_dialog.dart';
import 'package:divvy/core/widgets/snack_bar_helper.dart';
import 'package:divvy/feature/expense_dialog.dart';
import 'package:divvy/feature/split_expense_dialog.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class GroupDetailsScreen extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String expensesId;
  final String expensesName;

  const GroupDetailsScreen({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.expensesId,
    required this.expensesName,
  });

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final TelegramService _telegramService = TelegramService();
  final TelegramBotService _botService = TelegramBotService();
  final GroupExpenseService _expenseService = GroupExpenseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 80),
        children: [
          _buildGroupInfo(),
          const SizedBox(height: 16),
          _buildExpensesList(),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, Color(0xFF8B7FFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        widget.groupName,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 22,
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [primaryColor, Color(0xFF8B7FFF)],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () => _showExpenseDialog(),
        backgroundColor: Colors.transparent,
        elevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        splashColor: Colors.transparent,

        label: const Row(
          children: [
            Text(
              'Добавить расход',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.wallet, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupInfo() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _firebaseService.getGroupMembers(widget.groupId),
      builder: (context, membersSnapshot) {
        return StreamBuilder<List<Map<String, dynamic>>>(
          stream: _firebaseService.getExpenses(widget.expensesId),
          builder: (context, expensesSnapshot) {
            final expenses = expensesSnapshot.data ?? [];
            final members = membersSnapshot.data ?? [];

            final totalAmount = _expenseService.calculateTotalAmount(expenses);
            final expensesCount = expenses.length;
            final membersCount = members.length;

            return Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: cardDecoration(),
              child: Column(
                children: [
                  _buildTotalAmountRow(totalAmount),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Участники',
                          '$membersCount',
                          Icons.people,
                          onTap: _showMembersDialog,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Расходы',
                          '$expensesCount',
                          Icons.receipt_long,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTotalAmountRow(double totalAmount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Общая сумма',
              style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              '${totalAmount.toStringAsFixed(0)} ₽',
              style: const TextStyle(
                color: primaryColor,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [primaryColor, Color(0xFF8B7FFF)],
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(
            Icons.account_balance_wallet,
            color: Colors.white,
            size: 32,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: primaryColor, size: 24),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF9E9E9E),
                    fontSize: 12,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF2D3142),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpensesList() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      constraints: const BoxConstraints(minHeight: 300),
      decoration: cardDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildExpensesHeader(),
          const SizedBox(height: 16),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _firebaseService.getExpenses(widget.expensesId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return _buildErrorState('Ошибка загрузки расходов');
              }

              final expenses = snapshot.data ?? [];

              if (expenses.isEmpty) {
                return _buildEmptyState();
              }

              return _buildExpensesItems(expenses);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExpensesHeader() {
    return Row(
      children: [
        const Icon(Icons.receipt_long, color: primaryColor),
        const SizedBox(width: 12),
        const Text(
          'Расходы',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3142),
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: _shareExpenses,
          child: const Text('Разделить траты', style: TextStyle(fontSize: 18)),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt, size: 64, color: primaryColor.withOpacity(0.3)),
            const SizedBox(height: 16),
            const Text(
              'Нет расходов',
              style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Добавьте первый расход',
              style: TextStyle(color: Color(0xFFBDBDBD), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return SizedBox(
      height: 200,
      child: Center(
        child: Text(message, style: const TextStyle(color: accentColor)),
      ),
    );
  }

  Widget _buildExpensesItems(List<Map<String, dynamic>> expenses) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: expenses.map((expense) => _buildExpenseItem(expense)).toList(),
    );
  }

  Widget _buildExpenseItem(Map<String, dynamic> expense) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [primaryColor, Color(0xFF8B7FFF)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.receipt, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense['name'] ?? 'Без названия',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3142),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${expense['amount'] ?? '0'} ₽',
                  style: const TextStyle(
                    fontSize: 14,
                    color: primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          PopupMenuButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            color: backgroundColor,
            icon: const Icon(Icons.more_vert, color: Color(0xFF9E9E9E)),
            onSelected: (value) async {
              if (value == 'edit') {
                _showExpenseDialog(expense: expense);
              } else if (value == 'delete') {
                await _deleteExpense(expense);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, color: primaryColor),
                    SizedBox(width: 12),
                    Text('Редактировать'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: accentColor),
                    SizedBox(width: 12),
                    Text('Удалить'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showExpenseDialog({Map<String, dynamic>? expense}) {
    final isEditing = expense != null;
    final nameController = TextEditingController(text: expense?['name'] ?? '');
    final amountController = TextEditingController(
      text: expense?['amount']?.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) => ExpenseDialog(
        isEditing: isEditing,
        nameController: nameController,
        amountController: amountController,
        onSubmit: (name, amount) => isEditing
            ? _updateExpense(expense['id'] as String, name, amount)
            : _createExpense(name, amount),
      ),
    ).then((_) {
      nameController.dispose();
      amountController.dispose();
    });
  }

  void _showMembersDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Участники',
              style: TextStyle(
                color: Color(0xFF2D3142),
                fontWeight: FontWeight.w600,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.person_add, color: primaryColor),
              onPressed: () {
                Navigator.pop(context);
                _inviteToTelegram();
              },
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: _firebaseService.getGroupMembers(widget.groupId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final members = snapshot.data ?? [];

              if (members.isEmpty) {
                return const Center(child: Text('Нет участников'));
              }

              return ListView.builder(
                shrinkWrap: true,
                itemCount: members.length,
                itemBuilder: (context, index) {
                  final member = members[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: primaryColor,
                      child: Text(
                        (member['firstName']?[0] ?? '?').toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    title: Text(
                      member['firstName'] ?? 'Без имени',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: member['username'] != null
                        ? Text('@${member['username']}')
                        : null,
                    trailing: member['isOwner'] == true
                        ? const Icon(Icons.star, color: Colors.amber, size: 20)
                        : null,
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  // ==================== Business Logic ====================
  Future<void> _createExpense(String name, double amount) async {
    try {
      await _expenseService.createExpense(
        name: name,
        amount: amount,
        expensesId: widget.expensesId,
        expensesName: widget.expensesName,
      );

      if (mounted) {
        SnackBarHelper.showSuccess(
          context,
          'Расход "$name" на сумму $amount ₽ добавлен',
        );
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(context, 'Ошибка: $e');
      }
    }
  }

  Future<void> _updateExpense(String id, String name, double amount) async {
    try {
      await _expenseService.updateExpense(id: id, name: name, amount: amount);
      if (mounted) {
        SnackBarHelper.showSuccess(
          context,
          'Расход "$name" на сумму $amount ₽ обновлен',
        );
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(context, 'Ошибка: $e');
      }
    }
  }

  Future<void> _deleteExpense(Map<String, dynamic> expense) async {
    final confirm = await showConfirmDialog(
      context: context,
      title: 'Удалить расход?',
      content:
          'Вы уверены, что хотите удалить "${expense['name'] ?? 'расход'}"?',
    );

    if (confirm != true) return;

    try {
      await _expenseService.deleteExpense(expense['id'] as String);
      if (mounted) {
        SnackBarHelper.showSuccess(context, 'Расход удален');
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(context, 'Ошибка удаления: $e');
      }
    }
  }

  Future<void> _inviteToTelegram() async {
    try {
      final link = await _botService.buildInviteLink(groupId: widget.groupId);

      if (link == null) {
        throw 'Не удалось сформировать ссылку приглашения';
      }

      final message =
          'Присоединяйся к группе "${widget.groupName}" и следи за расходами!';
      final shareUrl =
          'https://t.me/share/url?url=${Uri.encodeComponent(link)}&text=${Uri.encodeComponent(message)}';

      final openedInTelegram = _telegramService.openTelegramLink(
        shareUrl.trim(),
      );

      if (!openedInTelegram) {
        final uri = Uri.parse(shareUrl);
        if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
          throw 'Не удалось открыть Telegram';
        }
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(context, 'Ошибка при приглашении: $e');
      }
    }
  }

  void _shareExpenses() async {
    final members = await _firebaseService
        .getGroupMembers(widget.groupId)
        .first;

    if (members.isEmpty) {
      if (mounted) {
        SnackBarHelper.showError(context, 'В группе нет участников');
      }
      return;
    }

    final expenses = await _firebaseService
        .getExpenses(widget.expensesId)
        .first;

    if (expenses.isEmpty) {
      if (mounted) {
        SnackBarHelper.showError(context, 'Нет расходов для разделения');
      }
      return;
    }

    final totalAmount = _expenseService.calculateTotalAmount(expenses);

    if (!mounted) return;

    final debts = await showDialog<List<Map<String, dynamic>>>(
      context: context,
      builder: (context) => SplitExpensesDialog(
        members: members,
        totalAmount: totalAmount,
        groupName: widget.groupName,
      ),
    );

    if (debts != null && debts.isNotEmpty && mounted) {
      try {
        final result = await _expenseService.sendDebtNotifications(
          groupId: widget.groupId,
          groupName: widget.groupName,
          debts: debts,
          members: members,
        );

        if (mounted) {
          if (result['success']! > 0) {
            SnackBarHelper.showSuccess(
              context,
              'Уведомления отправлены ${result['success']} участникам',
            );
          }
          if (result['failed']! > 0) {
            SnackBarHelper.showError(
              context,
              'Не удалось отправить ${result['failed']} уведомлений',
            );
          }
        }
      } catch (e) {
        if (mounted) {
          SnackBarHelper.showError(context, 'Ошибка отправки уведомлений: $e');
        }
      }
    }
  }
}
