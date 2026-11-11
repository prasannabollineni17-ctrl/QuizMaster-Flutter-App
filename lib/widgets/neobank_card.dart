import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum CardVariant { lime, dark, white }

class NeobankCard extends StatelessWidget {
  final Widget child;
  final CardVariant variant;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final Border? border;

  const NeobankCard({
    super.key,
    required this.child,
    this.variant = CardVariant.white,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
    this.width,
    this.height,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Border? effectiveBorder = border;
    List<BoxShadow> shadows = AppTheme.softShadow;

    switch (variant) {
      case CardVariant.lime:
        bg = AppTheme.limeAccent;
        effectiveBorder ??= Border.all(color: AppTheme.limeAccentDark, width: 1);
        break;
      case CardVariant.dark:
        bg = AppTheme.surfaceDark;
        shadows = AppTheme.darkCardShadow;
        effectiveBorder ??= Border.all(color: AppTheme.borderDark, width: 1);
        break;
      case CardVariant.white:
        bg = AppTheme.surfaceWhite;
        effectiveBorder ??= Border.all(color: AppTheme.borderLight, width: 1);
        break;
    }

    final cardWidget = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
        border: effectiveBorder,
        boxShadow: shadows,
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: cardWidget,
      );
    }
    return cardWidget;
  }
}
