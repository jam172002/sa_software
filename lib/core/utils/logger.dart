class Log {
  static void d(String msg) {
    // ignore: avoid_print
    print('[D] $msg');
  }

  static void w(String msg) {
    print('[W] $msg');
  }

  static void e(String msg, [Object? err]) {
    print('[E] $msg ${err ?? ''}');
  }
}
