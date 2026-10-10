import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/strings.dart';
import '../store/masrofy_store.dart';
import '../theme/app_theme.dart';
import '../widgets/pickers.dart';
import '../widgets/tx_tile.dart';

class TransactionsPage extends StatelessWidget {
  final MasrofyStore store;

  const TransactionsPage({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final s = Strings(store.language);
    final p = context.palette;
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final items = store.monthTransactions();
        final monthLabel =
            DateFormat('MMMM y', store.language).format(store.selectedMonth);
        return SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
                child: Row(
                  children: [
                    Text(s.navTransactions,
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
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 2, 22, 8),
                child: Text(s.transactionsCount(items.length),
                    style: TextStyle(fontSize: 12, color: p.textMuted)),
              ),
              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.receipt_long_outlined,
                                size: 44,
                                color: p.textMuted.withValues(alpha: 0.5)),
                            const SizedBox(height: 10),
                            Text(s.noTransactionsThisMonth,
                                style: TextStyle(color: p.textMuted)),
                          ],
                        ),
                      )
                    : Container(
                        margin: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                        decoration: BoxDecoration(
                          color: p.card,
                          borderRadius: BorderRadius.circular(20),
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
                          itemBuilder: (context, i) => TxTile(
                            tx: items[i],
                            strings: s,
                            onDelete: () => store.remove(items[i].id),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
