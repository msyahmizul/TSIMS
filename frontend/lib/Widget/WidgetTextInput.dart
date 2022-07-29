import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WidgetTextInput extends StatelessWidget {
  final String labelText;
  final String hintText;
  final String initialValue;
  final bool obscureText;
  final String? customErrorMessage;

  final String? Function(String?) validate;
  final List<TextInputFormatter> formatter;
  final void Function(String?) onSaved;

  const WidgetTextInput(
      {Key? key,
      this.customErrorMessage,
      this.obscureText = false,
      required this.labelText,
      this.hintText = "",
      required this.validate,
      required this.onSaved,
      this.initialValue = "",
      this.formatter = const []})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onSaved: onSaved,
      obscureText: obscureText,
      initialValue: initialValue,
      inputFormatters: formatter,
      validator: validate,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        errorText: customErrorMessage,
        border: const UnderlineInputBorder(),
      ),
    );
  }
}
