import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/strings.dart';
import '../models/transaction.dart';
import '../store/masrofy_store.dart';
import '../theme/app_theme.dart';

/// صف عملية مالي: يعرض تعديلاً وحذفاً واضحين مع تأكيد وتراجع فوري.
class TxTile extends StatefulWidget {
  final Transaction tx;
  final Strings strings;
  final MasrofyStore store;
  final VoidCallback? onEdit;
  final bool showCheck;

  const TxTile({
    super.key,
    required this.tx,
    required this.strings,
    required this.store,
    this.onEdit,
    this.showCheck = false,
  });

  @override
  State<TxTile> createState() => _TxTileState();
}

class _TxTileState extends State<TxTile> {
  bool _deleting = false;

  Future<bool> _confirmDelete() async {
    final s = widget.strings;
    final p = context.palette;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.deleteTransactionTitle),
        content: Text(s.deleteTransactionMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(s.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: p.expense),
            child: Text(s.delete),
          ),
        ],
      ),
    );
    return result == true;
  }

  Future<void> _delete() async {
    if (_deleting) return;
    setState(() => _deleting = true);
    final removed = await widget.store.remove(widget.tx.id);
    if (!mounted) return;
    setState(() => _deleting = false);
    if (removed == null) return;
    final s = widget.strings;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(s.deleted),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: s.undo,
          onPressed: () => widget.store.restore(removed),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final s = widget.strings;
    final tx = widget.tx;
    final cat = AppCategory.byId(tx.categoryId, tx.type);
    final isIncome = tx.type == TxType.income;
    final sign = isIncome ? '+' : '-';
    final fmt = NumberFormat.decimalPattern(s.dateLocale());

    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      child: Row(
        children: [
          if (widget.showCheck)
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
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.showCheck && tx.note.isNotEmpty
                      ? tx.note
                      : cat.localName(s.language),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: p.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  tx.note.isNotEmpty &&
                          (!widget.showCheck ||
                              tx.note != cat.localName(s.language))
                      ? tx.note
                      : DateFormat('d MMMM', s.dateLocale()).format(tx.date),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: p.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$sign${fmt.format(tx.amount)} ${s.currencySymbol()}',
                style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: isIncome ? p.income : p.expense),
              ),
              const SizedBox(height: 2),
              Text(DateFormat('d MMM', s.dateLocale()).format(tx.date),
                  style: TextStyle(fontSize: 10, color: p.textMuted)),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: s.edit,
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints.tightFor(width: 32, height: 32),
                padding: EdgeInsets.zero,
                icon: Icon(Icons.edit_outlined, size: 17, color: p.textMuted),
                onPressed: widget.onEdit,
              ),
              IconButton(
                tooltip: s.delete,
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints.tightFor(width: 32, height: 32),
                padding: EdgeInsets.zero,
                icon: _deleting
                    ? SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: p.expense),
                      )
                    : Icon(Icons.delete_outline, size: 18, color: p.expense),
                onPressed: _deleting ? null : _delete,
              ),
            ],
          ),
        ],
      ),
    );

    return Dismissible(
      key: ValueKey(tx.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(),
      onDismissed: (_) => _delete(),
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
