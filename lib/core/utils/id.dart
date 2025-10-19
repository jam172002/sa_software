import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

/// ULID-like, time-sortable IDs with a stable per-device prefix.
/// Ensures **no collisions** when multiple offline devices create records.
class Id {
  static const _alphabet = '0123456789ABCDEFGHJKMNPQRSTVWXYZ'; // Crockford base32
  static final _rand = Random.secure();
  static String _deviceId = 'dev0000';

  /// Call once at app start.
  static Future<void> init() async {
    final sp = await SharedPreferences.getInstance();
    _deviceId = sp.getString('device_id') ?? _randomDeviceId();
    await sp.setString('device_id', _deviceId);
  }

  static String ulid() {
    final time = DateTime.now().millisecondsSinceEpoch;
    final timePart = _encodeTime(time);
    final randPart = _encodeRandom(80); // 80 random bits
    return '${_deviceId}_$timePart$randPart';
    // Example: dv8k3w9a_01J9Z6V8M2ABCDEF...
  }

  static String _randomDeviceId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final buf = StringBuffer('dv');
    for (var i = 0; i < 8; i++) {
      buf.write(chars[_rand.nextInt(chars.length)]);
    }
    return buf.toString();
  }

  static String _encodeTime(int ms) {
    final buf = List.filled(10, 0);
    var value = ms;
    for (var i = 9; i >= 0; i--) {
      buf[i] = value % 32;
      value ~/= 32;
    }
    return String.fromCharCodes(buf.map((i) => _alphabet.codeUnitAt(i)));
  }

  static String _encodeRandom(int bits) {
    final len = (bits / 5).ceil();
    final out = StringBuffer();
    for (var i = 0; i < len; i++) {
      out.write(_alphabet[_rand.nextInt(32)]);
    }
    return out.toString();
  }
}
