import 'package:flutter/material.dart';

class AuthField extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final bool isObscureText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool filled;
  final Color? fillColor;
  final bool enableTogglePassword;

  const AuthField({
    super.key,
    required this.hintText,
    required this.controller,
    this.isObscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.validator,
    this.filled = true,
    this.fillColor = Colors.white,
    this.enableTogglePassword = false,
  });

  @override
  State<AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<AuthField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isObscureText;
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget? suffixWidget = widget.suffixIcon;
    
    if (widget.enableTogglePassword && widget.isObscureText) {
      suffixWidget = IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: Colors.grey[600],
        ),
        onPressed: _togglePasswordVisibility,
      );
    }

    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      obscureText: widget.enableTogglePassword ? _obscureText : widget.isObscureText,
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
        suffixIcon: suffixWidget,
        border: const OutlineInputBorder(),
        filled: widget.filled,
        fillColor: widget.fillColor,
      ),
      validator: widget.validator ??
          (value) {
            if (value!.isEmpty) {
              return "${widget.hintText} is missing!";
            }
            return null;
          },
    );
  }
}
