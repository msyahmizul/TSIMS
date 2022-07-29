import 'dart:convert';

import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:mobile/provider/ProviderSignUpForm.dart';
import 'package:mobile/screen/ScreenLogin.dart';

import '../../const.dart';
import '../../service/ServiceUserSignUp.dart';
import '../ScreenHome.dart';

class Page5_Finalise extends ConsumerWidget {
  const Page5_Finalise({Key? key}) : super(key: key);
  static const path = "/signup/5";

  static page() {
    return const BeamPage(child: Page5_Finalise(), key: ValueKey("signup-5"));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userData = ref.read(providerUserSignUp);

    Future<void>(() async {
      var box = Hive.box(BoxName.name);
      String jwtKey = box.get(BoxName.jwtKey);
      await ServiceUserSignUp.signUpUserData(jwtKey, userData.userData);
      await ServiceUserSignUp.uploadUserData(jwtKey, userData.userFile);
      await box.put(BoxName.userData, jsonEncode(userData.userData));
      ref.invalidate(providerUserSignUp);
    }).then((value) async {
      context.beamToReplacementNamed(ScreenHome.path);
    }).catchError((e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
      var box = Hive.box(BoxName.name);
      box.clear().then((_) {
        context.beamToReplacementNamed(ScreenLogin.path);
      });
    });
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text("Signing Up"),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
