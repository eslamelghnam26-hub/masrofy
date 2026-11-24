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
        final monthLabel = DateFormat(
          'MMMM y',
          widget.store.language,
        ).format(widget.store.selectedMonth);
        final categories = <String>{
          ...AppCategory.income.map((c) => c.id),
          ...AppCategory.allExpense.map((c) => c.id),
          ...items.map((t) => t.categoryId),
        }.toList()..sort();

        return SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 620;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // الجزء العلوي قابل للتمرير وحده حتى لا يتزاحم مع القائمة
                  // على الشاشات القصيرة أو عند تكبير خط النظام.
                  Flexible(
                    flex: 2,
                    fit: FlexFit.loose,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.zero,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildHeader(s, p, monthLabel),
                          _buildSearchField(s),
                          _buildTypeChips(s, p),
                          _buildFilterFields(s, p, categories, wide),
                          _buildCountRow(s, p, items.length),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: items.isEmpty
                        ? _buildEmptyState(s, p)
                        : _buildList(s, p, items),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildHeader(Strings s, MasrofyPalette p, String monthLabel) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
      child: Row(
        children: [
          Flexible(
            child: Text(
              s.navTransactions,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: p.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 170),
            child: Material(
              color: p.bgElevated,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () => showMonthPicker(context, widget.store),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: p.cardBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.calendar_month_outlined,
                          size: 13, color: p.textSecondary),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          monthLabel,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 12, color: p.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(Strings s) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      child: TextField(
        controller: _queryController,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: s.search,
          prefixIcon: const Icon(Icons.search),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          suffixIcon: _queryController.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => setState(() => _queryController.clear()),
                ),
        ),
      ),
    );
  }

  Widget _buildTypeChips(Strings s, MasrofyPalette p) {
    return SizedBox(
      height: 44,
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
            onTap: () => setState(() => _typeFilter = TxType.income),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: s.filterExpense,
            selected: _typeFilter == TxType.expense,
            palette: p,
            onTap: () => setState(() => _typeFilter = TxType.expense),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterFields(
    Strings s,
    MasrofyPalette p,
    List<String> categories,
    bool wide,
  ) {
    final categoryField = _FilterDropdown<String?>(
      label: s.category,
      value: _categoryFilter,
      palette: p,
      items: [
        DropdownMenuItem<String?>(value: null, child: Text(s.allCategories)),
        for (final id in categories)
          DropdownMenuItem<String?>(
            value: id,
            child: Text(
              _categoryLabel(id, widget.store.language),
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
      onChanged: (v) => setState(() => _categoryFilter = v),
    );

    final sortField = _FilterDropdown<String>(
      label: s.sortBy,
      value: _sortField,
      palette: p,
      items: [
        DropdownMenuItem(value: 'date', child: Text(s.sortDate)),
        DropdownMenuItem(value: 'amount', child: Text(s.sortAmount)),
      ],
      onChanged: (v) => setState(() => _sortField = v ?? 'date'),
    );

    final directionButton = _SortDirectionButton(
      descending: _descending,
      palette: p,
      ascendingLabel: s.oldestFirst,
      descendingLabel: s.newestFirst,
      onTap: () => setState(() => _descending = !_descending),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
      child: wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(flex: 3, child: categoryField),
                const SizedBox(width: 12),
                Expanded(flex: 2, child: sortField),
                const SizedBox(width: 4),
                directionButton,
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                categoryField,
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(child: sortField),
                    const SizedBox(width: 4),
                    directionButton,
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildCountRow(Strings s, MasrofyPalette p, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 8, 14, 4),
      child: Row(
        children: [
          Flexible(
            child: Text(
              s.transactionsCount(count),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: p.textMuted),
            ),
          ),
          if (_hasFilters)
            TextButton(
              onPressed: _resetFilters,
              child: Text(s.cancel),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(Strings s, MasrofyPalette p) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_outlined,
                size: 44, color: p.textMuted.withValues(alpha: 0.5)),
            const SizedBox(height: 10),
            Text(
              _hasFilters ? s.noFilterResults : s.noTransactionsThisMonth,
              textAlign: TextAlign.center,
              style: TextStyle(color: p.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(Strings s, MasrofyPalette p, List<Transaction> items) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 6, 20, 18),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: p.cardBorder),
      ),
      clipBehavior: Clip.antiAlias,
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
    );
  }
}

/// قائمة منسدلة بتسمية مستقلة فوقها؛ تحل مشكلة تداخل الـ label مع حدود الحقل
/// وتضمن ظهور النص الكامل مع اتجاه RTL/LTR بشكل صحيح.
class _FilterDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final MasrofyPalette palette;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.palette,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final p = palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: p.textSecondary,
            ),
          ),
        ),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: p.bgElevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: p.cardBorder),
          ),
          child: DropdownButton<T>(
            value: value,
            isExpanded: true,
            underline: const SizedBox.shrink(),
            icon: Icon(Icons.expand_more, size: 18, color: p.textSecondary),
            iconSize: 18,
            padding: EdgeInsets.zero,
            alignment: AlignmentDirectional.centerStart,
            dropdownColor: p.card,
            borderRadius: BorderRadius.circular(12),
            selectedItemBuilder: (context) => items.map((item) {
              return Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  _menuItemText(item.child),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: p.textPrimary),
                ),
              );
            }).toList(),
            items: items,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  String _menuItemText(Widget child) {
    if (child is Text) return child.data ?? '';
    return label;
  }
}

class _SortDirectionButton extends StatelessWidget {
  final bool descending;
  final MasrofyPalette palette;
  final String ascendingLabel;
  final String descendingLabel;
  final VoidCallback onTap;

  const _SortDirectionButton({
    required this.descending,
    required this.palette,
    required this.ascendingLabel,
    required this.descendingLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = palette;
    return SizedBox(
      width: 44,
      height: 48,
      child: Material(
        color: p.bgElevated,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: p.cardBorder),
            ),
            child: Icon(
              descending ? Icons.arrow_downward : Icons.arrow_upward,
              size: 18,
              color: p.textSecondary,
            ),
          ),
        ),
      ),
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
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: selected ? p.accent : p.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
