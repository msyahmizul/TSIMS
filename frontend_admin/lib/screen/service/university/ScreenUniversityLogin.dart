import 'dart:convert';

import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:frontend_admin/screen/service/university/ScreenUniversityHome.dart';
import 'package:frontend_admin/screen/service/university/ScreenUniversitySignUp.dart';
import 'package:frontend_admin/widget/WidgetCenterScreenLayout.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../Util.dart';
import '../../../const.dart';
import '../../../model/Agent/ModelInitConnection.dart';
import '../../../model/Agent/ModelPresentProofSendRequest.dart';
import '../../../service/ServiceAgent.dart';

class ScreenUniversityLogin extends StatefulWidget {
  static const path = "/service/uni/login";

  static page() {
    return const BeamPage(
        child: ScreenUniversityLogin(), key: ValueKey("uni-login"));
  }

  const ScreenUniversityLogin({Key? key}) : super(key: key);

  @override
  State<ScreenUniversityLogin> createState() => _ScreenUniversityLoginState();
}

class _ScreenUniversityLoginState extends State<ScreenUniversityLogin> {
  String qrData = "";
  String messageProgress = "";
  String connectionID = "";
  String timestamp = "";
  String proofExchangeID = "";
  bool hasError = false;

  Future<void> _createConnection() async {
    timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    var u = await ServiceAgentConnection.sendConnectionRequest(
        AgentURL.university, timestamp);
    ModelInitConnection con = ModelInitConnection(
        agentType: AgentType.university,
        agentName: "University Agent",
        invitation: jsonEncode(u["invitation"]),
        qrType: QRType.connectionRequest);
    u = await ServiceAgentConnection.getSingleConnectionDataViaAlias(
        AgentURL.university, timestamp);
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
          AgentURL.university, connectionID);
      if (res["state"] == "active") {
        setState(() {
          messageProgress = "Successfully Connected";
        });
        var box = Util.getBox();
        await box.put(HiveBox.connectionUniversity, connectionID);
        break;
      }
    }
  }

  Future<void> _sendCredentialPresentProofRequest() async {
    setState(() {
      messageProgress = "Verifying Credential Exist in user wallet..";
    });
    var payload = ModelPresentProofSendRequest(
        proofRequest: ProofRequest(
          name: 'Request For University Credential',
          version: '1.0',
          requestedAttributes: RequestedAttributes(attributes: {
            "first_name": Attributes(restrictions: [
              Restrictions(schemaId: AgentSchemaID.university)
            ], name: 'first_name'),
            "last_name": Attributes(restrictions: [
              Restrictions(schemaId: AgentSchemaID.university)
            ], name: 'last_name'),
            "degree": Attributes(restrictions: [
              Restrictions(schemaId: AgentSchemaID.university)
            ], name: 'degree'),
            "status": Attributes(restrictions: [
              Restrictions(schemaId: AgentSchemaID.university)
            ], name: 'status'),
          }),
          requestedPredicates: RequestedPredicates(predicates: {}),
        ),
        connectionId: connectionID,
        comment: 'University Agent');
    var resp = await ServiceAgentPresentProof.sendRequest(
        AgentURL.university, payload);
    proofExchangeID = resp["presentation_exchange_id"];
  }

  Future<ProofType> _checkPresentProofRequest() async {
    while (true) {
      await Future.delayed(const Duration(seconds: 3));
      assert(proofExchangeID.isNotEmpty);
      var resp = await ServiceAgentPresentProof.getSingleProofRequest(
          AgentURL.university, proofExchangeID);
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
            AgentURL.university, proofExchangeID);
        if (respVerify["state"] == "verified" &&
            respVerify["verified"] == "true") {
          setState(() {
            messageProgress = "User has approve the request, and validated";
          });
          var box = Util.getBox();
          await box.put(
              HiveBox.universityData,
              jsonEncode({
                "first_name": respVerify["presentation"]["requested_proof"]
                    ["revealed_attrs"]["first_name"]["raw"],
                "last_name": respVerify["presentation"]["requested_proof"]
                    ["revealed_attrs"]["last_name"]["raw"],
                "degree": respVerify["presentation"]["requested_proof"]
                    ["revealed_attrs"]["degree"]["raw"],
                "status": respVerify["presentation"]["requested_proof"]
                    ["revealed_attrs"]["status"]["raw"],
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

  void initPage() {
    _createConnection()
        .then((_) => _checkConnection())
        .then((_) => _sendCredentialPresentProofRequest())
        .then((_) => _checkPresentProofRequest())
        .then((requestType) {
      switch (requestType) {
        case ProofType.notExist:
          context.beamToNamed(ScreenUniversitySignUp.path);
          break;
        case ProofType.exist:
          context.beamToNamed(ScreenUniversityHome.path);
          break;
        case ProofType.rejected:
          setState(() {
            messageProgress = "User Reject the Request";
          });
          break;
      }
    }).catchError((e) {
      Util.runSnackBarMessage(context, e.toString());
    });
  }

  @override
  void initState() {
    initPage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("University System"),
      ),
      body: WidgetCenterScreenLayout(
        child: Column(
          children: [
            const SizedBox(height: 30),
            Align(
              alignment: Alignment.center,
              child: Text(
                "Welcome to University System",
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
            const SizedBox(height: 10),
            qrData.isEmpty
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
            const SizedBox(height: 20),
            hasError
                ? OutlinedButton(
                    onPressed: () {
                      _createConnection();
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
            Align(
              alignment: Alignment.center,
              child: Text(
                "Please Scan the barcode to establish connection between the University System Agent",
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
