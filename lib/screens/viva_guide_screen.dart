import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/neobank_card.dart';

class VivaGuideScreen extends StatelessWidget {
  const VivaGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab Exam Viva Cheat Sheet'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            NeobankCard(
              variant: CardVariant.lime,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '🎓 Examiner Quick Reference',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textDark,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Review these technical explanations before demonstrating your app to the external lab examiner tomorrow.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF374151), height: 1.3),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            _buildQACard(
              number: '1',
              q: 'How does the app fetch questions from the Open Trivia API?',
              a: 'We use the `http` package in `TriviaApiService.fetchQuestions()`. It constructs a GET request with query parameters (amount, category ID, difficulty, type=multiple). When the HTTP response code is 200, we decode the JSON payload with `jsonDecode()` and map each record into `QuestionModel`.',
            ),
            const SizedBox(height: 12),

            _buildQACard(
              number: '2',
              q: 'How does the per-question countdown timer work?',
              a: 'Inside `QuizScreen`, we instantiate a `Timer.periodic(const Duration(seconds: 1))` in `initState()`. On every tick, we call `setState()` to decrement `_remainingSeconds`. If it reaches 0, `_onTimeExpired()` marks the question timed out and auto-advances. Crucially, in `dispose()`, we cancel the timer (`_timer?.cancel()`) to prevent memory leaks.',
            ),
            const SizedBox(height: 12),

            _buildQACard(
              number: '3',
              q: 'How does local persistence work for Leaderboards and Custom Files?',
              a: 'We use `shared_preferences` in `LocalStorageService`. High score objects are converted to Dart Maps via `toJson()`, serialized to JSON strings with `jsonEncode()`, and stored as a `List<String>`. Custom subject files are stored in a key-value JSON map.',
            ),
            const SizedBox(height: 12),

            _buildQACard(
              number: '4',
              q: 'What is the difference between StatelessWidget and StatefulWidget?',
              a: 'StatelessWidget is immutable — its properties cannot change over time once built. StatefulWidget maintains mutable state across rebuilds via its companion `State<T>` class, and calling `setState()` marks the widget dirty to trigger a UI re-render.',
            ),
            const SizedBox(height: 12),

            _buildQACard(
              number: '5',
              q: 'How does the custom file upload / parsing work?',
              a: '`CustomQuizParser.parseContent()` accepts either JSON arrays or plaintext format (`Q: ... A: ... B: ... Answer: ...`). It validates the question structure, extracts options and correct answer, and saves it into local storage so users can take custom subject exams.',
            ),
            const SizedBox(height: 12),

            _buildQACard(
              number: '6',
              q: 'What is PopScope and why did we use it?',
              a: '`PopScope` manages Android/web back button presses. By setting `canPop: false` and listening to `onPopInvokedWithResult`, we prompt the student with an alert dialog ("Quit Quiz?") to avoid accidental loss of active quiz progress.',
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildQACard({required String number, required String q, required String a}) {
    return NeobankCard(
      variant: CardVariant.white,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: AppTheme.surfaceDark,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  number,
                  style: const TextStyle(
                    color: AppTheme.limeAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  q,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            a,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF4B5563),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
