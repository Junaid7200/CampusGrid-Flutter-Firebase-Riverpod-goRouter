import 'package:flutter/material.dart';
import 'router.dart';
import 'theme.dart';
import '../features/startup/splash.dart';

class CampusGridApp extends StatelessWidget {
  const CampusGridApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routerConfig: appRouter, theme:lightTheme);
    // return MaterialApp(
    //   title: "Campus Grid",
    //   theme: lightTheme,
    //   home: const SplashPage()
    // );
  }
}