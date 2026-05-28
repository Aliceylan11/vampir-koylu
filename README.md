# 🦇 Vampir Köylü — Mobil Oyun Projesi

> Karanlık bir köy, kana susamış vampirler ve gerçeği arayan köylüler...
> Bu proje, klasik Mafya/Werewolf türündeki sosyal çıkarım oyununun
> **tek telefonla oynanabilen modern bir dijital moderatör** uygulamasıdır.

---

## 📖 1. Proje Tanıtımı

**Vampir Köylü**, arkadaş gruplarının bir telefon etrafında toplanarak oynayacağı,
**pass-and-play (telefonu sıraya geçirme)** mantığıyla çalışan bir mobil oyundur.
Telefon, hem **anlatıcı (moderatör)** rolünü üstlenir hem de tüm oyun durumunu yönetir:

- Roller dağıtılır, her oyuncu sırayla telefonu alıp gizlice kendi rolünü görür.
- Gece fazında telefon karanlık bir arayüze geçer; uygun roller (vampir, görücü, doktor vs.) sırayla telefonu alıp eylemlerini yapar.
- Gündüz fazında köy uyanır, telefon o gece olanları anlatır, oyuncular tartışıp linç oyu kullanır.
- Oyun, vampirler tüm köylüleri öldürene veya köylüler tüm vampirleri elimine edene kadar sürer.

> 💡 **Felsefe:** Telefon bir "araç" değil, **anlatıcı bir karakterdir.**
> Atmosferik ses efektleri, animasyonlu gece/gündüz geçişleri ve dramatik anlatım metinleri
> oyunu bir "uygulama" olmaktan çıkarıp **interaktif bir hikâyeye** dönüştürecek.

---

## 🧰 2. Teknoloji Seçimi ve Gerekçesi

### 🎯 Seçilen Dil: **Dart** | Framework: **Flutter**

#### Neden Flutter? (Senin C#/Python bilgine rağmen)

| Kriter | Flutter | C# + Unity | C# + MAUI | Python + Kivy |
|---|---|---|---|---|
| **APK kolaylığı** | ⭐⭐⭐⭐⭐ Tek komut | ⭐⭐⭐ Ağır kurulum | ⭐⭐⭐ Orta | ⭐⭐ Buildozer kâbusu |
| **Boyut (MB)** | ~20 MB | ~80 MB+ | ~30 MB | ~25 MB |
| **UI güzelliği** | ⭐⭐⭐⭐⭐ Yerleşik | ⭐⭐⭐ Manuel | ⭐⭐⭐⭐ İyi | ⭐⭐ Sınırlı |
| **Tüm mobil cihazlar** | ✅ Android+iOS | ✅ | ✅ | ⚠️ Android odaklı |
| **Performans** | Native | Native+ | Native | Yavaş |
| **Hot Reload** | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐ | ⭐⭐ |

#### Dart neye benziyor? (C#/Python bilen biri için 30 saniyelik özet)
```dart
// C#'a çok benzer, null-safety var, async/await tanıdık
class Vampir extends Rol {
  final String isim;
  int gücü = 1;

  Vampir(this.isim);

  Future<void> avlan(Oyuncu hedef) async {
    await Future.delayed(Duration(seconds: 1));
    hedef.öldür(sebep: 'Vampir saldırısı');
  }
}
```

Dart'ı **bir akşamda öğrenebilirsin** — söz veriyorum.

### 📦 Kullanılacak Ana Paketler
| Paket | Görevi |
|---|---|
| `flutter_riverpod` | State management (oyun durumunu yönetmek için) |
| `hive` + `hive_flutter` | Yerel veritabanı (oyun geçmişi, ayarlar) |
| `audioplayers` | Atmosfer müzikleri ve ses efektleri |
| `flutter_animate` | Smooth animasyonlar |
| `google_fonts` | Gotik/karanlık fontlar |
| `wakelock_plus` | Oyun sırasında ekranı uyutmama |
| `vibration` | Önemli olaylarda titreşim |
| `lottie` | Vampir/dolunay animasyonları |
| `shared_preferences` | Basit ayarlar |
| `flutter_localizations` | Türkçe/İngilizce dil desteği |

---

## 🎮 3. Oyun Mekaniği

### Oyuncu Sayısı: **5–20 kişi**

