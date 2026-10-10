import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/strings.dart';
import '../models/transaction.dart';
import '../store/masrofy_store.dart';
import '../theme/app_theme.dart';
import '../widgets/pickers.dart';
import '../widgets/pie_chart.dart';
import '../widgets/tx_tile.dart';
import 'add_transaction_screen.dart';
import 'budget_screen.dart';
import 'reports_screen.dart';
import 'settings_screen.dart';
import 'transactions_screen.dart';

class RootScreen extends StatefulWidget {
  final MasrofyStore store;

  const RootScreen({super.key, required this.store});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final s = Strings(widget.store.language);
    final store = widget.store;
    final p = context.palette;

    final pages = [
      DashboardPage(store: store, onViewAll: () => setState(() => _index = 1)),
      TransactionsPage(store: store),
      ReportsPage(store: store),
      SettingsPage(store: store),
    ];

    return Scaffold(
      backgroundColor: p.bg,
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: _ThemedNavBar(
        index: _index,
        onChanged: (i) => setState(() => _index = i),
        palette: p,
        items: [
          (Icons.home_outlined, Icons.home_rounded, s.navHome),
          (Icons.receipt_long_outlined, Icons.receipt_long_rounded,
              s.navTransactions),
          (Icons.pie_chart_outline, Icons.pie_chart_rounded, s.navReports),
          (Icons.settings_outlined, Icons.settings_rounded, s.navSettings),
        ],
      ),
    );
  }
}

class _ThemedNavBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;
  final MasrofyPalette palette;
  final List<(IconData, IconData, String)> items;

  const _ThemedNavBar({
    required this.index,
    required this.onChanged,
    required this.palette,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: palette.bgElevated,
        border: Border(top: BorderSide(color: palette.cardBorder)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 66,
          child: Row(
            children: List.generate(items.length, (i) {
              final selected = i == index;
              final it = items[i];
              final color =
                  selected ? palette.accent : palette.textMuted;
              return Expanded(
                child: InkWell(
                  onTap: () => onChanged(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(selected ? it.$2 : it.$1, color: color, size: 24),
                      const SizedBox(height: 4),
                      Text(
                        it.$3,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              selected ? FontWeight.w800 : FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  final MasrofyStore store;
  final VoidCallback onViewAll;

  const DashboardPage({super.key, required this.store, required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    final s = Strings(store.language);
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final p = context.palette;
        final isDark = store.darkMode;
        final fmt = NumberFormat.currency(
            locale: s.currencyLocale(), symbol: s.currencySymbol());
        final breakdown = store.monthExpenseBreakdown();
        final expenseTotal = breakdown.fold<double>(0, (a, e) => a + e.value);
        final recent = store.recent(5);

        return SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
            children: [
              _Header(store: store, strings: s),
              const SizedBox(height: 20),
              _BalancePanel(
                store: store,
                strings: s,
                fmt: fmt,
                isDark: isDark,
                palette: p,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      label: s.addIncome,
                      icon: Icons.add,
                      color: p.income,
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => AddTransactionScreen(
                            store: store, type: TxType.income),
                      )),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionButton(
                      label: s.addExpense,
                      icon: Icons.remove,
                      color: p.expense,
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => AddTransactionScreen(
                            store: store, type: TxType.expense),
                      )),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              _Panel(
                palette: p,
                children: [
                  _SubHeader(title: s.expenseBreakdown),
                  const SizedBox(height: 14),
                  _BreakdownContent(
                    entries: breakdown,
                    total: expenseTotal,
                    strings: s,
                    palette: p,
                  ),
                  _PanelDivider(palette: p),
                  _SubHeader(title: s.expenseDistribution),
                  const SizedBox(height: 14),
                  _PieContent(
                    entries: breakdown,
                    total: expenseTotal,
                    strings: s,
                    palette: p,
                  ),
                  _PanelDivider(palette: p),
                  _SubHeader(
                      title: s.recentTransactions,
                      action: s.viewAll,
                      onTap: onViewAll),
                  const SizedBox(height: 2),
                  _RecentContent(items: recent, strings: s, palette: p),
                ],
              ),
              const SizedBox(height: 24),
              _SectionTitle(
                  title: s.monthlyBudget,
                  action: s.manageBudget,
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => BudgetScreen(store: store),
                  ))),
              const SizedBox(height: 12),
              _BudgetSection(store: store, strings: s, palette: p),
            ],
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  final MasrofyStore store;
  final Strings strings;

  const _Header({required this.store, required this.strings});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final s = strings;
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: p.bgElevated,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: p.cardBorder),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset('assets/icon/app_icon.png', fit: BoxFit.cover),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.appName,
                  style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      color: p.textPrimary)),
              Text(s.appSubtitle,
                  style: TextStyle(fontSize: 11, color: p.textSecondary)),
            ],
          ),
        ),
        IconButton(
          tooltip: store.darkMode ? s.themeCream : s.themeGreen,
          onPressed: () => store.toggleTheme(),
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) =>
                RotationTransition(turns: anim, child: child),
            child: Icon(
              store.darkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              key: ValueKey(store.darkMode),
              size: 22,
              color: p.textSecondary,
            ),
          ),
        ),
        IconButton(
          tooltip: s.languageLabel,
          onPressed: () => showLanguagePicker(context, store),
          icon: Icon(Icons.translate, size: 22, color: p.textSecondary),
        ),
      ],
    );
  }
}

