import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:frontend_admin/screen/admin/ScreenUserListBriefScreen.dart';
import 'package:frontend_admin/screen/service/banking/ScreenBankingLogin.dart';
import 'package:frontend_admin/screen/service/carrier/ScreenCarrierLogin.dart';
import 'package:frontend_admin/screen/service/university/ScreenUniversityLogin.dart';
import 'package:frontend_admin/widget/WidgetCenterScreenLayout.dart';

class ScreenPathChoice extends StatelessWidget {
  static const path = "/";

  static page() {
    return BeamPage(child: ScreenPathChoice(), key: ValueKey("path-choice"));
  }

  const ScreenPathChoice({Key? key}) : super(key: key);

  List<Widget> serviceList(BuildContext context) {
    List<Widget> u = [];
    u.add(const SizedBox(height: 20));

    u.add(SizedBox(
      width: 250,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          context.beamToNamed(ScreenBankingLogin.path);
        },
        style: ElevatedButton.styleFrom(primary: Colors.red),
        child: const Text("1. Bank Service"),
      ),
    ));
    u.add(const SizedBox(height: 20));

    u.add(SizedBox(
      width: 250,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          context.beamToNamed(ScreenCarrierLogin.path);
        },
        style: ElevatedButton.styleFrom(primary: Colors.deepPurpleAccent),
        child: const Text("2. Carrier Service"),
      ),
    ));
    u.add(const SizedBox(height: 20));

    u.add(SizedBox(
      width: 250,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          context.beamToNamed(ScreenUniversityLogin.path);
        },
        style: ElevatedButton.styleFrom(primary: Colors.green),
        child: const Text("3. University Service"),
      ),
    ));
    u.add(const SizedBox(height: 20));
    return u;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WidgetCenterScreenLayout(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              Text(
                "Welcome to Trusted Shared Identity Management System",
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontSize: 50),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 250,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    context.beamToNamed(ScreenUserListBrief.path);
                  },
                  style: ElevatedButton.styleFrom(primary: Colors.blue),
                  child: const Text("Admin Login"),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Service Page",
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontSize: 50),
              ),
              ...serviceList(context)
            ],
          ),
        ),
      ),
    );
  }
}
