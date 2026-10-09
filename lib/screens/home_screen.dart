import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/transaction.dart';
import '../store/masrofy_store.dart';
import '../theme/app_theme.dart';
import 'add_transaction_screen.dart';

class HomeScreen extends StatelessWidget {
  final MasrofyStore store;

  const HomeScreen({super.key, required this.store});

  Future<void> _pickMonth(BuildContext context) async {
    final now = DateTime.now();
    var year = store.selectedMonth.year;
    final months = {
      1: 'يناير', 2: 'فبراير', 3: 'مارس', 4: 'أبريل', 5: 'مايو', 6: 'يونيو',
      7: 'يوليو', 8: 'أغسطس', 9: 'سبتمبر', 10: 'أكتوبر', 11: 'نوفمبر', 12: 'ديسمبر',
    };

    final selected = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 42,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).dividerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => setSheetState(() => year--),
                        icon: const Icon(Icons.chevron_right),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            '$year',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: year < now.year
                            ? () => setSheetState(() => year++)
                            : null,
                        icon: const Icon(Icons.chevron_left),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.7,
                    children: months.entries.map((entry) {
                      final month = DateTime(year, entry.key, 1);
                      final isSelected =
                          month.year == store.selectedMonth.year &&
                              month.month == store.selectedMonth.month;
                      final isFuture = month.isAfter(DateTime(now.year, now.month, 1));
                      return Material(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: !isFuture
                              ? () => Navigator.of(sheetContext).pop(month)
                              : null,
                          child: Center(
                            child: Text(
                              entry.value,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? Colors.white
                                    : Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (selected != null) {
      await store.setMonth(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(store: store, onPickMonth: () => _pickMonth(context)),
            Expanded(child: _TransactionFeed(store: store)),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final MasrofyStore store;
  final VoidCallback onPickMonth;

  const _Header({required this.store, required this.onPickMonth});

  String _monthLabel(DateTime month) {
    return DateFormat('MMMM y', 'ar').format(month);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final fmt = NumberFormat.currency(locale: 'ar', symbol: 'ج.م');
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [p.accent, Color(0xFF4C67F5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.account_balance_wallet_outlined,
                    color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('مصروفي',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: p.textPrimary)),
                    Text('لحظاتك المالية ببساطة',
                        style: TextStyle(fontSize: 12, color: p.textSecondary)),
                  ],
                ),
              ),
              IconButton(
                tooltip: store.darkMode ? 'الوضع الفاتح' : 'الوضع الداكن',
                onPressed: () => store.toggleTheme(),
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, anim) =>
                      RotationTransition(turns: anim, child: child),
                  child: Icon(
                    store.darkMode
                        ? Icons.light_mode_outlined
                        : Icons.dark_mode_outlined,
                    key: ValueKey(store.darkMode),
                    size: 20,
                    color: p.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Material(
                color: p.bgElevated,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: onPickMonth,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: p.cardBorder),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_month_outlined,
                            size: 13, color: p.textSecondary),
                        const SizedBox(width: 6),
                        Text(_monthLabel(store.selectedMonth),
                            style: TextStyle(fontSize: 12, color: p.textSecondary)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          AnimatedBuilder(
            animation: store,
            builder: (context, _) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: store.darkMode
                        ? const [Color(0xFF1D1B33), Color(0xFF16161B)]
                        : const [Color(0xFFEDE8FF), Color(0xFFF2EEFB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: p.cardBorder),
                  boxShadow: [
                    BoxShadow(
                      color: store.darkMode
                          ? const Color(0x667C5CFC)
                          : const Color(0x337C5CFC),
                      blurRadius: 34,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('رصيدك الحالي',
                            style: TextStyle(
                                fontSize: 13, color: store.darkMode ? p.textSecondary : p.textMuted)),
                        const Spacer(),
                        Icon(Icons.visibility_outlined,
                            size: 15, color: store.darkMode ? p.textMuted : p.textSecondary),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(fmt.format(store.balance),
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: store.darkMode ? p.textPrimary : p.textPrimary)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _MiniStat(
                            label: 'الدخل',
                            amount: fmt.format(store.totalIncome),
                            color: p.income,
                            icon: Icons.arrow_downward_rounded,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _MiniStat(
                            label: 'المصروفات',
                            amount: fmt.format(store.totalExpense),
                            color: p.expense,
                            icon: Icons.arrow_upward_rounded,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  label: 'اضافة دخل',
                  icon: Icons.add,
                  income: true,
                  onTap: () async {
                    await Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) =>
                          AddTransactionScreen(store: store, type: TxType.income),
                    ));
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionButton(
                  label: 'اضافة مصروف',
                  icon: Icons.remove,
                  income: false,
                  onTap: () async {
                    await Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) =>
                          AddTransactionScreen(store: store, type: TxType.expense),
                    ));
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String amount;
  final Color color;
  final IconData icon;

  const _MiniStat({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: p.bgElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(fontSize: 11, color: p.textMuted)),
                const SizedBox(height: 2),
                Text(amount,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool income;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.income,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final color = income ? p.income : p.expense;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withValues(alpha: 0.22), color.withValues(alpha: 0.08)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.45)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(label,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: color)),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransactionFeed extends StatelessWidget {
  final MasrofyStore store;

  const _TransactionFeed({required this.store});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final items = store.monthTransactions();
        final monthLabel = DateFormat('MMMM y', 'ar').format(store.selectedMonth);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
              child: Row(
                children: [
                  Text(monthLabel,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: p.textMuted)),
                  const Spacer(),
                  Text('${items.length} عملية',
                      style: TextStyle(fontSize: 11, color: p.textMuted)),
                ],
              ),
            ),
            if (items.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.receipt_long_outlined,
                          size: 42, color: p.textMuted.withValues(alpha: 0.5)),
                      const SizedBox(height: 10),
                      Text('لا توجد عمليات في هذا الشهر',
                          style: TextStyle(color: p.textMuted)),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: p.card,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: p.cardBorder),
                  ),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: items.length,
                    separatorBuilder: (_, j) => Divider(
                        height: 1,
                        thickness: 0.6,
                        indent: 68,
                        endIndent: 16,
                        color: p.cardBorder),
                    itemBuilder: (context, i) {
                      final tx = items[i];
                      return _TxTile(
                        tx: tx,
                        onDelete: () => store.remove(tx.id),
                      );
                    },
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _TxTile extends StatelessWidget {
  final Transaction tx;
  final VoidCallback onDelete;

  const _TxTile({required this.tx, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final cat = AppCategory.byId(tx.categoryId, tx.type);
    final isIncome = tx.type == TxType.income;
    final sign = isIncome ? '+' : '-';
    final fmt = NumberFormat.decimalPattern('ar');

    return Dismissible(
      key: ValueKey(tx.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          color: p.expense.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(Icons.delete_outline, color: p.expense),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: cat.color.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: Icon(cat.icon, size: 20, color: cat.color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cat.name,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: p.textPrimary)),
                  const SizedBox(height: 2),
                  Text(
                    tx.note.isEmpty
                        ? DateFormat('d MMMM', 'ar').format(tx.date)
                        : tx.note,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: p.textMuted),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$sign${fmt.format(tx.amount)} ج.م',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isIncome ? p.income : p.expense,
                  ),
                ),
                const SizedBox(height: 2),
                Text(DateFormat('d MMM', 'ar').format(tx.date),
                    style: TextStyle(fontSize: 10, color: p.textMuted)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}