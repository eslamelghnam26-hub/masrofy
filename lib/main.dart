import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'screens/login_screen.dart';
import 'screens/root_screen.dart';
import 'services/auth_service.dart';
import 'store/masrofy_store.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ar');
  await initializeDateFormatting('en_US');
  await AuthService.instance.init();
  final store = MasrofyStore();
  await store.load();

  // جلسة Firebase موجودة؟ دخّل المستخدم تلقائياً.
  if (!store.loggedIn && await AuthService.instance.hasActiveSession()) {
    await store.setLoggedIn(true);
  }

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
        final locale = Locale(store.language);
        return MaterialApp(
          title: 'مصروفي',
          debugShowCheckedModeBanner: false,
          theme: store.darkMode ? buildDarkTheme() : buildLightTheme(),
          locale: locale,
          supportedLocales: const [
            Locale('ar', ''),
            Locale('en', ''),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: store.loggedIn
              ? RootScreen(store: store)
              : LoginScreen(store: store),
        );
      },
    );
  }
}