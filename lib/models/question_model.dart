/// Represents a single quiz question with options, answer, and user selection.
class QuestionModel {
  final String id;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String? explanation;
  final String category;
  final String difficulty;
  String? selectedAnswer;
  bool isTimedOut;

  QuestionModel({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.explanation,
    this.category = 'General',
    this.difficulty = 'Medium',
    this.selectedAnswer,
    this.isTimedOut = false,
  });

  bool get isAnswered => selectedAnswer != null || isTimedOut;
  bool get isCorrect => selectedAnswer != null && selectedAnswer == correctAnswer;

  /// Helper to decode HTML entities returned by Open Trivia API
  static String decodeHtml(String text) {
    return text
        .replaceAll('&quot;', '"')
        .replaceAll('&#039;', "'")
        .replaceAll('&apos;', "'")
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&eacute;', 'é')
        .replaceAll('&Eacute;', 'É')
        .replaceAll('&oacute;', 'ó')
        .replaceAll('&deg;', '°')
        .replaceAll('&shy;', '')
        .replaceAll('&#160;', ' ')
        .replaceAll('&hellip;', '...');
  }

  /// Construct from Open Trivia DB API JSON structure
  factory QuestionModel.fromOpenTrivia(Map<String, dynamic> json, int index) {
    final rawQuestion = decodeHtml(json['question']?.toString() ?? '');
    final rawCorrect = decodeHtml(json['correct_answer']?.toString() ?? '');
    final incorrectList = (json['incorrect_answers'] as List? ?? [])
        .map((e) => decodeHtml(e.toString()))
        .toList();

    final allOptions = <String>[...incorrectList, rawCorrect];
    allOptions.shuffle();

    return QuestionModel(
      id: 'otdb_$index',
      question: rawQuestion,
      options: allOptions,
      correctAnswer: rawCorrect,
      category: decodeHtml(json['category']?.toString() ?? 'General Trivia'),
      difficulty: json['difficulty']?.toString().toUpperCase() ?? 'MEDIUM',
    );
  }

  /// Construct from custom file or manual JSON upload
  factory QuestionModel.fromCustomJson(Map<String, dynamic> json, int index) {
    final q = json['question']?.toString() ?? 'Question $index';
    final correct = json['correctAnswer']?.toString() ?? json['answer']?.toString() ?? '';
    List<String> opts = [];
    if (json['options'] is List) {
      opts = (json['options'] as List).map((e) => e.toString()).toList();
    }
    if (!opts.contains(correct) && correct.isNotEmpty) {
      opts.add(correct);
    }
    if (opts.length < 2) {
      opts = ['True', 'False'];
    }

    return QuestionModel(
      id: 'custom_$index',
      question: q,
      options: opts,
      correctAnswer: correct.isNotEmpty ? correct : opts.first,
      explanation: json['explanation']?.toString(),
      category: json['category']?.toString() ?? 'Custom Subject',
      difficulty: json['difficulty']?.toString() ?? 'Standard',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
      'category': category,
      'difficulty': difficulty,
      'selectedAnswer': selectedAnswer,
      'isTimedOut': isTimedOut,
    };
  }
}
