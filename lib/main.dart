import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'screens/home_screen.dart';
import 'store/masrofy_store.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ar');
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
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        return MaterialApp(
          title: 'مصروفي',
          debugShowCheckedModeBanner: false,
          theme: store.darkMode ? buildDarkTheme() : buildLightTheme(),
          locale: const Locale('ar'),
          supportedLocales: const [Locale('ar'), Locale('en')],
          home: HomeScreen(store: store),
        );
      },
    );
  }
}