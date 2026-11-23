import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../store/masrofy_store.dart';
import '../theme/app_theme.dart';
import '../widgets/pickers.dart';
import 'budget_screen.dart';
import 'login_screen.dart';

class SettingsPage extends StatelessWidget {
  final MasrofyStore store;

  const SettingsPage({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final s = Strings(store.language);
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final p = context.palette;
        return SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
            children: [
              Text(s.settingsTitle,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: p.textPrimary)),
              const SizedBox(height: 18),
              _Group(
                palette: p,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.fromLTRB(14, 12, 14, 4),
                    child: Row(
                      children: [
                        Icon(Icons.palette_outlined, size: 20, color: p.accent),
                        const SizedBox(width: 12),
                        Text(s.themeLabel,
                            style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: p.textPrimary)),
                      ],
                    ),
                  ),
                  _ThemeTile(
                    selected: store.themeName == 'green',
                    icon: Icons.light_mode_outlined,
                    title: s.themeGreen,
                    subtitle: s.themeGreenHint,
                    accent: p.accent,
                    textPrimary: p.textPrimary,
                    textSecondary: p.textSecondary,
                    onTap: () => store.setTheme('green'),
                  ),
                  _ThemeTile(
                    selected: store.themeName == 'cream',
                    icon: Icons.brush_outlined,
                    title: s.themeCream,
                    subtitle: s.themeCreamHint,
                    accent: p.accent,
                    textPrimary: p.textPrimary,
                    textSecondary: p.textSecondary,
                    onTap: () => store.setTheme('cream'),
                  ),
                  _ThemeTile(
                    selected: store.themeName == 'dark',
                    icon: Icons.dark_mode_outlined,
                    title: s.themeDark,
                    subtitle: s.themeDarkHint,
                    accent: p.accent,
                    textPrimary: p.textPrimary,
                    textSecondary: p.textSecondary,
                    onTap: () => store.setTheme('dark'),
                  ),
                  Divider(height: 1, color: p.cardBorder),
                  ListTile(
                    leading: Icon(Icons.translate, color: p.accent),
                    title: Text(s.languageLabel,
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: p.textPrimary)),
                    subtitle: Text(
                        store.language == 'ar' ? s.arabic : s.english,
                        style: TextStyle(
                            color: p.textSecondary, fontSize: 12)),
                    trailing:
                        Icon(Icons.chevron_left, color: p.textMuted),
                    onTap: () => showLanguagePicker(context, store),
                  ),
                  Divider(height: 1, color: p.cardBorder),
                  ListTile(
                    leading: Icon(Icons.calendar_month_outlined, color: p.accent),
                    title: Text(s.pickMonthTitle,
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: p.textPrimary)),
                    trailing:
                        Icon(Icons.chevron_left, color: p.textMuted),
                    onTap: () => showMonthPicker(context, store),
                  ),
                  Divider(height: 1, color: p.cardBorder),
                  ListTile(
                    leading: Icon(Icons.savings_outlined, color: p.accent),
                    title: Text(s.manageBudget,
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: p.textPrimary)),
                    subtitle: Text(s.monthlyBudget,
                        style: TextStyle(
                            color: p.textSecondary, fontSize: 12)),
                    trailing:
                        Icon(Icons.chevron_left, color: p.textMuted),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => BudgetScreen(store: store),
                    )),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _Group(
                palette: p,
                children: [
                  ListTile(
                    leading: Icon(Icons.logout, color: p.expense),
                    title: Text(s.logout,
                        style: TextStyle(
                            fontWeight: FontWeight.w800, color: p.expense)),
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(s.logoutConfirmTitle),
                          content: Text(s.logoutConfirmMessage),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: Text(s.no),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              style: FilledButton.styleFrom(
                                backgroundColor: p.expense,
                              ),
                              child: Text(s.yes),
                            ),
                          ],
                        ),
                      );
                      if (confirm != true) return;
                      await store.setLoggedIn(false);
                      if (!context.mounted) return;
                      Navigator.of(context, rootNavigator: true)
                          .pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => LoginScreen(store: store),
                        ),
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Center(
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset('assets/icon/app_icon.png',
                          width: 56, height: 56, fit: BoxFit.cover),
                    ),
                    const SizedBox(height: 8),
                    Text(s.appName,
                        style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: p.textPrimary)),
                    Text(s.appSubtitle,
                        style: TextStyle(
                            fontSize: 11, color: p.textMuted)),
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

class _ThemeTile extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final Color textPrimary;
  final Color textSecondary;
  final VoidCallback onTap;

  const _ThemeTile({
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.textPrimary,
    required this.textSecondary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: accent),
      title: Text(title,
          style: TextStyle(fontWeight: FontWeight.w700, color: textPrimary)),
      subtitle: Text(subtitle,
          style: TextStyle(color: textSecondary, fontSize: 12)),
      trailing: Icon(
        selected ? Icons.check_circle : Icons.circle_outlined,
        color: selected ? accent : textSecondary,
      ),
    );
  }
}

class _Group extends StatelessWidget {
  final MasrofyPalette palette;
  final List<Widget> children;

  const _Group({required this.palette, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.cardBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: Column(children: children),
      ),
    );
  }
}
