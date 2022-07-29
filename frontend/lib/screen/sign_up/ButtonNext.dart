import 'package:flutter/material.dart';

class ButtonNext extends StatelessWidget {
  final Function onPressed;
  final String textButton;

  const ButtonNext(
      {Key? key, required this.onPressed, this.textButton = "Next"})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => onPressed(),
        child: Text(textButton),
      ),
    );
  }
}
