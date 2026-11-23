import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:masrofy/l10n/strings.dart';
import 'package:masrofy/main.dart';
import 'package:masrofy/store/masrofy_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await initializeDateFormatting('ar');
    await initializeDateFormatting('en_US');
    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('التطبيق يبدأ مباشرة في الرئيسية عندما لا يكون القفل مفعّلاً',
      (tester) async {
    final store = MasrofyStore();
    await store.load();

    await tester.pumpWidget(MasrofyApp(store: store));
    await tester.pumpAndSettle();

    final s = Strings('ar');
    expect(find.text(s.navHome), findsWidgets);
    expect(find.text(s.pinEntryTitle), findsNothing);
  });

  testWidgets('شاشة PIN تحجب الرئيسية حتى إدخال الرقم الصحيح', (tester) async {
    final store = MasrofyStore();
    await store.load();
    await store.setPin('1234');

    await tester.pumpWidget(MasrofyApp(store: store));
    await tester.pumpAndSettle();

    final s = Strings('ar');
    expect(find.text(s.pinEntryTitle), findsOneWidget);
    expect(find.text(s.navHome), findsNothing);

    for (final digit in '0000'.split('')) {
      await tester.tap(find.text(digit));
      await tester.pumpAndSettle();
    }
    expect(find.text(s.pinWrong), findsOneWidget);
    expect(find.text(s.navHome), findsNothing);

    for (final digit in '1234'.split('')) {
      await tester.tap(find.text(digit));
      await tester.pumpAndSettle();
    }
    expect(find.text(s.pinEntryTitle), findsNothing);
    expect(find.text(s.navHome), findsWidgets);
  });
}
