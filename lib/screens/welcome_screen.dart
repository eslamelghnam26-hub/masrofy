import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/strings.dart';
import '../store/masrofy_store.dart';
import 'root_screen.dart';

class WelcomeScreen extends StatelessWidget {
  final MasrofyStore store;

  const WelcomeScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final s = Strings(store.language);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarContrastEnforced: false,
      ),
      child: Scaffold(
      backgroundColor: const Color(0xFFCDF2EA),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          final buttonH = (h * 0.07).clamp(46.0, 58.0).toDouble();
          final bottomPad = (h * 0.07).clamp(28.0, 60.0).toDouble();
          return Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/illustrations/welcome.png',
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
              _pill(context, s.catIncome, Icons.attach_money,
                  const Color(0xFF12A070), w * 0.49, h * 0.138),
              _pill(context, s.catFood, Icons.fastfood, const Color(0xFFFDA91B),
                  w * 0.185, h * 0.205),
              _pill(context, s.catFun, Icons.sports_esports,
                  const Color(0xFF9080E0), w * 0.815, h * 0.205),
              _pill(context, s.catBills, Icons.receipt_long,
                  const Color(0xFF00A6DF), w * 0.175, h * 0.342),
              _pill(context, s.catInstall, Icons.payments,
                  const Color(0xFFFD7568), w * 0.825, h * 0.342),
              Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPad),
                    child: SizedBox(
                      width: double.infinity,
                      height: buttonH,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFA9BD91),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            PageRouteBuilder(
                              pageBuilder: (_, _, _) => RootScreen(store: store),
                              transitionsBuilder: (_, animation, _, child) =>
                                  FadeTransition(
                                      opacity: animation, child: child),
                            ),
                          );
                        },
                        child: Center(
                          child: Text(
                            s.startApp,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      ),
    );
  }

  Widget _pill(
      BuildContext context, String label, IconData icon, Color color,
      double cx, double cy) {
    return Positioned(
      left: cx - 55,
      top: cy - 17,
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x40000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}