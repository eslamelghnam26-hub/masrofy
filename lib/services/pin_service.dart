import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// خدمة PIN محلية بالكامل: لا تُحفظ كلمة المرور الأصلية أبداً.
///
/// نستخدم salt عشوائي + تكرار SHA-256. الغرض حماية خصوصية بسيطة على الجهاز،
/// وليس حماية تشفيرية قوية ضد مهاجم يملك الجهاز (هذا دور قفل الجهاز نفسه).
class PinService {
  PinService._();

  static const int saltLength = 16;
  static const int iterations = 2000;

  static String newSalt() {
    final random = Random.secure();
    final bytes = Uint8List.fromList(
      List<int>.generate(saltLength, (_) => random.nextInt(256)),
    );
    return base64.encode(bytes);
  }

  static String hash(String pin, String salt) {
    final saltBytes = base64.decode(salt);
    List<int> bytes = <int>[...utf8.encode(pin), ...saltBytes];
    for (var i = 0; i < iterations; i++) {
      bytes = sha256.convert(<int>[
        ...bytes,
        i & 0xFF,
        (i >> 8) & 0xFF,
      ]).bytes;
    }
    return base64.encode(bytes);
  }

  static bool verify(String pin, String salt, String expectedHash) {
    try {
      final actual = base64.decode(hash(pin, salt));
      final expected = base64.decode(expectedHash);
      if (actual.length != expected.length) return false;
      var diff = 0;
      for (var i = 0; i < expected.length; i++) {
        diff |= actual[i] ^ expected[i];
      }
      return diff == 0;
    } catch (_) {
      return false;
    }
  }

  static bool isValidPin(String value) =>
      RegExp(r'^[0-9]{4}$').hasMatch(value);
}