### 🌙 Faz Döngüsü
```
1. Hazırlık Fazı  → Oyuncu sayısı, roller seçilir
2. Rol Dağıtımı   → Telefon sırayla her oyuncuya verilir
3. İlk Gece       → Bazı roller kendini tanır (aşıklar, komşular, vampirler birbirini görür)
4. Gece Fazı      → Karanlık eylemler (avlanma, kehanet, koruma…)
5. Sabah          → Anlatıcı geceyi dramatik anlatır
6. Tartışma       → Köy konuşur (zamanlayıcı: 2–5 dk ayarlanabilir)
7. Oylama         → Linç için oy kullanılır
8. İdam           → Linç edilen kişinin son sözü ve rol açıklaması
9. → 4'e dön      → Kazanan belirlenene kadar
```

---

## 👥 4. Roller (TOPLAM 25+ ROL)

### 🏘️ Köy Tarafı
| Rol | Yeteneği | Özel Notu |
|---|---|---|
| **Köylü** | Hiçbiri, sadece oy kullanır | Sayıca en kalabalık |
| **Görücü (Kâhin)** | Her gece bir oyuncunun rolünü öğrenir | Oyunun en kritik rollerinden |
| **Doktor** | Her gece birini korur (kendisi dahil) | Ardışık aynı kişiyi koruyamaz |
| **Avcı** | Öldüğünde son nefesinde birini yanında götürür | Linç edilse de gece ölse de |
| **Cadı (İyi)** | 1 hayat iksiri + 1 ölüm iksiri (toplam oyun boyunca) | Tek seferlik güçler |
| **Köy Bekçisi** | Bir evi koruyarak vampir saldırısını engeller | Avcıdan farkı: bilgi vermez |
| **Muhtar** | Oyu **2 sayılır** | Ölünce yeni muhtar seçimi olur |
| **Aşık (Romeo/Juliet)** | Oyun başında bir eş atanır; biri ölürse diğeri de ölür | İki tarafa da düşebilir |
| **Komşu** | İlk gece iki yanındaki komşusunun rolünü görür | Pasif bilgi |
| **Medyum** | Geceleri ölülerin sohbetini görür | Ama konuşamaz |
| **Rahip** | Ölen birinin mezarını kutsayarak rolünü tüm köye açıklar | Günde 1 |
| **Suikastçi** | Tüm oyunda **bir kez** birini geceleri öldürebilir | Vampir avcısı |
| **Kahraman** | İlk vampir saldırısından sağ çıkar | Bir kerelik kalkan |
| **Şamandıra (Joker İyi)** | Linç oyunda oy verirken hatalıysa ipucu alır | Hafif yardımcı |

### 🦇 Vampir Tarafı
| Rol | Yeteneği |
|---|---|
| **Vampir** | Geceleri toplu olarak bir kurban seçer |
| **Vampir Lord** | Lider; ölürse taç rastgele bir vampire geçer |
| **Genç Vampir** | Sadece 2. geceden itibaren saldırıya katılır |
| **Vampir Ajan** | **Görücüye "köylü" olarak görünür**, müthiş kamuflaj |
| **Hipnotizör** | Geceleri bir köylüyü gündüz konuşmaktan men eder |
| **Kâhin Vampir** | Vampirlerin de bir görücüsü var (rakibi dengeler) |

### 👻 Üçüncü Taraf (Bağımsız Hedefler)
| Rol | Hedef |
|---|---|
| **Soytarı / Deli** | **Linç edilirse kazanır.** İyi numaralar yaparak suçlu görünmeli |
| **Kurt Adam** | Tek başına. Gece avlanır, tüm köyü yok edince kazanır |
| **Hayalet** | Önceden ölmüş ruh, gizli bir görev tamamlarsa dirilir |
| **Şeytan Tapan** | Bir vampiri rastgele bilir; vampirler kazanırsa kazanır ama oy hakkı yok |
| **Tarafsız Aşık** | Bir oyuncuyla aşk yaşar; eşinin tarafıyla kazanır |

---

## 🎲 5. Özel Olaylar (Random Events) — *Bu özellik oyuna can katar*

Her gece **%20 ihtimalle** bir özel olay tetiklenir. Anlatıcı dramatik bir metinle duyurur:

