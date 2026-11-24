import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../store/masrofy_store.dart';
import '../theme/app_theme.dart';
import '../widgets/pin_pad.dart';

enum PinSetupMode { create, change, disable }

class PinSetupSheet extends StatefulWidget {
  final MasrofyStore store;
  final PinSetupMode mode;
  final void Function(bool success, String message) onDone;

  const PinSetupSheet({
    super.key,
    required this.store,
    required this.mode,
    required this.onDone,
  });

  @override
  State<PinSetupSheet> createState() => _PinSetupSheetState();
}

class _PinSetupSheetState extends State<PinSetupSheet> {
  String _buffer = '';
  String _currentPin = '';
  String _newPin = '';
  int _step = 0;
  String? _error;

  String get _title {
    final s = Strings(widget.store.language);
    switch (widget.mode) {
      case PinSetupMode.create:
        return _step == 0 ? s.pinCreateTitle : s.pinConfirmTitle;
      case PinSetupMode.change:
        if (_step == 0) return s.pinCurrentTitle;
        return _step == 1 ? s.pinNewTitle : s.pinConfirmTitle;
      case PinSetupMode.disable:
        return s.pinDisableTitle;
    }
  }

  String get _subtitle {
    final s = Strings(widget.store.language);
    if (widget.mode == PinSetupMode.disable) return s.pinPrivacyNote;
    return _step > 0 && widget.mode != PinSetupMode.change
        ? s.pinConfirmTitle
        : s.appLockHint;
  }

  void _onDigit(String digit) {
    if (_buffer.length >= 4) return;
    setState(() {
      _buffer += digit;
      _error = null;
    });
    if (_buffer.length == 4) _advance();
  }

  void _onBackspace() {
    if (_buffer.isEmpty) return;
    setState(() => _buffer = _buffer.substring(0, _buffer.length - 1));
  }

  Future<void> _advance() async {
    final s = Strings(widget.store.language);
    final entered = _buffer;

    if (widget.mode == PinSetupMode.create) {
      if (_step == 0) {
        setState(() {
          _newPin = entered;
          _buffer = '';
          _step = 1;
        });
        return;
      }
      if (entered != _newPin) {
        setState(() {
          _error = s.pinMismatch;
          _buffer = '';
        });
        return;
      }
      final ok = await widget.store.setPin(_newPin);
      _finish(ok, ok ? s.pinSetSuccess : s.pinInvalid);
      return;
    }

    if (widget.mode == PinSetupMode.change) {
      if (_step == 0) {
        if (!widget.store.verifyPin(entered)) {
          setState(() {
            _error = s.pinWrong;
            _buffer = '';
          });
          return;
        }
        setState(() {
          _currentPin = entered;
          _buffer = '';
          _step = 1;
        });
        return;
      }
      if (_step == 1) {
        setState(() {
          _newPin = entered;
          _buffer = '';
          _step = 2;
        });
        return;
      }
      if (entered != _newPin) {
        setState(() {
          _error = s.pinMismatch;
          _buffer = '';
        });
        return;
      }
      final ok =
          await widget.store.changePin(_currentPin, _newPin);
      _finish(ok, ok ? s.pinChanged : s.pinWrong);
      return;
    }

    final ok = await widget.store.disablePin(entered);
    _finish(ok, ok ? s.pinDisabled : s.pinWrong);
  }

  void _finish(bool success, String message) {
    if (!mounted) return;
    Navigator.of(context).pop();
    widget.onDone(success, message);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final s = Strings(widget.store.language);

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 12,
        bottom: MediaQuery.viewInsetsOf(context).bottom +
            MediaQuery.viewPaddingOf(context).bottom +
            24,
      ),
      decoration: BoxDecoration(
        color: p.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: p.cardBorder,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 18),
            Icon(
              widget.mode == PinSetupMode.disable
                  ? Icons.lock_open_outlined
                  : Icons.lock_outline,
              color: p.accent,
              size: 30,
            ),
            const SizedBox(height: 12),
            Text(_title,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: p.textPrimary)),
            const SizedBox(height: 6),
            Text(_subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11.5, color: p.textSecondary)),
            const SizedBox(height: 24),
            PinPad(
              length: 4,
              value: _buffer,
              palette: p,
              onDigit: _onDigit,
              onBackspace: _onBackspace,
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 20,
              child: Text(
                _error ?? '',
                style: TextStyle(fontSize: 12, color: p.expense),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(s.cancel),
            ),
          ],
        ),
      ),
    );
  }
}
