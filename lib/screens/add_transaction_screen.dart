import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../l10n/strings.dart';
import '../models/transaction.dart';
import '../store/masrofy_store.dart';
import '../theme/app_theme.dart';

class AddTransactionScreen extends StatefulWidget {
  final MasrofyStore store;
  final TxType type;

  const AddTransactionScreen({
    super.key,
    required this.store,
    required this.type,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  late String _selectedCategory;
  late DateTime _selectedDate;

  bool get _isIncome => widget.type == TxType.income;

  @override
  void initState() {
    super.initState();
    _selectedCategory =
        AppCategory.byId(_isIncome ? 'salary' : 'food', widget.type).id;
    _selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final s = Strings(widget.store.language);
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      _snack(s.enterValidAmount);
      return;
    }
    final tx = Transaction(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      type: widget.type,
      categoryId: _selectedCategory,
      amount: amount,
      date: _selectedDate,
      note: _noteController.text.trim(),
    );
    await widget.store.add(tx);
    if (mounted) Navigator.of(context).pop();
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final s = Strings(widget.store.language);
    final accent = _isIncome ? p.income : p.expense;
    return Scaffold(
      backgroundColor: p.bg,
      appBar: AppBar(
        title: Text(_isIncome ? s.addIncome : s.addExpense),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          _AmountCard(accent: accent, controller: _amountController, strings: s),
          const SizedBox(height: 20),
          Text(s.category,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: p.textSecondary)),
          const SizedBox(height: 10),
          _CategoryGrid(
            type: widget.type,
            selected: _selectedCategory,
            strings: s,
            onSelect: (id) => setState(() => _selectedCategory = id),
          ),
          const SizedBox(height: 20),
          Text(s.date,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: p.textSecondary)),
          const SizedBox(height: 10),
          InkWell(
            onTap: () => _pickDate(accent),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              decoration: BoxDecoration(
                color: p.bgElevated,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: p.cardBorder),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 17, color: p.textMuted),
                  const SizedBox(width: 10),
                  Text(
                      widget.store.language == 'ar'
                          ? DateFormat('EEEE، d MMMM y', 'ar').format(_selectedDate)
                          : DateFormat('EEEE, d MMMM y', 'en').format(_selectedDate),
                      style: TextStyle(color: p.textPrimary, fontSize: 14)),
                  const Spacer(),
                  Icon(Icons.chevron_left, size: 20, color: p.textMuted),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _noteController,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: s.note,
              prefixIcon: const Icon(Icons.notes_outlined),
              hintText: s.noteHint,
            ),
          ),
          const SizedBox(height: 22),
          ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: Colors.white,
              textStyle: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700),
            ),
            child: Text(s.saveTransaction),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate(Color accent) async {
    final p = context.palette;
    final s = Strings(widget.store.language);
    final d = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      helpText: s.chooseDate,
      cancelText: s.cancel,
      confirmText: s.ok,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme(
            brightness: Theme.of(context).brightness,
            primary: accent,
            secondary: accent,
            surface: p.card,
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onSurface: p.textPrimary,
            onError: Colors.white,
            error: p.expense,
          ),
        ),
        child: child!,
      ),
    );
    if (d != null) setState(() => _selectedDate = d);
  }
}

class _AmountCard extends StatelessWidget {
  final Color accent;
  final TextEditingController controller;
  final Strings strings;

  const _AmountCard({
    required this.accent,
    required this.controller,
    required this.strings,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final s = strings;
    final fmt = NumberFormat.currency(
        locale: s.currencyLocale(), symbol: s.currencySymbol());
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accent.withValues(alpha: 0.3),
            p.bgElevated,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accent.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Text(s.amount, style: TextStyle(fontSize: 12, color: p.textSecondary)),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: TextField(
                  controller: controller,
                  autofocus: true,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: p.textPrimary),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    filled: false,
                    hintText: '0',
                    hintStyle: TextStyle(
                        fontSize: 30,
                        color: p.textMuted,
                        fontWeight: FontWeight.w700),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 6, right: 6),
                child: Text(s.currencySymbol(),
                    style: TextStyle(color: p.textSecondary)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(fmt.format(0), style: TextStyle(fontSize: 12, color: p.textMuted)),
        ],
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  final TxType type;
  final String selected;
  final Strings strings;
  final ValueChanged<String> onSelect;

  const _CategoryGrid({
    required this.type,
    required this.selected,
    required this.strings,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final categories = AppCategory.byType(type);
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 0.86,
      children: [
        for (final c in categories)
          _CategoryItem(
            cat: c,
            selected: c.id == selected,
            strings: strings,
            onTap: () => onSelect(c.id),
          ),
      ],
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final TxCategory cat;
  final bool selected;
  final Strings strings;
  final VoidCallback onTap;

  const _CategoryItem({
    required this.cat,
    required this.selected,
    required this.strings,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: selected ? cat.color.withValues(alpha: 0.22) : p.bgElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? cat.color : p.cardBorder,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(cat.icon, color: cat.color, size: 22),
            const SizedBox(height: 6),
            Text(cat.localName(strings.language),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  color: selected ? p.textPrimary : p.textSecondary,
                )),
          ],
        ),
      ),
    );
  }
}