class _BalancePanel extends StatelessWidget {
  final MasrofyStore store;
  final Strings strings;
  final NumberFormat fmt;
  final bool isDark;
  final MasrofyPalette palette;

  const _BalancePanel({
    required this.store,
    required this.strings,
    required this.fmt,
    required this.isDark,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final income = store.monthlyIncome;
    final expense = store.monthlyExpense;
    final remaining = store.monthlyBalance;
    final ratio = income > 0 ? (expense / income).clamp(0.0, 1.0) : 0.0;

    final bg = isDark ? p.bgElevated : const Color(0xFF0D221C);
    final fg = isDark ? p.textPrimary : Colors.white;
    final sub = isDark ? p.textSecondary : const Color(0xFFB9CCC4);
    final barColor = isDark ? p.accent : Colors.white;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: isDark ? p.cardBorder : Colors.transparent,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : const Color(0xFF0D221C))
                .withValues(alpha: isDark ? 0.35 : 0.18),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(strings.remainingThisMonth,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: sub)),
              const Spacer(),
              InkWell(
                onTap: () => showMonthPicker(context, store),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.calendar_month_outlined, size: 14, color: sub),
                      const SizedBox(width: 6),
                      Text(
                          DateFormat('MMMM y', store.language)
                              .format(store.selectedMonth),
                          style: TextStyle(fontSize: 12, color: sub)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(fmt.format(remaining),
              style: TextStyle(
                  fontSize: 32, fontWeight: FontWeight.w900, color: fg)),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 9,
              backgroundColor: Colors.white.withValues(alpha: 0.18),
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('${(ratio * 100).round()}%',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: barColor)),
              const SizedBox(width: 6),
              Text(strings.incomeUsed,
                  style: TextStyle(fontSize: 11, color: sub)),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: strings.income,
                  amount: fmt.format(income),
                  solid: const Color(0xFF2FBF71),
                  pastel: const Color(0xFFDCF2E6),
                  icon: Icons.arrow_downward_rounded,
                  isDark: isDark,
                  palette: p,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: strings.expenses,
                  amount: fmt.format(expense),
                  solid: const Color(0xFFE5544B),
                  pastel: const Color(0xFFFBE0DE),
                  icon: Icons.arrow_upward_rounded,
                  isDark: isDark,
                  palette: p,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String amount;
  final Color solid;
  final Color pastel;
  final IconData icon;
  final bool isDark;
  final MasrofyPalette palette;

