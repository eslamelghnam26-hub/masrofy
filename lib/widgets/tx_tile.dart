import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/strings.dart';
import '../models/transaction.dart';
import '../theme/app_theme.dart';

class TxTile extends StatelessWidget {
  final Transaction tx;
  final Strings strings;
  final VoidCallback? onDelete;
  final bool showCheck;

  const TxTile({
    super.key,
    required this.tx,
    required this.strings,
    this.onDelete,
    this.showCheck = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final s = strings;
    final cat = AppCategory.byId(tx.categoryId, tx.type);
    final isIncome = tx.type == TxType.income;
    final sign = isIncome ? '+' : '-';
    final fmt = NumberFormat.decimalPattern(s.dateLocale());

    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          if (showCheck)
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: p.income.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_circle, size: 22, color: p.income),
            )
          else
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
                Text(
                  showCheck ? tx.note.ifEmpty(cat.localName(s.language)) : cat.localName(s.language),
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: p.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  showCheck
                      ? cat.localName(s.language)
                      : (tx.note.isEmpty
                          ? DateFormat('d MMMM', s.dateLocale()).format(tx.date)
                          : tx.note),
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
                '$sign${fmt.format(tx.amount)} ${s.currencySymbol()}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isIncome ? p.income : p.expense,
                ),
              ),
              const SizedBox(height: 2),
              Text(DateFormat('d MMM', s.dateLocale()).format(tx.date),
                  style: TextStyle(fontSize: 10, color: p.textMuted)),
            ],
          ),
        ],
      ),
    );

    if (onDelete == null) return content;

    return Dismissible(
      key: ValueKey(tx.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete!(),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          color: p.expense.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(Icons.delete_outline, color: p.expense),
      ),
      child: content,
    );
  }
}

extension _StringX on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}
