import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/provider/providerCredentialList.dart';
import 'package:mobile/util.dart';

import '../model/modelCredential.dart';

class ScreenIdentityCredentials extends ConsumerStatefulWidget {
  static const path = "/home/credentials";

  static page() {
    return const BeamPage(
        child: ScreenIdentityCredentials(), key: ValueKey("credentials"));
  }

  const ScreenIdentityCredentials({Key? key}) : super(key: key);

  @override
  ConsumerState<ScreenIdentityCredentials> createState() {
    return _ScreenIdentityCredentialsState();
  }
}

class _ScreenIdentityCredentialsState
    extends ConsumerState<ScreenIdentityCredentials> {
  List<_CredentialWidget> credentials = [];
  bool isLoading = true;

  Future<void> initData() async {
    await ref.read(providerCredentialListBrief.notifier).getData();
    var data = ref.read(providerCredentialListBrief);
    List<_CredentialWidget> p = [];
    data.forEach((key, value) {
      p.add(_CredentialWidget(cre: value, credID: key));
    });
    setState(() {
      credentials = p;
      isLoading = false;
    });
  }

  @override
  void initState() {
    initData().catchError((e) {
      Util.runSnackBarMessage(context, e.toString());
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<Map<String, ModelCredential>>(providerCredentialListBrief,
        (previous, next) {
      List<_CredentialWidget> p = [];
      next.forEach((key, value) {
        p.add(_CredentialWidget(cre: value, credID: key));
      });
      setState(() {
        credentials = p;
      });
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('My Credentials'),
        actions: [
          IconButton(
              onPressed: () async {
                if (isLoading) {
                  return;
                }
                setState(() {
                  isLoading = true;
                });
                await initData();
              },
              icon: const Icon(Icons.refresh))
        ],
        backgroundColor: const Color(0xF4ECF1F4),
        foregroundColor: Colors.black,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: credentials,
                ),
              ),
            ),
    );
  }
}

class _CredentialWidget extends StatelessWidget {
  final ModelCredential cre;
  final String credID;

  const _CredentialWidget({
    Key? key,
    required this.cre,
    required this.credID,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(primary: Colors.black),
      onPressed: () {
        Beamer.of(context).beamToNamed("/home/credentials/$credID");
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cre.type, textAlign: TextAlign.start),
                  Text(cre.origin, textAlign: TextAlign.start),
                ],
              ),
            ),
            const Icon(Icons.drag_handle),
          ],
        ),
      ),
    );
  }
}

class Credential {
  final String title;
  final String subtitle;

  Credential({required this.title, required this.subtitle});
}
