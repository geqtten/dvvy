import 'package:divvy/core/theme/constants/color.dart';
import 'package:divvy/feature/screen/home_screen.dart';
import 'package:flutter/material.dart';

class DvvyApp extends StatelessWidget {
  const DvvyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dvvy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: primaryColor,
        scaffoldBackgroundColor: backgroundColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
          secondary: secondaryColor,
          error: accentColor,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
