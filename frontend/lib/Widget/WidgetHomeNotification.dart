import 'package:flutter/material.dart';

class WidgetHomeNotification extends StatelessWidget {
  const WidgetHomeNotification({Key? key, required this.children})
      : super(key: key);

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView(children: children);
  }
}
