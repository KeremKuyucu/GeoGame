import 'package:flutter/material.dart';

/// MainScaffold için controller
class MainScaffoldController {
  static int selectedIndex = 0;

  /// Tab değişikliğini işler
  void onTabChanged(
      BuildContext context, int index, VoidCallback onStateChanged) {
    // Klavyeyi kapat
    final FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      currentFocus.unfocus();
    }

    selectedIndex = index;
    onStateChanged();
  }

  /// Mevcut tab index'i döndürür
  int get currentIndex => selectedIndex;
}
