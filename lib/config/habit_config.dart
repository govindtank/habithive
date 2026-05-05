/// Configuration constants for habit tracking and gamification
class HabitConfig {
  // XP system
  static const int dailyXp = 10;
  static const double streakBonusXpMultiplier = 1.5;
  
  // Streak rewards (streak days -> reward name)
  static const Map<int, String> streakRewards = {
    3: 'Bronze Streak',
    7: 'Silver Streak',
    14: 'Gold Streak',
    30: 'Platinum Streak',
    60: 'Diamond Streak',
    100: 'Legendary Streak',
    365: 'Eternal Streak',
  };
  
  // Habit categories
  static const List<String> categories = [
    'Health',
    'Productivity',
    'Mental',
    'Social',
    'Learning',
  ];
  
  // Category colors
  static const Map<String, int> categoryColors = {
    'Health': 0xFF4CAF50,
    'Productivity': 0xFF2196F3,
    'Mental': 0xFF9C27B0,
    'Social': 0xFFFF9800,
    'Learning': 0xFFF44336,
  };
}
