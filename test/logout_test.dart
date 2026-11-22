import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:masrofy/screens/login_screen.dart';
import 'package:masrofy/screens/settings_screen.dart';
import 'package:masrofy/store/masrofy_store.dart';

void main() {
  testWidgets('الضغط على تسجيل الخروج يعيد إلى شاشة الدخول',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final store = MasrofyStore();
    await store.load();
    await store.setLoggedIn(true);
    expect(store.loggedIn, isTrue);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar', ''), Locale('en', '')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Scaffold(body: SettingsPage(store: store)),
      ),
    );
    await tester.pumpAndSettle();

    final logout = find.text('تسجيل الخروج');
    await tester.scrollUntilVisible(logout, 300,
        scrollable: find.byType(Scrollable).first);

    // الضغط على الخروج يفتح رسالة تأكيد
    await tester.tap(logout);
    await tester.pumpAndSettle();
    expect(find.text('هل تريد تسجيل الخروج؟'), findsOneWidget);

    // اختيار "لا" يلغي الخروج
    await tester.tap(find.text('لا'));
    await tester.pumpAndSettle();
    expect(store.loggedIn, isTrue);
    expect(find.byType(LoginScreen), findsNothing);

    // اختيار "نعم" ينفّذ الخروج ويعود لشاشة الدخول
    await tester.tap(logout);
    await tester.pumpAndSettle();
    await tester.tap(find.text('نعم'));
    await tester.pumpAndSettle();

    expect(store.loggedIn, isFalse);
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
