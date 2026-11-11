/// Represents a single recorded leaderboard score.
class LeaderboardEntry {
  final String id;
  final String playerName;
  final String subject;
  final int score;
  final int totalQuestions;
  final int totalTimeSeconds;
  final DateTime date;

  LeaderboardEntry({
    required this.id,
    required this.playerName,
    required this.subject,
    required this.score,
    required this.totalQuestions,
    required this.totalTimeSeconds,
    required this.date,
  });

  int get percentage =>
      totalQuestions > 0 ? ((score / totalQuestions) * 100).round() : 0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'playerName': playerName,
      'subject': subject,
      'score': score,
      'totalQuestions': totalQuestions,
      'totalTimeSeconds': totalTimeSeconds,
      'date': date.toIso8601String(),
    };
  }

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      playerName: json['playerName'] ?? 'Anonymous Player',
      subject: json['subject'] ?? 'General Knowledge',
      score: json['score'] ?? 0,
      totalQuestions: json['totalQuestions'] ?? 10,
      totalTimeSeconds: json['totalTimeSeconds'] ?? 0,
      date: json['date'] != null
          ? DateTime.tryParse(json['date']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
