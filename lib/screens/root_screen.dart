import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../store/masrofy_store.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
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
      HomeScreen(store: store, onOpenTab: (i) => setState(() => _index = i)),
      TransactionsPage(store: store),
      ReportsPage(store: store),
      SettingsPage(store: store),
    ];

    return Scaffold(
      backgroundColor: p.bg,
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: _HomeNavBar(
        index: _index,
        onChanged: (i) => setState(() => _index = i),
        palette: p,
        isDark: store.darkMode,
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

class _HomeNavBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;
  final MasrofyPalette palette;
  final bool isDark;
  final List<(IconData, IconData, String)> items;

  const _HomeNavBar({
    required this.index,
    required this.onChanged,
    required this.palette,
    required this.isDark,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final bar = isDark ? p.bgElevated : Colors.white;
    final active = isDark ? p.accent : const Color(0xFF1E3A2F);
    final inactive = p.textMuted;

    return Container(
      decoration: BoxDecoration(
        color: bar,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            children: List.generate(items.length, (i) {
              final selected = i == index;
              final fg = selected ? active : inactive;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        selected ? items[i].$2 : items[i].$1,
                        size: 22,
                        color: fg,
                      ),
                      const SizedBox(height: 3),
                      Flexible(
                        child: Text(
                          items[i].$3,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight:
                                selected ? FontWeight.w800 : FontWeight.w500,
                            color: fg,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 20,
                        height: 3,
                        decoration: BoxDecoration(
                          color: selected ? active : Colors.transparent,
                          borderRadius: BorderRadius.circular(2),
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
