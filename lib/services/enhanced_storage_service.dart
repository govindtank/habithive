import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// EnhancedStorageService adds analytics and statistics tracking
class EnhancedStorageService extends StorageService {
  static final EnhancedStorageService _instance = EnhancedStorageService._internal();
  factory EnhancedStorageService() => _instance;
  EnhancedStorageService._internal();
  
  SharedPreferences? _prefs;
  
  /// Lazily initialize preferences
  Future<SharedPreferences> get _preferences async {
    await init();
    return _prefs!;
  }
  
  // ========================================
  // STATISTICS TRACKING
  // ========================================
  
  /// Get total habits created
  static int getTotalHabitCount() {
    final prefs = StorageService._prefs ?? throw StateError('Not initialized');
    return prefs.getInt(_keyTotalHabitsCreated) ?? 0;
  }
  
  /// Set habit creation counter
  static Future<void> incrementHabitCounter() async {
    final prefs = await _preferences;
    final current = prefs.getInt(_keyTotalHabitsCreated) ?? 0;
    await prefs.setInt(_keyTotalHabitsCreated, current + 1);
  }
  
  /// Get total completions across all habits
  static int getTotalCompletions() {
    final prefs = StorageService._prefs ?? throw StateError('Not initialized');
    return prefs.getInt(_keyTotalCompletions) ?? 0;
  }
  
  /// Increment completion counter
  static Future<void> incrementCompletionCounter() async {
    final prefs = await _preferences;
    final current = prefs.getInt(_keyTotalCompletions) ?? 0;
    await prefs.setInt(_keyTotalCompletions, current + 1);
  }
  
  /// Get completion rate percentage
  static double getCompletionRate() {
    final totalHabs = getTotalHabitCount();
    final totalComps = getTotalCompletions();
    if (totalHabs == 0) return 0.0;
    return (totalComps / (totalHabs * 365.0)) * 100.0; // Assume 3 habits per day avg
  }
  
  // ========================================
  // CATEGORY STATISTICS
  // ========================================
  
  static const String _keyCategoryStats = 'habithive_category_stats';
  
  /// Get completions count for a category
  static int getCategoryCompletions(String category) {
    final prefs = StorageService._prefs ?? throw StateError('Not initialized');
    final stats = jsonDecode(prefs.getString(_keyCategoryStats) ?? '{}') as Map<String, dynamic>;
    
    // Aggregate across habit instances in this category
    final categoryData = stats['$category'] as List<dynamic>? ?? [];
    return (categoryData.where((h) => h['completed'].toString() == 'true').length);
  }
  
  /// Set category statistics from habit data
  static Future<void> setCategoryStats(List<Map<String, dynamic>> habits) async {
    final prefs = await _preferences;
    
    // Aggregate by category
    final categoryCounts = <String, int>{};
    for (final habit in habits) {
      final category = habit['category'] as String?;
      if (category != null && !categoryCounts.containsKey(category)) {
        categoryCounts[category] = 0;
      }
      if (habit['completed'].toString() == 'true') {
        categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
      }
    }
    
    final statsData = <String, dynamic>{};
    for (final entry in categoryCounts.entries) {
      statsData[entry.key] = [
        {'name': entry.key},
        {'total': entry.value}, // total completed this period
        {'recent': 0}          // would track weekly/30-day counts
      ];
    }
    
    await prefs.setString(_keyCategoryStats, jsonEncode(statsData));
  }
  
  // ========================================
  // STREAK HISTORY
  // ========================================
  
  static const String _keyStreakHistory = 'habithive_streak_history';
  
  /// Get streak history as list of (dayNumber, streakLength) tuples
  static List<Map<String, int>> getStreakHistory() {
    final prefs = StorageService._prefs ?? throw StateError('Not initialized');
    try {
      final history = jsonDecode(prefs.getString(_keyStreakHistory) ?? '[]') as List<dynamic>;
      return (history as List).map((e) => {'day': e['day'] as int, 'length': e['length'] as int}).toList();
    } catch (_) {
      return [];
    }
  }
  
