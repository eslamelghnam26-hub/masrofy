import 'package:flutter/material.dart';

enum TxType { income, expense }

/// كل العمليات الحسابية تتم بالـcents لتجنب أخطاء الفاصلة العائمة.
class Money {
  const Money._();

  static int toCents(double value) => (value * 100).round();

  static double fromCents(int cents) => cents / 100;

  static double round(double value) => fromCents(toCents(value));
}

class TxCategory {
  final String id;
  final String name;
  final String nameEn;
  final IconData icon;
  final Color color;

  const TxCategory({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.icon,
    required this.color,
  });

  String localName(String language) => language == 'ar' ? name : nameEn;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'nameEn': nameEn,
        'icon': icon.codePoint,
        'color': color.toARGB32(),
      };

  factory TxCategory.fromJson(Map<String, dynamic> json) =>
      TxCategory.tryFromJson(json) ??
      TxCategory(
        id: 'custom_recovered',
        name: 'تصنيف مستعاد',
        nameEn: 'Recovered category',
        icon: Icons.label_outline,
        color: const Color(0xFF8D8D8D),
      );

  /// يرفض أي بيانات تالفة بدل رمي استثناء يوقف تحميل التطبيق.
  static TxCategory? tryFromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final name = json['name'];
    if (id is! String || id.trim().isEmpty) return null;
    if (name is! String || name.trim().isEmpty) return null;
    final iconCode = json['icon'];
    final colorValue = json['color'];
    final nameEn = json['nameEn'];
    return TxCategory(
      id: id,
      name: name,
      nameEn: nameEn is String && nameEn.trim().isNotEmpty ? nameEn : name,
      icon: iconCode is int ? AppCategory.iconFor(iconCode) : Icons.label_outline,
      color: colorValue is int ? Color(colorValue) : const Color(0xFF8D8D8D),
    );
  }
}

class AppCategory {
  static const List<TxCategory> income = [
    TxCategory(id: 'salary', name: 'راتب', nameEn: 'Salary', icon: Icons.payments_outlined, color: Color(0xFF4CAF7D)),
    TxCategory(id: 'bonus', name: 'مكافأة', nameEn: 'Bonus', icon: Icons.card_giftcard, color: Color(0xFFB78B4B)),
    TxCategory(id: 'freelance', name: 'عمل حر', nameEn: 'Freelance', icon: Icons.work_outline, color: Color(0xFF6FA8DC)),
    TxCategory(id: 'invest', name: 'استثمار', nameEn: 'Investment', icon: Icons.trending_up, color: Color(0xFF9B8AFB)),
    TxCategory(id: 'otherinc', name: 'أخرى', nameEn: 'Other', icon: Icons.add_circle_outline, color: Color(0xFF8D8D8D)),
  ];

  static const List<TxCategory> expense = [
    TxCategory(id: 'food', name: 'طعام ومشروبات', nameEn: 'Food & Drinks', icon: Icons.restaurant_outlined, color: Color(0xFFFF5252)),
    TxCategory(id: 'transport', name: 'مواصلات', nameEn: 'Transport', icon: Icons.directions_car_outlined, color: Color(0xFF8A2BE2)),
    TxCategory(id: 'bills', name: 'فواتير', nameEn: 'Bills', icon: Icons.receipt_long_outlined, color: Color(0xFF007BFF)),
    TxCategory(id: 'installments', name: 'أقساط', nameEn: 'Installments', icon: Icons.credit_card_outlined, color: Color(0xFF455A64)),
    TxCategory(id: 'shopping', name: 'تسوق', nameEn: 'Shopping', icon: Icons.shopping_bag_outlined, color: Color(0xFFB78B4B)),
    TxCategory(id: 'health', name: 'صحة', nameEn: 'Health', icon: Icons.medical_services_outlined, color: Color(0xFFEC6B5E)),
    TxCategory(id: 'education', name: 'تعليم', nameEn: 'Education', icon: Icons.school_outlined, color: Color(0xFF6FA8DC)),
    TxCategory(id: 'entertain', name: 'ترفيه', nameEn: 'Entertainment', icon: Icons.movie_outlined, color: Color(0xFF9B8AFB)),
    TxCategory(id: 'other', name: 'أخرى', nameEn: 'Other', icon: Icons.more_horiz, color: Color(0xFF8D8D8D)),
  ];

