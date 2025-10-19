import 'dart:async';
import 'package:flutter/foundation.dart';

/// MVP auth: treated as already signed-in to let you test POS quickly.
/// Swap with real FirebaseAuth later.
class AuthProvider extends ChangeNotifier {
  static final _controller = StreamController<void>.broadcast();
  static Stream<void> get stream => _controller.stream;

  bool isAuthenticated = true;

  void login() {
    isAuthenticated = true;
    _controller.add(null);
    notifyListeners();
  }

  void logout() {
    isAuthenticated = false;
    _controller.add(null);
    notifyListeners();
  }
}
