import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../store/masrofy_store.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class WelcomeScreen extends StatelessWidget {
  final MasrofyStore store;

  const WelcomeScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final s = Strings(store.language);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 1),
            Expanded(
              flex: 4,
              child: Hero(
                tag: 'welcome_art',
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Image.asset(
                    'assets/illustrations/welcome.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    Text(
                      s.welcomeTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: p.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      s.welcomeStory,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: p.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        _TagPill(label: '🍔 طعام', color: p.expense),
                        _TagPill(label: '👕 لبس', color: p.accent),
                        _TagPill(label: '🎬 ترفيه', color: p.income),
                        _TagPill(label: '📚 تعليم', color: const Color(0xFF6FA8DC)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(26, 14, 26, 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      PageRouteBuilder(
                        pageBuilder: (_, _, _) => HomeScreen(store: store),
                        transitionsBuilder: (_, animation, _, child) =>
                            FadeTransition(opacity: animation, child: child),
                      ),
                    );
                  },
                  child: Text(
                    s.startApp,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  final String label;
  final Color color;

  const _TagPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: p.textPrimary,
        ),
      ),
    );
  }
}