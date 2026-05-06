import 'package:flutter/foundation.dart';
import '../config/habit_config.dart';

/// Habit Model — represents a single habit with tracking data
class Habit {
  String id;
  String name;
  String description;
  String category; // Health, Productivity, Mental, Social, Learning
  int streak;
  int totalCompleted;
  DateTime? lastCompleted;
  bool isStreakActive;
  final Set<String> streakRewardsEarned;

  Habit({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.streak = 0,
    this.totalCompleted = 0,
    this.isStreakActive = true,
  }) : streakRewardsEarned = {};

  // Check if habit can be completed today
  bool get canComplete =>
      (isStreakActive || lastCompleted == null) &&
      DateTime.now().day != lastCompleted?.day ||
      lastCompleted == null;

  int earnXp(bool isStreakBonus) {
    final baseXp = HabitConfig.dailyXp;
    final multiplier = isStreakBonus ? HabitConfig.streakBonusXpMultiplier : 1.0;
    return (baseXp * multiplier).round();
  }

  bool checkStreakReward(int newStreak) {
    for (final entry in HabitConfig.streakRewards.entries) {
      if (newStreak == entry.key && !streakRewardsEarned.contains(entry.value)) {
        streakRewardsEarned.add(entry.value);
        return true;
      }
    }
    return false;
  }

  // ── JSON serialization ───────────────────────────────────────────
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'category': category,
        'streak': streak,
        'totalCompleted': totalCompleted,
        'lastCompleted': lastCompleted?.toIso8601String(),
        'isStreakActive': isStreakActive,
        'streakRewardsEarned': streakRewardsEarned.toList(),
      };

  factory Habit.fromJson(Map<String, dynamic> json) {
    final habit = Habit(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      streak: json['streak'] as int? ?? 0,
      totalCompleted: json['totalCompleted'] as int? ?? 0,
      isStreakActive: json['isStreakActive'] as bool? ?? true,
    );
    habit.streakRewardsEarned.addAll(
      (json['streakRewardsEarned'] as List<dynamic>?)
              ?.map((e) => e.toString()) ??
          [],
    );
    if (json['lastCompleted'] != null) {
      habit.lastCompleted = DateTime.tryParse(json['lastCompleted'] as String);
    }
    return habit;
  }
}

/// User Profile Model — tracks overall progress, XP, level, and habits
class UserProfile with ChangeNotifier {
  String _userId;
  String get userId => _userId;

  int _currentStreak;
  int get currentStreak => _currentStreak;

  DateTime? _lastHabitDate;
  DateTime? get lastHabitDate => _lastHabitDate;

  int _totalXp;
  int get totalXp => _totalXp;

  int _currentLevel;
  int get currentLevel => _currentLevel;

  int _levelUpThreshold;
  int get levelUpThreshold => _levelUpThreshold;

  List<Habit> _habits;
  List<Habit> get habits => List.unmodifiable(_habits);

  UserProfile()
      : _userId = 'user_${DateTime.now().millisecondsSinceEpoch}',
        _currentStreak = 0,
        _totalXp = 0,
        _currentLevel = 1,
        _levelUpThreshold = 1000,
        _habits = [];

  /// Named factory for creating a profile with default demo habits
  factory UserProfile.withDefaultHabits() {
    return UserProfile._internal(
      userId: 'user_${DateTime.now().millisecondsSinceEpoch}',
      currentStreak: 0,
      lastHabitDate: null,
      totalXp: 0,
      currentLevel: 1,
      levelUpThreshold: 1000,
      habits: _buildDefaultHabits(),
    );
  }

  UserProfile._internal({
    required String userId,
    required int currentStreak,
    DateTime? lastHabitDate,
    required int totalXp,
    required int currentLevel,
    required int levelUpThreshold,
    required List<Habit> habits,
  })  : _userId = userId,
        _currentStreak = currentStreak,
        _lastHabitDate = lastHabitDate,
        _totalXp = totalXp,
        _currentLevel = currentLevel,
        _levelUpThreshold = levelUpThreshold,
        _habits = habits;

