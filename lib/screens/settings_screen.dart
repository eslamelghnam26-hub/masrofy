import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../formatters/digit_formatter.dart';
import '../l10n/strings.dart';
import '../store/masrofy_store.dart';
import '../theme/app_theme.dart';
import '../widgets/pickers.dart';
import 'budget_screen.dart';
import 'pin_setup_sheet.dart';

class SettingsPage extends StatelessWidget {
  final MasrofyStore store;

  const SettingsPage({super.key, required this.store});

  void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openPinSheet(
      BuildContext context, PinSetupMode mode, String fallbackError) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PinSetupSheet(
        store: store,
        mode: mode,
        onDone: (success, message) =>
            Navigator.of(context).pop(success ? message : fallbackError),
      ),
    );
    if (!context.mounted || result == null) return;
    _snack(context, result);
  }

  Future<void> _editOpeningBalance(BuildContext context) async {
    final s = Strings(store.language);
    final controller = TextEditingController(
      text: store.openingBalance > 0
          ? store.openingBalance.toStringAsFixed(2)
          : '',
    );
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.openingBalance),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            DigitInputFormatter(),
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
          ],
          decoration: InputDecoration(
            labelText: s.openingBalance,
            hintText: s.openingBalanceHint,
            prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(s.cancel),
          ),
          FilledButton(
            onPressed: () {
              final value = double.tryParse(controller.text.trim()) ?? 0;
              store.setOpeningBalance(value);
              Navigator.of(ctx).pop();
            },
            child: Text(s.save),
          ),
        ],
      ),
    );
    controller.dispose();
  }

  Future<void> _exportBackup(BuildContext context) async {
    final s = Strings(store.language);
    try {
      final uri = await FilePicker.saveFile(
        dialogTitle: s.exportBackup,
        fileName: 'masrofy-backup-${DateTime.now().toIso8601String().substring(0, 10)}.json',
        mimeType: 'application/json',
        bytes: Uint8List.fromList(utf8.encode(store.exportBackup())),
      );
      if (!context.mounted) return;
      _snack(context, uri == null ? s.backupCancelled : s.backupExported);
    } catch (_) {
      if (context.mounted) _snack(context, s.backupExportFailed);
    }
  }

  Future<void> _importBackup(BuildContext context) async {
    final s = Strings(store.language);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.importConfirmTitle),
        content: Text(s.importConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(s.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(s.yes),
          ),
        ],
      ),
    );
    if (confirm != true || !context.mounted) return;

    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['json'],
      );
      final path = result.isEmpty ? null : result.first.path;
      if (path == null) {
        if (context.mounted) _snack(context, s.backupCancelled);
        return;
      }
      final text = await File(path).readAsString();
      final ok = await store.importBackup(text);
      if (!context.mounted) return;
      _snack(context, ok ? s.backupImported : s.backupInvalid);
    } catch (_) {
      if (context.mounted) _snack(context, s.backupImportFailed);
    }
  }

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
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
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
                        style:
                            TextStyle(color: p.textSecondary, fontSize: 12)),
                    trailing: Icon(Icons.chevron_left, color: p.textMuted),
                    onTap: () => showLanguagePicker(context, store),
                  ),
                  Divider(height: 1, color: p.cardBorder),
                  ListTile(
                    leading:
                        Icon(Icons.calendar_month_outlined, color: p.accent),
                    title: Text(s.pickMonthTitle,
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: p.textPrimary)),
                    trailing: Icon(Icons.chevron_left, color: p.textMuted),
                    onTap: () => showMonthPicker(context, store),
                  ),
                  Divider(height: 1, color: p.cardBorder),
                  ListTile(
                    leading: Icon(Icons.account_balance_wallet_outlined,
                        color: p.accent),
                    title: Text(s.openingBalance,
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: p.textPrimary)),
                    subtitle: Text(
                      store.openingBalance > 0
                          ? store.openingBalance.toStringAsFixed(2)
                          : s.openingBalanceHint,
                      style:
                          TextStyle(color: p.textSecondary, fontSize: 12)),
                    onTap: () => _editOpeningBalance(context),
                  ),
                  Divider(height: 1, color: p.cardBorder),
                  ListTile(
                    leading: Icon(Icons.savings_outlined, color: p.accent),
                    title: Text(s.manageBudget,
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: p.textPrimary)),
                    subtitle: Text(s.monthlyBudget,
                        style:
                            TextStyle(color: p.textSecondary, fontSize: 12)),
                    trailing: Icon(Icons.chevron_left, color: p.textMuted),
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
                  SwitchListTile(
                    secondary: Icon(Icons.lock_outline, color: p.accent),
                    title: Text(s.appLock,
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: p.textPrimary)),
                    subtitle: Text(s.appLockHint,
                        style: TextStyle(
                            color: p.textSecondary, fontSize: 12)),
                    value: store.appLockEnabled,
                    activeThumbColor: p.accent,
                    onChanged: (value) => _openPinSheet(
                      context,
                      value ? PinSetupMode.create : PinSetupMode.disable,
                      value ? s.pinInvalid : s.pinWrong,
                    ),
                  ),
                  if (store.appLockEnabled) ...[
                    Divider(height: 1, color: p.cardBorder),
                    ListTile(
                      leading: Icon(Icons.key_outlined, color: p.accent),
                      title: Text(s.pinChange,
                          style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: p.textPrimary)),
                      onTap: () => _openPinSheet(
                          context, PinSetupMode.change, s.pinWrong),
                    ),
                  ],
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                    child: Text(s.pinPrivacyNote,
                        style:
                            TextStyle(fontSize: 10.5, color: p.textMuted)),
                  ),
                ],
              ),

              const SizedBox(height: 18),
              _Group(
                palette: p,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
                    child: Row(
                      children: [
                        Icon(Icons.backup_outlined, color: p.accent),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(s.backupRestore,
                              style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: p.textPrimary)),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                    child: Text(s.backupHint,
                        style:
                            TextStyle(fontSize: 11, color: p.textSecondary)),
                  ),
                  ListTile(
                    leading: Icon(Icons.file_upload_outlined, color: p.accent),
                    title: Text(s.exportBackup,
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: p.textPrimary)),
                    onTap: () => _exportBackup(context),
                  ),
                  Divider(height: 1, color: p.cardBorder),
                  ListTile(
                    leading: Icon(Icons.file_download_outlined, color: p.accent),
                    title: Text(s.importBackup,
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: p.textPrimary)),
                    onTap: () => _importBackup(context),
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
                        style:
                            TextStyle(fontSize: 11, color: p.textMuted)),
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
