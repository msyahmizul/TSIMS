import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:mobile/screen/ScreenSplash.dart';

import 'beam_location.dart';
import 'const.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox(BoxName.name);
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);
  final routerDelegate = BeamerDelegate(
      locationBuilder: BeamerLocationBuilder(
        beamLocations: beamLocation,
      ),
      notFoundRedirectNamed: '/home',
      initialPath: ScreenSplash.path);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationParser: BeamerParser(),
      routerDelegate: routerDelegate,
      debugShowCheckedModeBanner: false,
      backButtonDispatcher:
          BeamerBackButtonDispatcher(delegate: routerDelegate),
      theme: ThemeData(
        primarySwatch: const MaterialColor(
          0xff109F97,
          <int, Color>{
            50: Color(0xFFe7f5f5),
            100: Color(0xFFcfecea),
            200: Color(0xFF9fd9d5),
            300: Color(0xFF70c5c1),
            400: Color(0xFF40b2ac),
            500: Color(0xff109F97),
            600: Color(0xFF0e8f88),
            700: Color(0xff0d7f79),
            800: Color(0xFF0b6f6a),
            900: Color(0xFF0a5f5b),
          },
        ),
        textTheme: ThemeData.light().textTheme.copyWith(
              titleMedium: ThemeData.light()
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
      ),
    );
    // return MaterialApp(
    //   title: "Trusted Shared Identity Management System Mobile Apps",
    //   theme: ThemeData(
    //     primarySwatch: const MaterialColor(
    //       0xff109F97,
    //       <int, Color>{
    //         50: Color(0xFFe7f5f5),
    //         100: Color(0xFFcfecea),
    //         200: Color(0xFF9fd9d5),
    //         300: Color(0xFF70c5c1),
    //         400: Color(0xFF40b2ac),
    //         500: Color(0xff109F97),
    //         600: Color(0xFF0e8f88),
    //         700: Color(0xff0d7f79),
    //         800: Color(0xFF0b6f6a),
    //         900: Color(0xFF0a5f5b),
    //       },
    //     ),
    //     textTheme: ThemeData.light().textTheme.copyWith(
    //           titleMedium: ThemeData.light()
    //               .textTheme
    //               .titleMedium
    //               ?.copyWith(fontWeight: FontWeight.bold),
    //         ),
    //   ),
    //   home: const ScreenLogin(),
    // );
  }
}
