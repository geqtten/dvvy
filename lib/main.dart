import 'package:divvy/app.dart';
import 'package:divvy/core/services/firebase_service.dart';
import 'package:divvy/core/services/telegram_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

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

  final userId = telegramService.getUserId();
  if (userId != null) {
    FirebaseService().setTelegramUserId(userId);
  } else {
    print('Running in browser mode - using test user ID');
    FirebaseService().setTelegramUserId('test_user_123');
  }

  runApp(const DvvyApp());
}
