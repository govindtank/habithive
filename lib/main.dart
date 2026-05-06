import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';
import '../screens/onboarding_screen.dart';
import '../screens/home_screen.dart';
import '../services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  runApp(const HabitHiveApp());
}

class HabitHiveApp extends StatefulWidget {
  const HabitHiveApp({super.key});

  @override
  State<HabitHiveApp> createState() => _HabitHiveAppState();
}

class _HabitHiveAppState extends State<HabitHiveApp> {
  bool _hasCompletedOnboarding = StorageService.hasCompletedOnboarding;

  // Light Theme — warm, energetic palette
  ThemeData get _lightTheme {
    const primary = Color(0xFFFF6B35);   // Vibrant orange
    const secondary = Color(0xFF7ED957); // Fresh green
    const surface = Color(0xFFF8F8F8);   // Off-white

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
        primary: primary,
        secondary: secondary,
        surface: surface,
        onSurface: const Color(0xFF1A1A1A),   // near-black for high contrast
        onPrimary: Colors.white,
      ),
      scaffoldBackgroundColor: surface,
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
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
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1A1A1A),  // High contrast vs off-white
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: primary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Color(0xFF444444),  // Comfortable reading gray
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Color(0xFF666666),  // Secondary text
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF0F0F0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return Colors.grey.shade400;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary.withOpacity(0.4);
          return Colors.grey.shade300;
        }),
      ),
    );
  }

  // Dark Theme — deep, eye-friendly palette
  ThemeData get _darkTheme {
    const primary = Color(0xFFFF6B35);
    const secondary = Color(0xFF7ED957);
    const surface = Color(0xFF121212);
    const surfaceVariant = Color(0xFF1E1E1E);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
        primary: primary,
        secondary: secondary,
        surface: surfaceVariant,
        onSurface: const Color(0xFFE8E8E8),
        onPrimary: Colors.white,
      ),
      scaffoldBackgroundColor: surface,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
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
      cardTheme: CardTheme(
        color: const Color(0xFF1E1E1E),
        elevation: 2,
        shadowColor: Colors.black45,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Color(0xFFE8E8E8),
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: primary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Color(0xFFBBBBBB),
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Color(0xFF999999),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return Colors.grey.shade600;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary.withOpacity(0.4);
          return Colors.grey.shade700;
        }),
      ),
    );
  }

  void _onOnboardingComplete() {
    setState(() {
      _hasCompletedOnboarding = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = StorageService.isDarkMode;

    return ChangeNotifierProvider(
      create: (_) {
        final provider = HabitHiveProvider();
        if (_hasCompletedOnboarding) {
          provider.loadFromStorage();
        }
        return provider;
      },
      child: MaterialApp(
        title: 'HabitHive',
        debugShowCheckedModeBanner: false,
        theme: _lightTheme,
        darkTheme: _darkTheme,
        themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
        home: _hasCompletedOnboarding
            ? const HomeScreen()
            : OnboardingScreen(onComplete: _onOnboardingComplete),
      ),
    );
  }
}
