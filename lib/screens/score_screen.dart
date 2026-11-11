import 'package:flutter/material.dart';
import '../models/leaderboard_entry.dart';
import '../models/question_model.dart';
import '../models/quiz_config.dart';
import '../services/local_storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/neobank_card.dart';
import '../widgets/pill_button.dart';
import 'answer_review_screen.dart';
import 'quiz_screen.dart';

class ScoreScreen extends StatefulWidget {
  final List<QuestionModel> questions;
  final int score;
  final int totalQuestions;
  final int totalTimeSeconds;
  final String subjectName;
  final QuizConfig config;

  const ScoreScreen({
    super.key,
    required this.questions,
    required this.score,
    required this.totalQuestions,
    required this.totalTimeSeconds,
    required this.subjectName,
    required this.config,
  });

  @override
  State<ScoreScreen> createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _loadInitialName();
  }

  Future<void> _loadInitialName() async {
    final name = await LocalStorageService.getPlayerName();
    _nameController.text = name;
  }

  Future<void> _saveToLeaderboard() async {
    final playerName = _nameController.text.trim().isEmpty
        ? 'Anonymous Student'
        : _nameController.text.trim();

    await LocalStorageService.savePlayerName(playerName);

    final entry = LeaderboardEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      playerName: playerName,
      subject: widget.subjectName,
      score: widget.score,
      totalQuestions: widget.totalQuestions,
      totalTimeSeconds: widget.totalTimeSeconds,
      date: DateTime.now(),
    );

    await LocalStorageService.saveScore(entry);

    setState(() {
      _isSaved = true;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🏆 High score successfully saved to Leaderboard!'),
          backgroundColor: AppTheme.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final percentage = widget.totalQuestions > 0
        ? ((widget.score / widget.totalQuestions) * 100).round()
        : 0;

    int timedOutCount = 0;
    int incorrectCount = 0;
    for (var q in widget.questions) {
      if (q.isTimedOut) {
        timedOutCount++;
      } else if (!q.isCorrect) {
        incorrectCount++;
      }
    }

    String feedback;
    if (percentage >= 80) {
      feedback = 'Outstanding Performance! 🌟';
    } else if (percentage >= 60) {
      feedback = 'Good Job! You passed! 👍';
    } else {
      feedback = 'Need more practice! Keep going! 📚';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Summary'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Lime-Green Score Card
              NeobankCard(
                variant: CardVariant.lime,
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceDark,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.subjectName.toUpperCase(),
                        style: const TextStyle(
                          color: AppTheme.limeAccent,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${widget.score} / ${widget.totalQuestions}',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textDark,
                        letterSpacing: -1.5,
                      ),
                    ),
                    Text(
                      '$percentage% Accuracy',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      feedback,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Breakdown Stats Cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      label: 'Correct',
                      value: '${widget.score}',
                      color: AppTheme.success,
                      icon: Icons.check_circle_rounded,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatItem(
                      label: 'Wrong',
                      value: '$incorrectCount',
                      color: AppTheme.error,
                      icon: Icons.cancel_rounded,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatItem(
                      label: 'Timed Out',
                      value: '$timedOutCount',
                      color: AppTheme.warning,
                      icon: Icons.hourglass_bottom_rounded,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatItem(
                      label: 'Total Time',
                      value: '${widget.totalTimeSeconds}s',
                      color: AppTheme.surfaceDark,
                      icon: Icons.timer_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Save to Leaderboard Section
              NeobankCard(
                variant: CardVariant.white,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Save to High Scores',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Record this score on your local device leaderboard',
                      style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _nameController,
                            enabled: !_isSaved,
                            decoration: InputDecoration(
                              hintText: 'Enter student name',
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              filled: true,
                              fillColor: AppTheme.background,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        PillButton(
                          label: _isSaved ? 'Saved ✓' : 'Save',
                          variant: _isSaved ? PillButtonVariant.outline : PillButtonVariant.dark,
                          onPressed: _isSaved ? null : _saveToLeaderboard,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Actions
              PillButton(
                label: 'Review All Answers',
                icon: Icons.fact_check_rounded,
                variant: PillButtonVariant.outline,
                isExpanded: true,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AnswerReviewScreen(questions: widget.questions),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: PillButton(
                      label: 'Play Again',
                      icon: Icons.replay_rounded,
                      variant: PillButtonVariant.lime,
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuizScreen(config: widget.config),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PillButton(
                      label: 'Home',
                      icon: Icons.home_rounded,
                      variant: PillButtonVariant.dark,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
