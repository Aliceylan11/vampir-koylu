import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Oylama tipi — açık (büyük yazı görünür) veya gizli (sadece kendine).
enum VotingType {
  open('Açık', 'Herkes oyları görebilir'),
  secret('Gizli', 'Her oyuncu sadece kendi oyunu görür');

  const VotingType(this.displayName, this.description);
  final String displayName;
  final String description;
}

@immutable
class AppSettings {
  const AppSettings({
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.musicEnabled = true,
    this.discussionSeconds = 180,
    this.eventProbability = 0.20,
    this.votingType = VotingType.open,
  });

  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool musicEnabled;
  final int discussionSeconds;
  final double eventProbability;
  final VotingType votingType;

  AppSettings copyWith({
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? musicEnabled,
    int? discussionSeconds,
    double? eventProbability,
    VotingType? votingType,
  }) {
    return AppSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      discussionSeconds: discussionSeconds ?? this.discussionSeconds,
      eventProbability: eventProbability ?? this.eventProbability,
      votingType: votingType ?? this.votingType,
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
  void setVotingType(VotingType t) => state = state.copyWith(votingType: t);
}
