import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String labelText;
  final String hintText;
  final IconData iconData;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextEditingController controller;

  const CustomTextField({
    Key? key,
    required this.labelText,
    required this.hintText,
    required this.iconData,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: Icon(iconData),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}