import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TimerBadge extends StatelessWidget {
  final int remainingSeconds;
  final int totalSeconds;

  const TimerBadge({
    super.key,
    required this.remainingSeconds,
    required this.totalSeconds,
  });

  @override
  Widget build(BuildContext context) {
    final double fraction = totalSeconds > 0 ? (remainingSeconds / totalSeconds) : 0;

    Color badgeColor;
    if (fraction > 0.45) {
      badgeColor = AppTheme.limeAccent;
    } else if (fraction > 0.20) {
      badgeColor = AppTheme.warning;
    } else {
      badgeColor = AppTheme.error;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor.withOpacity(0.4), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              value: fraction,
              strokeWidth: 2.2,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(badgeColor),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${remainingSeconds}s',
            style: TextStyle(
              color: badgeColor,
              fontWeight: FontWeight.w800,
              fontSize: 13,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
