import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/player.dart';
import '../providers/game_provider.dart';
import '../widgets/app_background.dart';
import '../widgets/role_card.dart';
import 'night_screen.dart';

/// Sırayla her oyuncuya telefonu uzatma ekranı.
/// 3 aşama: Hazır mısın? → Rol göster → Sıradakine geç
class RoleRevealScreen extends ConsumerStatefulWidget {
  const RoleRevealScreen({super.key});

  @override
  ConsumerState<RoleRevealScreen> createState() => _RoleRevealScreenState();
}

class _RoleRevealScreenState extends ConsumerState<RoleRevealScreen> {
  int _currentIndex = 0;
  _RevealStage _stage = _RevealStage.askReady;

  @override
  Widget build(BuildContext context) {
    final List<Player> players = ref.watch(gameStateProvider).players;
    if (_currentIndex >= players.length) {
      return _AllRolesDoneScreen(onContinue: () {
        ref.read(gameStateProvider.notifier).moveToFirstNight();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (_) => const NightScreen()),
        );
      });
    }

    final Player current = players[_currentIndex];

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: switch (_stage) {
              _RevealStage.askReady => _buildAskReady(current),
              _RevealStage.showRole => _buildShowRole(current),
              _RevealStage.confirmHidden => _buildConfirmHidden(current),
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAskReady(Player p) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(
          Icons.lock,
          size: 80,
          color: AppColors.gold,
        ).animate().fadeIn(),
        const SizedBox(height: 24),
        Text(
          '${p.name.toUpperCase()},',
          style: AppTextStyles.displaySmall,
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 12),
        Text(
          'Telefonu sadece sen görebileceğin\nşekilde aldın mı?',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyLarge,
        ).animate().fadeIn(delay: 400.ms),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.visibility),
            label: const Text('ROLÜMÜ GÖSTER'),
            onPressed: () => setState(() => _stage = _RevealStage.showRole),
          ),
        ),
      ],
    );
  }

  Widget _buildShowRole(Player p) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          const SizedBox(height: 20),
          RoleCard(role: p.role, playerName: p.name),
          if (p.lover != null) ...<Widget>[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFF69B4).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFF69B4)),
              ),
              child: Row(
                children: <Widget>[
                  const Icon(Icons.favorite, color: Color(0xFFFF69B4)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '💕 Aşkın: ${p.lover!.name}',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.visibility_off),
              label: const Text('ROLÜMÜ GİZLE'),
              onPressed: () =>
                  setState(() => _stage = _RevealStage.confirmHidden),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmHidden(Player p) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(
          Icons.check_circle,
          size: 100,
          color: AppColors.success,
        ).animate().scale(curve: Curves.elasticOut),
        const SizedBox(height: 24),
        Text(
          'Hatırla, ${p.name}',
          style: AppTextStyles.headlineLarge,
        ),
        const SizedBox(height: 12),
        Text(
          'Telefonu sıradaki oyuncuya uzat:',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium,
        ),
        const SizedBox(height: 8),
        Text(
          _currentIndex + 1 < ref.read(gameStateProvider).players.length
              ? ref.read(gameStateProvider).players[_currentIndex + 1].name
              : '— Herkes bitti —',
          style: AppTextStyles.displaySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.arrow_forward),
            label: const Text('SIRADAKİNE GEÇ'),
            onPressed: () {
              setState(() {
                _currentIndex++;
                _stage = _RevealStage.askReady;
              });
            },
          ),
        ),
      ],
    );
  }
}

enum _RevealStage { askReady, showRole, confirmHidden }

class _AllRolesDoneScreen extends StatelessWidget {
  const _AllRolesDoneScreen({required this.onContinue});
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.nights_stay, size: 100, color: AppColors.gold)
                    .animate()
                    .fadeIn()
                    .scale(curve: Curves.elasticOut, duration: 1200.ms),
                const SizedBox(height: 24),
                Text(
                  'KÖY UYUYOR...',
                  style: AppTextStyles.displaySmall,
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 400.ms),
                const SizedBox(height: 12),
                Text(
                  'Herkes rolünü öğrendi.\nİlk gece başlamak üzere.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyLarge,
                ).animate().fadeIn(delay: 800.ms),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.bedtime),
                    label: const Text('İLK GECEYİ BAŞLAT'),
                    onPressed: onContinue,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
