import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Tüm ekranlar için kullanılabilen gotik gradient arkaplan.
class AppBackground extends StatelessWidget {
  const AppBackground({
    super.key,
    required this.child,
    this.useNight = true,
  });

  final Widget child;
  final bool useNight;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: useNight
            ? AppColors.nightGradient
            : AppColors.backgroundGradient,
      ),
      child: Stack(
        children: <Widget>[
          // Soluk dolunay efekti
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: <Color>[
                    AppColors.gold.withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
