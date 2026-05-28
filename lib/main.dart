import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Sadece dikey yön — pass-and-play için daha doğal
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);

  // Karanlık status bar — gotik atmosfer
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0A0613),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Oyun sırasında ekran kapanmasın
  await WakelockPlus.enable();

  runApp(const ProviderScope(child: VampirKoyluApp()));
}
