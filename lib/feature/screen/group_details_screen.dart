import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:divvy/core/theme/constants/color.dart';
import 'package:divvy/core/theme/custom_text_form_field.dart';
import 'package:divvy/core/services/firebase_service.dart';
import 'package:divvy/core/services/telegram_service.dart';
import 'package:divvy/core/services/bot_telegram_service.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
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
      ),

      body: ListView(
        padding: const EdgeInsets.only(bottom: 80),
        children: [
          _buildGroupInfo(),
          const SizedBox(height: 16),
          _buildExpensesList(),
        ],
      ),
      floatingActionButton: Container(
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
          onPressed: _addExpense,
          backgroundColor: Colors.transparent,
          highlightElevation: 0,
          hoverElevation: 0,
          elevation: 0,
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
            double totalAmount = 0;
            int expensesCount = 0;
            int memberCount = 0;

            if (expensesSnapshot.hasData) {
              final expenses = expensesSnapshot.data ?? [];
              expensesCount = expenses.length;
              for (var expense in expenses) {
                final amountStr = expense['amount']?.toString() ?? '0';
                final amount = double.tryParse(amountStr) ?? 0;
                totalAmount += amount;
              }
            }

            return Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Общая сумма',
                            style: TextStyle(
                              color: Color(0xFF9E9E9E),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${totalAmount.toStringAsFixed(0)} ₽',
                            style: TextStyle(
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
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Участники',
                          '$memberCount',
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
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long, color: primaryColor),
              SizedBox(width: 12),
              Text(
                'Расходы',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3142),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => _shareExpenses(),
                child: Text('Разделить траты', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
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
                return SizedBox(
                  height: 200,
                  child: Center(
                    child: Text(
                      'Ошибка загрузки расходов',
                      style: TextStyle(color: accentColor),
                    ),
                  ),
                );
              }

              final expenses = snapshot.data ?? [];

              if (expenses.isEmpty) {
                return SizedBox(
                  height: 200,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt,
                          size: 64,
                          color: primaryColor.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Нет расходов',
                          style: TextStyle(
                            color: Color(0xFF9E9E9E),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Добавьте первый расход',
                          style: TextStyle(
                            color: Color(0xFFBDBDBD),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: expenses.map((expense) {
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
                          child: const Icon(
                            Icons.receipt,
                            color: Colors.white,
                            size: 24,
                          ),
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
                                style: TextStyle(
                                  fontSize: 14,
                                  color: primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            final confirm = await showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Удалить расход?'),
                                  content: Text(
                                    'Вы уверены, что хотите удалить "${expense['name'] ?? 'расход'}"?',
                                  ),
                                  backgroundColor: backgroundColor,
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text(
                                        'Отмена',
                                        style: TextStyle(
                                          color: Color(0xFF9E9E9E),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            primaryColor,
                                            Color(0xFF8B7FFF),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: ElevatedButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(true),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          'Удалить',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (confirm == true) {
                              try {
                                await _firebaseService.deleteExpenses(
                                  expense['id'] as String,
                                );
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Расход удален'),
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: secondaryColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Ошибка удаления: $e'),
                                      backgroundColor: accentColor,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                }
                              }
                            }
                          },
                          icon: const Icon(Icons.delete, color: Colors.red),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
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
                      backgroundColor: primaryColor.withOpacity(0.2),
                      child: Text(
                        member['firstName'][0].toUpperCase(),
                        style: const TextStyle(color: primaryColor),
                      ),
                    ),
                    title: Text(
                      member['firstName'] ?? 'Без имени',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: member['username'] != null
                        ? Text('@${member['username']}')
                        : null,
                    trailing: member['isOwner']
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

  Future<void> _inviteToTelegram() async {
    try {
      final link = await _botService.buildInviteLink(groupId: widget.groupId);

      if (link == null) {
        throw "Не удалось сформировать ссылку приглашения";
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
          throw "Не удалось открыть Telegram";
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Ошибка при приглашении: $e"),
            backgroundColor: accentColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  void _shareExpenses() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Реализация разделения скоро будет добавлена :)"),
          backgroundColor: primaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _addExpense() {
    final nameController = TextEditingController();
    final expensesController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        final formKey = GlobalKey<FormState>();

        return AlertDialog(
          backgroundColor: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          title: const Text(
            'Добавить расход',
            style: TextStyle(
              color: Color(0xFF2D3142),
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextFormField(
                  controller: nameController,
                  labelText: 'Название расхода',
                  hintText: 'Введите название',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Пожалуйста, введите название';
                    }
                    return null;
                  },
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),
                CustomTextFormField(
                  controller: expensesController,
                  labelText: 'Сумма',
                  hintText: 'Введите сумму',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Пожалуйста, введите сумму';
                    }
                    final amount = double.tryParse(value.trim());
                    if (amount == null || amount <= 0) {
                      return 'Пожалуйста, введите корректную сумму';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text(
                'Отмена',
                style: TextStyle(color: Color(0xFF9E9E9E)),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [primaryColor, Color(0xFF8B7FFF)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    final expensesName = nameController.text.trim();
                    final amount = expensesController.text.trim();
                    Navigator.of(dialogContext).pop();

                    try {
                      await _firebaseService.createExpenses(
                        name: expensesName,
                        id: widget.expensesId,
                        expense: widget.expensesName,
                        amount: amount,
                      );

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Расход "$expensesName" на сумму $amount ₽ добавлен',
                            ),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: secondaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Ошибка: $e'),
                            backgroundColor: accentColor,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      }
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Добавить',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    ).then((_) {
      nameController.dispose();
      expensesController.dispose();
    });
  }
}
