import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:campus_grid/src/shared/widgets/auth_img.dart';
import 'package:campus_grid/src/shared/widgets/text_field.dart';
import 'package:campus_grid/src/shared/widgets/button.dart';
import 'package:campus_grid/src/shared/widgets/outlined_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  final TextEditingController _name_controller = TextEditingController();
  final TextEditingController _email_controller = TextEditingController();
  final TextEditingController _password_controller = TextEditingController();

  bool _isGoogleSignInInitialized = false;
  StreamSubscription<GoogleSignInAuthenticationEvent>? _authEventSubscription;

  @override
  void initState() {
    super.initState();
    _initializeGoogleSignIn();
  }

  @override
  void dispose() {
    _name_controller.dispose();
    _email_controller.dispose();
    _password_controller.dispose();
    _authEventSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeGoogleSignIn() async {
    try {
      await GoogleSignIn.instance.initialize();
      _isGoogleSignInInitialized = true;
    } catch (e) {
      print('Google Sign-In initialization error: $e');
    }
  }

  void _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      print('Name: ${_name_controller.text}');
      print('Email: ${_email_controller.text}');
      print('Password: ${_password_controller.text}');
      setState(() {
        _isLoading = true;
      });
      try {
        final userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: _email_controller.text,
              password: _password_controller.text,
            );
        final user = userCredential.user;
        // await user?.sendEmailVerification();
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
                'displayName': _name_controller.text.trim(),
                'email': _email_controller.text.trim(),
                'createdAt': FieldValue.serverTimestamp(),
                'notesCount': 0,
                'likesReceived': 0,
                'savedNotes': 0,
              });
        }
        print('User registered: ${userCredential}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Signup successful! Welcome, ${_name_controller.text}',
              ),
            ),
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
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

  Future<void> _handleGoogleLogin() async {
    setState(() {
      _isGoogleLoading = true;
    });

    try {
      // Ensure Google Sign-In is initialized
      if (!_isGoogleSignInInitialized) {
        await _initializeGoogleSignIn();
      }

      // Create a Completer to handle the event-driven API
      final Completer<GoogleSignInAccount?> completer =
          Completer<GoogleSignInAccount?>();

      // Listen to authentication events
      _authEventSubscription?.cancel();
      _authEventSubscription = GoogleSignIn.instance.authenticationEvents
          .listen((event) {
            if (event is GoogleSignInAuthenticationEventSignIn) {
              if (!completer.isCompleted) {
                completer.complete(event.user);
              }
            }
          });

      // Trigger the authentication
      await GoogleSignIn.instance.authenticate();

      // Wait for the user from the event stream
      final GoogleSignInAccount? googleUser = await completer.future.timeout(
        Duration(seconds: 30),
        onTimeout: () => null,
      );

      // Cancel the subscription
      _authEventSubscription?.cancel();

      if (googleUser == null) {
        // User canceled the sign-in
        setState(() {
          _isGoogleLoading = false;
        });
        return;
      }

      // Get the authentication tokens (synchronous in v7)
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // Create a new credential for Firebase (only idToken is required)
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      final user = userCredential.user;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'displayName': user.displayName ?? 'No Name',
          'email': user.email,
          'createdAt': FieldValue.serverTimestamp(),
            'notesCount': 0,
            'likesReceived': 0,
            'savedNotes': 0,
        }, SetOptions(merge: true));
      }
      print('Google sign-in successful');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login successful! Welcome to Campus Grid.')),
        );
        context.go('/home');
      }
    } on GoogleSignInException catch (e) {
      // Handle Google Sign-In specific exceptions
      String message = "Google sign-in failed";
      if (e.code == GoogleSignInExceptionCode.canceled) {
        message = 'Sign-in was canceled';
      } else if (e.code == GoogleSignInExceptionCode.clientConfigurationError) {
        message = 'Configuration error. Please contact support.';
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
      print('Google sign-in exception: ${e.code} - ${e.description}');
    } on FirebaseAuthException catch (e) {
      String message = "Firebase authentication failed";
      if (e.code == 'account-exists-with-different-credential') {
        message = 'An account already exists with the same email address.';
      } else if (e.code == 'invalid-credential') {
        message = 'Invalid credential. Please try again.';
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      print('Error during Google sign-in: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred. Please try again.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
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
                    CustomButton(
                      text: "Sign Up",
                      onPressed: _handleSignup,
                      isLoading: _isLoading,
                    ),
                    SizedBox(height: 24),
                    CustomOutlinedButton(
                      text: "Continue with Google",
                      leadingIcon: FontAwesomeIcons.google,
                      onPressed: () => _handleGoogleLogin(),
                      isLoading: _isGoogleLoading,
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
