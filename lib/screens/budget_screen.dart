import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../l10n/strings.dart';
import '../models/transaction.dart';
import '../store/masrofy_store.dart';
import '../theme/app_theme.dart';

class BudgetScreen extends StatelessWidget {
  final MasrofyStore store;

  const BudgetScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final s = Strings(store.language);
        final p = context.palette;
        final custom = store.customCategories;
        final builtIn = AppCategory.expense;

        return Scaffold(
          backgroundColor: p.bg,
          appBar: AppBar(
            title: Text(s.manageBudget),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
            children: [
              _BudgetSummary(store: store, strings: s, palette: p),
              const SizedBox(height: 14),
              Text(s.budgetInfo,
                  style: TextStyle(fontSize: 12, color: p.textMuted)),
              const SizedBox(height: 22),
              _SectionLabel(text: s.customCategoriesLabel, palette: p),
              const SizedBox(height: 10),
              for (final cat in custom) ...[
                _CategoryBudgetTile(
                  cat: cat,
                  limit: store.budgetFor(cat.id),
                  spent: store.spentFor(cat.id),
                  strings: s,
                  palette: p,
                  onTap: () => _editBudget(context, store, cat),
                  onDelete: () => store.removeCustomCategory(cat.id),
                ),
                const SizedBox(height: 10),
              ],
              _AddCategoryButton(
                label: s.addCategory,
                palette: p,
                onTap: () => _addCategory(context, store),
              ),
              const SizedBox(height: 24),
              _SectionLabel(text: s.builtInCategoriesLabel, palette: p),
              const SizedBox(height: 10),
              for (final cat in builtIn) ...[
                _CategoryBudgetTile(
                  cat: cat,
                  limit: store.budgetFor(cat.id),
                  spent: store.spentFor(cat.id),
                  strings: s,
                  palette: p,
                  onTap: () => _editBudget(context, store, cat),
                ),
                const SizedBox(height: 10),
              ],
            ],
          ),
        );
      },
    );
  }

  String _trimNum(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  Future<void> _editBudget(
      BuildContext context, MasrofyStore store, TxCategory cat) async {
    final s = Strings(store.language);
    final current = store.budgetFor(cat.id);
    final controller =
        TextEditingController(text: current > 0 ? _trimNum(current) : '');
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(cat.icon, color: cat.color),
            const SizedBox(width: 8),
            Expanded(child: Text(cat.localName(store.language))),
          ],
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
          ],
          decoration: InputDecoration(
            labelText: s.monthlyLimit,
            hintText: s.limitEmptyHint,
            prefixIcon: const Icon(Icons.payments_outlined),
          ),
        ),
        actions: [
          if (current > 0)
            TextButton(
              onPressed: () {
                store.setBudget(cat.id, 0);
                Navigator.of(ctx).pop();
              },
              child: Text(s.delete),
            ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(s.cancel),
          ),
          FilledButton(
            onPressed: () {
              final v = double.tryParse(controller.text.trim());
              store.setBudget(cat.id, v ?? 0);
              Navigator.of(ctx).pop();
            },
            child: Text(s.save),
          ),
        ],
      ),
    );
    controller.dispose();
  }

  Future<void> _addCategory(BuildContext context, MasrofyStore store) async {
    final s = Strings(store.language);
    final controller = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.newCategory),
        content: TextField(
          controller: controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: s.categoryName,
            hintText: s.categoryNameHint,
            prefixIcon: const Icon(Icons.label_outline),
          ),
          onSubmitted: (value) {
            store.addCustomCategory(value);
            Navigator.of(ctx).pop();
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(s.cancel),
          ),
          FilledButton(
            onPressed: () {
              store.addCustomCategory(controller.text);
              Navigator.of(ctx).pop();
            },
            child: Text(s.save),
          ),
        ],
      ),
    );
    controller.dispose();
  }
}

class _BudgetSummary extends StatelessWidget {
  final MasrofyStore store;
  final Strings strings;
  final MasrofyPalette palette;

