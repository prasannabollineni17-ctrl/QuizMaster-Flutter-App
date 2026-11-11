import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum PillButtonVariant { lime, dark, outline, danger }

class PillButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final PillButtonVariant variant;
  final double height;
  final bool isExpanded;
  final bool isLoading;

  const PillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = PillButtonVariant.dark,
    this.height = 52,
    this.isExpanded = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    BorderSide borderSide = BorderSide.none;

    switch (variant) {
      case PillButtonVariant.lime:
        bg = AppTheme.limeAccent;
        fg = AppTheme.textDark;
        break;
      case PillButtonVariant.dark:
        bg = AppTheme.surfaceDark;
        fg = AppTheme.textLight;
        break;
      case PillButtonVariant.outline:
        bg = Colors.transparent;
        fg = AppTheme.textDark;
        borderSide = const BorderSide(color: AppTheme.borderLight, width: 1.5);
        break;
      case PillButtonVariant.danger:
        bg = AppTheme.error.withOpacity(0.12);
        fg = AppTheme.error;
        borderSide = BorderSide(color: AppTheme.error.withOpacity(0.3), width: 1);
        break;
    }

    Widget content = isLoading
        ? SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          )
        : Row(
            mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: fg),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: TextStyle(
                  color: fg,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          );

    final button = Material(
      color: onPressed == null ? bg.withOpacity(0.5) : bg,
      borderRadius: BorderRadius.circular(30),
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.fromBorderSide(borderSide),
          ),
          child: content,
        ),
      ),
    );

    return isExpanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}
