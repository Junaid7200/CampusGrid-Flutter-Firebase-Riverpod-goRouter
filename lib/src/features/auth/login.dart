import 'package:flutter/material.dart';
import 'package:campus_grid/src/shared/widgets/auth_img.dart';
import 'package:campus_grid/src/shared/widgets/text_field.dart';
import 'package:campus_grid/src/shared/widgets/button.dart';
import 'package:campus_grid/src/shared/widgets/outlined_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _email_controller = TextEditingController();
  final TextEditingController _password_controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              Column(
                children: [
                  AuthPagesImage(),
                  SizedBox(height: 14),
                  Text(
                    'Welcome Back',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 14),
                  Text(
                    'Login to continue to Campus Grid',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 24),
                ],
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomTextField(
                      labelText: "Email",
                      hintText: "enter your email here",
                      iconData: Icons.email_outlined,
                      controller: _email_controller,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 24),
                    CustomTextField(
                      labelText: "Password",
                      hintText: "enter your password here",
                      iconData: Icons.lock_outline,
                      obscureText: true,
                      controller: _password_controller,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters long';
                        }
                        return null;
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            context.go('/forgot-password');
                          },
                          child: Text("Forgot Password?"),
                        ),
                      ],
                    ),
                    CustomButton(text: "Login", onPressed: () {}),
                    SizedBox(height: 24),
                    CustomOutlinedButton(
                      text: "Continue with Google",
                      leadingIcon: FontAwesomeIcons.google,
                      onPressed: () {},
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account?"),
                        TextButton(
                          onPressed: () {
                            context.go('/signup');
                          },
                          child: Text("Signup"),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
