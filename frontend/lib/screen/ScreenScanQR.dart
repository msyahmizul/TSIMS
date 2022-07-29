import 'dart:convert';

import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/const.dart';
import 'package:mobile/model/ModelInitConnection.dart';
import 'package:mobile/provider/providerNotificationList.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../Widget/WidgetApproveConnection.dart';
import '../provider/providerReloadData.dart';
import '../util.dart';

class ScreenScanQR extends ConsumerStatefulWidget {
  static const path = "/home/scanQR";

  static page() {
    return BeamPage(child: ScreenScanQR(), key: const ValueKey("scan-qr"));
  }

  const ScreenScanQR({Key? key}) : super(key: key);

  @override
  ConsumerState<ScreenScanQR> createState() {
    return _StateScreenScanQR();
  }
}

class _StateScreenScanQR extends ConsumerState<ScreenScanQR> {
  runChange(Widget addToList, String timestamp) {
    ref
        .read(providerNotificationList.notifier)
        .addToNotification(addToList, timestamp);
    ref
        .read(providerReloadData.notifier)
        .update((state) => {"reloadNotification": "true"});
    context.beamBack();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Code Scanner')),
      body: Container(
        width: double.infinity,
        height: 500,
        child: MobileScanner(
            allowDuplicates: false,
            onDetect: (barcode, args) {
              var rawValue = barcode.rawValue;
              if (rawValue == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Invalid QR Code")));
              } else {
                final String data = rawValue;
                try {
                  var jsonData = jsonDecode(data);
                  var qrType = Util.strToQRType(jsonData["qrType"]);

                  String timestamp =
                      DateTime.now().millisecondsSinceEpoch.toString();
                  switch (qrType) {
                    case QRType.connectionRequest:
                      ModelInitConnection conInfo =
                          ModelInitConnection.fromJson(jsonData);
                      runChange(
                          WidgetApproveNewConnection(
                              conData: conInfo, keyNotification: timestamp),
                          timestamp);
                      break;
                    case QRType.invalid:
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Invalid Json QR Format $jsonData")));
                      context.beamBack();
                      break;
                  }
                } on FormatException catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Invalid Json QR Format")));
                } catch (e) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(e.toString())));
                }
              }
            }),
      ),
    );
  }
}
