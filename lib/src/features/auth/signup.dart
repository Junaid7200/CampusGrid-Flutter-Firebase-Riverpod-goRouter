import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:campus_grid/src/shared/widgets/auth_img.dart';
import 'package:campus_grid/src/shared/widgets/text_field.dart';
import 'package:campus_grid/src/shared/widgets/button.dart';
import 'package:campus_grid/src/shared/widgets/outlined_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final TextEditingController _name_controller = TextEditingController();
  final TextEditingController _email_controller = TextEditingController();
  final TextEditingController _password_controller = TextEditingController();

  void _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      print('Name: ${_name_controller.text}');
      print('Email: ${_email_controller.text}');
      print('Password: ${_password_controller.text}');
      setState(() {
        _isLoading = true;
      });
      try {
        final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _email_controller.text,
          password: _password_controller.text,
        );
          await userCredential.user?.updateDisplayName(_name_controller.text.trim());
        print('User registered: ${userCredential}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Signup successful! Welcome, ${_name_controller.text}')),
          );
          context.go('/home');
        }
      } on FirebaseAuthException catch (e) {
        String message = "Signup failed";
        if (e.code == 'weak-password') {
          message = 'The password provided is too weak.';
        } else if (e.code == 'email-already-in-use') {
          message = 'The account already exists for that email.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      } catch (e) {
        print(e);
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

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
                    'Create Account',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 14),
                  Text(
                    'Join the Learning Community',
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
                      labelText: "Full Name",
                      hintText: "enter your full name here",
                      iconData: Icons.person_outline,
                      controller: _name_controller,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your full name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 24),
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
                    SizedBox(height: 24),
                    CustomButton(text: "Sign Up", onPressed: _handleSignup, isLoading: _isLoading),
                    SizedBox(height: 24),
                    CustomOutlinedButton(
                      text: "Continue with Google",
                      leadingIcon: FontAwesomeIcons.google,
                      onPressed: () {},
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Already have an account?"),
                        TextButton(
                          onPressed: () {
                            context.go('/login');
                          },
                          child: Text("Login"),
                        ),
                      ],
                    ),
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
