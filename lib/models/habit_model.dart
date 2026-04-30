import 'package:flutter/foundation.dart';

/// Habit Model - Represents a single habit with tracking data
class Habit {
  String id;
  String name;
  String description;
  String category; // Health, Productivity, Mental, Social, Learning
  int streak;      // Current consecutive day streak
  int totalCompleted;  // Total times completed across all days
  DateTime? lastCompleted;   // Last completion date
  bool isStreakActive;
  
  Habit({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    int streak = 0,
    int totalCompleted = 0,
    bool isStreakActive = true,
  })  : lastCompleted = null;
  
  // Check if habit can be completed today
  bool get canComplete => 
      (isStreakActive || lastCompleted == null) &&
      DateTime.now().day != lastCompleted?.day ||
      lastCompleted == null;
  
  // Calculate completion percentage for daily view
  int get dailyCompletion {
    final now = DateTime.now();
    final todayStr = now.toString().substring(0, 10);
    
    if (lastCompleted == null) return 1; // New habit, consider complete
    if (lastCompleted!.toString().substring(0, 10) == todayStr) return 1;
    
    return 0;
  }
  
  /// Earn XP for completing the habit
  int earnXp(bool isStreakBonus) {
    final baseXp = HabitConfig.dailyXp;
    final multiplier = isStreakBonus ? HabitConfig.streakBonusXpMultiplier : 1.0;
    return (baseXp * multiplier).round();
  }
  
  /// Check if habit reached a streak reward milestone
  bool checkStreakReward(int newStreak) {
    for (final entry in HabitConfig.streakRewards.entries) {
      if (newStreak == entry.key && !streakRewardsEarned.contains(entry.value)) {
        streakRewardsEarned.add(entry.value);
        return true; // Award badge
      }
    }
    return false;
  }
  
  final Set<String> streakRewardsEarned = {};
}

/// User Profile Model - Tracks overall progress and achievements
class UserProfile with ChangeNotifier {
  String _userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
  String get userId => _userId;
  
  // Streak tracking
  int _currentStreak = 0;
  int get currentStreak => _currentStreak;
  
  DateTime? _lastHabitDate;
  DateTime? get lastHabitDate => _lastHabitDate;
  
  // XP and Level system
  int _totalXp = 0;
  int get totalXp => _totalXp;
  
  int _currentLevel = 1;
  int get currentLevel => _currentLevel;
  
  int _levelUpThreshold = 1000; // XP needed to level up
  int get levelUpThreshold => _levelUpThreshold;
  
  // Completed habits list
  List<Habit> _habits = [];
  List<Habit> get habits => _habits;
  
  // Add new habit
  void addHabit(Habit habit) {
    if (!_habits.any((h) => h.id == habit.id)) {
      _habits.add(habit);
      notifyListeners();
    }
  }
  
  // Remove habit
  void removeHabit(String habitId) {
    _habits.removeWhere((h) => h.id == habitId);
    notifyListeners();
  }
  
  // Find habit by ID
  Habit? findHabit(String id) {
    return _habits.firstWhere(
      (h) => h.id == id,
      orElse: () => Habit(
        id: '', 
        name: 'New Habit', 
        description: '', 
        category: 'Health'
      ),
    );
  }
  
  // Get habits by category
  List<Habit> getHabitsByCategory(String category) {
    return _habits.where((h) => h.category == category).toList();
  }
  
  // Check if habit exists
  bool hasHabit(String id) {
    return _habits.any((h) => h.id == id);
  }
  
  // Daily check - complete all habits that haven't been completed today
  void checkHabitsDaily() {
    final now = DateTime.now();
    final todayStr = now.toString().substring(0, 10);
    
    for (final habit in _habits) {
      if (habit.canComplete && 
          (habit.lastCompleted == null || 
           habit.lastCompleted!.toString().substring(0, 10) != todayStr)) {
        // Mark as complete by default if streak is active or it's the first day
        if (habit.isStreakActive || habit.lastCompleted == null) {
          habit.lastCompleted = now;
          habit.totalCompleted++;
        }
      }
    }
    
    // Check for streak maintenance
    final lastDate = _lastHabitDate?.toString().substring(0, 10);
    if (lastDate != todayStr && lastDate != null) {
      // Streak is still active, update last date
      _lastHabitDate = now;
    } else if (_currentStreak > 0) {
      // Streak broken - reset to 1 for today's completion
      _currentStreak = 1;
      _lastHabitDate = now;
    } else {
      _currentStreak = 0;
      _lastHabitDate = now;
    }
    
    notifyListeners();
  }
  
  // Earn XP and potentially level up
  void addXp(int xp) {
    _totalXp += xp;
    
    // Check for level up
    while (_totalXp >= _levelUpThreshold && 
           _currentLevel < 100) {
      _totalXp -= _levelUpThreshold;
      _currentLevel++;
      _levelUpThreshold = (_levelUpThreshold * 12 / 5).round(); // Scale difficulty
    }
    
    notifyListeners();
  }
  
  /// Level progression - returns level name and progress bar value
  Map<String, dynamic> getLevelProgression() {
    final levels = ['Novice', 'Initiate', 'Apprentice', 'Contributor', 
                    'Expert', 'Master', 'Legend'];
    
    final maxLevels = levels.length;
    final levelIndex = (_currentLevel - 1).clamp(0, maxLevels - 1);
    
    return {
      'levelName': levels[levelIndex],
      'progress': _totalXp / _levelUpThreshold,
      'nextLevel': _currentLevel + 1,
      'totalLevels': maxLevels,
    };
  }
  
  /// Calculate overall completion rate
  double getCompletionRate() {
    if (_habits.isEmpty) return 0.0;
    
    final today = DateTime.now();
    final completedToday = _habits.where((h) {
      final last = h.lastCompleted ?? today.subtract(const Duration(days: 365));
      return last.year == today.year &&
             last.month == today.month &&
             last.day == today.day;
    }).length;
    
    return (completedToday / _habits.length).clamp(0.0, 1.0);
  }
}
