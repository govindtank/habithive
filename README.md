# HabitHive - Gamified Habit Tracker

## Overview
HabitHive transforms habit building into an exciting game with streaks, challenges, and rewarding achievements. Build better habits while having fun!

## Features
- 🎯 Streak tracking with visual counters
- 🏆 Challenge modes for extra motivation
- 🌟 Achievement system with rewards
- 📊 Progress visualization and analytics
- 👥 Optional social features (future)
- 🎨 Engaging, game-like interface
- 🔔 Reminder notifications

## How It Works
1. **Set Your Habits**: Define what you want to build
2. **Complete Daily Tasks**: Check off habits each day
3. **Earn Rewards**: Build streaks and unlock achievements
4. **Compete or Collaborate**: Take on challenges with friends (coming soon)

## Getting Started

### Prerequisites
- [Flutter](https://flutter.dev) SDK >= 3.5.0
- [Dart](https://dart.dev) SDK >= 3.5.0
- LocalNotifications package configured

### Installation
```bash
git clone https://github.com/govind/habithive.git
cd habithive
flutter pub get
flutter run
```

### Development
```bash
# Run on device or emulator
flutter run -d <device_id>

# Debug mode with notifications enabled
flutter run --debug

# Hot reload for quick iteration
flutter run
```

## Project Structure
```
habithive/
├── lib/
│   ├── main.dart             # App entry point
│   ├── models/               # Data models
│   │   └── habit.dart        # Habit data model
│   ├── screens/              # UI screens
│   │   ├── home_screen.dart  # Main dashboard
│   │   ├── add_habit.dart    # Create new habits
│   │   └── achievements.dart # Achievement list
│   ├── services/             # Business logic
│   │   ├── streak_service.dart
│   │   └── notification_service.dart
│   └── widgets/              # Reusable UI components
├── pubspec.yaml             # Dependencies and metadata
├── analysis_options.yaml    # Linting rules
└── README.md               # This file
```

## Key Metrics Tracked
- Daily completion rate
- Streak length
- Achievements unlocked
- Personal bests
- Consistency score

## Notification Setup
Configure reminders in settings to never miss a habit check-in:
```
Settings → Notifications → Enable Reminders
```

## Gamification Elements
- XP points for each completed habit
- Badge unlocks at milestone achievements
- Color-coded progress bars
- Celebratory animations for big wins

## Contributing
Pull requests are welcome! Please open an issue first to discuss major changes.

## License
MIT License - See LICENSE file for details.
