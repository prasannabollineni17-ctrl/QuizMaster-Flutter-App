/// Holds configuration settings chosen by the user before launching a quiz.
class QuizConfig {
  final String subjectName;
  final int? categoryId; // Open Trivia category ID (e.g. 18 for Computers)
  final int numberOfQuestions;
  final int timerSecondsPerQuestion;
  final String difficulty; // 'easy', 'medium', 'hard', 'any'
  final String source; // 'api', 'file', 'preloaded'
  final String? customFilePath;
  final String? customContent;

  const QuizConfig({
    required this.subjectName,
    this.categoryId,
    this.numberOfQuestions = 10,
    this.timerSecondsPerQuestion = 15,
    this.difficulty = 'any',
    this.source = 'api',
    this.customFilePath,
    this.customContent,
  });

  QuizConfig copyWith({
    String? subjectName,
    int? categoryId,
    int? numberOfQuestions,
    int? timerSecondsPerQuestion,
    String? difficulty,
    String? source,
    String? customFilePath,
    String? customContent,
  }) {
    return QuizConfig(
      subjectName: subjectName ?? this.subjectName,
      categoryId: categoryId ?? this.categoryId,
      numberOfQuestions: numberOfQuestions ?? this.numberOfQuestions,
      timerSecondsPerQuestion:
          timerSecondsPerQuestion ?? this.timerSecondsPerQuestion,
      difficulty: difficulty ?? this.difficulty,
      source: source ?? this.source,
      customFilePath: customFilePath ?? this.customFilePath,
      customContent: customContent ?? this.customContent,
    );
  }
}
