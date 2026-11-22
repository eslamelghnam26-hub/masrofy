import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'screens/login_screen.dart';
import 'screens/root_screen.dart';
import 'screens/splash_screen.dart';
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

  // جلسة Firebase موجودة؟ دخّل المستخدم تلقائياً واربط بياناته السحابية.
  if (await AuthService.instance.hasActiveSession()) {
    final uid = AuthService.instance.currentUid;
    if (uid != null) {
      await store.attachUser(uid);
    }
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
          theme: switch (store.themeName) {
            'dark' => buildDarkTheme(),
            'cream' => buildCreamTheme(),
            _ => buildLightTheme(),
          },
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
          home: SplashScreen(
            next: store.loggedIn
                ? RootScreen(store: store)
                : LoginScreen(store: store),
          ),
        );
      },
    );
  }
}