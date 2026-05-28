import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../providers/settings_provider.dart';
import '../widgets/app_background.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppSettings s = ref.watch(settingsProvider);
    final SettingsNotifier notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: AppBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: <Widget>[
              _SectionTitle('Ses & Hissel'),
              SwitchListTile(
                title: const Text('Ses efektleri'),
                subtitle: const Text('Vampir saldırısı, ölüm sesi, vs.'),
                value: s.soundEnabled,
                onChanged: (_) => notifier.toggleSound(),
              ),
              SwitchListTile(
                title: const Text('Atmosfer müziği'),
                subtitle: const Text('Gece/gündüz arka müzikleri'),
                value: s.musicEnabled,
                onChanged: (_) => notifier.toggleMusic(),
              ),
              SwitchListTile(
                title: const Text('Titreşim'),
                subtitle: const Text('Önemli olaylarda titreşim'),
                value: s.vibrationEnabled,
                onChanged: (_) => notifier.toggleVibration(),
              ),
              const Divider(),
              _SectionTitle('Oyun'),
              ListTile(
                title: const Text('Tartışma süresi'),
                subtitle: Text(
                  '${(s.discussionSeconds / 60).toStringAsFixed(1)} dakika',
                  style: AppTextStyles.caption,
                ),
              ),
              Slider(
                value: s.discussionSeconds.toDouble(),
                min: 60,
                max: 600,
                divisions: 18,
                label: '${(s.discussionSeconds / 60).toStringAsFixed(1)} dk',
                onChanged: (double v) =>
                    notifier.setDiscussionSeconds(v.round()),
              ),
              ListTile(
                title: const Text('Özel olay olasılığı'),
                subtitle: Text(
                  '%${(s.eventProbability * 100).toStringAsFixed(0)} ihtimal',
                  style: AppTextStyles.caption,
                ),
              ),
              Slider(
                value: s.eventProbability,
                min: 0,
                max: 0.5,
                divisions: 10,
                label: '%${(s.eventProbability * 100).round()}',
                onChanged: (double v) => notifier.setEventProbability(v),
              ),
              const Divider(),
              _SectionTitle('Hakkında'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Vampir Köylü',
                          style: AppTextStyles.headlineMedium),
                      const SizedBox(height: 4),
                      Text('Sürüm 1.0.0', style: AppTextStyles.caption),
                      const SizedBox(height: 12),
                      Text(
                        'Karanlık bir köy, kana susamış vampirler ve '
                        'gerçeği arayan köylüler... Klasik Mafya/Werewolf '
                        'türünün modern dijital moderatörü.\n\n'
                        '🦇 Flutter ile yapıldı.',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.bodySmall.copyWith(
          letterSpacing: 2,
          color: AppColors.gold,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