| Olay | Etkisi |
|---|---|
| 🌕 **Dolunay** | Vampirler bu gece **2 kişi öldürebilir** |
| 🎭 **Karnaval** | Bugün **linç yapılamaz** |
| 🦠 **Veba Salgını** | Rastgele 1 oyuncu sabaha ölü bulunur |
| 💕 **Aşk Gecesi** | İki rastgele oyuncu aşık olur (kim olduklarını bilmezler) |
| 🌪️ **Fırtına** | Bu gece **Doktor ve Bekçi güçleri çalışmaz** |
| 👻 **Hayalet Konseyi** | Ölü oyuncular bir köylüye anonim mesaj yollayabilir |
| 🔮 **Kehanet** | Görücü bu gece **2 kişiyi** kontrol edebilir |
| 🌹 **Gizli Aşık** | Anonim aşk mektubu — oyuncuların moralini bozar |
| ⚔️ **Düello** | İki rastgele oyuncu düello eder, telefon bir yazı-tura atar |
| 🕯️ **Karanlık Ritüel** | Vampirler bir köylüyü kendi tarafına çevirmeye çalışır |
| 🌒 **Kayıp Gece** | Hiçbir özel rol bu gece güç kullanamaz |
| 🦉 **Bilge Baykuş** | Tüm köye rastgele 1 doğru ipucu verilir |
| 🩸 **Kan Yağmuru** | Vampirlerin sayısı tüm köye açıklanır |
| 🕊️ **Affediliş** | Bugün lince başlanmadan oylama sıfırlanır |

---

## 🛠️ 6. Teknik Mimari

### Klasör Yapısı
```
VampirKoylu/
├── android/                  # Android native config (auto)
├── ios/                      # iOS native config (auto)
├── assets/
│   ├── audio/                # Atmosfer ve efekt sesleri
│   ├── images/               # Rol kartları, arka planlar
│   ├── animations/           # Lottie/Rive dosyaları
│   └── fonts/                # Gotik fontlar
├── lib/
│   ├── main.dart             # Giriş noktası
│   ├── app.dart              # MaterialApp, tema
│   ├── core/
│   │   ├── theme/            # Renk paleti, tema
│   │   ├── audio/            # Ses yöneticisi
│   │   └── utils/            # Yardımcılar
│   ├── models/
│   │   ├── player.dart       # Oyuncu sınıfı
│   │   ├── role.dart         # Soyut rol sınıfı
│   │   ├── roles/            # Her rol kendi dosyasında
│   │   │   ├── vampir.dart
│   │   │   ├── gorucu.dart
│   │   │   ├── doktor.dart
│   │   │   └── ...
│   │   ├── game_event.dart   # Özel olay sınıfı
│   │   └── game_state.dart   # Anlık oyun durumu
│   ├── game_engine/
│   │   ├── game_controller.dart   # Oyun akış kontrolü
│   │   ├── role_assigner.dart     # Rol dağıtım algoritması
│   │   ├── night_resolver.dart    # Gece eylemlerini birleştirme
│   │   ├── win_checker.dart       # Kazanma koşulu kontrol
│   │   └── event_generator.dart   # Random event üretici
│   ├── providers/            # Riverpod state providers
│   ├── screens/
│   │   ├── home_screen.dart       # Ana menü
│   │   ├── setup_screen.dart      # Oyuncu sayısı, isimler
│   │   ├── role_selection.dart    # Rol kompozisyonu
│   │   ├── role_reveal.dart       # Sırayla rol gösterimi
│   │   ├── night_screen.dart      # Gece fazı
│   │   ├── day_screen.dart        # Gündüz fazı + tartışma
│   │   ├── vote_screen.dart       # Oylama
│   │   ├── result_screen.dart     # Oyun sonu
│   │   └── settings_screen.dart   # Ayarlar
│   └── widgets/              # Yeniden kullanılabilir bileşenler
│       ├── role_card.dart
│       ├── countdown_timer.dart
│       ├── narrator_box.dart
│       └── player_grid.dart
├── test/                     # Unit testler
├── pubspec.yaml              # Bağımlılıklar
└── README.md                 # Bu dosya
```

### Mimari Yaklaşımı
- **MVVM benzeri** yapı: `Model → Provider (ViewModel) → Screen (View)`
- **Riverpod** ile reactive state management
- **Strategy Pattern**: Her rol kendi `nightAction()` metodunu implement eder
- **Observer Pattern**: Oyun durumu değişikliklerinde tüm ekranlar tepki verir
- **Engine'in UI'den tamamen ayrı olması**: Aynı motor ileride web/desktop'a taşınabilir

