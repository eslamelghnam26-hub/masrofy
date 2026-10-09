import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'store/masrofy_store.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = MasrofyStore();
  await store.load();
  await store.seedIfEmpty();
  runApp(MasrofyApp(store: store));
}

class MasrofyApp extends StatelessWidget {
  final MasrofyStore store;

  const MasrofyApp({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'مصروفي',
      debugShowCheckedModeBanner: false,
      theme: buildDarkTheme(),
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      home: HomeScreen(store: store),
    );
  }
}