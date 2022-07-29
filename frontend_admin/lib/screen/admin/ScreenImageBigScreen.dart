import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:frontend_admin/const.dart';

class ImageBigScreen extends StatelessWidget {
  final String imgID;
  static const path = "/user/:id/img/:${ImageBigScreen.argsName}";
  static const argsName = "imgID";

  static page(String imageID) {
    return BeamPage(
        child: ImageBigScreen(imgID: imageID), key: ValueKey('img-$imageID'));
  }

  const ImageBigScreen({Key? key, required this.imgID}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Image"),
      ),
      body: Center(
        child: Image.network(
          "https://appwrite.tsims.ml/v1/storage/buckets/${Backend.bucketStorageID}/files/$imgID/preview",
          headers: Backend.headerAPINetworkImage,
        ),
      ),
    );
  }
}
