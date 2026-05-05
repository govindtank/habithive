# 🏠 HabitHive — Gamified Habit Tracker

![Flutter](https://img.shields.io/badge/Flutter-3.24.0-02569B?style=flat-square&logo=flutter)
![Web](https://img.shields.io/badge/Platform-Web-4285F4?style=flat-square&logo=google-chrome&logoColor=white)
![Material](https://img.shields.io/badge/Material%20Design-3-757DE8?style=flat-square&logo=material-design)
![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)
![Dart](https://img.shields.io/badge/Dart-3.5.0-0175C2?style=flat-square&logo=dart)

> **Live Demo**: [https://govindtank.github.io/habithive/](https://govindtank.github.io/habithive/)

HabitHive transforms habit building into an exciting game with streaks, challenges, and rewarding achievements. Built with Flutter and powered by Material Design 3.

## ✨ Features

- 🎯 **Daily Habit Tracking** — Track multiple habits with visual completion states
- 🔥 **Streak System** — Build consecutive day streaks with streak bonuses
- ⭐ **XP & Leveling** — Earn XP for completing habits, level up as you progress
- 🏆 **Gamification** — Milestone badges (Bronze, Silver, Gold, Platinum, Diamond)
- 📊 **Progress Dashboard** — Real-time daily completion rate and stats
- 🎨 **Material Design 3** — Modern orange/green energetic theme
- 📱 **Responsive Web** — Optimized for desktop, tablet, and mobile browsers

## 🚀 Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.24.0 |
| Language | Dart 3.5 |
| State Management | Provider |
| Design System | Material Design 3 |
| Platform | Web (Flutter Web) |
| CI/CD | GitHub Actions |
| Hosting | GitHub Pages |

## 📁 Project Structure

```
habit-hive/
├── lib/
│   ├── main.dart                    # App entry point & theme
│   ├── config/
│   │   ├── app_config.dart          # App-wide configuration
│   │   └── habit_config.dart        # Habit tracking constants
│   ├── models/
│   │   └── habit_model.dart         # Habit & UserProfile models
│   ├── providers/
│   │   └── habit_provider.dart      # State management with Provider
│   └── screens/
│       ├── home_screen.dart         # Main dashboard
│       └── onboarding_screen.dart   # Onboarding flow
├── web/
│   └── index.html                    # Web entry point
├── .github/
│   └── workflows/
│       └── deploy.yml               # GitHub Actions CI/CD
├── pubspec.yaml                     # Dependencies & metadata
└── README.md                        # This file
```

## 🛠️ Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev) >= 3.24.0
- [Dart SDK](https://dart.dev) >= 3.5.0

### Local Development

```bash
# Clone the repository
git clone https://github.com/govindtank/habithive.git
cd habithive

# Install dependencies
flutter pub get

# Run on web (Chrome)
flutter run -d chrome

# Build for web production
flutter build web --release --base-href /habithive/
```

## 🎮 Gamification System

| Feature | Details |
|---------|---------|
| **Base XP** | 10 XP per habit completion |
| **Streak Bonus** | 1.5x multiplier when streak is active |
| **Levels** | Novice → Initiate → Apprentice → Contributor → Expert → Master → Legend |
| **Streak Badges** | Bronze (3d), Silver (7d), Gold (14d), Platinum (30d), Diamond (60d), Legendary (100d), Eternal (365d) |

## 🌐 Browser Support

HabitHive Web works on all modern browsers:
- ✅ Chrome / Edge (recommended)
- ✅ Firefox
- ✅ Safari

## 📜 License

MIT License — see [LICENSE](LICENSE) for details.

---

Built with ❤️ using Flutter | Deployed on GitHub Pages