---

## 🎨 7. UI / UX Tasarım Felsefesi

### Renk Paleti (Gotik / Atmosferik)
- **Ana Arkaplan:** `#0A0613` (Derin gece moru)
- **İkincil:** `#1A0F2E` (Karanlık menekşe)
- **Vurgu (Kan):** `#8B0000` (Koyu kırmızı)
- **Altın (Gündüz):** `#D4AF37` (Eski altın)
- **Yazı:** `#E8DCC4` (Eski kâğıt beji)

### Tipografi
- **Başlıklar:** `Cinzel` veya `Pirata One` (gotik)
- **Gövde:** `Lora` veya `Crimson Text` (okunabilir serif)
- **Anlatıcı:** `Special Elite` (daktilo hissi)

### Geçişler ve Animasyonlar
- Gece → Gündüz geçişinde **güneş doğumu animasyonu**
- Vampir saldırısında **kırmızı flash + titreşim**
- Rol kartları **flip animasyonu** ile açılır
- Anlatıcı metni **typewriter efekti** ile yazılır
- Ölüm anında **kalp atışı sesi yavaşlar ve durur**

### Erişilebilirlik
- **Büyük dokunma alanları** (parmakla kolay basılabilir)
- **Yüksek kontrast** (karanlıkta da okunur)
- **Sesli anlatım seçeneği** (gelecek sürüm için planda)
- **Yazı boyutu ayarı** (Küçük / Orta / Büyük)

---

## 📱 8. Hedef Platformlar ve Uyumluluk

| Platform | Min Sürüm | Notlar |
|---|---|---|
| **Android** | 5.0 (Lollipop, API 21) | %99+ aktif cihaz kapsama |
| **iOS** | 12.0 | iPhone 5s+ |
| **Tablet** | ✅ | Responsive layout |
| **Katlanabilir telefon** | ✅ | Flutter otomatik destekliyor |

### Ekran Yönü
- Portre (dikey) **zorunlu** — tek telefonla paylaşımlı oyun mantığı için optimal

---

## 📦 9. APK Build Süreci (Senin Telefonuna Nasıl Yüklersin?)

