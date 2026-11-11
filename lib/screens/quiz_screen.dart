import 'dart:async';
import 'package:flutter/material.dart';
import '../models/question_model.dart';
import '../models/quiz_config.dart';
import '../services/trivia_api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/answer_option_tile.dart';
import '../widgets/neobank_card.dart';
import '../widgets/pill_button.dart';
import '../widgets/timer_badge.dart';
import 'score_screen.dart';

class QuizScreen extends StatefulWidget {
  final QuizConfig config;

  const QuizScreen({super.key, required this.config});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<QuestionModel> _questions = [];
  int _currentIndex = 0;

  Timer? _timer;
  late int _remainingSeconds;
  int _totalQuizElapsedSeconds = 0;
  Timer? _overallStopwatch;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.config.timerSecondsPerQuestion;
    _loadQuestions();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _overallStopwatch?.cancel();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await TriviaApiService.fetchQuestions(widget.config);
      if (list.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'No questions found for the selected subject.';
        });
      } else {
        setState(() {
          _questions = list;
          _isLoading = false;
        });
        _startQuestionTimer();
        _startOverallTimer();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load questions. Please check network or file format.';
      });
    }
  }

  void _startOverallTimer() {
    _overallStopwatch = Timer.periodic(const Duration(seconds: 1), (t) {
      _totalQuizElapsedSeconds++;
    });
  }

  void _startQuestionTimer() {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = widget.config.timerSecondsPerQuestion;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 1) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        // Time expired for this question
        timer.cancel();
        _onTimeExpired();
      }
    });
  }

  void _onTimeExpired() {
    if (_currentIndex < _questions.length) {
      _questions[_currentIndex].isTimedOut = true;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('⏱️ Time expired! Auto-advancing to next question.'),
        duration: Duration(seconds: 1),
        backgroundColor: AppTheme.warning,
      ),
    );

    _advanceNextQuestion();
  }

  void _onSelectOption(String option) {
    if (_questions.isEmpty || _currentIndex >= _questions.length) return;
    setState(() {
      _questions[_currentIndex].selectedAnswer = option;
    });
  }

  void _advanceNextQuestion() {
    _timer?.cancel();
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _startQuestionTimer();
    } else {
      _finishQuiz();
    }
  }

  void _finishQuiz() {
    _timer?.cancel();
    _overallStopwatch?.cancel();

    int score = 0;
    for (var q in _questions) {
      if (q.isCorrect) score++;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ScoreScreen(
          questions: _questions,
          score: score,
          totalQuestions: _questions.length,
          totalTimeSeconds: _totalQuizElapsedSeconds,
          subjectName: widget.config.subjectName,
          config: widget.config,
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Quit Quiz?', style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text('Are you sure you want to exit? Your current progress will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Resume', style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Quit'),
          ),
        ],
      ),
    );
    return shouldExit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final nav = Navigator.of(context);
        final shouldExit = await _onWillPop();
        if (shouldExit) {
          nav.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () async {
              final nav = Navigator.of(context);
              final shouldExit = await _onWillPop();
              if (shouldExit) {
                nav.pop();
              }
            },
          ),
          title: Text(widget.config.subjectName),
          actions: [
            if (!_isLoading && _questions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Center(
                  child: TimerBadge(
                    remainingSeconds: _remainingSeconds,
                    totalSeconds: widget.config.timerSecondsPerQuestion,
                  ),
                ),
              ),
          ],
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: AppTheme.surfaceDark,
                shape: BoxShape.circle,
              ),
              child: const CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.limeAccent),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Fetching Questions...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.config.source == 'api'
                  ? 'Connecting to Open Trivia Database API'
                  : 'Reading file question definitions',
              style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null || _questions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: AppTheme.error),
              const SizedBox(height: 16),
              Text(
                _errorMessage ?? 'Failed to load quiz.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 20),
              PillButton(
                label: 'Retry',
                variant: PillButtonVariant.dark,
                onPressed: _loadQuestions,
              ),
            ],
          ),
        ),
      );
    }

    final currentQ = _questions[_currentIndex];
    final letters = ['A', 'B', 'C', 'D', 'E', 'F'];
    final progress = (_currentIndex + 1) / _questions.length;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Bar & Question Tracker
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question ${_currentIndex + 1} of ${_questions.length}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceDark,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    currentQ.difficulty.toUpperCase(),
                    style: const TextStyle(
                      color: AppTheme.limeAccent,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: AppTheme.borderLight,
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.limeAccentDark),
              ),
            ),
            const SizedBox(height: 16),

            // Question Card (Neobank Dark or Clean White)
            NeobankCard(
              variant: CardVariant.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentQ.category,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textMuted,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentQ.question,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textDark,
                      height: 1.35,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Options List
            Expanded(
              child: ListView.builder(
                itemCount: currentQ.options.length,
                itemBuilder: (context, i) {
                  final opt = currentQ.options[i];
                  final isSelected = currentQ.selectedAnswer == opt;
                  final label = i < letters.length ? letters[i] : '${i + 1}';

                  return AnswerOptionTile(
                    label: label,
                    optionText: opt,
                    status: isSelected ? OptionStatus.selected : OptionStatus.unselected,
                    onTap: () => _onSelectOption(opt),
                  );
                },
              ),
            ),

            // Bottom Navigation Actions
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: PillButton(
                    label: 'Skip',
                    variant: PillButtonVariant.outline,
                    onPressed: _advanceNextQuestion,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: PillButton(
                    label: _currentIndex == _questions.length - 1 ? 'Submit Quiz' : 'Next Question',
                    icon: _currentIndex == _questions.length - 1
                        ? Icons.check_circle_rounded
                        : Icons.arrow_forward_rounded,
                    variant: PillButtonVariant.lime,
                    onPressed: _advanceNextQuestion,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
