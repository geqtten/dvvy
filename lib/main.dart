import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:divvy/core/app.dart';

import 'package:divvy/core/services/telegram_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyBoQ6lQi6-xPF2mv8lMDfhqJ4SLuRTLmjY',
        appId: '1:907673788834:web:e431f6db82b3c30c09d2fb',
        messagingSenderId: '907673788834',
        projectId: 'dvvy-eb34b',
        authDomain: 'dvvy-eb34b.firebaseapp.com',
        storageBucket: 'dvvy-eb34b.firebasestorage.app',
      ),
    );
  } catch (e) {
    print('Firebase initialization error: $e');
  }
  final telegramService = TelegramService();
  telegramService.initialize();

  if (telegramService.isRunningInTelegram()) {
    print('Running in Telegram');
    print(
      'User: ${telegramService.getFirstName()} (@${telegramService.getUsername()})',
    );
  } else {
    print('Running in browser mode - test user will be used');
  }

  runApp(const MaterialApp(home: DvvyApp()));
}
