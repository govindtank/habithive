// HabitHive App Configuration - Gamified Habit Tracker
// Theme: Energetic and motivating colors

class HabitColors {
  // Primary palette - energetic greens and oranges
  static const Color primaryOrange = Color(0xFFFF6B35);
  static const Color deepOrange = Color(0xFFE94E1D);
  static const Color brightGreen = Color(0xFF7ED957);
  static const Color forestGreen = Color(0xFF2D8A4E);
  
  // Accent colors for different habit types
  static const Color healthBlue = Color(0xFF4FC3F7);
  static const Color productivYellow = Color(0xFFFFEA00);
  static const Color mentalPurple = Color(0xFF9C27B0);
  static const Color socialPink = Color(0xFFFF80AB);
  
  // Neutral tones
  static const Color softGray = Color(0xFFF5F5F5);
  static const Color mediumGray = Color(0xFF7A7A7A);
  static const Color darkGray = Color(0xFF333333);
  
  // Success and feedback colors
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color errorRed = Color(0xFFF44336);
}

class HabitConfig {
  // Streak reward milestones (XP points)
  static const Map<int, String> streakRewards = {
    3: 'Early Bird',           // Started tracking for 3 days
    7: 'Week Warrior',         // 1 week consistency
    14: 'Halfway Hero',        // Half a month
    21: 'Habit Builder',       // Classic habit formation time
    30: 'Streak Master',       // Full month!
    60: 'Dedicated',           // 2 months
    90: 'Unstoppable',         // 3 months - elite level
    180: 'Lifelong Habit',     // Half a year - legendary
  };
  
  // Daily XP rewards for completing habits
  static const int dailyXp = 50;
  static const int streakBonusXpMultiplier = 1.5;
  
  // Streak fire animation threshold
  static const int fireIntensityStreak = 7; // Show fire effect at this streak
  
  // Challenge settings
  static const String weeklyChallengeDay = 'Saturday';
  static const List<String> challengeCategories = [
    'Health', 'Productivity', 'Mental', 'Social', 'Learning'
  ];
  
  // Reward points per completed habit type
  static const Map<String, int> categoryPoints = {
    'Health': 10,   // Exercise, healthy eating, hydration
    'Productivity': 8,  // Deep work, reading, organization
    'Mental': 7,        // Meditation, journaling, learning
    'Social': 6,        // Calling loved ones, meeting friends
    'Learning': 9,      // Courses, new skills, research
  };
}

class HabitStrings {
  // Onboarding
  static const String welcomeTitle = 'Welcome to HabitHive';
  static const String welcomeSubtitle = 'Build lasting habits through fun and rewards!';
  
  // Main actions
  static const String addHabit = '+ Add Habit';
  static const String completeHabit = 'Complete Today\'s Habits';
  static const String streakFire = '🔥 Fire Streak 🔥';
  
  // Categories
  static const List<String> categories = [
    {'name': 'Health', 'icon': Icons.favorite},
    {'name': 'Productivity', 'icon': Icons.work'},
    {'name': 'Mental', 'icon': Icons.self_improvement},
    {'name': 'Social', 'icon': Icons.people},
    {'name': 'Learning', 'icon': Icons.school},
  ];
  
  // Rewards
  static const String earnedBadge = '🏆 Badge Earned';
  static const String streakBonus = 'Streak Bonus!';
}
