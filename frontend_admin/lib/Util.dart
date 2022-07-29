import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'const.dart';

class Util {
  static QRType strToQRType(String value) {
    switch (value) {
      case "connectionRequest":
        return QRType.connectionRequest;
      default:
        throw Exception("Invalid QR Type");
    }
  }

  static Box getBox() {
    return Hive.box(HiveBox.boxName);
  }

  static void runSnackBarMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  static AgentType strToAgentType(String value) {
    switch (value) {
      case "multi":
        return AgentType.multi;
      case "banking":
        return AgentType.banking;
      case "carrier":
        return AgentType.carrier;
      case "university":
        return AgentType.university;
      case "invalid":
        return AgentType.invalid;
      default:
        throw Exception("Invalid Agent Type");
    }
  }
}
