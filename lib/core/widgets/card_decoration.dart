import 'package:flutter/material.dart';
import 'package:divvy/core/theme/constants/color.dart';

BoxDecoration cardDecoration() {
  return BoxDecoration(
    color: cardColor,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );
}
