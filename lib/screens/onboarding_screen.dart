import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';
import '../services/storage_service.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'title': 'Welcome to HabitHive',
      'description':
          'Build better habits and achieve your goals with our gamified tracking system.',
      'image': '🎯',
    },
    {
      'title': 'Track Your Progress',
      'description':
          'Monitor your daily habits and watch your streaks grow stronger each day.',
      'image': '📊',
    },
    {
      'title': 'Earn Rewards',
      'description':
          'Complete habits to earn XP, level up, and unlock amazing achievements.',
      'image': '🏆',
    },
  ];

  void _completeOnboarding() async {
    await StorageService.setOnboardingComplete(true);
    Provider.of<HabitHiveProvider>(context, listen: false)
        .initializeDemoHabits();
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isWide = MediaQuery.of(context).size.width > 600;

    // Colors chosen for WCAG AA contrast in both modes
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF8F8F8);
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final titleColor = isDark ? const Color(0xFFE8E8E8) : const Color(0xFF1A1A1A);
    final subtitleColor = isDark ? const Color(0xFFBBBBBB) : const Color(0xFF444444);
    final dotActive = theme.colorScheme.primary;
    final dotInactive = isDark ? const Color(0xFF444444) : const Color(0xFFCCCCCC);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar: Theme toggle ───────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    isDark ? Icons.dark_mode : Icons.light_mode,
                    size: 20,
                    color: subtitleColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isDark ? 'Dark' : 'Light',
                    style: TextStyle(
                      fontSize: 14,
                      color: subtitleColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Switch(
                    value: isDark,
                    onChanged: (val) async {
                      await StorageService.setDarkMode(val);
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),

            // ── Page content ──────────────────────────────────────
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: isWide ? 600 : double.infinity),
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.all(isWide ? 40.0 : 24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _pages[index]['image']!,
                              style: TextStyle(fontSize: isWide ? 140 : 100),
                            ),
                            SizedBox(height: isWide ? 48 : 36),
                            Text(
                              _pages[index]['title']!,
                              style: TextStyle(
                                fontSize: isWide ? 36 : 28,
                                fontWeight: FontWeight.bold,
                                color: titleColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              _pages[index]['description']!,
                              style: TextStyle(
                                fontSize: isWide ? 18 : 16,
                                color: subtitleColor,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // ── Bottom controls ───────────────────────────────────
            Container(
              color: cardBg,
              padding: EdgeInsets.all(isWide ? 32.0 : 24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  children: [
                    // Page indicator dots — now high-contrast
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _pages.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 10,
                          width: _currentPage == index ? 32 : 10,
                          decoration: BoxDecoration(
                            color: _currentPage == index ? dotActive : dotInactive,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Primary CTA button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_currentPage == _pages.length - 1) {
                            _completeOnboarding();
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            _currentPage == _pages.length - 1
                                ? 'Get Started 🚀'
                                : 'Next',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Skip button
                    if (_currentPage == 0)
                      TextButton(
                        onPressed: () {
                          // Skip directly to last page to show "Get Started"
                          _pageController.animateToPage(
                            _pages.length - 1,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: Text(
                          'Skip intro',
                          style: TextStyle(
                            color: subtitleColor,
                            fontSize: 14,
                          ),
                        ),
                      )
                    else if (_currentPage > 0)
                      TextButton(
                        onPressed: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: Text(
                          'Back',
                          style: TextStyle(
                            color: subtitleColor,
                            fontSize: 14,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
