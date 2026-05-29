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
      // BOŞ controller — kullanıcı yazınca hiçbir şeyle çakışmaz.
      // Görsel ipucu "Oyuncu N" sadece hintText (placeholder) olarak gösterilir.
      _controllers.add(TextEditingController());
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Oyuncu Hazırlığı'),
      ),
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    children: <Widget>[
                      Text(
                        'Oyuncu Sayısı: $_playerCount',
                        style: AppTextStyles.headlineMedium,
                      ),
                      Slider(
                        value: _playerCount.toDouble(),
                        min: 5,
                        max: 20,
                        divisions: 15,
                        label: '$_playerCount',
                        onChanged: (double v) {
                          setState(() {
                            _playerCount = v.round();
                            _rebuildControllers();
                          });
                        },
                      ),
                      Text(
                        'En az 5, en çok 20 oyuncu',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: _playerCount,
                    itemBuilder: (BuildContext ctx, int i) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: TextField(
                        controller: _controllers[i],
                        textCapitalization: TextCapitalization.words,
                        // Yazılan metin AÇIKÇA görünsün (krem-beyaz, kalın)
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                        cursorColor: AppColors.gold,
                        decoration: InputDecoration(
                          prefixIcon: Container(
                            margin: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.blood.withValues(alpha: 0.3),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${i + 1}',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.gold,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          // Hint: kullanıcı yazınca otomatik kaybolur
                          hintText: 'Oyuncu ${i + 1}',
                          hintStyle: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textMuted,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('ROL SEÇİMİNE GEÇ'),
                    onPressed: () {
                      // Boş kalanlar için "Oyuncu N" fallback
                      final List<String> names = <String>[];
                      for (int i = 0; i < _controllers.length; i++) {
                        final String typed = _controllers[i].text.trim();
                        names.add(typed.isEmpty ? 'Oyuncu ${i + 1}' : typed);
                      }
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => RoleSelectionScreen(
                            playerNames: names,
                          ),
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