### Build Hattı
```bash
# 1. Flutter SDK kurulumu (bir kerelik)
# Windows: https://docs.flutter.dev/get-started/install/windows

# 2. Bağımlılıklar
flutter pub get

# 3. APK üretimi (release modu, optimize edilmiş)
flutter build apk --release --split-per-abi

# 4. Çıktı dosyası
# build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

### Telefona Yükleme (3 yöntem)
1. **USB kablo:** `adb install app-release.apk`
2. **Cloud:** APK'yi Google Drive'a at, telefondan indir, yükle
3. **WhatsApp / Telegram:** Kendine gönder, dosyayı aç

> ⚠️ Android'de "Bilinmeyen kaynaklardan yükleme" izni vermen gerekecek.

### iOS Notu
iOS'a yüklemek için **Mac + Xcode + Apple Developer hesabı** gerekir (yıllık 99$).
Şimdilik Android odaklı gideceğiz; Mac'in varsa veya ileride alırsan kod **olduğu gibi** iOS'a build alır.

---

## 🗺️ 10. Geliştirme Yol Haritası

### 🚀 Sürüm 1.0 (MVP — İlk Çalışan Versiyon)
- [x] Proje iskeleti
- [ ] Ana menü
- [ ] Oyuncu kurulum ekranı (isim girme, 5–20 kişi)
- [ ] Rol seçim ekranı (preset paketler: "Klasik 8 kişi", "Vahşi 15 kişi" vs.)
- [ ] Rol dağıtımı + gizli rol gösterimi (telefonu sıraya geç)
- [ ] İlk gece (vampirler birbirini tanır, aşıklar bilinir)
- [ ] Gece eylemleri (vampir saldırısı, görücü, doktor)
- [ ] Sabah anlatımı
- [ ] Tartışma + oylama
- [ ] Linç ve son söz
- [ ] Kazanma kontrolü
- [ ] Oyun sonu ekranı

### 🌟 Sürüm 1.5
- [ ] **Tüm 25+ rol** aktif
- [ ] **Özel olaylar** sistemi
- [ ] Atmosferik ses efektleri
- [ ] Animasyonlu geçişler
- [ ] Oyun geçmişi (kim ne oynadı?)

### 💎 Sürüm 2.0
- [ ] Çoklu dil (Türkçe + İngilizce)
- [ ] Özel rol oluşturucu (kullanıcı kendi rolünü yaratır)
- [ ] İstatistikler (en çok kazanan oyuncu vs.)
- [ ] Tema seçenekleri (Vampir, Korsan, Cadı temaları)
- [ ] Sesli anlatıcı

### 🌠 Sürüm 3.0 (Hayal)
- [ ] Online çok oyunculu (uzakta arkadaşlarla)
- [ ] Bot oyuncular (tek başına oynama)
- [ ] Hikâye modu (kampanya)

---

## 🧪 11. Test Stratejisi
- **Unit testler:** Her rolün `nightAction()` mantığı test edilecek
- **Widget testler:** Kritik ekranlar (oylama, rol gösterimi)
- **Integration test:** Tam bir oyun simülasyonu (5 oyuncu, otomatik)

---

## 📚 12. Kullanılacak Dosyaların / Varlıkların Listesi

### Sesler (CC0 veya kendi üretimimiz)
- `night_ambient.mp3` (kurt uluması, rüzgâr)
- `day_ambient.mp3` (kuş sesleri, köy)
- `vampire_attack.mp3` (kanat çırpma + çığlık)
- `death_bell.mp3` (kilise çanı)
- `heartbeat.mp3` (kalp atışı)
- `bell_morning.mp3` (sabah çanı)

### Görseller
- Her rol için **portre kartı** (AI üretimi veya CC0 illüstrasyon)
- Köy arkaplanı (gündüz/gece versiyonları)
- Mezar taşı ikonları (ölen oyuncular için)

### Animasyonlar
- Dolunay animasyonu (Lottie)
- Kan damlası efekti (Lottie)
- Ateş yanıyor (mum/şömine) (Rive)

---

## ⚙️ 13. Performans Hedefleri
- APK boyutu: **< 30 MB** (split-per-abi ile)
- RAM kullanımı: **< 150 MB**
- Açılış süresi: **< 2 saniye**
- 5 yaşındaki bir telefonda akıcı çalışacak

---

## 📝 14. Geliştirme Süreci (Senin Görmen İçin)

İşi şu sırayla yapacağım:

1. **Proje iskeletini kuracağım** (`flutter create`)
2. **Tema ve renk paletini ayarlayacağım**
3. **Oyun motorunu (engine) yazacağım** — UI'siz, saf mantık
4. **Ana ekranları teker teker yapacağım**
5. **Roller ve özel olayları ekleyeceğim**
6. **Sesler ve animasyonları entegre edeceğim**
7. **APK build alacağım**
8. **Sana APK dosyasını teslim edeceğim** (Drive linki veya proje klasöründe)

Her aşamada sana **ekran görüntüsü ve özet** vereceğim.

---

## ❓ 15. Senden Onaylamanı İstediğim Konular

Aşağıdaki kararları onaylar mısın? Hayır dersen alternatif öneririm:

1. ✅ **Dil: Dart/Flutter** — Senin C# bilgine yakın, mobil için en iyisi
2. ✅ **Pass-and-play modu** — Tek telefon, gruba paylaşımlı
3. ✅ **Önce Android (APK), iOS sonra** — Mac gerekmediği için pratik
4. ✅ **Türkçe arayüz** (sonra İngilizce eklenir)
5. ✅ **Karanlık/gotik tema** — Oyunun atmosferine uygun
6. ✅ **25+ rol + özel olaylar** — Yüksek tekrar oynanabilirlik

---

## 🚦 Sıradaki Adım

Bu raporu inceledikten sonra **"devam"** dersen:
1. Flutter SDK'nın kurulu olup olmadığını kontrol edeceğim
2. Yoksa kurulum için sana adımları göstereceğim
3. Projeyi başlatıp ilk çalışan versiyonu (MVP) üreteceğim
4. APK'yı hazırlayıp sana ulaştıracağım

Değişiklik isterse söyle — örneğin:
- "Renk paleti açık olsun"
- "Aşk rollerini istemem"
- "Sadece 10 rol yeter"
- "İngilizce de olsun"
- "Tema vampir değil de kurt adam olsun"

---

**Hazır mısın? 🦇**
