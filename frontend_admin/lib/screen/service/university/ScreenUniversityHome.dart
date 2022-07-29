import 'dart:convert';

import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:frontend_admin/Util.dart';
import 'package:frontend_admin/const.dart';
import 'package:frontend_admin/screen/service/university/ScreenUniversityLogin.dart';
import 'package:frontend_admin/widget/WidgetCenterScreenLayout.dart';

class ScreenUniversityHome extends StatefulWidget {
  static const path = "/service/uni";

  static page() {
    return const BeamPage(
        child: ScreenUniversityHome(), key: ValueKey("uni-home"));
  }

  const ScreenUniversityHome({Key? key}) : super(key: key);

  @override
  State<ScreenUniversityHome> createState() => _ScreenUniversityHomeState();
}

class _ScreenUniversityHomeState extends State<ScreenUniversityHome> {
  String firstname = "";
  String lastName = "";
  String degree = "";
  String status = "";

  @override
  void initState() {
    var box = Util.getBox();
    String data = box.get(HiveBox.universityData, defaultValue: "");
    if (data.isNotEmpty) {
      var d = jsonDecode(data);
      firstname = d["first_name"];
      lastName = d["last_name"];
      degree = d["degree"];
      status = d["status"];
    } else {
      context.beamToReplacementNamed(ScreenUniversityLogin.path);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("University System - Home"),
      ),
      body: WidgetCenterScreenLayout(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            "University Home Page",
            style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Text(
            "Name: $firstname $lastName",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          Text(
            "Course Enroll: $degree",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          Text(
            "Status: $status",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 5),
        ]),
      ),
    );
  }
}