  const _StatCard({
    required this.label,
    required this.amount,
    required this.solid,
    required this.pastel,
    required this.icon,
    required this.isDark,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? solid : pastel;
    final fg = isDark ? Colors.white : const Color(0xFF1C2A24);
    final fgSoft = isDark ? Colors.white70 : palette.textSecondary;
    final iconBg = isDark ? Colors.white24 : solid.withValues(alpha: 0.18);
    final iconColor = isDark ? Colors.white : solid;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: solid.withValues(alpha: 0.35),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 12),
          Text(label,
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600, color: fgSoft)),
          const SizedBox(height: 4),
          Text(amount,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w900, color: fg)),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 17, color: color),
              const SizedBox(width: 8),
              Text(label,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: color)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  final String? action;

  const _SectionTitle({required this.title, this.onTap, this.action});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      children: [
        Text(title,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w900, color: p.textPrimary)),
        const Spacer(),
        if (onTap != null)
          GestureDetector(
            onTap: onTap,
            child: Text(action ?? '',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: p.accent)),
          ),
      ],
    );
  }
}

class _Panel extends StatelessWidget {
  final MasrofyPalette palette;
  final List<Widget> children;

  const _Panel({required this.palette, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

class _PanelDivider extends StatelessWidget {
  final MasrofyPalette palette;

  const _PanelDivider({required this.palette});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Divider(height: 1, thickness: 0.7, color: palette.cardBorder),
    );
  }
}

class _SubHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onTap;

  const _SubHeader({required this.title, this.action, this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      children: [
        Text(title,
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: p.textPrimary)),
        const Spacer(),
        if (onTap != null)
          GestureDetector(
            onTap: onTap,
            child: Text(action ?? '',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: p.accent)),
          ),
      ],
    );
  }
}

class _BudgetSection extends StatelessWidget {
  final MasrofyStore store;
  final Strings strings;
  final MasrofyPalette palette;

  const _BudgetSection({
    required this.store,
    required this.strings,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final rows = <TxCategory>[];
    for (final c in store.expenseCategories) {
      if (store.budgetFor(c.id) > 0 || store.spentFor(c.id) > 0) rows.add(c);
    }

    if (rows.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        decoration: BoxDecoration(
          color: p.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: p.cardBorder),
        ),
        child: Column(
          children: [
            Icon(Icons.savings_outlined,
                size: 34, color: p.textMuted.withValues(alpha: 0.7)),
            const SizedBox(height: 10),
            Text(strings.budgetEmpty,
                style: TextStyle(
                    fontWeight: FontWeight.w800, color: p.textPrimary)),
            const SizedBox(height: 4),
            Text(strings.budgetEmptyHint,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: p.textMuted)),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => BudgetScreen(store: store),
              )),
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: Text(strings.manageBudget),
            ),
          ],
        ),
      );
    }

    return _Panel(
      palette: p,
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          _BudgetSectionRow(
            cat: rows[i],
            limit: store.budgetFor(rows[i].id),
            spent: store.spentFor(rows[i].id),
            strings: strings,
            palette: p,
          ),
          if (i != rows.length - 1) const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class _BudgetSectionRow extends StatelessWidget {
  final TxCategory cat;
  final double limit;
  final double spent;
  final Strings strings;
  final MasrofyPalette palette;

  const _BudgetSectionRow({
    required this.cat,
    required this.limit,
    required this.spent,
    required this.strings,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final fmt = NumberFormat.decimalPattern(strings.dateLocale());
    final hasLimit = limit > 0;
    final over = hasLimit && spent > limit;
    final ratio = hasLimit ? (spent / limit).clamp(0.0, 1.0) : 0.0;
    final barColor = over ? p.expense : cat.color;

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
              child: Text(cat.localName(strings.language),
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: p.textPrimary)),
            ),
            Text(
              hasLimit
                  ? '${fmt.format(spent)} / ${fmt.format(limit)}'
                  : strings.noLimit,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: over ? FontWeight.w700 : FontWeight.w500,
                  color: over ? p.expense : p.textMuted),
            ),
          ],
        ),
        const SizedBox(height: 8),
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
    );
  }
}

