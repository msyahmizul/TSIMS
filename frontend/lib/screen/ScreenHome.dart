import 'dart:async';
import 'dart:convert';

import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:mobile/Widget/WidgetApproveCredentialProof.dart';
import 'package:mobile/provider/providerCredentialList.dart';
import 'package:mobile/provider/providerHoldData.dart';
import 'package:mobile/provider/providerNotificationList.dart';
import 'package:mobile/screen/ScreenLogin.dart';
import 'package:mobile/screen/sign_up/Page2_SignUpProfile.dart';
import 'package:mobile/service/ServiceAgent.dart';

import '../ScreenGenerateDIDFlow.dart';
import '../Widget/WidgetApproveOfferCredential.dart';
import '../Widget/WidgetHomeNotification.dart';
import '../const.dart';
import '../model/ModelUserData.dart';
import '../model/ModelWallet.dart';
import '../provider/providerReloadData.dart';
import '../service/ServiceUser.dart';
import '../util.dart';
import 'ScreenIdentityCredentials.dart';
import 'ScreenScanQR.dart';

class ScreenHome extends ConsumerStatefulWidget {
  static const path = "/home";

  static page() {
    return BeamPage(child: ScreenHome(), key: const ValueKey("home"));
  }

  ScreenHome({Key? key}) : super(key: key);

  @override
  ConsumerState<ScreenHome> createState() {
    return _ScreenHomeState();
  }
}

class _ScreenHomeState extends ConsumerState<ScreenHome> {
  List<Widget> wList = [];

  ModelWallet wallet = ModelWallet();
  ModelUserData user = const ModelUserData();
  Timer? timeCheck;

  @override
  void dispose() {
    if (timeCheck != null) {
      timeCheck?.cancel();
    }
    super.dispose();
  }

  initData() {
    final box = Hive.box(BoxName.name);
    var u = jsonDecode(box.get(BoxName.userData));
    user = ModelUserData.fromJson(u, u!["username"]);
    u = box.get(BoxName.walletData, defaultValue: "");
    if (u.isNotEmpty) {
      wallet = ModelWallet.fromJson(jsonDecode(u));
      ref.read(providerCredentialListBrief.notifier).getData();
      ServiceAgentUtil.getMultiTenantAuthToken();
      intervalCheck().catchError((e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      });
    } else {
      wList = [
        const ListTile(
            title: Text(
                "We are still verifying your documents. This may take a few business days"))
      ];

      checkStatus(box).catchError((e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      });
    }
  }

