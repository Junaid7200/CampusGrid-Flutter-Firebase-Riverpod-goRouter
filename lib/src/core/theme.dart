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
);
