import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/habit_model.dart';
import '../services/storage_service.dart';

/// Habit Hive Provider — manages habits with CRUD, daily completion, XP, and level
class HabitHiveProvider extends ChangeNotifier {
  UserProfile _profile = UserProfile();
  UserProfile get profile => _profile;

  // ── Persistence ─────────────────────────────────────────────────
  void loadFromStorage() {
    final json = StorageService.profileJson;
    if (json != null && json.isNotEmpty) {
      try {
        final data = jsonDecode(json) as Map<String, dynamic>;
        _profile = UserProfile.fromJson(data);
      } catch (_) {
        _profile = UserProfile();
      }
    }
  }

  Future<void> _save() async {
    try {
      await StorageService.setProfileJson(jsonEncode(_profile.toJson()));
    } catch (_) {}
  }

  // ── Demo initialization ──────────────────────────────────────────
  void initializeDemoHabits() {
    _profile = UserProfile.withDefaultHabits();
    _save();
    notifyListeners();
  }

  // ── CRUD ─────────────────────────────────────────────────────────
  void addHabit(String name, String description, String category) {
    final habit = Habit(
      id: 'h_${DateTime.now().millisecondsSinceEpoch}_${_profile.habits.length}',
      name: name,
      description: description,
      category: category,
    );
    _profile.addHabit(habit);
    _save();
  }

  void updateHabit(String id, String name, String description, String category) {
    _profile.updateHabit(id, name, description, category);
    _save();
  }

  void deleteHabit(String id) {
    _profile.removeHabit(id);
    _save();
  }

  // ── Daily completion ─────────────────────────────────────────────
  void completeHabit(String habitId) {
    final habit = _profile.findHabit(habitId);
    if (habit == null || !habit.canComplete) return;

    habit.toggleComplete();

    // Update streak
    _profile.handleHabitCompleted();

    // Award XP
    final xpEarned = habit.earnXp(habit.isStreakActive);
    _profile.addXp(xpEarned);

    notifyListeners();
    _save();
  }

  // ── Stats ────────────────────────────────────────────────────────
  int get completedToday {
    final now = DateTime.now();
    return _profile.habits.where((h) =>
        h.lastCompleted != null &&
        h.lastCompleted!.year == now.year &&
        h.lastCompleted!.month == now.month &&
        h.lastCompleted!.day == now.day).length;
  }

  List<int> get weekHistory => _profile.getWeekHistory();
}
