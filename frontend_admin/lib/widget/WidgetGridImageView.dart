import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:frontend_admin/const.dart';

class WidgetGridImageView extends StatelessWidget {
  final String userID;
  final List<String> files;

  const WidgetGridImageView(
      {Key? key, required this.files, required this.userID})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> childImage = files
        .map((fileID) => SizedBox(
              width: 200,
              height: 200,
              child: GestureDetector(
                onTap: () {
                  Beamer.of(context).beamToNamed("/user/$userID/img/$fileID");
                },
                child: Card(
                  child: Image.network(
                    "https://appwrite.tsims.ml/v1/storage/buckets/${Backend.bucketStorageID}/files/$fileID/preview?width=200&height=200",
                    headers: Backend.headerAPINetworkImage,
                    loadingBuilder: (context, child, progress) {
                      return progress == null
                          ? child
                          : CircularProgressIndicator(
                              value: progress.expectedTotalBytes! /
                                  progress.cumulativeBytesLoaded,
                            );
                    },
                  ),
                ),
              ),
            ))
        .toList();
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 4,
      children: childImage,
    );
  }
}
