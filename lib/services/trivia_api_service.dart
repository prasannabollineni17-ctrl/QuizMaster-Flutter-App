import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../models/question_model.dart';
import '../models/quiz_config.dart';

class TriviaApiService {
  static const String _baseUrl = 'https://opentdb.com/api.php';

  /// Fetches questions based on QuizConfig (API or Offline Asset)
  static Future<List<QuestionModel>> fetchQuestions(QuizConfig config) async {
    // 1. If user selected a preloaded asset or file
    if (config.source == 'preloaded' && config.customFilePath != null) {
      return _loadFromAsset(config.customFilePath!, config.numberOfQuestions);
    }

    // 2. If user provided raw custom content (from uploaded file or paste)
    if (config.customContent != null && config.customContent!.isNotEmpty) {
      return _loadFromContent(config.customContent!, config.numberOfQuestions);
    }

    // 3. Attempt to fetch from Open Trivia Database API
    try {
      final queryParams = <String, String>{
        'amount': config.numberOfQuestions.toString(),
        'type': 'multiple', // 4 multiple choice options
      };

      if (config.categoryId != null) {
        queryParams['category'] = config.categoryId.toString();
      }

      if (config.difficulty != 'any') {
        queryParams['difficulty'] = config.difficulty.toLowerCase();
      }

      final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParams);
      final response = await http.get(uri).timeout(
        const Duration(seconds: 8),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final responseCode = data['response_code'];

        // response_code 0 = Success
        if (responseCode == 0 && data['results'] is List) {
          final results = data['results'] as List;
          final questions = <QuestionModel>[];
          for (int i = 0; i < results.length; i++) {
            questions.add(QuestionModel.fromOpenTrivia(results[i], i + 1));
          }
          if (questions.isNotEmpty) {
            return questions;
          }
        }
      }
    } catch (_) {
      // Network failure, timeout, or rate-limited. Fallback gracefully.
    }

    // 4. Offline Fallback: If network is unavailable in lab, load bundled questions
    if (config.subjectName.toLowerCase().contains('flutter') ||
        config.subjectName.toLowerCase().contains('dart')) {
      return _loadFromAsset('assets/questions/flutter_lab.json', config.numberOfQuestions);
    }
    return _loadFromAsset('assets/questions/computer_science.json', config.numberOfQuestions);
  }

  static Future<List<QuestionModel>> _loadFromAsset(String assetPath, int limit) async {
    try {
      final raw = await rootBundle.loadString(assetPath);
      final list = jsonDecode(raw) as List;
      final questions = <QuestionModel>[];
      for (int i = 0; i < list.length; i++) {
        questions.add(QuestionModel.fromCustomJson(list[i], i + 1));
      }
      questions.shuffle();
      return questions.take(limit).toList();
    } catch (_) {
      // Return hardcoded safety fallback if asset reading failed
      return _getSafetyFallback();
    }
  }

  static List<QuestionModel> _loadFromContent(String content, int limit) {
    try {
      final list = jsonDecode(content) as List;
      final questions = <QuestionModel>[];
      for (int i = 0; i < list.length; i++) {
        questions.add(QuestionModel.fromCustomJson(list[i], i + 1));
      }
      return questions.take(limit).toList();
    } catch (_) {
      return _getSafetyFallback();
    }
  }

  static List<QuestionModel> _getSafetyFallback() {
    return [
      QuestionModel(
        id: 'fallback_1',
        question: 'Which method is called first in a StatefulWidget lifecycle?',
        options: ['createState()', 'build()', 'initState()', 'dispose()'],
        correctAnswer: 'createState()',
        category: 'Flutter Basics',
      ),
      QuestionModel(
        id: 'fallback_2',
        question: 'What is the default port number used by HTTP?',
        options: ['80', '443', '21', '8080'],
        correctAnswer: '80',
        category: 'Computer Networks',
      ),
      QuestionModel(
        id: 'fallback_3',
        question: 'Which data structure follows the LIFO (Last In First Out) principle?',
        options: ['Stack', 'Queue', 'Array', 'Linked List'],
        correctAnswer: 'Stack',
        category: 'Data Structures',
      ),
    ];
  }
}
