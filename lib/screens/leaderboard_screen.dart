import 'package:flutter/material.dart';
import '../models/leaderboard_entry.dart';
import '../services/local_storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/neobank_card.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<LeaderboardEntry> _entries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadScores();
  }

  Future<void> _loadScores() async {
    setState(() => _isLoading = true);
    final list = await LocalStorageService.getLeaderboard();
    setState(() {
      _entries = list;
      _isLoading = false;
    });
  }

  Future<void> _clearScores() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reset Leaderboard?'),
        content: const Text('Are you sure you want to clear all recorded high scores?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await LocalStorageService.clearLeaderboard();
      _loadScores();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard & High Scores'),
        actions: [
          if (_entries.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded),
              onPressed: _clearScores,
              tooltip: 'Clear Leaderboard',
            ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _entries.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: _loadScores,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top 3 Podium
                          if (_entries.length >= 3) _buildPodium(),
                          const SizedBox(height: 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'All Rankings',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              Text(
                                '${_entries.length} Records',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Ranked List
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _entries.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, i) {
                              final item = _entries[i];
                              return _buildRankRow(item, i + 1);
                            },
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.limeLight,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Text('🏆', style: TextStyle(fontSize: 40)),
            ),
            const SizedBox(height: 16),
            const Text(
              'No High Scores Yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textDark),
            ),
            const SizedBox(height: 6),
            const Text(
              'Complete a quiz to record your name and high score on the local leaderboard!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPodium() {
    final first = _entries[0];
    final second = _entries[1];
    final third = _entries[2];

    return NeobankCard(
      variant: CardVariant.dark,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd Place
          _buildPodiumPillar(
            entry: second,
            rank: '2nd',
            height: 90,
            badgeColor: Colors.grey.shade400,
            avatarIcon: '🥈',
          ),
          // 1st Place (Champion)
          _buildPodiumPillar(
            entry: first,
            rank: '1st',
            height: 120,
            badgeColor: AppTheme.limeAccent,
            avatarIcon: '👑',
            isChampion: true,
          ),
          // 3rd Place
          _buildPodiumPillar(
            entry: third,
            rank: '3rd',
            height: 75,
            badgeColor: Colors.amber.shade700,
            avatarIcon: '🥉',
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumPillar({
    required LeaderboardEntry entry,
    required String rank,
    required double height,
    required Color badgeColor,
    required String avatarIcon,
    bool isChampion = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(avatarIcon, style: TextStyle(fontSize: isChampion ? 26 : 20)),
        const SizedBox(height: 4),
        SizedBox(
          width: 78,
          child: Text(
            entry.playerName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.textLight,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Text(
          '${entry.score}/${entry.totalQuestions}',
          style: TextStyle(
            color: badgeColor,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 70,
          height: height,
          decoration: BoxDecoration(
            color: isChampion ? AppTheme.limeAccent : AppTheme.cardDark,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            border: Border.all(color: badgeColor.withOpacity(0.5)),
          ),
          alignment: Alignment.center,
          child: Text(
            rank,
            style: TextStyle(
              color: isChampion ? AppTheme.textDark : AppTheme.textLight,
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRankRow(LeaderboardEntry item, int rank) {
    Color rankColor = AppTheme.textMuted;
    if (rank == 1) rankColor = AppTheme.limeAccentDark;
    if (rank == 2) rankColor = Colors.grey.shade600;
    if (rank == 3) rankColor = Colors.amber.shade800;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        children: [
          // Rank Badge
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: rank <= 3 ? rankColor.withOpacity(0.15) : AppTheme.background,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$rank',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 12,
                color: rankColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.playerName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: AppTheme.textDark,
                  ),
                ),
                Text(
                  item.subject,
                  style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${item.score}/${item.totalQuestions}',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  color: AppTheme.textDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.limeLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${item.percentage}%',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
