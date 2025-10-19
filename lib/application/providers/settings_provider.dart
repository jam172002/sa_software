import 'package:flutter/foundation.dart';

class SettingsProvider extends ChangeNotifier {
  bool clearAfterPrint = true;
  void toggleClearAfterPrint(bool v) {
    clearAfterPrint = v;
    notifyListeners();
  }
}