  const _BudgetSummary({
    required this.store,
    required this.strings,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final fmt = NumberFormat.currency(
        locale: strings.currencyLocale(), symbol: strings.currencySymbol());
    final total = store.monthlyBudgetTotal;
    final spent = store.monthlyExpense;
    final ratio = total > 0 ? (spent / total).clamp(0.0, 1.0) : 0.0;
    final isDark = store.darkMode;
    final bg = isDark ? p.bgElevated : const Color(0xFF0D221C);
    final fg = isDark ? p.textPrimary : Colors.white;
    final sub = isDark ? p.textSecondary : const Color(0xFFB9CCC4);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: isDark ? p.cardBorder : Colors.transparent),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : const Color(0xFF0D221C))
                .withValues(alpha: isDark ? 0.35 : 0.16),
            blurRadius: 26,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(strings.totalBudget,
              style: TextStyle(fontSize: 13, color: sub)),
          const SizedBox(height: 8),
          Text(fmt.format(total),
              style: TextStyle(
                  fontSize: 28, fontWeight: FontWeight.w900, color: fg)),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 9,
              backgroundColor: Colors.white.withValues(alpha: 0.18),
              valueColor:
                  AlwaysStoppedAnimation<Color>(isDark ? p.accent : Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text('${strings.spent}: ${fmt.format(spent)}',
                  style: TextStyle(fontSize: 12, color: sub)),
              const Spacer(),
              Text('${strings.remaining}: ${fmt.format(total - spent)}',
                  style: TextStyle(fontSize: 12, color: sub)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final MasrofyPalette palette;

  const _SectionLabel({required this.text, required this.palette});

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: palette.textPrimary));
  }
}

class _CategoryBudgetTile extends StatelessWidget {
  final TxCategory cat;
  final double limit;
  final double spent;
  final Strings strings;
  final MasrofyPalette palette;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const _CategoryBudgetTile({
    required this.cat,
    required this.limit,
    required this.spent,
    required this.strings,
    required this.palette,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final fmt = NumberFormat.decimalPattern(strings.dateLocale());
    final hasLimit = limit > 0;
    final over = hasLimit && spent > limit;
    final ratio = hasLimit ? (spent / limit).clamp(0.0, 1.0) : 0.0;
    final barColor = over ? p.expense : cat.color;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 13, 10, 13),
          decoration: BoxDecoration(
            color: p.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: p.cardBorder),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: cat.color.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(cat.icon, size: 19, color: cat.color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(cat.localName(strings.language),
                            style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: p.textPrimary)),
                        const SizedBox(height: 2),
                        Text(
                          hasLimit
                              ? '${fmt.format(spent)} / ${fmt.format(limit)}'
                              : '${strings.noLimit} • ${fmt.format(spent)}',
                          style: TextStyle(
                              fontSize: 11,
                              color: over ? p.expense : p.textMuted,
                              fontWeight:
                                  over ? FontWeight.w700 : FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  if (onDelete != null)
                    IconButton(
                      tooltip: strings.delete,
                      onPressed: onDelete,
                      icon: Icon(Icons.delete_outline,
                          size: 20, color: p.textMuted),
                    ),
                  Icon(Icons.chevron_left, size: 20, color: p.textMuted),
                ],
              ),
              if (hasLimit) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 7,
                    backgroundColor: p.cardBorder,
                    valueColor: AlwaysStoppedAnimation<Color>(barColor),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AddCategoryButton extends StatelessWidget {
  final String label;
  final MasrofyPalette palette;
  final VoidCallback onTap;

  const _AddCategoryButton({
    required this.label,
    required this.palette,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = palette;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
                color: p.accent.withValues(alpha: 0.5), width: 1.2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, size: 18, color: p.accent),
              const SizedBox(width: 8),
              Text(label,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: p.accent)),
            ],
          ),
        ),
      ),
    );
  }
}
