import 'dart:convert';

import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../Util.dart';
import '../../../const.dart';
import '../../../model/Agent/ModelInitConnection.dart';
import '../../../model/Agent/ModelPresentProofSendRequest.dart';
import '../../../service/ServiceAgent.dart';
import '../../../widget/WidgetCenterScreenLayout.dart';
import 'ScreenBankingHome.dart';
import 'ScreenBankingSignUp.dart';

class ScreenBankingLogin extends ConsumerStatefulWidget {
  static const path = "/service/bank/login/";

  static page() {
    return const BeamPage(
        child: ScreenBankingLogin(), key: ValueKey("bank-login"));
  }

  const ScreenBankingLogin({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _ScreenLoginBankingState();
  }
}

class _ScreenLoginBankingState extends ConsumerState<ScreenBankingLogin> {
  String qrData = "";
  String messageProgress = "";
  String connectionID = "";
  String timestamp = "";
  String proofExchangeID = "";
  bool hasError = false;

  Future<ProofType> _checkPresentRequest() async {
    while (true) {
      await Future.delayed(const Duration(seconds: 3));
      assert(proofExchangeID.isNotEmpty);
      var resp = await ServiceAgentPresentProof.getSingleProofRequest(
          AgentURL.banking, proofExchangeID);
      setState(() {
        messageProgress =
            "Proof Exchange ID of $proofExchangeID.\nAwaiting Conformation from Agent";
      });
      if (resp["state"] == "abandoned") {
        setState(() {
          messageProgress = "Agent has decline the request";
        });
        return ProofType.notExist;
      } else if (resp["state"] == "presentation_received") {
        setState(() {
          messageProgress =
              "Agent has approve the request\nValidating the presentation response";
        });
        var respVerify = await ServiceAgentPresentProof.verifyProofRequest(
            AgentURL.banking, proofExchangeID);
        if (respVerify["state"] == "verified" &&
            respVerify["verified"] == "true") {
          setState(() {
            messageProgress = "User has approve the request, and validated";
          });
          var box = Util.getBox();

          await box.put(
              HiveBox.bankData,
              jsonEncode({
                "first_name": respVerify["presentation"]["requested_proof"]
                    ["revealed_attrs"]["first_name"]["raw"],
                "last_name": respVerify["presentation"]["requested_proof"]
                    ["revealed_attrs"]["last_name"]["raw"],
                "uid": respVerify["presentation"]["requested_proof"]
                    ["revealed_attrs"]["uid"]["raw"]
              }));
          return ProofType.exist;
        } else {
          setState(() {
            messageProgress =
                "Failed to validate user data\nMessage: ${respVerify["error_msg"]}";
          });
          return ProofType.rejected;
        }
      }
    }
  }

  Future<void> _sendCredentialPresentProofRequest() async {
    setState(() {
      messageProgress = "Verifying Credential Exist in user wallet..";
    });
    var payload = ModelPresentProofSendRequest(
        proofRequest: ProofRequest(
          name: 'Request For Bank Credential',
          version: '1.0',
          requestedAttributes: RequestedAttributes(attributes: {
            "first_name": Attributes(
                restrictions: [Restrictions(schemaId: AgentSchemaID.banking)],
                name: 'first_name'),
            "last_name": Attributes(
                restrictions: [Restrictions(schemaId: AgentSchemaID.banking)],
                name: 'last_name'),
            "uid": Attributes(
                restrictions: [Restrictions(schemaId: AgentSchemaID.banking)],
                name: 'uid'),
          }),
          requestedPredicates: RequestedPredicates(predicates: {}),
        ),
        connectionId: connectionID,
        comment: 'Bank Agent');
    var resp =
        await ServiceAgentPresentProof.sendRequest(AgentURL.banking, payload);
    proofExchangeID = resp["presentation_exchange_id"];
  }

  Future<void> createConnection() async {
    timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    var u = await ServiceAgentConnection.sendConnectionRequest(
        AgentURL.banking, timestamp);
    ModelInitConnection con = ModelInitConnection(
        agentType: AgentType.banking,
        agentName: "Banking Agent",
        invitation: jsonEncode(u["invitation"]),
        qrType: QRType.connectionRequest);
    u = await ServiceAgentConnection.getSingleConnectionDataViaAlias(
        AgentURL.banking, timestamp);
    connectionID = u["connection_id"];

    setState(() {
      qrData = jsonEncode(con.toJson());
      messageProgress =
          "Agent Connection ID: $connectionID\nAwaiting Connection from user";
    });
  }

  Future<void> _checkConnection() async {
    while (true) {
      await Future.delayed(const Duration(seconds: 3));
      var res = await ServiceAgentConnection.getSingleConnectionInfo(
          AgentURL.banking, connectionID);
      if (res["state"] == "active") {
        setState(() {
          messageProgress = "Successfully Connected";
        });
        var box = Util.getBox();
        await box.put(HiveBox.connectionBank, connectionID);
        break;
      }
    }
  }

  @override
  void initState() {
    createConnection()
        .then((_) => _checkConnection())
        .then((_) => _sendCredentialPresentProofRequest())
        .then((_) => _checkPresentRequest())
        .then((proofType) {
      switch (proofType) {
        case ProofType.notExist:
          context.beamToReplacementNamed(ScreenBankingSignUp.path);
          break;
          break;
        case ProofType.exist:
          context.beamToReplacementNamed(ScreenBankingHome.path);
          break;
        case ProofType.rejected:
          setState(() {
            messageProgress = "User Reject the Request";
          });
          break;
      }
    }).catchError((e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
      setState(() {
        hasError = true;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Banking System"),
      ),
      body: WidgetCenterScreenLayout(
        child: Column(
          children: [
            const SizedBox(height: 30),
            Align(
              alignment: Alignment.center,
              child: Text(
                "Welcome to Banking System",
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontSize: 50),
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.center,
              child: Text(
                "Login/Register",
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontSize: 45),
              ),
            ),
            const SizedBox(height: 70),
            Card(
              child: SizedBox(
                height: 200,
                width: 200,
                child: qrData.isEmpty
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          const SizedBox(height: 10),
                          Text("Generating QR Code")
                        ],
                      )
                    : QrImage(
                        data: qrData,
                        version: QrVersions.auto,
                        size: 200,
                        padding: const EdgeInsets.all(8),
                      ),
              ),
            ),
            hasError
                ? OutlinedButton(
                    onPressed: () {
                      createConnection();
                      setState(() {
                        hasError = false;
                      });
                    },
                    child: Text("Retry"))
                : Align(
                    alignment: Alignment.center,
                    child: Text(
                      messageProgress,
                      style: Theme.of(context).textTheme.bodyLarge,
                    )),
            const SizedBox(height: 30),
            Align(
              alignment: Alignment.center,
              child: Text(
                "Please Scan the barcode to establish connection between the banking System Agent",
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontSize: 20),
              ),
            )
          ],
        ),
      ),
    );
  }
}