class _BreakdownContent extends StatelessWidget {
  final List<MapEntry<String, double>> entries;
  final double total;
  final Strings strings;
  final MasrofyPalette palette;

  const _BreakdownContent({
    required this.entries,
    required this.total,
    required this.strings,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final p = palette;
    if (entries.isEmpty) {
      return _EmptyBlock(text: strings.noData, palette: p);
    }
    return Column(
      children: [
        for (var i = 0; i < entries.length; i++) ...[
          _BreakdownRow(
            categoryId: entries[i].key,
            amount: entries[i].value,
            fraction: total > 0 ? entries[i].value / total : 0,
            strings: strings,
            palette: p,
          ),
          if (i != entries.length - 1) const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final String categoryId;
  final double amount;
  final double fraction;
  final Strings strings;
  final MasrofyPalette palette;

  const _BreakdownRow({
    required this.categoryId,
    required this.amount,
    required this.fraction,
    required this.strings,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final cat = AppCategory.byId(categoryId, TxType.expense);
    final fmt = NumberFormat.decimalPattern(strings.dateLocale());
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
              child: Text(cat.localName(strings.language),
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

class _PieContent extends StatelessWidget {
  final List<MapEntry<String, double>> entries;
  final double total;
  final Strings strings;
  final MasrofyPalette palette;

  const _PieContent({
    required this.entries,
    required this.total,
    required this.strings,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final fmt = NumberFormat.decimalPattern(strings.dateLocale());
    final slices = [
      for (final e in entries)
        PieSlice(
          value: e.value,
          color: AppCategory.byId(e.key, TxType.expense).color,
        ),
    ];
    return Column(
      children: [
        PieChart(
          slices: slices,
          emptyColor: p.cardBorder,
          size: 170,
          thickness: 24,
          center: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(strings.totalLabel,
                  style: TextStyle(fontSize: 11, color: p.textMuted)),
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
        Wrap(
          spacing: 12,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: [
            for (final e in entries)
              _LegendDot(
                color: AppCategory.byId(e.key, TxType.expense).color,
                label: AppCategory.byId(e.key, TxType.expense)
                    .localName(strings.language),
                value: total > 0 ? e.value / total : 0,
                palette: p,
              ),
          ],
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  final double value;
  final MasrofyPalette palette;

  const _LegendDot({
    required this.color,
    required this.label,
    required this.value,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text('$label ${(value * 100).round()}%',
            style: TextStyle(fontSize: 11, color: palette.textSecondary)),
      ],
    );
  }
}

class _RecentContent extends StatelessWidget {
  final List<Transaction> items;
  final Strings strings;
  final MasrofyPalette palette;

  const _RecentContent({
    required this.items,
    required this.strings,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final p = palette;
    if (items.isEmpty) {
      return _EmptyBlock(text: strings.noTransactions, palette: p);
    }
    return Column(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          TxTile(tx: items[i], strings: strings, showCheck: true),
          if (i != items.length - 1)
            Divider(
                height: 1,
                thickness: 0.6,
                indent: 68,
                endIndent: 4,
                color: p.cardBorder),
        ],
      ],
    );
  }
}

class _EmptyBlock extends StatelessWidget {
  final String text;
  final MasrofyPalette palette;

  const _EmptyBlock({required this.text, required this.palette});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 22),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined,
              size: 34, color: palette.textMuted.withValues(alpha: 0.6)),
          const SizedBox(height: 8),
          Text(text, style: TextStyle(color: palette.textMuted)),
        ],
      ),
    );
  }
}
