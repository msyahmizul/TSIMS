import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:mobile/screen/ScreenLogin.dart';

import '../const.dart';
import 'ScreenHome.dart';

class ScreenSplash extends StatelessWidget {
  static const path = "/splash";

  static page() {
    return BeamPage(child: ScreenSplash(), key: const ValueKey("splash"));
  }

  const ScreenSplash({Key? key}) : super(key: key);

  initCheck(BuildContext context) {
    Future.delayed(const Duration(seconds: 1), () {}).then((value) async {
      var box = Hive.box(BoxName.name);
      String jwtKey = await box.get(BoxName.jwtKey, defaultValue: "");
      String userData = await box.get(BoxName.userData, defaultValue: "");

      return jwtKey.isNotEmpty && userData.isNotEmpty;
    }).then((bool isExist) {
      if (!isExist) {
        context.beamToReplacementNamed(ScreenLogin.path);
      } else {
        context.beamToReplacementNamed(ScreenHome.path);
      }
    }).catchError((e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
      context.beamToNamed(ScreenLogin.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    initCheck(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text("Loading", style: Theme.of(context).textTheme.headline6),
          ],
        ),
      ),
    );
  }
}
