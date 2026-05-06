import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/habit_model.dart';
import '../services/storage_service.dart';

/// Habit Hive Provider — manages habit list, daily completion, XP, and level
class HabitHiveProvider extends ChangeNotifier {
  UserProfile _profile = UserProfile();
  UserProfile get profile => _profile;

  // ── Persistence ─────────────────────────────────────────────────
  /// Load previously saved profile from storage (called on startup if already onboarded)
  void loadFromStorage() {
    final json = StorageService.profileJson;
    if (json != null && json.isNotEmpty) {
      try {
        final data = jsonDecode(json) as Map<String, dynamic>;
        _profile = UserProfile.fromJson(data);
        notifyListeners();
      } catch (_) {
        // Corrupt data — start fresh
        _profile = UserProfile();
      }
    }
  }

  /// Save current profile to storage
  Future<void> _saveToStorage() async {
    try {
      final json = jsonEncode(_profile.toJson());
      await StorageService.setProfileJson(json);
    } catch (_) {
      // Storage full or unavailable — continue anyway
    }
  }

  // ── Demo initialization ──────────────────────────────────────────
  /// Initialize with sample habits for first-time users
  void initializeDemoHabits() {
    _profile = UserProfile.withDefaultHabits();
    _saveToStorage();
    notifyListeners();
  }

  // ── Habit operations ─────────────────────────────────────────────
  /// Mark a habit as completed today
  void completeHabit(String habitId) {
    final habit = _profile.findHabit(habitId);
    if (habit != null && habit.canComplete) {
      habit.lastCompleted = DateTime.now();
      habit.totalCompleted++;

      final xpEarned = habit.earnXp(habit.isStreakActive);
      _profile.addXp(xpEarned);

      notifyListeners();
      _saveToStorage();
    }
  }

  /// Get number of habits completed today
  int get completedToday =>
      _profile.habits.where((h) => h.canComplete).length;
}
