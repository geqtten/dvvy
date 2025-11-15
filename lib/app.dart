import 'package:divvy/home_screen.dart';
import 'package:flutter/material.dart';

class DvvyApp extends StatelessWidget {
  const DvvyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomeScreen(),
    );
  }
}
