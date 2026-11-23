import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'l10n/strings.dart';
import 'screens/pin_screen.dart';
import 'screens/root_screen.dart';
import 'store/masrofy_store.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // الخطوط مضمّنة داخل assets/google_fonts، ولا يوجد أي طلب شبكة وقت التشغيل.
  GoogleFonts.config.allowRuntimeFetching = false;
  await initializeDateFormatting('ar');
  await initializeDateFormatting('en_US');
  final store = MasrofyStore();
  await store.load();

  runApp(MasrofyApp(store: store));
}

class MasrofyApp extends StatefulWidget {
  final MasrofyStore store;

  const MasrofyApp({super.key, required this.store});

  @override
  State<MasrofyApp> createState() => _MasrofyAppState();
}

class _MasrofyAppState extends State<MasrofyApp> {
  final GlobalKey<ScaffoldMessengerState> _messengerKey =
      GlobalKey<ScaffoldMessengerState>();
  late bool _unlocked;
  String? _shownError;

  @override
  void initState() {
    super.initState();
    _unlocked = !widget.store.appLockEnabled;
    widget.store.addListener(_onStoreChanged);
  }

  @override
  void dispose() {
    widget.store.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _onStoreChanged() {
    final error = widget.store.lastError;
    if (error != null && error != _shownError) {
      _shownError = error;
      _messengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(error),
          action: SnackBarAction(
            label: Strings(widget.store.language).ok,
            onPressed: widget.store.clearError,
          ),
        ),
      );
    } else if (error == null) {
      _shownError = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.store,
      builder: (context, _) {
        final locale = Locale(widget.store.language);
        final locked = widget.store.appLockEnabled && !_unlocked;
        return MaterialApp(
          scaffoldMessengerKey: _messengerKey,
          title: 'مصروفي',
          debugShowCheckedModeBanner: false,
          theme: switch (widget.store.themeName) {
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
          home: locked
              ? PinScreen(
                  store: widget.store,
                  onSuccess: () => setState(() => _unlocked = true),
                )
              : RootScreen(store: widget.store),
        );
      },
    );
  }
}
