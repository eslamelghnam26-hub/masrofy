import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:masrofy/models/transaction.dart';
import 'package:masrofy/store/masrofy_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

Transaction _tx({
  required String id,
  required TxType type,
  required double amount,
  String categoryId = 'other',
}) {
  return Transaction(
    id: id,
    type: type,
    categoryId: categoryId,
    amount: amount,
    date: DateTime(2026, 1, 15),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('يحفظ العمليات ويعيدها بعد إعادة تشغيل المتجر', () async {
    final store = MasrofyStore();
    await store.load();

    await store.setOpeningBalance(100);
    await store.add(_tx(id: 'in', type: TxType.income, amount: 50, categoryId: 'salary'));
    await store.add(_tx(id: 'out', type: TxType.expense, amount: 30, categoryId: 'food'));

    expect(store.totalIncome, 50);
    expect(store.totalExpense, 30);
    expect(store.balance, 120);

    final reopened = MasrofyStore();
    await reopened.load();
    expect(reopened.transactions.length, 2);
    expect(reopened.openingBalance, 100);
    expect(reopened.balance, 120);
  });

  test('التعديل يحتفظ بالمعرّف والحذف يدعم التراجع', () async {
    final store = MasrofyStore();
    await store.load();
    final tx = _tx(id: 'a', type: TxType.expense, amount: 20, categoryId: 'food');
    await store.add(tx);

    await store.update(tx.copyWith(amount: 25, note: 'عدّل'));
    expect(store.transactions.single.id, 'a');
    expect(store.transactions.single.amount, 25);
    expect(store.transactions.single.note, 'عدّل');

    final removed = await store.remove('a');
    expect(removed, isNotNull);
    expect(store.transactions, isEmpty);
    await store.restore(removed!);
    expect(store.transactions.single.id, 'a');
    expect(await store.remove('a'), isNotNull);
    expect(await store.remove('a'), isNull);
  });

  test('يتعامل مع JSON تالف بأمان', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      MasrofyStore.dataKey: '{json-تالف',
    });
    final store = MasrofyStore();
    await store.load();
    expect(store.loaded, isTrue);
    expect(store.transactions, isEmpty);
  });

  test('يهاجر بيانات الإصدار القديم دون فقدانها', () async {
    final legacyTx = _tx(id: 'old', type: TxType.income, amount: 75);
    SharedPreferences.setMockInitialValues(<String, Object>{
      'masrofy.transactions.v1': jsonEncode([legacyTx.toJson()]),
      'masrofy.language.v1': 'en',
    });
    final store = MasrofyStore();
    await store.load();
    expect(store.transactions.length, 1);
    expect(store.transactions.first.id, 'old');
    expect(store.language, 'en');

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(MasrofyStore.dataKey), contains('old'));
  });

  group('قفل التطبيق', () {
    test('ينشئ ويتحقق ويغيّر ويلغي الرقم السري', () async {
      final store = MasrofyStore();
      await store.load();

      expect(await store.setPin('1234'), isTrue);
      expect(store.appLockEnabled, isTrue);
      expect(store.verifyPin('1234'), isTrue);
      expect(store.verifyPin('0000'), isFalse);
      expect(store.verifyPin('12a4'), isFalse);

      expect(await store.changePin('0000', '9999'), isFalse);
      expect(await store.changePin('1234', '5678'), isTrue);
      expect(store.verifyPin('5678'), isTrue);

      expect(await store.disablePin('1234'), isFalse);
      expect(await store.disablePin('5678'), isTrue);
      expect(store.appLockEnabled, isFalse);
    });

    test('لا يخزّن الرقم الأصلي كنص صريح', () async {
      final store = MasrofyStore();
      await store.load();
      await store.setPin('4321');

      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(MasrofyStore.dataKey) ?? '';
      expect(raw.contains('4321'), isFalse);
      expect(raw.contains('pinSalt'), isTrue);
      expect(raw.contains('pinHash'), isTrue);
    });
  });

  test('يصدّر ويستورد نسخة JSON مع رفض الملف التالف', () async {
    final store = MasrofyStore();
    await store.load();
    await store.add(_tx(id: 'x', type: TxType.expense, amount: 12.5));

    final backup = store.exportBackup();
    expect(backup, contains('"schema": 2'));

    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final other = MasrofyStore();
    await other.load();
    expect(await other.importBackup('{not-json'), isFalse);
    expect(other.transactions, isEmpty);

    expect(await other.importBackup(backup), isTrue);
    expect(other.transactions.length, 1);
    expect(other.transactions.first.amount, 12.5);
  });

  test('يحسب الميزانية حسب الشهر المختار', () async {
    final store = MasrofyStore();
    await store.load();
    await store.setMonth(DateTime(2026, 1));
    await store.setBudget('food', 100);
    await store.add(_tx(id: 'jan', type: TxType.expense, amount: 40, categoryId: 'food'));

    expect(store.budgetFor('food'), 100);
    expect(store.spentFor('food'), 40);
    expect(store.monthlyBudgetTotal, 100);
    expect(store.remainingBudget, 60);
    expect(store.hasOverBudgetCategory, isFalse);

    await store.add(_tx(id: 'jan2', type: TxType.expense, amount: 80, categoryId: 'food'));
    expect(store.hasOverBudgetCategory, isTrue);

    await store.setMonth(DateTime(2026, 2));
    expect(store.budgetFor('food'), 0);
    expect(store.spentFor('food'), 0);
  });
}
