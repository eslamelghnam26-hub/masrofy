import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../store/masrofy_store.dart';
import '../theme/app_theme.dart';
import '../widgets/pickers.dart';

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
                  SwitchListTile(
                    value: store.darkMode,
                    onChanged: (_) => store.toggleTheme(),
                    activeThumbColor: p.accent,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 14),
                    secondary: Icon(
                      store.darkMode
                          ? Icons.dark_mode_outlined
                          : Icons.light_mode_outlined,
                      color: p.accent,
                    ),
                    title: Text(s.themeLabel,
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: p.textPrimary)),
                    subtitle: Text(
                      store.darkMode ? s.themeGreen : s.themeCream,
                      style: TextStyle(color: p.textSecondary, fontSize: 12),
                    ),
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
                    onTap: () => store.setLoggedIn(false),
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
      child: Column(children: children),
    );
  }
}
