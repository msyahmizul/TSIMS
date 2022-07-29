import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';

class NotFoundScreen extends StatelessWidget {
  static const path = "/404";
  static const pathBuilder = [
    BeamPage(child: NotFoundScreen(), key: ValueKey("404"))
  ];

  const NotFoundScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "404 not found",
        style: Theme.of(context).textTheme.bodyText1,
      ),
    );
  }
}
