import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WidgetApproveCredentialProof extends ConsumerWidget {
  final String keyNotification;
  final String name;

  const WidgetApproveCredentialProof(
      {Key? key, required this.keyNotification, required this.name})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Text("New Credential Proof Request"),
      trailing: ElevatedButton(
          onPressed: () {
            context.beamToNamed("/home/credentialRequest/$keyNotification");
          },
          child: const Text("View Detail")),
      subtitle: Text(name),
    );
  }
}
