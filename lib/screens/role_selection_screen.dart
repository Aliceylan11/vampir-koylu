import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/role.dart';
import '../models/roles_catalog.dart';
import '../providers/game_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/app_background.dart';
import 'role_reveal_screen.dart';

class RoleSelectionScreen extends ConsumerStatefulWidget {
  const RoleSelectionScreen({super.key, required this.playerNames});

  final List<String> playerNames;

  @override
  ConsumerState<RoleSelectionScreen> createState() =>
      _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends ConsumerState<RoleSelectionScreen> {
  RolePreset? _selectedPreset;
  final Map<String, int> _customCounts = <String, int>{};

  int get _totalSelected =>
      _customCounts.values.fold(0, (int a, int b) => a + b);

  @override
  Widget build(BuildContext context) {
    final int playerCount = widget.playerNames.length;
    final List<RolePreset> applicable = RolePreset.presets
        .where((RolePreset p) =>
            playerCount >= p.minPlayers && playerCount <= p.maxPlayers)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Rol Seçimi ($playerCount kişi)'),
      ),
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: ListView(
                    children: <Widget>[
                      Text(
                        'HAZIR KOMPOZİSYONLAR',
                        style: AppTextStyles.headlineSmall,
                      ),
                      const SizedBox(height: 12),
                      if (applicable.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            '$playerCount kişiye uygun hazır kompozisyon yok. '
                            'Aşağıdan özel seçim yapabilirsin.',
                            style: AppTextStyles.bodyMedium,
                          ),
                        ),
                      ...applicable.map(_buildPresetCard),
                      const SizedBox(height: 24),
                      Text(
                        'ÖZEL SEÇİM (opsiyonel)',
                        style: AppTextStyles.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Toplam seçili: $_totalSelected / $playerCount',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: _totalSelected == playerCount
                              ? AppColors.success
                              : AppColors.warning,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...RolesCatalog.all.map(_buildRoleCounter),
                    ],
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.casino),
                    label: const Text('OYUNA BAŞLA'),
                    onPressed: _canStart() ? _startGame : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPresetCard(RolePreset preset) {
    final bool selected = _selectedPreset?.name == preset.name;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPreset = preset;
          _customCounts.clear();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.blood.withValues(alpha: 0.2)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.gold : AppColors.gold.withValues(alpha: 0.3),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: <Widget>[
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: AppColors.gold,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(preset.name, style: AppTextStyles.headlineSmall),
                  const SizedBox(height: 4),
                  Text(
                    preset.description,
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCounter(Role role) {
    final int count = _customCounts[role.id] ?? 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: role.accentColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: <Widget>[
          Icon(role.icon, color: role.accentColor, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(role.displayName, style: AppTextStyles.bodyMedium),
                Text(
                  role.team.displayName,
                  style: AppTextStyles.caption.copyWith(color: role.team.color),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: count > 0
                ? () => setState(() {
                      _customCounts[role.id] = count - 1;
                      if (_customCounts[role.id] == 0) {
                        _customCounts.remove(role.id);
                      }
                      _selectedPreset = null;
                    })
                : null,
            icon: const Icon(Icons.remove_circle_outline),
          ),
          SizedBox(
            width: 20,
            child: Text(
              '$count',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge,
            ),
          ),
          IconButton(
            onPressed: count < role.maxCount
                ? () => setState(() {
                      _customCounts[role.id] = count + 1;
                      _selectedPreset = null;
                    })
                : null,
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
    );
  }

  bool _canStart() {
    if (_selectedPreset != null) return true;
    return _totalSelected == widget.playerNames.length;
  }

  void _startGame() {
    final List<Role> roles = _selectedPreset != null
        ? _selectedPreset!.buildRoles()
        : <Role>[
            for (final MapEntry<String, int> e in _customCounts.entries)
              for (int i = 0; i < e.value; i++) RolesCatalog.byId(e.key)!,
          ];

    final int discussionSeconds = ref.read(settingsProvider).discussionSeconds;
    ref.read(gameStateProvider.notifier).startNewGame(
          playerNames: widget.playerNames,
          roles: roles,
          discussionSeconds: discussionSeconds,
        );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => const RoleRevealScreen(),
      ),
    );
  }
}
