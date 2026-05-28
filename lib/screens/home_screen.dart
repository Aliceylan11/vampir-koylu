import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../providers/game_provider.dart';
import '../widgets/app_background.dart';
import 'roles_info_screen.dart';
import 'settings_screen.dart';
import 'setup_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: <Widget>[
                const Spacer(),
                Icon(
                  Icons.bedtime,
                  size: 100,
                  color: AppColors.gold.withValues(alpha: 0.9),
                ).animate().fadeIn(duration: 800.ms).scale(
                      begin: const Offset(0.5, 0.5),
                      curve: Curves.elasticOut,
                      duration: 1200.ms,
                    ),
                const SizedBox(height: 24),
                Text(
                  'VAMPİR\nKÖYLÜ',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.displayLarge.copyWith(
                    height: 1.1,
                    fontSize: 56,
                  ),
                ).animate().fadeIn(delay: 400.ms, duration: 800.ms),
                const SizedBox(height: 8),
                Text(
                  '"Karanlık çöker, köy uyumaz..."',
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 16,
                  ),
                ).animate().fadeIn(delay: 800.ms),
                const Spacer(flex: 2),
                _MenuButton(
                  label: 'YENİ OYUN',
                  icon: Icons.play_arrow,
                  primary: true,
                  onTap: () {
                    ref.read(gameStateProvider.notifier).reset();
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const SetupScreen(),
                      ),
                    );
                  },
                ).animate().fadeIn(delay: 1000.ms, duration: 500.ms),
                const SizedBox(height: 12),
                _MenuButton(
                  label: 'ROLLER',
                  icon: Icons.menu_book,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const RolesInfoScreen(),
                    ),
                  ),
                ).animate().fadeIn(delay: 1200.ms, duration: 500.ms),
                const SizedBox(height: 12),
                _MenuButton(
                  label: 'AYARLAR',
                  icon: Icons.settings,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const SettingsScreen(),
                    ),
                  ),
                ).animate().fadeIn(delay: 1400.ms, duration: 500.ms),
                const Spacer(),
                Text(
                  'v1.0.0',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.primary = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: primary
          ? ElevatedButton.icon(
              onPressed: onTap,
              icon: Icon(icon, size: 28),
              label: Text(label),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
              ),
            )
          : OutlinedButton.icon(
              onPressed: onTap,
              icon: Icon(icon, size: 24),
              label: Text(label),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
              ),
            ),
    );
  }
}
