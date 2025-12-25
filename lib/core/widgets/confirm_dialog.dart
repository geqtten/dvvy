import 'package:flutter/material.dart';
import 'package:divvy/core/theme/constants/color.dart';
import 'package:divvy/core/widgets/gradient_button.dart';

Future<bool?> showConfirmDialog({
  required BuildContext context,
  required String title,
  required String content,
  String confirmText = 'Удалить',
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF2D3142),
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Text(content, style: const TextStyle(color: Color(0xFF2D3142))),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text(
            'Отмена',
            style: TextStyle(color: Color(0xFF9E9E9E)),
          ),
        ),
        GradientButton(
          text: confirmText,
          onPressed: () => Navigator.of(context).pop(true),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ],
    ),
  );
}
