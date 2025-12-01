import 'package:flutter/material.dart';
import 'package:divvy/core/theme/constants/color.dart';

class SplitExpensesDialog extends StatefulWidget {
  final List<Map<String, dynamic>> members;
  final double totalAmount;
  final String expenseName;

  const SplitExpensesDialog({
    super.key,
    required this.members,
    required this.totalAmount,
    required this.expenseName,
  });

  @override
  State<SplitExpensesDialog> createState() => _SplitExpensesDialogState();
}

class _SplitExpensesDialogState extends State<SplitExpensesDialog> {
  bool _isExpanded = false;
  final Map<String, bool> _selectedMembers = {};
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Инициализируем всех участников как выбранных
    for (var member in widget.members) {
      _selectedMembers[member['id']] = true;
    }
    _amountController.text = widget.totalAmount.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  int get _selectedCount => _selectedMembers.values.where((v) => v).length;

  double get _amountPerPerson {
    if (_selectedCount == 0) return 0;
    final amount = double.tryParse(_amountController.text) ?? 0;
    return amount / _selectedCount;
  }

  void _toggleMember(String memberId) {
    setState(() {
      _selectedMembers[memberId] = !(_selectedMembers[memberId] ?? false);
    });
  }

  void _calculateDebts() {
    if (_selectedCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Выберите хотя бы одного участника'),
          backgroundColor: accentColor,
        ),
      );
      return;
    }

    // Здесь будет логика сохранения долгов в Firebase
    final debts = <Map<String, dynamic>>[];

    for (var member in widget.members) {
      if (_selectedMembers[member['id']] == true) {
        debts.add({
          'memberId': member['id'],
          'memberName': member['firstName'] ?? 'Без имени',
          'amount': _amountPerPerson,
        });
      }
    }

    Navigator.pop(context, debts);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            _buildSummaryCard(),
            _buildAmountInput(),
            _buildExpandButton(),
            _buildAnimatedMembersList(),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [primaryColor, Color(0xFF8B7FFF)]),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.payments, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Разделить расход',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.expenseName,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Выбрано участников',
                style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                '$_selectedCount из ${widget.members.length}',
                style: const TextStyle(
                  color: primaryColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [primaryColor, Color(0xFF8B7FFF)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text(
                  'На человека',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_amountPerPerson.toStringAsFixed(0)} ₽',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: _amountController,
        keyboardType: TextInputType.number,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: 'Общая сумма',
          suffixText: '₽',
          prefixIcon: const Icon(Icons.currency_ruble, color: primaryColor),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: primaryColor, width: 2),
          ),
        ),
        onChanged: (value) => setState(() {}),
      ),
    );
  }

  Widget _buildExpandButton() {
    return InkWell(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Выбрать участников',
              style: TextStyle(
                color: Color(0xFF2D3142),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Icon(
              _isExpanded ? Icons.expand_less : Icons.expand_more,
              color: primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedMembersList() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: _isExpanded ? 300 : 0,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: _isExpanded ? 1.0 : 0.0,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.all(8),
              itemCount: widget.members.length,
              itemBuilder: (context, index) {
                final member = widget.members[index];
                final memberId = member['id'] as String;
                final isSelected = _selectedMembers[memberId] ?? false;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? primaryColor.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CheckboxListTile(
                    value: isSelected,
                    onChanged: (value) => _toggleMember(memberId),
                    title: Text(
                      member['firstName'] ?? 'Без имени',
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: isSelected
                            ? primaryColor
                            : const Color(0xFF2D3142),
                      ),
                    ),
                    subtitle: member['username'] != null
                        ? Text(
                            '@${member['username']}',
                            style: TextStyle(
                              color: isSelected
                                  ? primaryColor.withOpacity(0.7)
                                  : const Color(0xFF9E9E9E),
                              fontSize: 12,
                            ),
                          )
                        : null,
                    secondary: CircleAvatar(
                      backgroundColor: isSelected
                          ? primaryColor
                          : primaryColor.withOpacity(0.2),
                      child: Text(
                        (member['firstName']?[0] ?? '?').toUpperCase(),
                        style: TextStyle(
                          color: isSelected ? Colors.white : primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    activeColor: primaryColor,
                    checkColor: Colors.white,
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Отмена',
                style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [primaryColor, Color(0xFF8B7FFF)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _calculateDebts,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Разделить',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
