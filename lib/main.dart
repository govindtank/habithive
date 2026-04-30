import 'package:flutter/material.dart';
import '../models/habit_model.dart';
import '../providers/habit_provider.dart';
import '../screens/onboarding_screen.dart';
import '../screens/home_screen.dart';

void main() {
  runApp(const HabitHiveApp());
}

class HabitHiveApp extends StatelessWidget {
  const HabitHiveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HabitHive',
      debugShowCheckedModeBanner: false,
      
      // Energetic and motivating theme
      theme: ThemeData(
        useMaterial3: true,
        
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF6B35),
          brightness: Brightness.light,
          primary: const Color(0xFFFF6B35),
          secondary: const Color(0xFF7ED957),
          surface: const Color(0xFFF8F8F8),
        ),
        
        scaffoldBackgroundColor: const Color(0xFFF8F8F8),
        
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFF6B35),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: 'Google Sans',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        
        // Card theme with fun rounded corners
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        
        // Text theme with energetic colors
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
          titleLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Color(0xFFFF6B35),
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: Color(0xFF555555),
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: Color(0xFF7A7A7A),
          ),
        ),
        
        // Elevated buttons with energetic styling
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF6B35),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 14,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        
        // Input decoration with rounded fields
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF5F5F5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
      
      // Simple routing
      home: const OnboardingScreen(),
    );
  }
}