  /// Record a streak event
  static Future<void> recordStreakEvent(int dayNumber, int streakLength) async {
    final prefs = await _preferences;
    
    final history = getStreakHistory();
    // Remove existing entry for this day if exists
    history.removeWhere((h) => h['day'] == dayNumber);
    history.add({'day': dayNumber, 'length': streakLength});
    
    await prefs.setString(_keyStreakHistory, jsonEncode(history));
  }
  
  // ========================================
  // BEST STREAK TRACKING
  // ========================================
  
  static int getBestStreak() {
    final prefs = StorageService._prefs ?? throw StateError('Not initialized');
    return prefs.getInt(_keyBestStreak) ?? 0;
  }
  
  /// Update best streak if current is better
  static Future<void> setBestStreak(int streak) async {
    final prefs = await _preferences;
    final current = prefs.getInt(_keyBestStreak) ?? 0;
    if (streak > current) {
      await prefs.setInt(_keyBestStreak, streak);
      print('🏆 New best streak: $streak days!');
    }
  }
  
  // ========================================
  // ACHIEVEMENT TRACKING
  // ========================================
  
  static const String _keyUnlockedAchievements = 'habithive_unlocked_achievements';
  
  /// Get list of unlocked achievement IDs
  static List<String> getUnlockedAchievements() {
    final prefs = StorageService._prefs ?? throw StateError('Not initialized');
    return (prefs.getStringList(_keyUnlockedAchievements) ?? []) as List<String>;
  }
  
  /// Mark achievement as unlocked
  static Future<void> unlockAchievement(String achievementId) async {
    final prefs = await _preferences;
    
    final achievements = getUnlockedAchievements();
    if (!achievements.contains(achievementId)) {
      achievements.add(achievementId);
      await prefs.setStringList(_keyUnlockedAchievements, achievements);
      
      // Also track first unlock timestamp
      final now = DateTime.now().millisecondsSinceEpoch;
      await prefs.setInt('$achievementId_timestamp', now);
      print('🎉 Achievement unlocked: $achievementId');
    }
  }
  
  /// Check if achievement is unlocked
  static bool isAchievementUnlocked(String achievementId) {
    return getUnlockedAchievements().contains(achievementId);
  }
  
  // ========================================
  // WEEKLY ACTIVITY TRACKING
  // ========================================
  
  static const String _keyWeeklyActivity = 'habithive_weekly_activity';
  
  /// Get completions count for current week (Monday-Sunday)
  static int getWeeklyCompletions() {
    final prefs = StorageService._prefs ?? throw StateError('Not initialized');
    
    try {
      final activity = jsonDecode(prefs.getString(_keyWeeklyActivity) ?? '{}') as Map<String, dynamic>;
      
      final now = DateTime.now();
      final startOfWeek = _getMonday(now);
      final currentWeekKey = startOfWeek.millisecondsSinceEpoch.toString();
      
      return (activity['completions']?['$currentWeekKey'] as int?) ?? 0;
    } catch (_) {
      return 0;
    }
  }
  
  /// Add completion to weekly tracking
  static Future<void> addWeeklyCompletion() async {
    final prefs = await _preferences;
    
    try {
      final activity = jsonDecode(prefs.getString(_keyWeeklyActivity) ?? '{}') as Map<String, dynamic>;
      
      final now = DateTime.now();
      final startOfWeek = _getMonday(now);
      final currentWeekKey = startOfWeek.millisecondsSinceEpoch.toString();
      
      if (!activity.containsKey('completions')) {
        activity['completions'] = {};
      }
      if (!activity['completions'].containsKey(currentWeekKey)) {
        activity['completions'][currentWeekKey] = 0;
      }
      
      activity['completions'][currentWeekKey] = (activity['completions'][currentWeekKey] as int) + 1;
      
      await prefs.setString(_keyWeeklyActivity, jsonEncode(activity));
    } catch (_) {
      // Continue on error
    }
  }
  
