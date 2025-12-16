import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';



class AuthPagesImage extends StatelessWidget {
  const AuthPagesImage({super.key});

  @override
  Widget build(BuildContext context) {
  const String splashIcon = 'assets/images/startup/Splash_Icon.svg';
  final colors = Theme.of(context).colorScheme;
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Color(0xFFE3F2FD),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: SvgPicture.asset(
          splashIcon,
          colorFilter: ColorFilter.mode(colors.primary, BlendMode.srcIn),
          width: 60,
          height: 60,
        ),
      )
    );
  }
}