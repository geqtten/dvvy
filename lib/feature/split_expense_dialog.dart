import 'package:flutter/material.dart';
import 'package:divvy/core/theme/constants/color.dart';

class SplitExpensesDialog extends StatefulWidget {
  final List<Map<String, dynamic>> members;
  final double totalAmount;
  final String groupName;

  const SplitExpensesDialog({
    super.key,
    required this.members,
    required this.totalAmount,
    required this.groupName,
  });

  @override
  State<SplitExpensesDialog> createState() => _SplitExpensesDialogState();
}

class _SplitExpensesDialogState extends State<SplitExpensesDialog> {
  bool _isExpanded = false;
  final Map<String, bool> _selectedMembers = {};
  final TextEditingController _amountController = TextEditingController();

  bool _isAutoSplit = true;

  @override
  void initState() {
    super.initState();
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
            _choiceAmountSplit(),
            if (!_isAutoSplit) _buildExpandButton(),
            if (!_isAutoSplit) _buildAnimatedMembersList(),
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
                  widget.groupName,
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

  Widget _choiceAmountSplit() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: _buildChoiceOption(
              title: 'Автоматически',
              subtitle: 'Поровну на всех',
              isSelected: _isAutoSplit,
              onTap: () => setState(() => _isAutoSplit = true),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildChoiceOption(
              title: 'Самостоятельно',
              subtitle: 'Указать суммы',
              isSelected: !_isAutoSplit,
              onTap: () => setState(() => _isAutoSplit = false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceOption({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.1) : backgroundColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? primaryColor : const Color(0xFF9E9E9E),
                  width: 2,
                ),
                color: isSelected ? primaryColor : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? primaryColor
                          : const Color(0xFF2D3142),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected
                          ? primaryColor.withOpacity(0.7)
                          : const Color(0xFF9E9E9E),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
            child: _isAutoSplit
                ? _buildAutoSplitList()
                : _buildManualSplitList(),
          ),
        ),
      ),
    );
  }

  Widget _buildAutoSplitList() {
    return ListView.builder(
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
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? primaryColor : const Color(0xFF2D3142),
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
            activeColor: primaryColor,
            checkColor: Colors.white,
            controlAffinity: ListTileControlAffinity.leading,
          ),
        );
      },
    );
  }

  Widget _buildManualSplitList() {
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.all(8),
      itemCount: widget.members.length,
      itemBuilder: (context, index) {
        final member = widget.members[index];
        final memberId = member['id'] as String;
        final isSelected = _selectedMembers[memberId] ?? false;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected
                ? primaryColor.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? primaryColor.withOpacity(0.3)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Checkbox(
                value: isSelected,
                onChanged: (value) => _toggleMember(memberId),
                activeColor: primaryColor,
              ),
              CircleAvatar(
                backgroundColor: isSelected
                    ? primaryColor
                    : primaryColor.withOpacity(0.2),
                radius: 18,
                child: Text(
                  (member['firstName']?[0] ?? '?').toUpperCase(),
                  style: TextStyle(
                    color: isSelected ? Colors.white : primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member['firstName'] ?? 'Без имени',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? primaryColor
                            : const Color(0xFF2D3142),
                      ),
                    ),
                    if (member['username'] != null)
                      Text(
                        '@${member['username']}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isSelected
                              ? primaryColor.withOpacity(0.7)
                              : const Color(0xFF9E9E9E),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(
                width: 110,
                child: TextField(
                  enabled: isSelected,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? primaryColor : const Color(0xFF9E9E9E),
                  ),
                  decoration: InputDecoration(
                    suffixText: '₽',
                    hintText: '0',
                    border: InputBorder.none,
                    enabled: isSelected,
                  ),
                  // TODO: implement manual split amount
                  onChanged: (value) {},
                ),
              ),
            ],
          ),
        );
      },
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
