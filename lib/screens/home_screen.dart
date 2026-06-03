import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/habit_provider.dart';
import '../models/habit_model.dart';
import '../config/habit_config.dart';
import '../services/storage_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5),
      appBar: _buildAppBar(context, isDark),
      body: Consumer<HabitHiveProvider>(
        builder: (context, provider, _) {
          final profile = provider.profile;
          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 700;
              final mw = isWide ? 800.0 : double.infinity;
              return SingleChildScrollView(
                padding: EdgeInsets.all(isWide ? 24 : 16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: mw),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProgressCard(context, profile),
                        const SizedBox(height: 20),
                        if (profile.habits.isNotEmpty) _buildWeekChart(context, provider),
                        if (profile.habits.isNotEmpty) const SizedBox(height: 24),
                        _buildSectionHeader(context, 'Your Habits', profile.habits.length),
                        const SizedBox(height: 16),
                        if (profile.habits.isEmpty)
                          _buildEmptyState(context)
                        else
                          ...profile.habits.map((h) => _buildHabitCard(context, h, provider)),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showHabitForm(context, null),
        backgroundColor: const Color(0xFFFF6B35),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Habit', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDark) {
    return AppBar(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFF6B35),
      foregroundColor: Colors.white,
      elevation: 0,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.auto_awesome, size: 18, color: Color(0xFFFFD700)),
          ),
          const SizedBox(width: 10),
          const Text('Habit Hive', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
        ],
      ),
      actions: [
        Consumer<HabitHiveProvider>(
          builder: (context, provider, _) {
            final lv = provider.profile.currentLevel;
            final prog = provider.profile.getLevelProgression()['levelName'] ?? '';
            return Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.emoji_events, size: 14, color: Color(0xFFFFD700)),
                    const SizedBox(width: 4),
                    Text('Lv.$lv', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    Text(' $prog', style: TextStyle(fontSize: 9, color: Colors.white.withOpacity(0.7))),
                  ],
                ),
              ),
            );
          },
        ),
        IconButton(
          icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode, size: 20),
          onPressed: () async {
            await StorageService.setDarkMode(!isDark);
            if (context.mounted) (context as Element).markNeedsBuild();
          },
        ),
      ],
    );
  }

  // ── Progress Card ────────────────────────────────────────────────

  Widget _buildProgressCard(BuildContext context, UserProfile profile) {
    final done = completedTodayCount(profile);
    final total = profile.habits.length;
    final rate = total > 0 ? done / total : 0.0;
    final allDone = total > 0 && done == total;
    final color = allDone ? const Color(0xFF7ED957) : const Color(0xFFFF6B35);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            color.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.15 : 0.08),
            (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (allDone) ...[
                    const Text('🎉', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    allDone ? 'All Done!' : "Today's Progress",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFFE8E8E8) : const Color(0xFF1A1A1A)),
                  ),
                ],
              ),
              Text('${(rate * 100).toInt()}%',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: rate,
              backgroundColor: (Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF2A2A2A) : Colors.grey.shade200),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text('$done of $total habits completed',
                  style: TextStyle(fontSize: 13, color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF999999) : const Color(0xFF666666))),
              const Spacer(),
              Row(
                children: [
                  const Icon(Icons.local_fire_department, size: 14, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text('${profile.currentStreak} day streak',
                      style: const TextStyle(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  int completedTodayCount(UserProfile profile) {
    final now = DateTime.now();
    return profile.habits.where((h) =>
        h.lastCompleted != null &&
        h.lastCompleted!.year == now.year &&
        h.lastCompleted!.month == now.month &&
        h.lastCompleted!.day == now.day).length;
  }

  // ── Weekly Chart ─────────────────────────────────────────────────

  Widget _buildWeekChart(BuildContext context, HabitHiveProvider provider) {
    final week = provider.weekHistory;
    final maxVal = week.reduce((a, b) => a > b ? a : b).toDouble();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final today = DateTime.now().weekday % 7; // Sunday=0

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.06), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, size: 18, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text('Weekly Progress',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFFE8E8E8) : const Color(0xFF1A1A1A))),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 140,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxVal < 1 ? 1 : (maxVal * 1.3),
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      getTitlesWidget: (val, _) => Text('${val.toInt()}',
                          style: TextStyle(fontSize: 10, color: isDark ? Colors.white38 : Colors.black26)),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, _) {
                        final i = val.toInt();
                        if (i < 0 || i >= 7) return const SizedBox.shrink();
                        final isToday = i == today;
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(labels[i].substring(0, 3),
                              style: TextStyle(
                                fontSize: 10,
                                color: isToday ? const Color(0xFFFF6B35) : (isDark ? Colors.white38 : Colors.black38),
                                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                              )),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxVal < 1 ? 0.5 : 1,
                  getDrawingHorizontalLine: (val) => FlLine(
                    color: isDark ? Colors.white10 : Colors.black12,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(7, (i) {
                  final isToday = i == today;
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: week[i].toDouble(),
                        color: isToday
                            ? const Color(0xFFFF6B35)
                            : (isDark ? const Color(0xFF00BCD4) : const Color(0xFF00ACC1)),
                        width: isToday ? 18 : 14,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxVal < 1 ? 1 : (maxVal * 1.3),
                          color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Section Header ───────────────────────────────────────────────

  Widget _buildSectionHeader(BuildContext context, String title, int count) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600,
            color: isDark ? const Color(0xFFE8E8E8) : const Color(0xFF1A1A1A))),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text('$count', style: TextStyle(fontSize: 12,
              color: isDark ? Colors.white60 : Colors.black54)),
        ),
      ],
    );
  }

  // ── Empty State ──────────────────────────────────────────────────

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: (Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1E1E1E) : Colors.white),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text('🌱', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text('No habits yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFFE8E8E8) : const Color(0xFF1A1A1A))),
          const SizedBox(height: 8),
          Text('Start building better habits today!',
              style: TextStyle(fontSize: 14,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF999999) : const Color(0xFF666666))),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showHabitForm(context, null),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Your First Habit'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Habit Card ───────────────────────────────────────────────────

  Widget _buildHabitCard(BuildContext context, Habit habit, HabitHiveProvider provider) {
    final now = DateTime.now();
    final done = habit.lastCompleted != null &&
        habit.lastCompleted!.year == now.year &&
        habit.lastCompleted!.month == now.month &&
        habit.lastCompleted!.day == now.day;
    final catColor = Color(HabitConfig.categoryColors[habit.category] ?? 0xFF9E9E9E);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Dismissible(
      key: ValueKey('habit_${habit.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFF1744),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      confirmDismiss: (_) => showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          title: Text('Delete "${habit.name}"?',
              style: TextStyle(color: isDark ? const Color(0xFFE8E8E8) : const Color(0xFF1A1A1A))),
          content: const Text('This cannot be undone.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Delete', style: TextStyle(color: Color(0xFFFF1744)))),
          ],
        ),
      ).then((v) => v ?? false),
      onDismissed: (_) => provider.deleteHabit(habit.id),
      child: GestureDetector(
        onTap: () => _showHabitForm(context, habit),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: done
                  ? const Color(0xFF7ED957).withOpacity(0.4)
                  : Colors.transparent,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Category icon
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: done
                        ? const Color(0xFF7ED957).withOpacity(0.15)
                        : catColor.withOpacity(isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getCategoryIcon(habit.category),
                    color: done ? const Color(0xFF7ED957) : catColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(habit.name,
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
                              color: isDark ? const Color(0xFFE8E8E8) : const Color(0xFF1A1A1A))),
                      const SizedBox(height: 2),
                      if (habit.description.isNotEmpty)
                        Text(habit.description,
                            style: TextStyle(fontSize: 12,
                                color: isDark ? const Color(0xFF999999) : const Color(0xFF666666)),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.local_fire_department, size: 12, color: Colors.orange.withOpacity(0.8)),
                          const SizedBox(width: 3),
                          Text('${habit.streak}', style: const TextStyle(fontSize: 11, color: Colors.orange, fontWeight: FontWeight.w600)),
                          const SizedBox(width: 12),
                          Icon(Icons.check_circle, size: 12, color: Colors.green.withOpacity(0.7)),
                          const SizedBox(width: 3),
                          Text('${habit.totalCompleted}', style: const TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ],
                  ),
                ),

                // Complete button
                GestureDetector(
                  onTap: done
                      ? null
                      : () {
                          provider.completeHabit(habit.id);
                          _showCompletionEffect(context);
                        },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: done
                          ? const Color(0xFF7ED957)
                          : (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF0F0F0)),
                    ),
                    child: Icon(
                      done ? Icons.check : Icons.circle_outlined,
                      color: done ? Colors.white : (isDark ? Colors.white38 : Colors.black26),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCompletionEffect(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Habit completed! +10 XP', style: TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
        backgroundColor: const Color(0xFF7ED957),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // ── Habit Form Dialog ────────────────────────────────────────────

  void _showHabitForm(BuildContext context, Habit? existing) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    String category = existing?.category ?? 'Health';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = existing != null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                    child: Text(
                      isEditing ? 'Edit Habit' : 'Add New Habit',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFFE8E8E8) : const Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                    child: TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Habit name',
                        hintText: 'e.g. Morning Exercise',
                        prefixIcon: Icon(Icons.auto_awesome, size: 20),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                    child: TextField(
                      controller: descCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Description (optional)',
                        hintText: 'e.g. 30 min workout',
                        prefixIcon: Icon(Icons.description_outlined, size: 20),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                    child: DropdownButtonFormField<String>(
                      value: category,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        prefixIcon: Icon(Icons.category_outlined, size: 20),
                      ),
                      items: HabitConfig.categories.map((c) {
                        final cc = Color(HabitConfig.categoryColors[c] ?? 0xFF9E9E9E);
                        return DropdownMenuItem(
                          value: c,
                          child: Row(
                            children: [
                              Container(
                                width: 10, height: 10,
                                decoration: BoxDecoration(color: cc, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 8),
                              Text(c),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) setSheetState(() => category = v);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              side: BorderSide(color: isDark ? Colors.white24 : Colors.black12),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () {
                              final name = nameCtrl.text.trim();
                              if (name.isEmpty) return;
                              if (isEditing) {
                                context.read<HabitHiveProvider>().updateHabit(
                                  existing!.id, name, descCtrl.text.trim(), category);
                              } else {
                                context.read<HabitHiveProvider>().addHabit(
                                  name, descCtrl.text.trim(), category);
                              }
                              Navigator.pop(ctx);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF6B35),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(isEditing ? 'Save Changes' : 'Add Habit'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Health':       return Icons.favorite;
      case 'Productivity': return Icons.work;
      case 'Mental':       return Icons.psychology;
      case 'Social':       return Icons.people;
      case 'Learning':     return Icons.school;
      default:             return Icons.category;
    }
  }
}
