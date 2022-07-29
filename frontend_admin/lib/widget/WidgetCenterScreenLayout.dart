import 'package:flutter/material.dart';

class WidgetCenterScreenLayout extends StatelessWidget {
  Widget child;

  WidgetCenterScreenLayout({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        children: [
          const Spacer(flex: 2),
          Flexible(
            flex: 10,
            child: SingleChildScrollView(child: child),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}
