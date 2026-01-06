import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: TrueToneApp(),
    ),
  );
}

class TrueToneApp extends StatelessWidget {
  const TrueToneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'True Tone',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        primaryColor: const Color(0xFF850E35), // Burgundy
        scaffoldBackgroundColor: const Color(0xFFFCF5EE), // Cream
        textTheme: GoogleFonts.outfitTextTheme(
          ThemeData.light().textTheme,
        ),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.pink,
          backgroundColor: const Color(0xFFFCF5EE),
          accentColor: const Color(0xFFEE6983),
        ).copyWith(
          secondary: const Color(0xFFEE6983), // Rose Pink
          surface: Colors.white,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
