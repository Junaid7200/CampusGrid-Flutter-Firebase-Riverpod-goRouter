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








/*

Primary Colors
primary: Main brand color - used for:

AppBar background
FloatingActionButton
Prominent buttons (ElevatedButton)
Active states (selected tabs, checkboxes)
Headers
onPrimary: Text/icons on top of primary color

If primary is blue, onPrimary is usually white for contrast
Surface Colors
surface: Background color for "surfaces" like:

Cards
Dialogs
Bottom sheets
Menus
Not the main scaffold background (that's separate)
onSurface: Text/icons on surfaces (usually dark gray or black)

Secondary Colors
secondary: Accent color for less prominent elements:

Switches
Sliders
Progress indicators
Highlighting selections
Less important than primary (used sparingly)
onSecondary: Text/icons on secondary color backgrounds

Error Colors
error: Destructive actions and error states
onError: Text on error backgrounds


*/