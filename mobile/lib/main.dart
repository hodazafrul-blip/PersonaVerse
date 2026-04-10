import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/root_screen.dart';

void main() {
  runApp(const PersonaVerseApp());
}

class PersonaVerseApp extends StatelessWidget {
  const PersonaVerseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PersonaVerse',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        primaryColor: const Color(0xFF6366F1),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6366F1),
          secondary: Color(0xFFEC4899),
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        useMaterial3: true,
      ),
      home: const RootScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
