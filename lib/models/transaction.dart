import 'package:flutter/material.dart';

enum TxType { income, expense }

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

  factory TxCategory.fromJson(Map<String, dynamic> json) => TxCategory(
        id: json['id'] as String,
        name: json['name'] as String,
        nameEn: (json['nameEn'] as String?) ?? (json['name'] as String),
        icon: AppCategory.iconFor(json['icon'] as int),
        color: Color(json['color'] as int),
      );
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
    TxCategory(id: 'food', name: 'طعام ومشروبات', nameEn: 'Food & Drinks', icon: Icons.restaurant_outlined, color: Color(0xFFEC6B5E)),
    TxCategory(id: 'transport', name: 'مواصلات', nameEn: 'Transport', icon: Icons.directions_car_outlined, color: Color(0xFF6FA8DC)),
    TxCategory(id: 'bills', name: 'فواتير', nameEn: 'Bills', icon: Icons.receipt_long_outlined, color: Color(0xFFE0A458)),
    TxCategory(id: 'installments', name: 'أقساط', nameEn: 'Installments', icon: Icons.credit_card_outlined, color: Color(0xFF3FA9A0)),
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

  /// إعادة بناء أيقونة من رمزها المخزّن.
  static IconData iconFor(int codePoint) {
    for (final icon in paletteIcons) {
      if (icon.codePoint == codePoint) return icon;
    }
    return Icons.label_outline;
  }

  /// تصنيفات مصروفات مخصّصة أضافها المستخدم (تُحمَّل من التخزين).
  static List<TxCategory> customExpense = [];

  static List<TxCategory> get allExpense => [...expense, ...customExpense];

  static List<TxCategory> byType(TxType type) =>
      type == TxType.income ? income : allExpense;

  static TxCategory byId(String id, TxType type) {
    final list = type == TxType.income ? income : allExpense;
    for (final c in list) {
      if (c.id == id) return c;
    }
    if (type == TxType.income) return income.last;
    for (final c in expense) {
      if (c.id == 'other') return c;
    }
    return expense.last;
  }
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

  Transaction copyWith({double? amount, String? categoryId, DateTime? date, String? note}) {
    return Transaction(
      id: id,
      type: type,
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
        'amount': amount,
        'date': date.millisecondsSinceEpoch,
        'note': note,
      };

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json['id'] as String,
        type: json['type'] == 'income' ? TxType.income : TxType.expense,
        categoryId: json['categoryId'] as String,
        amount: (json['amount'] as num).toDouble(),
        date: DateTime.fromMillisecondsSinceEpoch(json['date'] as int),
        note: json['note'] as String? ?? '',
      );
}