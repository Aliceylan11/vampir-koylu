import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class AppSettings {
  const AppSettings({
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.musicEnabled = true,
    this.discussionSeconds = 180,
    this.eventProbability = 0.20,
  });

  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool musicEnabled;
  final int discussionSeconds;
  final double eventProbability;

  AppSettings copyWith({
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? musicEnabled,
    int? discussionSeconds,
    double? eventProbability,
  }) {
    return AppSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      discussionSeconds: discussionSeconds ?? this.discussionSeconds,
      eventProbability: eventProbability ?? this.eventProbability,
    );
  }
}

final StateNotifierProvider<SettingsNotifier, AppSettings> settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>(
        (Ref ref) => SettingsNotifier());

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(const AppSettings());

  void toggleSound() => state = state.copyWith(soundEnabled: !state.soundEnabled);
  void toggleVibration() =>
      state = state.copyWith(vibrationEnabled: !state.vibrationEnabled);
  void toggleMusic() => state = state.copyWith(musicEnabled: !state.musicEnabled);
  void setDiscussionSeconds(int seconds) =>
      state = state.copyWith(discussionSeconds: seconds);
  void setEventProbability(double p) =>
      state = state.copyWith(eventProbability: p);
}
