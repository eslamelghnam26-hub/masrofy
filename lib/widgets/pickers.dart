import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/strings.dart';
import '../store/masrofy_store.dart';
import '../theme/app_theme.dart';

Future<void> showMonthPicker(BuildContext context, MasrofyStore store) async {
  final s = Strings(store.language);
  final p = context.palette;
  final now = DateTime.now();
  var year = store.selectedMonth.year;

  final selected = await showModalBottomSheet<DateTime>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            decoration: BoxDecoration(
              color: p.card,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: p.cardBorder),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: p.cardBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  s.pickMonthTitle,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: p.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => setSheetState(() => year--),
                      icon: Icon(
                        store.language == 'ar'
                            ? Icons.chevron_right
                            : Icons.chevron_left,
                        color: p.textSecondary,
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          '$year',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: p.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: year < now.year
                          ? () => setSheetState(() => year++)
                          : null,
                      icon: Icon(
                        store.language == 'ar'
                            ? Icons.chevron_left
                            : Icons.chevron_right,
                        color: p.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.7,
                  children: List.generate(12, (i) {
                    final month = DateTime(year, i + 1, 1);
                    final isSelected =
                        month.year == store.selectedMonth.year &&
                            month.month == store.selectedMonth.month;
                    final isFuture =
                        month.isAfter(DateTime(now.year, now.month, 1));
                    final monthName =
                        DateFormat('MMMM', store.language).format(month);
                    return Material(
                      color: isSelected ? p.accent : p.bgElevated,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: !isFuture
                            ? () => Navigator.of(sheetContext).pop(month)
                            : null,
                        child: Center(
                          child: Text(
                            monthName,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? Colors.white : p.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          );
        },
      );
    },
  );

  if (selected != null) {
    await store.setMonth(selected);
  }
}

Future<void> showLanguagePicker(BuildContext context, MasrofyStore store) async {
  final s = Strings(store.language);
  final p = context.palette;
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) {
      return Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: p.card,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: p.cardBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                s.languageLabel,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: p.textPrimary,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.language, color: p.textPrimary),
              title: Text(s.arabic,
                  style: TextStyle(
                      fontWeight: FontWeight.w700, color: p.textPrimary)),
              trailing: store.language == 'ar'
                  ? Icon(Icons.check_circle, color: p.accent)
                  : null,
              onTap: () async {
                Navigator.of(sheetContext).pop();
                if (store.language != 'ar') await store.setLanguage('ar');
              },
            ),
            ListTile(
              leading: Icon(Icons.language, color: p.textPrimary),
              title: Text(s.english,
                  style: TextStyle(
                      fontWeight: FontWeight.w700, color: p.textPrimary)),
              trailing: store.language == 'en'
                  ? Icon(Icons.check_circle, color: p.accent)
                  : null,
              onTap: () async {
                Navigator.of(sheetContext).pop();
                if (store.language != 'en') await store.setLanguage('en');
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}
