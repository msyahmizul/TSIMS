import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_admin/beam_location.dart';
import 'package:frontend_admin/const.dart';
import 'package:frontend_admin/screen/ScreenChoicePath.dart';
import 'package:frontend_admin/screen/ScreenNotFound.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox(HiveBox.boxName);
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final routerDelegate = BeamerDelegate(
      locationBuilder: BeamerLocationBuilder(
        beamLocations: beamLocation,
      ),
      notFoundRedirectNamed: NotFoundScreen.path,
      initialPath: ScreenPathChoice.path);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routeInformationParser: BeamerParser(),
      routerDelegate: routerDelegate,
      backButtonDispatcher:
          BeamerBackButtonDispatcher(delegate: routerDelegate),
    );
  }
}
