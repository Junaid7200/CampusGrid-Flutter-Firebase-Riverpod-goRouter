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
    required this.iconData ,
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
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelText: labelText,
        hintText: hintText,
        hintStyle: TextStyle(color: Color(0xFF9E9E9E)),
        prefixIcon: Icon(iconData, color: Color(0xFF9E9E9E)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(
            color: Color(0xFF9E9E9E),
            width: 5.0,

          ),
        ),
        filled: true,
        fillColor: Color(0xFFF9FAFB),
      ),
    );
  }
}