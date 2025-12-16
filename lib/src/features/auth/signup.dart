import 'package:flutter/material.dart';
import 'package:campus_grid/src/shared/widgets/auth_img.dart';
import 'package:campus_grid/src/shared/widgets/text_field.dart';
import 'package:campus_grid/src/shared/widgets/button.dart';


class SignupPage extends StatefulWidget {
  const SignupPage({super.key});
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _name_controller = TextEditingController();
  final TextEditingController _email_controller = TextEditingController();
  final TextEditingController _password_controller = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: 
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const Spacer(flex: 1),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                  AuthPagesImage(),
                  SizedBox(height: 14),
                  Text('Create Account', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 14),
                  Text('Join the Learning Community', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  SizedBox(height: 24,),
                    ],
                  ),
                ),
              ),
              Expanded(
              flex: 5,
              child: Column(
                children: [
                CustomTextField(labelText: "Full Name", hintText: "enter your full name here", iconData: Icons.person_outline, controller: _name_controller),
                SizedBox(height: 24,),
                CustomTextField(labelText: "Email", hintText: "enter your email here", iconData: Icons.email_outlined, controller: _email_controller),
                SizedBox(height: 24,),
                CustomTextField(labelText: "Password", hintText: "enter your password here", iconData: Icons.lock_outline, obscureText: true, controller: _password_controller),
                SizedBox(height: 24,),
                CustomButton(text: "Sign Up", onPressed: () {})
                ],
              ))
            ],
          ),
        )),
    );
  }

}