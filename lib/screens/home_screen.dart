import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';
import '../models/habit_model.dart';
import '../config/habit_config.dart';
import '../services/storage_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _toggleDarkMode(BuildContext context) async {
    final current = StorageService.isDarkMode;
    await StorageService.setDarkMode(!current);
    // Force rebuild to apply new theme
    if (context.mounted) {
      (context as Element).markNeedsBuild();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🏠', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            const Text('HabitHive'),
          ],
        ),
        actions: [
          // Theme toggle button
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              size: 22,
            ),
            tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            onPressed: () => _toggleDarkMode(context),
          ),
          // Level badge
          Consumer<HabitHiveProvider>(
            builder: (context, provider, child) {
              final profile = provider.profile;
              final levelProgress = profile.getLevelProgression();
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: _buildLevelBadge(context, profile.currentLevel, levelProgress['levelName']),
              );
            },
          ),
        ],
      ),
      body: Consumer<HabitHiveProvider>(
        builder: (context, provider, child) {
          final profile = provider.profile;
          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 700;
              final maxWidth = isWide ? 800.0 : double.infinity;
              return SingleChildScrollView(
                padding: EdgeInsets.all(isWide ? 24.0 : 16.0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProgressCard(context, profile),
                        const SizedBox(height: 20),
                        _buildStatsRow(context, profile),
                        const SizedBox(height: 24),
                        Text(
                          'Your Habits',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        if (profile.habits.isEmpty)
                          _buildEmptyState(context)
                        else
                          ...profile.habits.map((habit) => _buildHabitCard(context, habit, provider)),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLevelBadge(BuildContext context, int level, String? levelName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.emoji_events, color: Colors.amber, size: 16),
          const SizedBox(width: 6),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Lv.$level',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (levelName != null)
                Text(
                  levelName,
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context, UserProfile profile) {
    final completionRate = profile.getCompletionRate();
    final completedCount = profile.habits.where((h) {
      final last = h.lastCompleted;
      if (last == null) return false;
      final now = DateTime.now();
      return last.year == now.year && last.month == now.month && last.day == now.day;
    }).length;
    final isAllDone = completedCount == profile.habits.length && profile.habits.isNotEmpty;
    final progressColor = isAllDone ? const Color(0xFF7ED957) : Theme.of(context).colorScheme.primary;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Card(
      elevation: 4,
      shadowColor: progressColor.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: cardBg,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              progressColor.withOpacity(isDark ? 0.15 : 0.05),
              cardBg,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (isAllDone) ...[
                      const Text('🎉', style: TextStyle(fontSize: 22)),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      isAllDone ? 'All Done Today!' : "Today's Progress",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: progressColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${(completionRate * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: progressColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: completionRate,
                backgroundColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '$completedCount of ${profile.habits.length} habits completed',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, UserProfile profile) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.local_fire_department,
            iconColor: Colors.orange,
            value: '${profile.currentStreak}',
            label: 'Day Streak',
            emoji: '🔥',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.star,
            iconColor: Colors.amber,
            value: '${profile.totalXp}',
            label: 'Total XP',
            emoji: '⭐',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.trending_up,
            iconColor: const Color(0xFF7ED957),
            value: '${profile.currentLevel}',
            label: 'Level',
            emoji: '🏆',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    required String emoji,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Card(
      elevation: 2,
      shadowColor: iconColor.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: cardBg,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark ? const Color(0xFF888888) : Colors.grey.shade600,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Card(
      elevation: 2,
      shadowColor: Colors.grey.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: cardBg,
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: [
            const Text('🌱', style: TextStyle(fontSize: 72)),
            const SizedBox(height: 20),
            Text(
              'No habits yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start building better habits today!',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Add Your First Habit'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitCard(BuildContext context, Habit habit, HabitHiveProvider provider) {
    final now = DateTime.now();
    final isCompletedToday = habit.lastCompleted != null &&
        habit.lastCompleted!.year == now.year &&
        habit.lastCompleted!.month == now.month &&
        habit.lastCompleted!.day == now.day;

    final categoryColor = Color(HabitConfig.categoryColors[habit.category] ?? 0xFF9E9E9E);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? const Color(0xFFE8E8E8) : const Color(0xFF1A1A1A);
    final subtextColor = isDark ? const Color(0xFF999999) : const Color(0xFF666666);

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      color: cardBg,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Category Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: categoryColor.withOpacity(isDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getCategoryIcon(habit.category),
                color: categoryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),

            // Habit Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    habit.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: subtextColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.local_fire_department, size: 16, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text(
                        '${habit.streak} day streak',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.check_circle, size: 16, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(
                        '${habit.totalCompleted} completed',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Complete Button
            IconButton(
              onPressed: isCompletedToday || !habit.canComplete
                  ? null
                  : () => provider.completeHabit(habit.id),
              icon: Icon(
                isCompletedToday ? Icons.check_circle : Icons.circle_outlined,
                color: isCompletedToday ? Colors.green : (isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                size: 32,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Health':     return Icons.favorite;
      case 'Productivity': return Icons.work;
      case 'Mental':     return Icons.psychology;
      case 'Social':     return Icons.people;
      case 'Learning':   return Icons.school;
      default:           return Icons.category;
    }
  }
}
