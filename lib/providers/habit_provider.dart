import 'package:flutter/material.dart';
import '../models/habit_model.dart';

/// Habit Hive Provider - Manages habit list and daily completion
class HabitHiveProvider extends ChangeNotifier {
  UserProfile _profile = UserProfile();
  UserProfile get profile => _profile;
  
  // Initialize with some default habits for demo
  void initializeDemoHabits() {
    final now = DateTime.now();
    
    _profile.addHabit(Habit(
      id: 'habit_1',
      name: 'Morning Exercise',
      description: 'Do 30 minutes of exercise each morning',
      category: 'Health',
      streak: 5,
      totalCompleted: 42,
      isStreakActive: true,
    ));
    
    _profile.addHabit(Habit(
      id: 'habit_2',
      name: 'Read for 30 mins',
      description: 'Read books or articles before bed',
      category: 'Learning',
      streak: 12,
      totalCompleted: 89,
      isStreakActive: true,
    ));
    
    _profile.addHabit(Habit(
      id: 'habit_3',
      name: 'Drink Water',
      description: 'Drink at least 8 glasses of water',
      category: 'Health',
      streak: 21,
      totalCompleted: 156,
      isStreakActive: true,
    ));
    
    _profile.addHabit(Habit(
      id: 'habit_4',
      name: 'Meditate',
      description: 'Practice mindfulness meditation',
      category: 'Mental',
      streak: 3,
      totalCompleted: 15,
      isStreakActive: true,
    ));
  }
  
  // Complete a habit for today
  void completeHabit(String habitId) {
    final habit = _profile.findHabit(habitId);
    
    if (habit != null && habit.canComplete) {
      habit.lastCompleted = DateTime.now();
      habit.totalCompleted++;
      
      // Earn XP
      final xpEarned = habit.earnXp(habit.isStreakActive);
      _profile.addXp(xpEarned);
      
      notifyListeners();
    }
  }
  
  // Get completed habits count for daily button
  int get completedToday => 
    _profile.habits.where((h) => h.canComplete).length;
}
