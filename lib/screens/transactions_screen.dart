import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/strings.dart';
import '../models/transaction.dart';
import '../store/masrofy_store.dart';
import '../theme/app_theme.dart';
import '../widgets/pickers.dart';
import '../widgets/tx_tile.dart';
import 'add_transaction_screen.dart';

class TransactionsPage extends StatefulWidget {
  final MasrofyStore store;

  const TransactionsPage({super.key, required this.store});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final _queryController = TextEditingController();
  TxType? _typeFilter;
  String? _categoryFilter;
  String _sortField = 'date';
  bool _descending = true;

  List<Transaction> _filtered() {
    final items = widget.store.monthTransactions();
    final q = _queryController.text.trim().toLowerCase();
    final filtered = items.where((tx) {
      if (_typeFilter != null && tx.type != _typeFilter) return false;
      if (_categoryFilter != null && tx.categoryId != _categoryFilter) {
        return false;
      }
      if (q.isNotEmpty && !tx.note.toLowerCase().contains(q)) return false;
      return true;
    }).toList();

    filtered.sort((a, b) {
      final result = _sortField == 'amount'
          ? a.amountCents.compareTo(b.amountCents)
          : a.date.compareTo(b.date);
      return _descending ? -result : result;
    });
    return filtered;
  }

  bool get _hasFilters =>
      _queryController.text.trim().isNotEmpty ||
      _typeFilter != null ||
      _categoryFilter != null;

  String _categoryLabel(String id, String language) {
    for (final cat in [...AppCategory.income, ...AppCategory.allExpense]) {
      if (cat.id == id) return cat.localName(language);
    }
    return id;
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  void _openEdit(Transaction tx) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => AddTransactionScreen(
        store: widget.store,
        type: tx.type,
        editing: tx,
      ),
    ));
  }

  void _resetFilters() {
    setState(() {
      _queryController.clear();
      _typeFilter = null;
      _categoryFilter = null;
      _sortField = 'date';
      _descending = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = Strings(widget.store.language);
    final p = context.palette;
    return AnimatedBuilder(
      animation: widget.store,
      builder: (context, _) {
        final items = _filtered();
        final monthLabel =
            DateFormat('MMMM y', widget.store.language).format(widget.store.selectedMonth);
        final categories = <String>{
          ...AppCategory.income.map((c) => c.id),
          ...AppCategory.allExpense.map((c) => c.id),
          ...items.map((t) => t.categoryId),
        }.toList()..sort();

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
                        onTap: () => showMonthPicker(context, widget.store),
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
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                child: TextField(
                  onChanged: (v) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: s.search,
                    prefixIcon: const Icon(Icons.search),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    suffixIcon: _queryController.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () =>
                                setState(() => _queryController.clear()),
                          ),
                  ),
                ),
              ),
              SizedBox(
                height: 42,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _FilterChip(
                      label: s.filterAll,
                      selected: _typeFilter == null,
                      palette: p,
                      onTap: () => setState(() => _typeFilter = null),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: s.filterIncome,
                      selected: _typeFilter == TxType.income,
                      palette: p,
                      onTap: () =>
                          setState(() => _typeFilter = TxType.income),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: s.filterExpense,
                      selected: _typeFilter == TxType.expense,
                      palette: p,
                      onTap: () =>
                          setState(() => _typeFilter = TxType.expense),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String?>(
                        initialValue: _categoryFilter,
                        isDense: true,
                        decoration: InputDecoration(
                          labelText: s.category,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                        ),
                        items: [
                          DropdownMenuItem<String?>(
                              value: null, child: Text(s.allCategories)),
                          for (final id in categories)
                            DropdownMenuItem<String?>(
                              value: id,
                              child: Text(
                                _categoryLabel(id, widget.store.language),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                        onChanged: (v) =>
                            setState(() => _categoryFilter = v),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _sortField,
                        isDense: true,
                        decoration: InputDecoration(
                          labelText: s.sortBy,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                        ),
                        items: [
                          DropdownMenuItem(
                              value: 'date', child: Text(s.sortDate)),
                          DropdownMenuItem(
                              value: 'amount', child: Text(s.sortAmount)),
                        ],
                        onChanged: (v) => setState(() => _sortField = v ?? 'date'),
                      ),
                    ),
                    IconButton(
                      tooltip: _descending ? s.newestFirst : s.oldestFirst,
                      onPressed: () =>
                          setState(() => _descending = !_descending),
                      icon: Icon(
                          _descending
                              ? Icons.arrow_downward
                              : Icons.arrow_upward,
                          size: 18),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 2, 22, 4),
                child: Row(
                  children: [
                    Text(s.transactionsCount(items.length),
                        style: TextStyle(fontSize: 12, color: p.textMuted)),
                    if (_hasFilters) ...[
                      const Spacer(),
                      TextButton(
                        onPressed: _resetFilters,
                        child: Text(s.cancel),
                      ),
                    ],
                  ],
                ),
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
                            Text(
                              _hasFilters
                                  ? s.noFilterResults
                                  : s.noTransactionsThisMonth,
                              style: TextStyle(color: p.textMuted),
                            ),
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
                          separatorBuilder: (_, _) => Divider(
                            height: 1,
                            thickness: 0.6,
                            indent: 68,
                            endIndent: 16,
                            color: p.cardBorder,
                          ),
                          itemBuilder: (context, i) => TxTile(
                            tx: items[i],
                            strings: s,
                            store: widget.store,
                            onEdit: () => _openEdit(items[i]),
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

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final MasrofyPalette palette;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.palette,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = palette;
    return Material(
      color: selected ? p.accent.withValues(alpha: 0.16) : p.bgElevated,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Center(
            child: Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: selected ? p.accent : p.textSecondary)),
          ),
        ),
      ),
    );
  }
}
