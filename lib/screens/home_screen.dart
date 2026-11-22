import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/strings.dart';
import '../models/transaction.dart';
import '../store/masrofy_store.dart';
import '../theme/app_theme.dart';
import '../widgets/pickers.dart';
import '../widgets/pie_chart.dart';
import 'add_transaction_screen.dart';

/// ألوان الهوية الفاتحة (مطابقة للتصميم المرجعي).
const Color _forest = Color(0xFF1E3A2F);
const Color _forestDeep = Color(0xFF0F2E23);
const Color _forestMid = Color(0xFF1E4A38);
const Color _brightGreen = Color(0xFF35D39A);

/// ألوان فئات التحليل (الدائرة المجزّأة).
Color _chartColor(String id) {
  switch (id) {
    case 'food':
      return const Color(0xFF22C55E); // أخضر — طعام ومشروبات
    case 'transport':
      return const Color(0xFFF59E0B); // برتقالي — مواصلات
    case 'entertain':
      return const Color(0xFF3B82F6); // أزرق — ترفيه
    case 'shopping':
    case 'installments':
      return const Color(0xFF8B5CF6); // بنفسجي — مشتريات/أقساط
    default:
      return const Color(0xFF9CA3AF); // رمادي — أخرى
  }
}

class HomeScreen extends StatelessWidget {
  final MasrofyStore store;
  final ValueChanged<int> onOpenTab;

  const HomeScreen({
    super.key,
    required this.store,
    required this.onOpenTab,
  });

  void _openAdd(BuildContext context, TxType type) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => AddTransactionScreen(store: store, type: type),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final s = Strings(store.language);
    final p = context.palette;
    final isDark = store.darkMode;

    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final fmt = NumberFormat.currency(
            locale: s.currencyLocale(), symbol: s.currencySymbol());
        final breakdown = store.monthExpenseBreakdown();
        final expenseTotal =
            breakdown.fold<double>(0, (a, e) => a + e.value);
        final recent = store.recent(5);

        return Stack(
          fit: StackFit.expand,
          children: [
            _HomeBackground(isDark: isDark, base: p.bg),
            SafeArea(
              bottom: false,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                children: [
                  _AppHeader(store: store, strings: s),
                  const SizedBox(height: 16),
                  _WelcomeRow(strings: s),
                  const SizedBox(height: 18),
                  _SummaryCard(
                    store: store,
                    strings: s,
                    fmt: fmt,
                  ),
                  const SizedBox(height: 16),
                  _QuickActions(
                    strings: s,
                    onReports: () => onOpenTab(2),
                    onExpenses: () => onOpenTab(1),
                    onAddExpense: () => _openAdd(context, TxType.expense),
                    onIncome: () => _openAdd(context, TxType.income),
                  ),
                  const SizedBox(height: 18),
                  _CategoryCard(
                    strings: s,
                    entries: breakdown,
                    total: expenseTotal,
                    fmt: fmt,
                    onViewAll: () => onOpenTab(2),
                  ),
                  const SizedBox(height: 18),
                  _RecentCard(
                    store: store,
                    strings: s,
                    items: recent,
                    onViewAll: () => onOpenTab(1),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// خلفية دافئة هادئة: تدرّج أبيض دافئ + لمسات خضراء باهتة.
class _HomeBackground extends StatelessWidget {
  final bool isDark;
  final Color base;

  const _HomeBackground({required this.isDark, required this.base});

  @override
  Widget build(BuildContext context) {
    if (isDark) return ColoredBox(color: base);
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF9F7F2), Color(0xFFF3F1EA), Color(0xFFEEF3EC)],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: -120,
            right: -100,
            child: _Glow(color: const Color(0xFFB7D8C2).withValues(alpha: 0.35)),
          ),
          Positioned(
            bottom: -140,
            left: -110,
            child: _Glow(color: const Color(0xFFCFE6D6).withValues(alpha: 0.30)),
          ),
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  final Color color;

  const _Glow({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    );
  }
}

/// رأس الصفحة: الشعار والاسم يميناً + زر الإشعارات يساراً.
class _AppHeader extends StatelessWidget {
  final MasrofyStore store;
  final Strings strings;

  const _AppHeader({required this.store, required this.strings});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final isDark = store.darkMode;
    final brand = isDark ? p.accent : _forest;
    final s = strings;

    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: brand,
            borderRadius: BorderRadius.circular(13),
            boxShadow: [
              BoxShadow(
                color: brand.withValues(alpha: 0.28),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(Icons.account_balance_wallet_rounded,
              color: Colors.white, size: 22),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.appName,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: brand,
                      height: 1.1)),
              const SizedBox(height: 2),
              Text(s.headerTagline,
                  style: TextStyle(fontSize: 11, color: p.textMuted)),
            ],
          ),
        ),
        _NotificationButton(strings: s),
      ],
    );
  }
}

