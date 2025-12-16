import 'package:flutter/material.dart';
import 'package:campus_grid/src/shared/widgets/auth_img.dart';


class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Text('Login Page'),
            AuthPagesImage(),
          ],
        ),
      ),
    );
  }
}