  static List<Habit> _buildDefaultHabits() {
    return [
      Habit(
        id: 'habit_1',
        name: 'Morning Exercise',
        description: 'Do 30 minutes of exercise each morning',
        category: 'Health',
        streak: 5,
        totalCompleted: 42,
        isStreakActive: true,
      ),
      Habit(
        id: 'habit_2',
        name: 'Read for 30 mins',
        description: 'Read books or articles before bed',
        category: 'Learning',
        streak: 12,
        totalCompleted: 89,
        isStreakActive: true,
      ),
      Habit(
        id: 'habit_3',
        name: 'Drink Water',
        description: 'Drink at least 8 glasses of water',
        category: 'Health',
        streak: 21,
        totalCompleted: 156,
        isStreakActive: true,
      ),
      Habit(
        id: 'habit_4',
        name: 'Meditate',
        description: 'Practice mindfulness meditation',
        category: 'Mental',
        streak: 3,
        totalCompleted: 15,
        isStreakActive: true,
      ),
    ];
  }

  // ── JSON serialization ───────────────────────────────────────────
  Map<String, dynamic> toJson() => {
        'userId': _userId,
        'currentStreak': _currentStreak,
        'lastHabitDate': _lastHabitDate?.toIso8601String(),
        'totalXp': _totalXp,
        'currentLevel': _currentLevel,
        'levelUpThreshold': _levelUpThreshold,
        'habits': _habits.map((h) => h.toJson()).toList(),
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final profile = UserProfile()
      .._userId = json['userId'] as String? ?? 'user_default'
      .._currentStreak = json['currentStreak'] as int? ?? 0
      .._totalXp = json['totalXp'] as int? ?? 0
      .._currentLevel = json['currentLevel'] as int? ?? 1
      .._levelUpThreshold = json['levelUpThreshold'] as int? ?? 1000
      .._habits = (json['habits'] as List<dynamic>?)
              ?.map((h) => Habit.fromJson(h as Map<String, dynamic>))
              .toList() ??
          [];
    if (json['lastHabitDate'] != null) {
      profile._lastHabitDate =
          DateTime.tryParse(json['lastHabitDate'] as String);
    }
    return profile;
  }

  // ── Habit operations ─────────────────────────────────────────────
  void addHabit(Habit habit) {
    if (!_habits.any((h) => h.id == habit.id)) {
      _habits.add(habit);
      notifyListeners();
    }
  }

  void removeHabit(String habitId) {
    _habits.removeWhere((h) => h.id == habitId);
    notifyListeners();
  }

  Habit? findHabit(String id) {
    try {
      return _habits.firstWhere((h) => h.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Habit> getHabitsByCategory(String category) {
    return _habits.where((h) => h.category == category).toList();
  }

  bool hasHabit(String id) => _habits.any((h) => h.id == id);

  void checkHabitsDaily() {
    final now = DateTime.now();
    final todayStr = now.toString().substring(0, 10);

    for (final habit in _habits) {
      if (habit.canComplete &&
          (habit.lastCompleted == null ||
              habit.lastCompleted!.toString().substring(0, 10) != todayStr)) {
        if (habit.isStreakActive || habit.lastCompleted == null) {
          habit.lastCompleted = now;
          habit.totalCompleted++;
        }
      }
    }

    final lastDate = _lastHabitDate?.toString().substring(0, 10);
    if (lastDate != todayStr && lastDate != null) {
      _lastHabitDate = now;
    } else if (_currentStreak > 0) {
      _currentStreak = 1;
      _lastHabitDate = now;
    } else {
      _currentStreak = 0;
      _lastHabitDate = now;
    }

    notifyListeners();
  }

  void addXp(int xp) {
    _totalXp += xp;
    while (_totalXp >= _levelUpThreshold && _currentLevel < 100) {
      _totalXp -= _levelUpThreshold;
      _currentLevel++;
      _levelUpThreshold = (_levelUpThreshold * 12 / 5).round();
    }
    notifyListeners();
  }

  Map<String, dynamic> getLevelProgression() {
    final levels = [
      'Novice', 'Initiate', 'Apprentice', 'Contributor',
      'Expert', 'Master', 'Legend'
    ];
    final maxLevels = levels.length;
    final levelIndex = (_currentLevel - 1).clamp(0, maxLevels - 1);
    return {
      'levelName': levels[levelIndex],
      'progress': _totalXp / _levelUpThreshold,
      'nextLevel': _currentLevel + 1,
      'totalLevels': maxLevels,
    };
  }

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
