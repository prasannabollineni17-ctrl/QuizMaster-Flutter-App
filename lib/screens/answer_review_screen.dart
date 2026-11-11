import 'package:flutter/material.dart';
import '../models/question_model.dart';
import '../theme/app_theme.dart';
import '../widgets/neobank_card.dart';

class AnswerReviewScreen extends StatelessWidget {
  final List<QuestionModel> questions;

  const AnswerReviewScreen({super.key, required this.questions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Answers'),
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          itemCount: questions.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, i) {
            final q = questions[i];
            return _buildQuestionReviewCard(q, i + 1);
          },
        ),
      ),
    );
  }

  Widget _buildQuestionReviewCard(QuestionModel q, int index) {
    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    if (q.isTimedOut) {
      statusColor = AppTheme.warning;
      statusLabel = 'Timed Out';
      statusIcon = Icons.hourglass_bottom_rounded;
    } else if (q.isCorrect) {
      statusColor = AppTheme.success;
      statusLabel = 'Correct (+1)';
      statusIcon = Icons.check_circle_rounded;
    } else {
      statusColor = AppTheme.error;
      statusLabel = 'Incorrect (0)';
      statusIcon = Icons.cancel_rounded;
    }

    return NeobankCard(
      variant: CardVariant.white,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question $index',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textMuted,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 12, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      statusLabel,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            q.question,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 14),

          // User's Answer
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: q.isCorrect ? AppTheme.success.withOpacity(0.08) : AppTheme.error.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: q.isCorrect ? AppTheme.success.withOpacity(0.3) : AppTheme.error.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'Your Choice: ',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: q.isCorrect ? AppTheme.success : AppTheme.error,
                  ),
                ),
                Expanded(
                  child: Text(
                    q.selectedAnswer ?? (q.isTimedOut ? '(Timed Out / No Answer)' : '(Skipped)'),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Correct Answer
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.limeLight.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.limeAccentDark),
            ),
            child: Row(
              children: [
                const Text(
                  'Correct Answer: ',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                  ),
                ),
                Expanded(
                  child: Text(
                    q.correctAnswer,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (q.explanation != null && q.explanation!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '💡 ${q.explanation}',
              style: const TextStyle(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
