import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum OptionStatus { unselected, selected, correct, incorrect }

class AnswerOptionTile extends StatelessWidget {
  final String label; // "A", "B", "C", "D"
  final String optionText;
  final OptionStatus status;
  final VoidCallback? onTap;

  const AnswerOptionTile({
    super.key,
    required this.label,
    required this.optionText,
    this.status = OptionStatus.unselected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color cardBg = AppTheme.surfaceWhite;
    Color borderColor = AppTheme.borderLight;
    Color badgeBg = AppTheme.background;
    Color badgeFg = AppTheme.textDark;
    Color textColor = AppTheme.textDark;
    double borderWidth = 1.0;

    switch (status) {
      case OptionStatus.selected:
        cardBg = AppTheme.limeLight.withOpacity(0.4);
        borderColor = AppTheme.limeAccentDark;
        badgeBg = AppTheme.surfaceDark;
        badgeFg = AppTheme.limeAccent;
        borderWidth = 2.0;
        break;
      case OptionStatus.correct:
        cardBg = AppTheme.success.withOpacity(0.10);
        borderColor = AppTheme.success;
        badgeBg = AppTheme.success;
        badgeFg = Colors.white;
        borderWidth = 2.0;
        break;
      case OptionStatus.incorrect:
        cardBg = AppTheme.error.withOpacity(0.08);
        borderColor = AppTheme.error;
        badgeBg = AppTheme.error;
        badgeFg = Colors.white;
        borderWidth = 2.0;
        break;
      case OptionStatus.unselected:
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Material(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: borderColor, width: borderWidth),
              boxShadow: AppTheme.softShadow,
            ),
            child: Row(
              children: [
                // Option letter badge (A, B, C, D)
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: badgeBg,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: badgeFg,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Text
                Expanded(
                  child: Text(
                    optionText,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: status == OptionStatus.selected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                ),
                // Status icon indicator
                if (status == OptionStatus.correct)
                  const Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 22)
                else if (status == OptionStatus.incorrect)
                  const Icon(Icons.cancel_rounded, color: AppTheme.error, size: 22)
                else if (status == OptionStatus.selected)
                  const Icon(Icons.radio_button_checked_rounded, color: AppTheme.surfaceDark, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
