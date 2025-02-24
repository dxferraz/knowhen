import 'package:flutter/material.dart';

class BottomSheetTheme {
  static BottomSheetThemeData lightTheme() {
    return BottomSheetThemeData(
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
    );
  }

  static BottomSheetThemeData darkTheme() {
    return BottomSheetThemeData(
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
    );
  }
}

class CustomAppBarTheme {
  static AppBarTheme lightTheme() {
    return AppBarTheme(
      backgroundColor: Colors.transparent,
    );
  }

  static AppBarTheme darkTheme() {
    return AppBarTheme(
      backgroundColor: Colors.transparent,
    );
  }
}
