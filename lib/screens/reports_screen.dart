import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/strings.dart';
import '../models/transaction.dart';
import '../store/masrofy_store.dart';
import '../theme/app_theme.dart';
import '../widgets/pickers.dart';
import '../widgets/pie_chart.dart';

class ReportsPage extends StatelessWidget {
  final MasrofyStore store;

  const ReportsPage({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final s = Strings(store.language);
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final p = context.palette;
        final fmt = NumberFormat.currency(
            locale: s.currencyLocale(), symbol: s.currencySymbol());
        final breakdown = store.monthExpenseBreakdown();
        final total = breakdown.fold<double>(0, (a, e) => a + e.value);
        final monthLabel =
            DateFormat('MMMM y', store.language).format(store.selectedMonth);
        final slices = [
          for (final e in breakdown)
            PieSlice(
                value: e.value,
                color: AppCategory.byId(e.key, TxType.expense).color),
        ];

        return SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
            children: [
              Row(
                children: [
                  Text(s.navReports,
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: p.textPrimary)),
                  const Spacer(),
                  Material(
                    color: p.bgElevated,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () => showMonthPicker(context, store),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: p.cardBorder),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_month_outlined,
                                size: 13, color: p.textSecondary),
                            const SizedBox(width: 6),
                            Text(monthLabel,
                                style: TextStyle(
                                    fontSize: 12, color: p.textSecondary)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _SummaryTile(
                      label: s.income,
                      value: fmt.format(store.monthlyIncome),
                      color: p.income,
                      palette: p,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryTile(
                      label: s.expenses,
                      value: fmt.format(store.monthlyExpense),
                      color: p.expense,
                      palette: p,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: p.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: p.cardBorder),
                ),
                child: Column(
                  children: [
                    PieChart(
                      slices: slices,
                      emptyColor: p.cardBorder,
                      size: 180,
                      thickness: 26,
                      center: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(s.totalLabel,
                              style:
                                  TextStyle(fontSize: 11, color: p.textMuted)),
                          const SizedBox(height: 2),
                          Text(fmt.format(total),
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: p.textPrimary)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (breakdown.isEmpty)
                      Text(s.noData,
                          style: TextStyle(color: p.textMuted))
                    else
                      Wrap(
                        spacing: 12,
                        runSpacing: 10,
                        alignment: WrapAlignment.center,
                        children: [
                          for (final e in breakdown)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                      color: AppCategory.byId(
                                              e.key, TxType.expense)
                                          .color,
                                      shape: BoxShape.circle),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                    '${AppCategory.byId(e.key, TxType.expense).localName(s.language)} ${total > 0 ? (e.value / total * 100).round() : 0}%',
                                    style: TextStyle(
                                        fontSize: 11, color: p.textSecondary)),
                              ],
                            ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Text(s.expenseBreakdown,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: p.textPrimary)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                decoration: BoxDecoration(
                  color: p.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: p.cardBorder),
                ),
                child: breakdown.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Center(
                            child: Text(s.noData,
                                style: TextStyle(color: p.textMuted))),
                      )
                    : Column(
                        children: [
                          for (final e in breakdown) ...[
                            _ReportRow(
                              categoryId: e.key,
                              amount: e.value,
                              fraction: total > 0 ? e.value / total : 0,
                              s: s,
                              p: p,
                            ),
                            const SizedBox(height: 14),
                          ],
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final MasrofyPalette palette;

  const _SummaryTile({
    required this.label,
    required this.value,
    required this.color,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: palette.textSecondary)),
          const SizedBox(height: 6),
          Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }
}

class _ReportRow extends StatelessWidget {
  final String categoryId;
  final double amount;
  final double fraction;
  final Strings s;
  final MasrofyPalette p;

  const _ReportRow({
    required this.categoryId,
    required this.amount,
    required this.fraction,
    required this.s,
    required this.p,
  });

  @override
  Widget build(BuildContext context) {
    final cat = AppCategory.byId(categoryId, TxType.expense);
    final fmt = NumberFormat.decimalPattern(s.dateLocale());
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: cat.color.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(cat.icon, size: 17, color: cat.color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(cat.localName(s.language),
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: p.textPrimary)),
            ),
            Text('${(fraction * 100).round()}%',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: cat.color)),
            const SizedBox(width: 8),
            Text(fmt.format(amount),
                style: TextStyle(fontSize: 11, color: p.textMuted)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: fraction.clamp(0.0, 1.0),
            minHeight: 7,
            backgroundColor: p.cardBorder,
            valueColor: AlwaysStoppedAnimation<Color>(cat.color),
          ),
        ),
      ],
    );
  }
}
