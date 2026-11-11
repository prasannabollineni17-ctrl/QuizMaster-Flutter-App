# 📱 Smart Quiz — Flutter Quiz Application

> A modern, high-contrast Flutter Quiz Application built with a **Neobank/Fintech UI design** (lime-green accents, rounded cards, clean typography). It connects to the **Open Trivia Database REST API**, supports **custom subject file uploads** (.json and text formats), live **per-question countdown timers**, and question review.

---

## 🌟 Key Features

1. **🌐 Open Trivia REST API Integration:**
   - Fetches dynamic trivia questions from `https://opentdb.com/api.php`.
   - Supports category filtering (Computers, Mathematics, General Knowledge, Science, Gadgets, etc.), difficulty levels (`Easy`, `Medium`, `Hard`, `Any`), and question count (5, 10, 15, 20).
   - Automatically decodes HTML entities (`&quot;`, `&#039;`, `&amp;`).

2. **📁 File Upload & Custom Subject Quizzes:**
   - **Upload Subject File:** Load question sets from `.json` or structured `.txt` files directly into the app.
   - **Preloaded Bundles:** Comes built-in with offline Flutter and Computer Science questions.
   - **Custom Parser:** Automatically validates questions and extracts options and correct answers.
   - **Persistence:** Custom uploaded files are stored locally in `SharedPreferences` so they remain accessible offline.

3. **🔍 Subject Auto-Suggestions:**
   - Live autocomplete search field: as you type, it suggests matching subjects from both Open Trivia API categories, bundled assets, and imported custom files.

4. **⏱️ Per-Question Countdown Timer:**
   - Selectable timer duration (10s, 15s, 20s, 30s per question).
   - Animated countdown ring that dynamically transitions color:
     - 🟢 Lime Green (> 45% time left)
     - 🟠 Amber Warning (20% – 45% time left)
     - 🔴 Coral Alert (< 20% time left)
   - Auto-advance on timeout with `isTimedOut` tracking.

5. **📝 Answer Review Mode:**
   - Review all questions with explanations, your choices, and highlighted correct answers.

---

## 🎨 UI / UX Design System (Neobank Aesthetic)

Inspired by modern fintech mobile applications:
- **Background:** Off-white / light slate `#F4F6F8`
- **Hero Accent:** Vibrant Lime / Neon Green `#CCF638` with high-contrast `#111418` typography
- **Surfaces:** Pure White `#FFFFFF` with soft drop shadows and 24px rounded corners
- **Navigation:** Floating pill bottom navigation bar with 2 clean tabs: **Quiz** and **Files**

---

## 🏗️ Project Architecture

```
lib/
├── main.dart                       # App entry point & main navigation shell (Quiz & Files)
├── models/
│   ├── question_model.dart         # Question model & OpenTDB HTML decoder
│   ├── quiz_config.dart            # Quiz configuration (count, timer, subject, source)
│   └── subject_category.dart       # Subject catalog with API category IDs
├── services/
│   ├── trivia_api_service.dart     # HTTP client for Open Trivia DB + offline fallbacks
│   ├── local_storage_service.dart  # SharedPreferences persistence for custom subjects
│   └── custom_quiz_parser.dart     # Parser for JSON and plain-text Q&A files
├── theme/
│   └── app_theme.dart              # Neobank color palette, typography, and card tokens
├── widgets/
│   ├── neobank_card.dart           # Rounded card (lime, dark, white variants)
│   ├── pill_button.dart            # Rounded pill action buttons
│   ├── timer_badge.dart            # Animated countdown progress badge
│   ├── answer_option_tile.dart     # Multiple-choice option tiles (A, B, C, D)
│   └── custom_bottom_nav.dart      # Floating bottom navigation bar (Quiz, Files)
└── screens/
    ├── home_screen.dart            # Quiz setup, hero card, autocomplete suggestions
    ├── quiz_screen.dart            # Active quiz with timer, progress bar, PopScope
    ├── score_screen.dart           # Score summary, accuracy %, breakdown stats
    ├── file_subjects_screen.dart   # File upload, paste questions, preloaded assets
    └── answer_review_screen.dart   # Question-by-question review
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
