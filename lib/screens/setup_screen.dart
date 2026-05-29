import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../widgets/app_background.dart';
import 'role_selection_screen.dart';

class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  int _playerCount = 7;
  final List<TextEditingController> _controllers = <TextEditingController>[];

  @override
  void initState() {
    super.initState();
    _rebuildControllers();
  }

  void _rebuildControllers() {
    while (_controllers.length < _playerCount) {
      final TextEditingController c = TextEditingController();
      // Her değişiklikte rebuild → yazılanı anlık üst başlıkta göstermek için
      c.addListener(() {
        if (mounted) setState(() {});
      });
      _controllers.add(c);
    }
    while (_controllers.length > _playerCount) {
      _controllers.removeLast().dispose();
    }
  }

  @override
  void dispose() {
    for (final TextEditingController c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  int get _filledCount =>
      _controllers.where((TextEditingController c) => c.text.trim().isNotEmpty).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Oyuncu Hazırlığı')),
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: <Widget>[
                // ÜST: oyuncu sayısı + slider + canlı sayaç
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Oyuncu Sayısı: $_playerCount',
                            style: AppTextStyles.headlineMedium,
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _filledCount == _playerCount
                                  ? AppColors.success.withValues(alpha: 0.2)
                                  : AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '$_filledCount yazıldı',
                              style: AppTextStyles.caption.copyWith(
                                color: _filledCount == _playerCount
                                    ? AppColors.success
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: _playerCount.toDouble(),
                        min: 5,
                        max: 50,
                        divisions: 45,
                        label: '$_playerCount',
                        onChanged: (double v) {
                          setState(() {
                            _playerCount = v.round();
                            _rebuildControllers();
                          });
                        },
                      ),
                      Text(
                        'En az 5, en çok 50 oyuncu',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // İSİM LİSTESİ
                Expanded(
                  child: ListView.builder(
                    itemCount: _playerCount,
                    itemBuilder: (BuildContext ctx, int i) =>
                        _PlayerRow(
                      key: ValueKey<int>(i),
                      number: i + 1,
                      controller: _controllers[i],
                    ),
                  ),
                ),

                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('ROL SEÇİMİNE GEÇ'),
                    onPressed: () {
                      final List<String> names = <String>[];
                      for (int i = 0; i < _controllers.length; i++) {
                        final String typed = _controllers[i].text.trim();
                        names.add(typed.isEmpty ? 'Oyuncu ${i + 1}' : typed);
                      }
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              RoleSelectionScreen(playerNames: names),
                        ),
                      );
                    },
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

/// Tek bir oyuncu satırı: Numara (sol) + TextField (sağ, expanded).
/// TextField'in stili EXPLICIT (tema bağımlılığı yok) — her cihazda
/// yazılan metin net görünür.
class _PlayerRow extends StatelessWidget {
  const _PlayerRow({
    super.key,
    required this.number,
    required this.controller,
  });

  final int number;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final String typed = controller.text.trim();
    final bool isEmpty = typed.isEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // ===== NUMARA (sol, sabit kutu) =====
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isEmpty
                  ? AppColors.blood.withValues(alpha: 0.25)
                  : AppColors.gold.withValues(alpha: 0.25),
              shape: BoxShape.circle,
              border: Border.all(
                color: isEmpty ? AppColors.blood : AppColors.gold,
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                '$number',
                style: TextStyle(
                  color: isEmpty ? AppColors.gold : AppColors.gold,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // ===== TEXTFIELD (sağ, expanded) =====
          // EXPLICIT renkler — tema'dan bağımsız, her cihazda görünür
          Expanded(
            child: TextField(
              controller: controller,
              textCapitalization: TextCapitalization.words,
              // YAZILAN METİN — net krem-beyaz, kalın, büyük
              style: const TextStyle(
                color: Color(0xFFFFFFFF), // saf beyaz
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
              cursorColor: AppColors.gold,
              cursorWidth: 2.2,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surface,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                hintText: 'Oyuncu $number',
                hintStyle: TextStyle(
                  color: const Color(0xFFFFFFFF).withValues(alpha: 0.35),
                  fontStyle: FontStyle.italic,
                  fontSize: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: AppColors.gold.withValues(alpha: 0.4),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: AppColors.gold.withValues(alpha: 0.4),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppColors.gold,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