class _NotificationButton extends StatelessWidget {
  final Strings strings;

  const _NotificationButton({required this.strings});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.noNotifications)),
        );
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: p.card,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: p.cardBorder),
            ),
            child: Icon(Icons.notifications_none_rounded,
                color: p.textSecondary, size: 22),
          ),
          Positioned(
            top: 9,
            right: 10,
            child: Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: p.expense,
                shape: BoxShape.circle,
                border: Border.all(color: p.card, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// قسم الترحيب: نص يميناً + رسمة يساراً.
class _WelcomeRow extends StatelessWidget {
  final Strings strings;

  const _WelcomeRow({required this.strings});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final s = strings;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text('${s.homeGreet} 👋',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: p.textPrimary)),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(s.homeGreetSub,
                  style: TextStyle(fontSize: 12, color: p.textMuted)),
            ],
          ),
        ),
        const SizedBox(width: 12),
        const _WelcomeArt(),
      ],
    );
  }
}

/// رسمة المحفظة والأوراق النقدية والعملات والنبتة على دائرة خضراء باهتة.
class _WelcomeArt extends StatelessWidget {
  const _WelcomeArt();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFDFF5E9), Color(0xFFC3E9D6)],
        ),
        boxShadow: [
          BoxShadow(
            color: _forest.withValues(alpha: 0.16),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // النبتة الصغيرة.
          const Positioned(
            bottom: 10,
            left: 12,
            child: Icon(Icons.eco_rounded, color: Color(0xFF2FA36B), size: 20),
          ),
          // أوراق نقدية.
          Positioned(
            top: 13,
            left: 12,
            child: Transform.rotate(
              angle: -0.35,
              child: const Icon(Icons.payments_rounded,
                  color: Color(0xFF3B82F6), size: 16),
            ),
          ),
          // المحفظة.
          const Center(
            child: Icon(Icons.account_balance_wallet_rounded,
                color: _forest, size: 36),
          ),
          // عملات ذهبية.
          Positioned(
            top: 10,
            right: 12,
            child: _Coin(size: 15),
          ),
          Positioned(
            bottom: 12,
            right: 10,
            child: _Coin(size: 11),
          ),
        ],
      ),
    );
  }
}

class _Coin extends StatelessWidget {
  final double size;

  const _Coin({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFE082), Color(0xFFF6B93B)],
        ),
        border: Border.all(color: const Color(0xFFD79A21), width: 1),
      ),
    );
  }
}

/// كارت الملخص الشهري الأخضر الداكن.
class _SummaryCard extends StatelessWidget {
  final MasrofyStore store;
  final Strings strings;
  final NumberFormat fmt;

  const _SummaryCard({
    required this.store,
    required this.strings,
    required this.fmt,
  });

