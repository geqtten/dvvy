import 'package:divvy/app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  runApp(const DvvyApp());
}
