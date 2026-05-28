# 📱 Vampir Köylü — Telefona Yükleme Rehberi

Bu rehber, kodu APK'ya dönüştürüp telefonuna nasıl yükleyeceğini anlatır.
**İki yol var** — sana en uygun olanı seç.

---

## 🚀 YOL 1 — Bulutta Build (Önerilen, PC'ne hiçbir şey kurma)

**Süre:** ~10 dakika kurulum + her build ~5 dk
**Gereken:** GitHub hesabı (ücretsiz)
**PC'ye kurulum:** YOK ✅

### Adım 1: GitHub'da boş bir repo oluştur
1. https://github.com/new aç
2. Repository name: `vampir-koylu` (veya istediğin isim)
3. Public veya Private fark etmez
4. README, .gitignore, license **EKLEME** (zaten dosyalarda var)
5. **Create repository** tıkla

### Adım 2: Kodu GitHub'a yükle

GitHub Desktop kullanıyorsan:
1. **File → Add local repository**
2. `C:\Users\ali_c\Desktop\VampirKoylu` klasörünü seç
3. **Publish repository** → biraz önce oluşturduğun repo
4. Bitti.

Git komut satırı kullanıyorsan:
```bash
cd c:\Users\ali_c\Desktop\VampirKoylu
git init
git add .
git commit -m "İlk sürüm"
git branch -M main
git remote add origin https://github.com/KULLANICI_ADIN/vampir-koylu.git
git push -u origin main
```

### Adım 3: APK'nın bitmesini bekle
1. Repo sayfanda **Actions** sekmesine git
2. Yeşil ✓ olana kadar bekle (~5 dakika)
3. Yeşil olunca tıkla → en aşağıda **Artifacts** bölümü
4. `vampir-koylu-apks` linkini tıkla → ZIP iner

### Adım 4: APK'yı telefona at
ZIP'i aç. İçinde 3 APK var:
- `app-arm64-v8a-release.apk` → **Bu en yaygın, dene**
- `app-armeabi-v7a-release.apk` → Çok eski Android için
- `app-x86_64-release.apk` → Emülatör için

APK'yı telefona transfer et:
- **WhatsApp Self Chat:** Kendine APK gönder, telefondan aç
- **Telegram Saved Messages:** Aynı şekilde
- **Google Drive:** APK'yı yükle, telefondan indir
- **USB kablo:** Doğrudan kopyala

### Adım 5: Telefonda yükle
1. Telefonda dosyayı aç
2. "Bilinmeyen kaynaklardan yüklemeye izin ver" → Aç
3. **Yükle**'ye dokun
4. 🎉 Vampir Köylü artık menüde!

### 💡 Tag ile Release oluşturma (opsiyonel)
GitHub'da `v1.0.0` gibi bir tag oluşturursan, APK'lar otomatik bir **Release** sayfasına yüklenir — paylaşımı kolaylaşır:
```bash
git tag v1.0.0
git push origin v1.0.0
```

---

## 🛠️ YOL 2 — Yerel Build (PC'ne Flutter kurma)

**Süre:** ~1 saat ilk kurulum + her build ~3 dk
**Gereken:** ~6 GB disk alanı
**PC'ye kurulum:** Flutter SDK + Android SDK + JDK 17

### Adım 1: Java 17 kur
PowerShell'i yönetici olarak aç:
```powershell
winget install -e --id EclipseAdoptium.Temurin.17.JDK
```

### Adım 2: Flutter SDK kur
1. https://docs.flutter.dev/get-started/install/windows adresinden ZIP indir
2. `C:\flutter` klasörüne aç (önemli: boşluk içeren yere koyma!)
3. PATH'e ekle:
   - Başlat → "Sistem değişkenleri" ara
   - Ortam değişkenleri → Path → Düzenle → Yeni
   - `C:\flutter\bin` ekle
4. Yeni bir PowerShell aç ve test et:
   ```powershell
   flutter --version
   ```

### Adım 3: Android Studio kur (Android SDK için)
```powershell
winget install -e --id Google.AndroidStudio
```
Android Studio'yu ilk açtığında:
1. Setup wizard → **Standard** kurulum seç
2. SDK indirmeleri bitsin (~3 GB)
3. Bu kadar, Studio'yu kapat — sadece SDK için gerekiyordu

### Adım 4: Lisansları kabul et
```powershell
flutter doctor --android-licenses
```
Çıkan soruların hepsine `y` de.

### Adım 5: Kontrol et
```powershell
flutter doctor
```
Tüm satırlarda ✓ veya yeşil yazı görmelisin.

### Adım 6: Projeyi tamamla ve build al
```powershell
cd c:\Users\ali_c\Desktop\VampirKoylu

# Eksik platform dosyalarını doldur
flutter create --platforms=android --project-name=vampir_koylu --org=com.vampirkoylu .

# Paketleri indir
flutter pub get

# APK al!
flutter build apk --release --split-per-abi
```

Çıktı: `build\app\outputs\flutter-apk\` klasöründe APK'lar.

### Adım 7: Telefona yükle
**Seçenek A — USB kablo (en hızlı):**
```powershell
# Telefonda "Geliştirici seçenekleri" → USB hata ayıklama açık olmalı
flutter install
```

**Seçenek B — Manuel:**
- APK'yı WhatsApp/Drive ile telefona at, yükle.

---

## 🔄 Geliştirme Döngüsü (Yerel)

Kodu değiştirdikçe:
```powershell
# Anlık değişiklik (telefon USB'de):
flutter run

# Sadece APK üret:
flutter build apk --release --split-per-abi
```

`flutter run` çalışırken `r` tuşuna basınca **Hot Reload** — değişiklikler 1 saniyede telefona yansır.

---

## ❓ Sorun Giderme

### "flutter: command not found"
PATH'e `C:\flutter\bin` ekle, PowerShell'i yeniden başlat.

### "Android licenses not accepted"
```powershell
flutter doctor --android-licenses
```
Sonra hepsine `y`.

### "Gradle build failed"
İlk build internet hızına bağlı 5-10 dakika sürebilir. Gradle indiriyor.
Sabırlı ol, kahve iç. ☕

### "Bilinmeyen kaynak" izni yok
Android Ayarlar → Uygulamalar → Özel uygulama erişimi → Bilinmeyen uygulamaları yükle → WhatsApp/Drive/Chrome'a izin ver.

### APK yüklenmiyor
- Aynı paket adıyla bir uygulama önceden yüklüyse, kaldır.
- "Yükleme blok edildi" → Play Protect'i geçici kapat.

---

## 🍎 iOS (iPhone) Notu

iOS için Mac + Xcode + Apple Developer hesabı ($99/yıl) gerekir.
Kod **aynı** — sadece build farklı:
```bash
flutter build ios --release
```
Bu rehber dışı. İhtiyacın olursa söyle, Codemagic ile iOS bulut build da kurabiliriz.

---

**🦇 İyi oyunlar!**

Sorun çıkarsa bana yaz, beraber çözeriz.