  DateTime _getMonday(DateTime date) {
    final days = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    final year = date.year;
    final month = date.month;
    final day = date.day;
    final dow = date.weekday; // 1=Sunday, 7=Saturday
    
    if (dow == 1) return date; // Sunday is start of week
    
    int daysUntilMonday = dow - 1;
    if (month > 2 && date.year % 4 == 0) {
      days[2] = 29;
    } else {
      days[2] = 28;
    }
    
    final currentYearDays = day + _daysBeforeYear(year);
    final prevYearDays = day + _daysBeforeYear(year - 1) + days[month - 1];
    
    if (dow > 4 && month == 12) {
      return DateTime(year - 1, 12, 30 - daysUntilMonday);
    } else if (dow <= 4 && month == 1) {
      return DateTime(year - 1, 12, 31 - daysUntilMonday);
    } else if (month > 2) {
      final prevMonthDays = _daysBeforeYear(year - 1) + _daysBeforeYear(year) + 
                            days[month - 1] - day;
      return DateTime(year, month - 1, days[month - 1]); // Previous month's last day
    } else {
      return DateTime(year, 12, 31);
    }
  }
  
  int _daysBeforeYear(int year) {
    int count = 0;
    for (int i = 1970; i < year; i++) {
      if ((i % 4 == 0 && i % 100 != 0) || (i % 400 == 0)) {
        count += 366;
      } else {
        count += 365;
      }
    }
    return count;
  }
  
  // ========================================
  // STREAK DROPPING TRACKING
  // ========================================
  
  static const String _keyStreakDrops = 'habithive_streak_drops';
  
  /// Get streak drop history
  static List<Map<String, dynamic>> getStreakDropHistory() {
    final prefs = StorageService._prefs ?? throw StateError('Not initialized');
    try {
      final drops = jsonDecode(prefs.getString(_keyStreakDrops) ?? '[]') as List<dynamic>;
      return (drops as List).map((e) => {
        'day': e['day'] as int,
        'previousStreak': e['previous'] as int,
        'droppedTo': e['droppedTo'] as int
      }).toList();
    } catch (_) {
      return [];
    }
  }
  
  /// Record a streak drop event
  static Future<void> recordStreakDrop(int dayNumber, int previousStreak, int droppedTo) async {
    final prefs = await _preferences;
    
    final drops = getStreakDropHistory();
    if (drops.isEmpty || drops.last['day'] < dayNumber) {
      drops.add({'day': dayNumber, 'previousStreak': previousStreak, 'droppedTo': droppedTo});
      await prefs.setString(_keyStreakDrops, jsonEncode(drops));
    }
  }
  
  // ========================================
  // DATA EXPORT/CLEAR
  // ========================================
  
  /// Get all analytics data as JSON
  static Map<String, dynamic> getAnalyticsSummary() {
    final summary = <String, dynamic>{
      'totalHabitCreations': getTotalHabitCount(),
      'totalCompletions': getTotalCompletions(),
      'completionRate': getCompletionRate().toStringAsFixed(1),
      'bestStreak': getBestStreak(),
      'unlockedAchievements': getUnlockedAchievements(),
    };
    
    // Add category stats if available
    try {
      final activity = jsonDecode(prefs?.getString(_keyWeeklyActivity) ?? '{}') as Map<String, dynamic>;
      final currentWeekKey = DateTime.now().millisecondsSinceEpoch.toString();
      if (activity.containsKey('completions') && 
          activity['completions'].containsKey(currentWeekKey)) {
        summary['weeklyCompletions'] = activity['completions'][currentWeekKey];
      }
    } catch (_) {}
    
    return summary;
  }
  
  /// Clear all analytics (preserves habits)
  static Future<void> clearAnalytics() async {
    final prefs = await _preferences;
    await prefs.remove(_keyStreakHistory);
    await prefs.remove(_keyBestStreak);
    await prefs.remove(_keyUnlockedAchievements);
    await prefs.remove(_keyStreakDrops);
    print('🗑️ Analytics cleared (habits preserved)');
  }
}
