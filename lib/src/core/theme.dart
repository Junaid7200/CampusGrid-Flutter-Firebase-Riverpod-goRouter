import 'package:flutter/material.dart';

const Color bgSplash_buttons_headers_floatingActionBtn = Color(0xFF1565C0);
const Color getStarted_login_signup_bottomTabs_cards = Color(0xFFFFFFFF);
const Color bg_main = Color(0xFFF9FAFB);
const Color delete_text_btn = Color(0xFFD32F2F);
const Color upvote_heart_count = Color(0xFFEF5350);
const Color icons_surroundings = Color(0xFFE3F2FD);

final ThemeData appThemeLight = ThemeData(
  colorScheme: const ColorScheme.light(
    primary: bgSplash_buttons_headers_floatingActionBtn,
    onPrimary: getStarted_login_signup_bottomTabs_cards,
    surface: getStarted_login_signup_bottomTabs_cards,
    onSurface: Colors.black87,
    error: delete_text_btn,
    onError: getStarted_login_signup_bottomTabs_cards,
    secondary: icons_surroundings,
    onSecondary: bgSplash_buttons_headers_floatingActionBtn,
  ),
  scaffoldBackgroundColor: bg_main,

  // elevated button theme
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: bgSplash_buttons_headers_floatingActionBtn,
      foregroundColor: getStarted_login_signup_bottomTabs_cards,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      elevation: 0,
      minimumSize: const Size(double.infinity, 55),
      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      disabledBackgroundColor: bgSplash_buttons_headers_floatingActionBtn
          .withAlpha((0.6 * 255).toInt()),
      disabledForegroundColor: getStarted_login_signup_bottomTabs_cards
          .withAlpha((0.7 * 255).toInt()),
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: bgSplash_buttons_headers_floatingActionBtn,
      side: const BorderSide(
        color: bgSplash_buttons_headers_floatingActionBtn,
        width: 2,
      ),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      minimumSize: const Size.fromHeight(55),
      overlayColor: bgSplash_buttons_headers_floatingActionBtn.withAlpha(
        (0.08 * 255).round(),
      ),
      disabledForegroundColor: bgSplash_buttons_headers_floatingActionBtn
          .withAlpha((0.6 * 255).round()),
    ),
  ),
  textTheme: const TextTheme(
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Color(0xFF1F2937),
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
    prefixIconColor: const Color(0xFF9E9E9E),
    suffixIconColor: const Color(0xFF9E9E9E),
    filled: true,
    fillColor: const Color(0xFFF9FAFB),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1.0),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFF9E9E9E), width: 1.5),
    ),
  ),
  // Add this to your appThemeLight in theme.dart
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: getStarted_login_signup_bottomTabs_cards,
    indicatorColor: icons_surroundings,
    indicatorShape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    iconTheme: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const IconThemeData(
          color: bgSplash_buttons_headers_floatingActionBtn,
        );
      }
      return const IconThemeData(color: Colors.grey);
    }),
    labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
  ),
);