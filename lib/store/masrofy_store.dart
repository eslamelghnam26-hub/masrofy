import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/transaction.dart';

class MasrofyStore extends ChangeNotifier {
  static const _key = 'masrofy.transactions.v1';

  List<Transaction> _transactions = [];
  bool _loaded = false;

  List<Transaction> get transactions => List.unmodifiable(_transactions);

  bool get loaded => _loaded;

  double get totalIncome =>
      _transactions.where((t) => t.type == TxType.income).fold(0, (s, t) => s + t.amount);

  double get totalExpense =>
      _transactions.where((t) => t.type == TxType.expense).fold(0, (s, t) => s + t.amount);

  double get balance => totalIncome - totalExpense;

  List<Transaction> sorted() {
    final list = List<Transaction>.from(_transactions);
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List;
        _transactions = list
            .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> add(Transaction t) async {
    _transactions.add(t);
    await _persist();
  }

  Future<void> remove(String id) async {
    _transactions.removeWhere((t) => t.id == id);
    await _persist();
  }

  Future<void> _persist() async {
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(_transactions.map((t) => t.toJson()).toList()),
    );
  }

  /// بيانات تجريبية تُحمّل أول مرة حتى لا تفتح شاشة فارغة.
  Future<void> seedIfEmpty() async {
    if (_transactions.isNotEmpty) return;
    final now = DateTime.now();
    final fallback = [
      Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: TxType.income,
        categoryId: 'salary',
        amount: 12000,
        date: DateTime(now.year, now.month, 1),
        note: 'الراتب الشهري',
      ),
      Transaction(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        type: TxType.expense,
        categoryId: 'bills',
        amount: 1500,
        date: DateTime(now.year, now.month, 3),
        note: 'الكهرباء والإنترنت',
      ),
      Transaction(
        id: (DateTime.now().millisecondsSinceEpoch + 2).toString(),
        type: TxType.expense,
        categoryId: 'food',
        amount: 850,
        date: DateTime(now.year, now.month, 5),
        note: 'تسوق الأسبوعي',
      ),
      Transaction(
        id: (DateTime.now().millisecondsSinceEpoch + 3).toString(),
        type: TxType.expense,
        categoryId: 'transport',
        amount: 400,
        date: DateTime(now.year, now.month, 7),
        note: 'بنزين',
      ),
      Transaction(
        id: (DateTime.now().millisecondsSinceEpoch + 4).toString(),
        type: TxType.income,
        categoryId: 'freelance',
        amount: 3200,
        date: DateTime(now.year, now.month, 9),
        note: 'مشروع جانبي',
      ),
    ];
    _transactions = fallback;
    await _persist();
  }
}