  Future<void> checkProofRequest(String walletToken) async {
    var resp = await ServiceAgentProof.getPresentProofExchange(
        AgentURL.multiTenant,
        Util.getHeader(AgentType.multi, walletToken),
        "request_received");
    if (resp.isEmpty) {
      return;
    }

    for (final x in resp) {
      if ((x["presentation_request"]["requested_attributes"]
              as Map<String, dynamic>)
          .isNotEmpty) {
        var t = (x["presentation_request"]["requested_attributes"]
            as Map<String, dynamic>);
        var p = t.entries.elementAt(0);
        String schemaID =
            (p.value as Map<String, dynamic>)["restrictions"][0]["schema_id"];

        if (!ref.read(providerCredentialListBrief).containsKey(schemaID)) {
          await ServiceAgentProof.sendRejectMessageProof(
              AgentURL.multiTenant,
              Util.getHeader(AgentType.multi, walletToken),
              x["presentation_exchange_id"],
              "User does not have credential with following scheme");
          continue;
        }
        Map<String, dynamic> predicateTest =
            x["presentation_request"]["requested_predicates"];
        if (predicateTest.containsKey("age")) {
          var age =
              ref.read(providerCredentialListBrief)[schemaID]!.attrs["dob"]!;
          if (predicateTest["age"]["p_value"] > int.parse(age)) {
            showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                      title: const Text("Request Predicate Failed"),
                      content: Text(
                          "Value age is not satisfy\nRequired ${predicateTest["age"]["p_value"]} and up\nCurrent Age $age"),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text("close"))
                      ],
                    ),
                barrierDismissible: true);
            await ServiceAgentProof.sendRejectMessageProof(
                AgentURL.multiTenant,
                Util.getHeader(AgentType.multi, walletToken),
                x["presentation_exchange_id"],
                "User does not have enough requirement 'age'");
            continue;
          }
        }
      } else {
        var t = (x["presentation_request"]["requested_predicates"]
            as Map<String, dynamic>);
        var p = t.entries.elementAt(0);
        String schemaID =
            (p.value as Map<String, dynamic>)["restrictions"][0]["schema_id"];
        if (!ref.read(providerCredentialListBrief).containsKey(schemaID)) {
          await ServiceAgentProof.sendRejectMessageProof(
              AgentURL.multiTenant,
              Util.getHeader(AgentType.multi, walletToken),
              x["presentation_exchange_id"],
              "User does not have credential with following scheme");
          continue;
        }
      }
      ref.read(providerNotificationList.notifier).addToNotification(
          WidgetApproveCredentialProof(
              keyNotification: x["presentation_exchange_id"],
              name: x["presentation_request"]["name"]),
          x["presentation_exchange_id"]);
      ref
          .read(providerHoldData.notifier)
          .storeKey(x["presentation_exchange_id"], jsonEncode(x));
    }
    ref
        .read(providerReloadData.notifier)
        .update((state) => {"reloadNotification": "true"});
  }

  Future<void> checkCredentialRequest(String walletToken) async {
    var resp = await ServiceAgentCredential.getCredentialProposalViaState(
        AgentURL.multiTenant,
        "offer_received",
        Util.getHeader(AgentType.multi, walletToken));
    if (resp.isEmpty) {
      return;
    }
    for (final credential in resp) {
      ref.read(providerNotificationList.notifier).addToNotification(
          WidgetApproveOfferCredential(
              keyNotification: credential["credential_exchange_id"],
              name: credential["credential_proposal_dict"]["comment"]),
          credential["credential_exchange_id"]);
      ref.read(providerHoldData.notifier).storeKey(
          credential["credential_exchange_id"], jsonEncode(credential));
      ref
          .read(providerReloadData.notifier)
          .update((state) => {"reloadNotification": "true"});
    }
  }

  Future<void> intervalCheck() async {
    const timerInterval = Duration(seconds: 6);
    timeCheck = Timer.periodic(timerInterval, (timer) async {
      String walletToken = await ServiceAgentUtil.getMultiTenantAuthToken();
      await checkProofRequest(walletToken);
      await Future.delayed(const Duration(seconds: 3));
      await checkCredentialRequest(walletToken);
      await Future.delayed(const Duration(seconds: 3));
    });
  }

  Future<void> checkStatus(Box box) async {
    var token = box.get(BoxName.jwtKey);
    const timerInterval = Duration(seconds: 2);
    Timer.periodic(timerInterval, (timer) async {
      try {
        var userStatusResult = await ServiceUser.checkUserApplication(token);
        if (userStatusResult["status"] == "APPROVE") {
          setState(() {
            wList = [
              ListTile(
                title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Your Application has been accepted"),
                      OutlinedButton(
                          onPressed: () async {
                            context.beamToNamed(ScreenGenerateDIDFlow.path);
                          },
                          child: const Text("Generate wallet & DID"))
                    ]),
              )
            ];
          });
          timer.cancel();
        } else if (userStatusResult["status"] == "REJECTED") {
          setState(() {
            wList = [
              ListTile(
                title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Your Application has been Rejected"),
                      Text("Reason: ${userStatusResult["rejectMessage"]}"),
                      OutlinedButton(
                          onPressed: () async {
                            context.beamToNamed(Page2_SignUpProfile.path);
                            // Util.runSnackBarMessage(context, "Debug Click");
                          },
                          child: const Text("Resubmit Application"))
                    ]),
              )
            ];
          });
          timer.cancel();
        }
      } catch (e) {
        Util.runSnackBarMessage(context, e.toString());
        timer.cancel();
      }
    });
  }

  reloadHomeNotification() {
    ref.listen<Map<String, String>>(providerReloadData, (previous, next) {
      if (next.containsKey("didAcceptDelete")) {
        var box = Util.getBox();
        String u = box.get(BoxName.walletData, defaultValue: "");
        if (u.isNotEmpty) {
          setState(() {
            wList = [];
            wallet = ModelWallet.fromJson(jsonDecode(u));
          });
        } else {
          setState(() {
            wList = [];
          });
        }
      } else if (next.containsKey("reloadNotification")) {
        var t = ref.read(providerNotificationList).values.toList();
        if (t.length != wList.length) {
          setState(() {
            wList = t;
          });
        }
        ref.read(providerReloadData.notifier).update((state) {
          var t = state;
          t.remove("reloadNotification");
          return t;
        });
      }
    });
  }

  @override
  void initState() {
    initData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    reloadHomeNotification();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 30, right: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                TextButton(
                    onPressed: () {
                      Future<void>(() async {
                        var box = Util.getBox();
                        await box.clear();
                      }).then((_) =>
                          context.beamToReplacementNamed(ScreenLogin.path));
                    },
                    child: const Text("Logout")),
                Text(
                  "Home Page",
                  style: Theme.of(context)
                      .textTheme
                      .headline3
                      ?.copyWith(color: Colors.black),
                ),
                Text(
                  "${user.firstName} ${user.lastName}",
                  style: Theme.of(context).textTheme.headline5,
                ),
                const SizedBox(height: 50),
                _PublicID(did: wallet.did),
                const SizedBox(height: 20),
                Text(
                  'Notification',
                  style: Theme.of(context)
                      .textTheme
                      .headline5
                      ?.copyWith(color: Colors.black),
                ),
                const SizedBox(height: 10),
                Container(
                  height: 230,
                  child: WidgetHomeNotification(
                    children: wList,
                  ),
                ),
                Container(
                  width: double.infinity,
                  child: Container(
                    width: 50,
                    alignment: AlignmentDirectional.center,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton(
                          onPressed: wallet.wallet.isEmpty
                              ? null
                              : () {
                                  context.beamToNamed(
                                      ScreenIdentityCredentials.path);
                                },
                          child: Text("Manage Credentials"),
                        ),
                        ElevatedButton(
                            onPressed: wallet.wallet.isEmpty
                                ? null
                                : () {
                                    context.beamToNamed(ScreenScanQR.path);
                                  },
                            child: Text("Scan QR Code"))
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PublicID extends StatelessWidget {
  const _PublicID({Key? key, required this.did}) : super(key: key);
  final String did;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Your Public ID (DID)'),
        TextButton(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
              side: const BorderSide(color: Color(0xffBFBFBF)),
            ),
          ),
          onPressed: () {},
          child: Row(children: [
            Expanded(child: Text(did)),
          ]),
        )
      ],
    );
  }
}

// class _Button extends StatelessWidget {
//   final String title;
//   final Function? onPressed;
//
//   const _Button({
//     Key? key,
//     required this.title,
//     required this.onPressed,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton(
//       onPressed: () => onPressed(),
//       child: Text(title),
//     );
//   }
// }
