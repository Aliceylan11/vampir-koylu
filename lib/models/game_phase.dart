/// Oyunun ana fazları.
enum GamePhase {
  setup('Hazırlık', 'Oyuncular ve roller belirleniyor'),
  roleReveal('Rol Dağıtımı', 'Herkes rolünü gizlice öğreniyor'),
  firstNight('İlk Gece', 'Roller birbirini tanıyor'),
  night('Gece', 'Karanlık güçler iş başında'),
  morning('Sabah', 'Köy uyandı, anlatıcı konuşuyor'),
  discussion('Tartışma', 'Köy konuşuyor'),
  voting('Oylama', 'Linç oyu kullanılıyor'),
  lynch('İdam', 'Linç edilen kişi açıklanıyor'),
  gameOver('Oyun Bitti', 'Kazanan belirlendi');

  const GamePhase(this.displayName, this.description);

  final String displayName;
  final String description;

  bool get isNight => this == GamePhase.night || this == GamePhase.firstNight;
  bool get isDay =>
      this == GamePhase.morning ||
      this == GamePhase.discussion ||
      this == GamePhase.voting ||
      this == GamePhase.lynch;
}

/// Bir oyuncunun ölüm sebebi — anlatıcı için gerekli.
enum DeathCause {
  vampireAttack('Vampir saldırısı'),
  lynch('Köy lincesi'),
  hunterRevenge('Avcının intikamı'),
  loverGrief('Aşk acısı'),
  witchPotion('Cadı iksiri'),
  assassin('Suikast'),
  plague('Veba salgını'),
  werewolf('Kurt Adam'),
  duel('Düello'),
  unknown('Bilinmeyen sebep');

  const DeathCause(this.displayName);
  final String displayName;
}
