# 📱 Smart Quiz — Flutter Lab External Exam Project

> A modern, high-contrast Flutter Quiz Application built with a **Neobank/Fintech UI design** (lime-green accents, rounded cards, clean typography). It connects to the **Open Trivia Database REST API**, supports **custom file uploads** (.json and text formats), live **per-question countdown timers**, **high score leaderboards** via local persistence, and an interactive **lab exam viva guide**.

---

## 🌟 Key Features

1. **🌐 Open Trivia REST API Integration:**
   - Fetches dynamic trivia questions from `https://opentdb.com/api.php`.
   - Supports category filtering (Computers, Mathematics, General Knowledge, Science, Gadgets, etc.), difficulty levels (`Easy`, `Medium`, `Hard`, `Any`), and question count (5, 10, 15, 20).
   - Automatically decodes HTML entities (`&quot;`, `&#039;`, `&amp;`).

2. **📁 File Upload & Custom Subject Quizzes:**
   - **Upload Subject File:** Load question sets from `.json` or structured `.txt` files directly into the app.
   - **Preloaded Lab Bundles:** Comes built-in with offline Flutter Lab questions and Computer Science & OS questions.
   - **Custom Parser:** Automatically validates questions and extracts options and correct answers.
   - **Persistence:** Custom uploaded files are stored locally in `SharedPreferences` so they remain accessible offline.

3. **🔍 Subject Auto-Suggestions:**
   - Live autocomplete search field: as you type, it suggests matching subjects from both Open Trivia API categories, bundled lab assets, and imported custom files.

4. **⏱️ Per-Question Countdown Timer:**
   - Selectable timer duration (10s, 15s, 20s, 30s per question).
   - Animated countdown ring that dynamically transitions color:
     - 🟢 Lime Green (> 45% time left)
     - 🟠 Amber Warning (20% – 45% time left)
     - 🔴 Coral Alert (< 20% time left)
   - Auto-advance on timeout with `isTimedOut` tracking.

5. **🏆 Local Leaderboard & High Scores:**
   - Save your score and student name after every quiz.
   - Top 3 Podium (1st 👑, 2nd 🥈, 3rd 🥉) with rankings list, percentage badges, and persistent storage.

6. **📝 Answer Review Mode:**
   - Review all questions with explanations, your choices, and highlighted correct answers.

7. **🎓 In-App Lab Exam Viva Cheat Sheet:**
   - Dedicated tab covering the exact questions external examiners ask (Stateless vs Stateful, initState, setState, async/await, Timer lifecycle, and SQLite/SharedPreferences persistence).

---

## 🎨 UI / UX Design System (Neobank Aesthetic)

Inspired by modern fintech mobile applications:
- **Background:** Off-white / light slate `#F4F6F8`
- **Hero Accent:** Vibrant Lime / Neon Green `#CCF638` with high-contrast `#111418` typography
- **Surfaces:** Pure White `#FFFFFF` with soft drop shadows and 24px rounded corners
- **Navigation:** Floating pill bottom navigation bar with active tab indicators

---

## 🏗️ Project Architecture

```
lib/
├── main.dart                       # App entry point & main navigation shell
├── models/
│   ├── question_model.dart         # Question model & OpenTDB HTML decoder
│   ├── quiz_config.dart            # Quiz configuration (count, timer, subject, source)
│   ├── leaderboard_entry.dart      # Leaderboard score record with percentage
│   └── subject_category.dart       # Subject catalog with API category IDs
├── services/
│   ├── trivia_api_service.dart     # HTTP client for Open Trivia DB + offline fallbacks
│   ├── local_storage_service.dart  # SharedPreferences persistence
│   └── custom_quiz_parser.dart     # Parser for JSON and plain-text Q&A files
├── theme/
│   └── app_theme.dart              # Neobank color palette, typography, and card tokens
├── widgets/
│   ├── neobank_card.dart           # Rounded card (lime, dark, white variants)
│   ├── pill_button.dart            # Rounded pill action buttons
│   ├── timer_badge.dart            # Animated countdown progress badge
│   ├── answer_option_tile.dart     # Multiple-choice option tiles (A, B, C, D)
│   └── custom_bottom_nav.dart      # Floating bottom navigation bar
└── screens/
    ├── home_screen.dart            # Quiz setup, hero card, autocomplete suggestions
    ├── quiz_screen.dart            # Active quiz with timer, progress bar, PopScope
    ├── score_screen.dart           # Score summary, breakdown stats, save to leaderboard
    ├── file_subjects_screen.dart   # File upload, paste questions, preloaded assets
    ├── leaderboard_screen.dart     # Podium & high score rankings
    ├── answer_review_screen.dart   # Question-by-question review
    └── viva_guide_screen.dart      # In-app lab exam viva reference
```

---

## 🚀 How to Run

### 1. Run in Google Chrome (Fastest for testing)
```bash
flutter run -d chrome
```

### 2. Run as Windows Desktop Application
```bash
flutter run -d windows
```

### 3. Run on Connected Android Device / Emulator
```bash
flutter run
```

---

## 📦 Custom Subject File Formats

### JSON Format:
```json
[
  {
    "question": "What is Flutter?",
    "options": ["UI SDK", "Operating System", "Database", "Browser"],
    "correctAnswer": "UI SDK",
    "explanation": "Flutter is Google's open-source UI software development kit."
  }
]
```

### Plain Text Format:
```text
Q: What is the primary language of Flutter?
A: Dart
B: Java
C: Swift
D: Python
Answer: Dart
```

---

## 🎯 Lab Exam Viva Questions & Answers

1. **Q: How does the countdown timer work?**
   - *A:* We use `Timer.periodic(const Duration(seconds: 1))` in `QuizScreen`. Each second, `setState()` updates the UI. If time hits 0, `_onTimeExpired()` advances to the next question. In `dispose()`, we call `_timer?.cancel()` to prevent memory leaks.

2. **Q: How does the app handle offline environments if lab Wi-Fi is down?**
   - *A:* `TriviaApiService` wraps the HTTP request in a try-catch block with a timeout. If the request fails, it automatically falls back to bundled JSON assets (`flutter_lab.json` or `computer_science.json`).

3. **Q: How is data persisted without a dedicated server?**
   - *A:* We utilize `SharedPreferences` to serialize Dart objects to JSON strings using `jsonEncode()`.
