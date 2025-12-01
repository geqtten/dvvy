import 'package:divvy/core/app/components/custom_text_form_field.dart';
import 'package:divvy/core/theme/constants/color.dart';
import 'package:flutter/material.dart';

class ExpenseDialog extends StatelessWidget {
  final bool isEditing;
  final TextEditingController nameController;
  final TextEditingController amountController;
  final Function(String name, double amount) onSubmit;

  const ExpenseDialog({
    super.key,
    required this.isEditing,
    required this.nameController,
    required this.amountController,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    return AlertDialog(
      backgroundColor: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      title: Text(
        isEditing ? 'Редактирование расхода' : 'Добавить расход',
        style: const TextStyle(
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
              controller: amountController,
              labelText: 'Сумма',
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
          onPressed: () => Navigator.of(context).pop(),
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
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final name = nameController.text.trim();
                final amount = double.parse(amountController.text.trim());
                Navigator.of(context).pop();
                onSubmit(name, amount);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              isEditing ? 'Обновить' : 'Добавить',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
