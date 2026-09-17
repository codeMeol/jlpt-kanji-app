import 'package:flutter/material.dart';

import 'screens/study_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const JlptKanjiApp());
}

class JlptKanjiApp extends StatelessWidget {
  const JlptKanjiApp({super.key});

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF14213D);
    const gold = Color(0xFFF2B134);
    return MaterialApp(
      title: 'JLPT 한자 쓰기',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: navy, primary: navy, secondary: gold),
        scaffoldBackgroundColor: const Color(0xFFF6F4EE),
        appBarTheme: const AppBarTheme(
            backgroundColor: navy, foregroundColor: Colors.white),
        useMaterial3: true,
      ),
      home: const StudyScreen(),
    );
  }
}