  @override
  Widget build(BuildContext context) {
    final s = strings;
    final income = store.monthlyIncome;
    final expense = store.monthlyExpense;
    final remaining = income - expense;
    final ratio = income > 0 ? (remaining / income).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [_forestMid, _forestDeep],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _forestDeep.withValues(alpha: 0.30),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.calendar_month_outlined,
                  size: 14, color: Colors.white.withValues(alpha: 0.75)),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => showMonthPicker(context, store),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('MMMM y', s.language)
                          .format(store.selectedMonth),
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.85)),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down_rounded,
                        size: 16, color: Colors.white.withValues(alpha: 0.85)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // المصروفات (يمين).
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.14),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                                Icons.account_balance_wallet_outlined,
                                size: 16,
                                color: Colors.white),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(s.expensesThisMonth,
                                style: TextStyle(
                                    fontSize: 11,
                                    height: 1.3,
                                    color:
                                        Colors.white.withValues(alpha: 0.80))),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(fmt.format(expense),
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Colors.white)),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 14),
                  color: Colors.white.withValues(alpha: 0.18),
                ),
                // المتبقي (يسار).
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.remainingThisMonth,
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.80))),
                      const SizedBox(height: 12),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(fmt.format(remaining),
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Colors.white)),
                      ),
                      const Spacer(),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: ratio,
                          minHeight: 8,
                          backgroundColor:
                              Colors.white.withValues(alpha: 0.20),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              _brightGreen),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// أربعة أزرار إجراءات سريعة.
class _QuickActions extends StatelessWidget {
  final Strings strings;
  final VoidCallback onReports;
  final VoidCallback onExpenses;
  final VoidCallback onAddExpense;
  final VoidCallback onIncome;

  const _QuickActions({
    required this.strings,
    required this.onReports,
    required this.onExpenses,
    required this.onAddExpense,
    required this.onIncome,
  });

  @override
  Widget build(BuildContext context) {
    final s = strings;
    final cards = [
      _QuickCard(
        label: s.navReports,
        icon: Icons.bar_chart_rounded,
        color: const Color(0xFF8B5CF6),
        bg: const Color(0xFFF1EDFE),
        onTap: onReports,
      ),
      _QuickCard(
        label: s.expenses,
        icon: Icons.shopping_bag_rounded,
        color: const Color(0xFFF0644B),
        bg: const Color(0xFFFCEAE5),
        onTap: onExpenses,
      ),
      _QuickCard(
        label: s.addExpense,
        icon: Icons.add_rounded,
        color: const Color(0xFF22C55E),
        bg: const Color(0xFFE6F7EE),
        onTap: onAddExpense,
      ),
      _QuickCard(
        label: s.income,
        icon: Icons.account_balance_wallet_rounded,
        color: const Color(0xFF3B82F6),
        bg: const Color(0xFFE8F1FE),
        onTap: onIncome,
      ),
    ];

    return Row(
      children: [
        for (var i = 0; i < cards.length; i++) ...[
          Expanded(child: cards[i]),
          if (i != cards.length - 1) const SizedBox(width: 10),
        ],
      ],
    );
  }
}

class _QuickCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color bg;
  final VoidCallback onTap;

  const _QuickCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.bg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 92,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: p.card,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: color, size: 19),
            ),
            const SizedBox(height: 9),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w700, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardShell extends StatelessWidget {
  final Widget child;

  const _CardShell({required this.child});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _CardHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final String action;
  final VoidCallback onViewAll;

  const _CardHeader({
    required this.title,
    required this.icon,
    required this.action,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: p.income.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 16, color: p.income),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: p.textPrimary)),
        ),
        GestureDetector(
          onTap: onViewAll,
          behavior: HitTestBehavior.opaque,
          child: Row(
            children: [
              Text(action,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: p.accent)),
              const SizedBox(width: 2),
              Icon(Icons.arrow_forward_rounded, size: 15, color: p.accent),
            ],
          ),
        ),
      ],
    );
  }
}

/// كارت المصروفات حسب الفئات (دائرة مجزّأة + قائمة).
class _CategoryCard extends StatelessWidget {
  final Strings strings;
  final List<MapEntry<String, double>> entries;
  final double total;
  final NumberFormat fmt;
  final VoidCallback onViewAll;

