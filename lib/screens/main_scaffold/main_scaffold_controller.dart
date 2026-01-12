import 'package:flutter/material.dart';
import 'package:geogame/models/app_context.dart';

/// MainScaffold için controller
class MainScaffoldController {
  /// Tab değişikliğini işler
  void onTabChanged(
      BuildContext context, int index, VoidCallback onStateChanged) {
    // Klavyeyi kapat
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      currentFocus.unfocus();
    }

    AppState.selectedIndex = index;
    onStateChanged();
  }

  /// Mevcut tab index'i döndürür
  int get currentIndex => AppState.selectedIndex;
}
