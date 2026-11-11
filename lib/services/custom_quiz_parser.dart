import 'dart:convert';
import '../models/question_model.dart';

class CustomQuizParser {
  /// Parses raw string (from an uploaded file or user paste) into QuestionModel list
  static List<QuestionModel> parseContent(String rawContent, String subjectTitle) {
    final trimmed = rawContent.trim();
    if (trimmed.isEmpty) return [];

    // Attempt JSON parsing first
    if (trimmed.startsWith('[') || trimmed.startsWith('{')) {
      try {
        final dynamic decoded = jsonDecode(trimmed);
        if (decoded is List) {
          final list = <QuestionModel>[];
          for (int i = 0; i < decoded.length; i++) {
            final item = decoded[i];
            if (item is Map<String, dynamic>) {
              list.add(QuestionModel.fromCustomJson(item, i + 1));
            }
          }
          return list;
        } else if (decoded is Map<String, dynamic> && decoded['questions'] is List) {
          final list = <QuestionModel>[];
          final questions = decoded['questions'] as List;
          for (int i = 0; i < questions.length; i++) {
            list.add(QuestionModel.fromCustomJson(questions[i], i + 1));
          }
          return list;
        }
      } catch (_) {
        // Fall through to plain-text parser
      }
    }

    // Plain text line-by-line parser (Q: ... A: ... B: ... C: ... D: ... Answer: ...)
    return _parsePlainText(trimmed, subjectTitle);
  }

  static List<QuestionModel> _parsePlainText(String content, String subjectTitle) {
    final lines = content.split('\n');
    final questions = <QuestionModel>[];

    String? currentQ;
    List<String> currentOpts = [];
    String? currentAns;
    int index = 1;

    void saveCurrent() {
      if (currentQ != null && currentOpts.isNotEmpty && currentAns != null) {
        if (!currentOpts.contains(currentAns)) {
          currentOpts.add(currentAns!);
        }
        questions.add(QuestionModel(
          id: 'text_$index',
          question: currentQ!,
          options: List.from(currentOpts),
          correctAnswer: currentAns!,
          category: subjectTitle,
        ));
        index++;
      }
      currentQ = null;
      currentOpts = [];
      currentAns = null;
    }

    for (var rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;

      if (line.toLowerCase().startsWith('q:') || line.toLowerCase().startsWith('question:')) {
        saveCurrent();
        currentQ = line.substring(line.indexOf(':') + 1).trim();
      } else if (RegExp(r'^[a-dA-D][\.\:\)]').hasMatch(line)) {
        // Options like A. Option or A) Option or A: Option
        final optText = line.substring(2).trim();
        if (optText.isNotEmpty) currentOpts.add(optText);
      } else if (line.toLowerCase().startsWith('answer:') || line.toLowerCase().startsWith('ans:')) {
        final ansRaw = line.substring(line.indexOf(':') + 1).trim();
        // If answer was specified as a letter (e.g. "A" or "B"), resolve to the option text
        if (ansRaw.length == 1 && RegExp(r'^[a-dA-D]$').hasMatch(ansRaw)) {
          final charCode = ansRaw.toUpperCase().codeUnitAt(0) - 65;
          if (charCode >= 0 && charCode < currentOpts.length) {
            currentAns = currentOpts[charCode];
          } else {
            currentAns = ansRaw;
          }
        } else {
          currentAns = ansRaw;
        }
      }
    }

    saveCurrent();
    return questions;
  }
}
