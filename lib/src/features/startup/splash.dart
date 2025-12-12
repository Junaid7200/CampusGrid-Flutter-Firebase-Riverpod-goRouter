import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});


  @override
  Widget build(BuildContext context) {
    const String splash_icon = 'assets/images/startup/Splash_Icon.svg';
    final colors = Theme.of(context).colorScheme;
    // debugPrint('primary = ${Theme.of(context).colorScheme.primary.value.toRadixString(16)}');

    return 
    Scaffold(
      backgroundColor: colors.primary,
      body: Center(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: colors.onPrimary.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SvgPicture.asset(
                  splash_icon,
                  width: 100,
                  height: 100,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Campus Grid',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: colors.onPrimary),
            ),
            const SizedBox(height: 10),
            Text(
              'Peer-to-Peer Learning Platform',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: colors.onPrimary),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(colors.onPrimary),
                strokeWidth: 4,
              ),
            )
          ],
        )
      ),
    );
  }
}