  /// أيقونات متاحة لاختيارها للتصنيفات المخصّصة (ثابتة لإمكانية إعادة البناء).
  static const List<IconData> paletteIcons = [
    Icons.label_outline,
    Icons.local_cafe_outlined,
    Icons.pets_outlined,
    Icons.fitness_center_outlined,
    Icons.flight_takeoff_outlined,
    Icons.savings_outlined,
    Icons.phone_android_outlined,
    Icons.sports_esports_outlined,
  ];

  static IconData iconFor(int codePoint) {
    for (final icon in paletteIcons) {
      if (icon.codePoint == codePoint) return icon;
    }
    return Icons.label_outline;
  }

  static List<TxCategory> customExpense = [];

  static List<TxCategory> get allExpense => [...expense, ...customExpense];

  static List<TxCategory> byType(TxType type) =>
      type == TxType.income ? income : allExpense;

  static TxCategory byId(String id, TxType type) {
    final list = type == TxType.income ? income : allExpense;
    for (final c in list) {
      if (c.id == id) return c;
    }
    return type == TxType.income ? income.last : expense.last;
  }

  /// معرّفات التصنيفات الأساسية، تُحفظ في النسخة الاحتياطية للترحيل المستقبلي.
  static List<String> get defaultIds => [
        ...income.map((c) => c.id),
        ...expense.map((c) => c.id),
      ];
}

class Transaction {
  final String id;
  final TxType type;
  final String categoryId;
  final double amount;
  final DateTime date;
  final String note;

  const Transaction({
    required this.id,
    required this.type,
    required this.categoryId,
    required this.amount,
    required this.date,
    this.note = '',
  });

  int get amountCents => Money.toCents(amount);

  Transaction copyWith({
    String? id,
    TxType? type,
    String? categoryId,
    double? amount,
    DateTime? date,
    String? note,
  }) {
    return Transaction(
      id: id ?? this.id,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'categoryId': categoryId,
        'amount': Money.round(amount),
        'date': date.millisecondsSinceEpoch,
        'note': note,
      };

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      Transaction.tryFromJson(json) ??
      Transaction(
        id: 'recovered_${DateTime.now().microsecondsSinceEpoch}',
        type: TxType.expense,
        categoryId: 'other',
        amount: 0,
        date: DateTime.now(),
      );

  /// decoder آمن: يرفض البيانات غير المنطقية بدل إفساد الحسابات.
  static Transaction? tryFromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final typeRaw = json['type'];
    final categoryId = json['categoryId'];
    final amountRaw = json['amount'];
    final dateRaw = json['date'];
    final noteRaw = json['note'];

    if (id is! String || id.trim().isEmpty) return null;
    if (categoryId is! String || categoryId.trim().isEmpty) return null;
    if (typeRaw != 'income' && typeRaw != 'expense') return null;
    if (amountRaw is! num) return null;
    final amount = Money.round(amountRaw.toDouble());
    if (amount <= 0 || amount.isNaN || amount.isInfinite) return null;
    if (dateRaw is! int) return null;
    final date = DateTime.fromMillisecondsSinceEpoch(dateRaw);
    if (date.year < 2000 || date.year > DateTime.now().year + 5) return null;

    return Transaction(
      id: id,
      type: typeRaw == 'income' ? TxType.income : TxType.expense,
      categoryId: categoryId,
      amount: amount,
      date: date,
      note: noteRaw is String ? noteRaw : '',
    );
  }
}
