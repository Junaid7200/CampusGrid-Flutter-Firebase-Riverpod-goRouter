import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';



class AuthPagesImage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
  const String splashIcon = 'assets/images/startup/Splash_Icon.svg';
  final colors = Theme.of(context).colorScheme;
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: colors.primary.withAlpha(30),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: SvgPicture.asset(
          splashIcon,
          width: 60,
          height: 60,
        ),
      )
    );
  }
}