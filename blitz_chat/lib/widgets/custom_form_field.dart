import 'package:flutter/material.dart';

class CustomFormField extends StatelessWidget {
  final String hintText;
  final double height;
  final RegExp validationRegexp;
  final bool obscureText;
  final void Function(String?) onSaved;

  const CustomFormField({
    super.key,
    required this.hintText,
    required this.height,
    required this.validationRegexp,
    this.obscureText = false,
    required this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: TextFormField(
        onSaved: onSaved,
        obscureText: obscureText,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Please enter your $hintText.";
          }
          if (!validationRegexp.hasMatch(value)) {
            return "Please enter a valid ${hintText.toLowerCase()}. Make sure the Password has one uppercase, one number, and one special character.";
          }
          return null;
        },
        style: const TextStyle(color: Colors.white), // Set the text color to white
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey), // Set the hint color to grey
          border: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.white,
              width: 2.0,
            ),
          ),
          prefixIcon: _buildPrefixIcon(),
        ),
      ),
    );
  }

  Icon? _buildPrefixIcon() {
    switch (hintText) {
      case 'Email':
        return const Icon(Icons.email, color: Colors.white);
      case 'Password':
        return const Icon(Icons.lock, color: Colors.white);
      case 'Name':
        return const Icon(Icons.person, color: Colors.white);
      default:
        return null;
    }
  }
}
