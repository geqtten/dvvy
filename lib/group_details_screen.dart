import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'package:divvy/core/theme/constants/color.dart';

class GroupDetailsScreen extends StatefulWidget {
  final String groupId;
  final String groupName;

  const GroupDetailsScreen({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
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
      body: Column(
        children: [
          _buildGroupInfo(),
          const SizedBox(height: 16),
          Expanded(child: _buildExpensesList()),
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
          onPressed: () {
            _addExpense();
          },
          backgroundColor: Colors.transparent,
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
                    style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '0 ₽',
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
                  '0',
                  Icons.people,
                  onTap: () => _inviteToTelegram(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard('Расходы', '0', Icons.receipt_long),
              ),
            ],
          ),
        ],
      ),
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
          const Row(
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
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: primaryColor.withOpacity(0.3),
                  ),
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
          ),
        ],
      ),
    );
  }

  Future<void> _inviteToTelegram() async {
    const functionUrl =
        "https://eur3-dvvy-eb34b.cloudfunctions.net/getTelegramInviteLink";

    try {
      final response = await http.get(Uri.parse(functionUrl));

      if (response.statusCode == 200) {
        final link = jsonDecode(response.body)['link'];
        final uri = Uri.parse(link);

        if (!await launchUrl(uri)) {
          throw "Не удалось открыть Telegram";
        }
      } else {
        throw "Ошибка функции";
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Ошибка при приглашении")));
    }
  }

  void _addExpense() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Добавление расхода - скоро будет реализовано'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
