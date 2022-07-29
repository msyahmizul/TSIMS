import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WidgetApproveOfferCredential extends ConsumerWidget {
  final String keyNotification;
  final String name;

  const WidgetApproveOfferCredential(
      {Key? key, required this.keyNotification, required this.name})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Text("New Credential Store Request"),
      trailing: ElevatedButton(
          onPressed: () {
            context.beamToNamed("/home/credentialNew/$keyNotification");
          },
          child: const Text("View Detail")),
      subtitle: Text(name),
    );
  }
}
