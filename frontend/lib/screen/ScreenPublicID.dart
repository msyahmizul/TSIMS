import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ScreenPublicID extends StatefulWidget {
  const ScreenPublicID({Key? key}) : super(key: key);

  @override
  State<ScreenPublicID> createState() {
    return _StateScreenPublicID();
  }
}

class _StateScreenPublicID extends State<ScreenPublicID> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Your Public ID'),
        backgroundColor: const Color(0xF4ECF1F4),
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Stack(
            children: [
              Positioned(
                child: Container(
                  width: 300,
                  height: 300,
                  color: const Color(0xfff8e7f1),
                ),
              ),
              Positioned(
                child: Container(
                  alignment: AlignmentDirectional.center,
                  child: Card(
                    color: Colors.white,
                    elevation: 0,
                    child: QrImage(
                      data: "kkj2nsjslk2ajhhjbjn2jnkjiosacjkoa",
                      version: QrVersions.auto,
                      size: 200,
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