  const _CategoryCard({
    required this.strings,
    required this.entries,
    required this.total,
    required this.fmt,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final s = strings;
    final top = entries.take(5).toList();
    final slices = [
      for (final e in top)
        PieSlice(value: e.value, color: _chartColor(e.key)),
    ];

    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            title: s.expensesByCategory,
            icon: Icons.bar_chart_rounded,
            action: s.viewAll,
            onViewAll: onViewAll,
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: top.isEmpty
                    ? Text(s.noData,
                        style: TextStyle(fontSize: 12, color: p.textMuted))
                    : Column(
                        children: [
                          for (var i = 0; i < top.length; i++) ...[
                            _CategoryRow(
                              categoryId: top[i].key,
                              amount: top[i].value,
                              fraction: total > 0 ? top[i].value / total : 0,
                              strings: s,
                              fmt: fmt,
                            ),
                            if (i != top.length - 1)
                              const SizedBox(height: 11),
                          ],
                        ],
                      ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 128,
                height: 128,
                child: PieChart(
                  slices: slices,
                  size: 128,
                  thickness: 18,
                  emptyColor: p.cardBorder,
                  center: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(s.totalLabel,
                          style: TextStyle(
                              fontSize: 10, color: p.textMuted)),
                      const SizedBox(height: 2),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(fmt.format(total),
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  color: p.textPrimary)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final String categoryId;
  final double amount;
  final double fraction;
  final Strings strings;
  final NumberFormat fmt;

  const _CategoryRow({
    required this.categoryId,
    required this.amount,
    required this.fraction,
    required this.strings,
    required this.fmt,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final cat = AppCategory.byId(categoryId, TxType.expense);
    final color = _chartColor(categoryId);
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(cat.localName(strings.language),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: p.textPrimary)),
        ),
        const SizedBox(width: 6),
        Text(fmt.format(amount),
            style: TextStyle(fontSize: 11, color: p.textMuted)),
        const SizedBox(width: 6),
        SizedBox(
          width: 34,
          child: Text('${(fraction * 100).round()}%',
              textAlign: TextAlign.end,
              style: TextStyle(
                  fontSize: 11.5, fontWeight: FontWeight.w800, color: color)),
        ),
      ],
    );
  }
}

/// كارت أحدث المعاملات.
class _RecentCard extends StatelessWidget {
  final MasrofyStore store;
  final Strings strings;
  final List<Transaction> items;
  final VoidCallback onViewAll;

  const _RecentCard({
    required this.store,
    required this.strings,
    required this.items,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final s = strings;
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            title: s.recentTransactionsTitle,
            icon: Icons.access_time_rounded,
            action: s.viewAll,
            onViewAll: onViewAll,
          ),
          const SizedBox(height: 8),
          if (items.isEmpty)
            const _EmptyRecent()
          else
            for (var i = 0; i < items.length; i++) ...[
              _RecentRow(tx: items[i], strings: s),
              if (i != items.length - 1)
                Divider(height: 1, thickness: 0.6, color: p.cardBorder),
            ],
        ],
      ),
    );
  }
}

class _RecentRow extends StatelessWidget {
  final Transaction tx;
  final Strings strings;

  const _RecentRow({required this.tx, required this.strings});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final s = strings;
    final cat = AppCategory.byId(tx.categoryId, tx.type);
    final isIncome = tx.type == TxType.income;
    final fmt = NumberFormat.currency(
        locale: s.currencyLocale(), symbol: s.currencySymbol());
    final title =
        tx.note.isNotEmpty ? tx.note : cat.localName(s.language);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: cat.color.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(cat.icon, size: 19, color: cat.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: p.textPrimary)),
                const SizedBox(height: 2),
                Text(DateFormat('d MMM y', s.dateLocale()).format(tx.date),
                    style: TextStyle(fontSize: 11, color: p.textMuted)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${isIncome ? '+' : '-'}${fmt.format(tx.amount)}',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: isIncome ? p.income : p.expense,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyRecent extends StatelessWidget {
  const _EmptyRecent();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final s = Strings(storeLanguage(context));
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 22),
      child: Column(
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 34, color: p.textMuted.withValues(alpha: 0.6)),
          const SizedBox(height: 8),
          Text(s.noTransactions, style: TextStyle(color: p.textMuted)),
        ],
      ),
    );
  }
}

/// لغة الواجهة من اتجاه الـLocale النشط (احتياطي: عربي).
String storeLanguage(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'en' ? 'en' : 'ar';
