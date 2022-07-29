import 'dart:convert';

import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_admin/Util.dart';
import 'package:frontend_admin/const.dart';
import 'package:frontend_admin/widget/WidgetCenterScreenLayout.dart';

class ScreenBankingHome extends ConsumerStatefulWidget {
  static const path = "/service/bank";

  static page() {
    return const BeamPage(
        child: ScreenBankingHome(), key: ValueKey("bank-home"));
  }

  const ScreenBankingHome({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _ScreenBankingHomeState();
  }
}

class _ScreenBankingHomeState extends ConsumerState<ScreenBankingHome> {
  String firstName = "";
  String lastName = "";

  @override
  void initState() {
    var box = Util.getBox();
    String data = box.get(HiveBox.bankData, defaultValue: "");
    if (data.isNotEmpty) {
      var d = jsonDecode(data);
      firstName = d["first_name"];
      lastName = d["last_name"];
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var box = Util.getBox();
    String data = box.get(HiveBox.bankData, defaultValue: "");
    if (data.isNotEmpty) {
      Future.delayed(const Duration(seconds: 3)).then((_) {
        var d = jsonDecode(data);
        firstName = d["first_name"];
        lastName = d["last_name"];
      });
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Banking System - Home"),
      ),
      body: WidgetCenterScreenLayout(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            "Bank Home Page",
            style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Text(
            "Account Overview",
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Text(
            "Name: $firstName $lastName",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Text(
            "User ID: 7072034878907",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          Text(
            "Current Balance",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 5),
          Text(
            "MYR 10000",
            style: Theme.of(context).textTheme.titleLarge,
          )
        ]),
      ),
    );
  }
}
