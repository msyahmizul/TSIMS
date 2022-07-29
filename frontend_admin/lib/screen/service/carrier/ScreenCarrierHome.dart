import 'dart:convert';

import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:frontend_admin/const.dart';
import 'package:frontend_admin/widget/WidgetCenterScreenLayout.dart';

import '../../../Util.dart';

class ScreenCarrierHome extends StatefulWidget {
  static const path = "/service/carrier";

  static page() {
    return const BeamPage(
        child: ScreenCarrierHome(), key: ValueKey("carrier-home"));
  }

  const ScreenCarrierHome({Key? key}) : super(key: key);

  @override
  State<ScreenCarrierHome> createState() => _ScreenCarrierHomeState();
}

class _ScreenCarrierHomeState extends State<ScreenCarrierHome> {
  String firstName = "";
  String lastName = "";
  String planType = "";

  loadData() {
    var box = Util.getBox();
    String data = box.get(HiveBox.carrierData, defaultValue: "");
    if (data.isNotEmpty) {
      var d = jsonDecode(data);
      firstName = d["first_name"];
      lastName = d["last_name"];
      planType = d["plan_type"];
    }
  }

  @override
  void initState() {
    loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Carrier System - Home"),
      ),
      body: WidgetCenterScreenLayout(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            "Carrier Home Page",
            style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Text(
            "Account Overview",

            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Text(
            "Name : $firstName $lastName",
            style: Theme.of(context).textTheme.titleLarge,
          ),const SizedBox(height: 20),
          Text(
            "Current Plan: $planType",
            style: Theme.of(context).textTheme.titleLarge,
          ),const SizedBox(height: 20),
          Text(
            "User ID: 91724932843",
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ]),
      ),
    );
  }
}
