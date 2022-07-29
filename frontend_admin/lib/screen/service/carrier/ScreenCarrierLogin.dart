import 'dart:convert';

import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_admin/screen/service/carrier/ScreenCarrierHome.dart';
import 'package:frontend_admin/screen/service/carrier/ScreenCarrierSignUp.dart';
import 'package:frontend_admin/widget/WidgetCenterScreenLayout.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../Util.dart';
import '../../../const.dart';
import '../../../model/Agent/ModelInitConnection.dart';
import '../../../model/Agent/ModelPresentProofSendRequest.dart';
import '../../../service/ServiceAgent.dart';

class ScreenCarrierLogin extends ConsumerStatefulWidget {
  static const path = "/service/carrier/login";

  static page() {
    return const BeamPage(
        child: ScreenCarrierLogin(), key: ValueKey("carrier-login"));
  }

  const ScreenCarrierLogin({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _ScreenCarrierLoginState();
  }
}

class _ScreenCarrierLoginState extends ConsumerState<ScreenCarrierLogin> {
  String qrData = "";
  String messageProgress = "";
  String connectionID = "";
  String timestamp = "";
  String proofExchangeID = "";
  bool hasError = false;

  Future<ProofType> _checkPresentProofRequest() async {
    while (true) {
      assert(proofExchangeID.isNotEmpty);
      await Future.delayed(const Duration(seconds: 3));
      var resp = await ServiceAgentPresentProof.getSingleProofRequest(
          AgentURL.carrier, proofExchangeID);
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
            AgentURL.carrier, proofExchangeID);
        if (respVerify["state"] == "verified" &&
            respVerify["verified"] == "true") {
          setState(() {
            messageProgress = "User has approve the request, and validated";
          });
          var box = Util.getBox();
          await box.put(
              HiveBox.carrierData,
              jsonEncode({
                "first_name": respVerify["presentation"]["requested_proof"]
                    ["revealed_attrs"]["first_name"]["raw"],
                "last_name": respVerify["presentation"]["requested_proof"]
                    ["revealed_attrs"]["last_name"]["raw"],
                "uid": respVerify["presentation"]["requested_proof"]
                    ["revealed_attrs"]["uid"]["raw"],
                "plan_type": respVerify["presentation"]["requested_proof"]
                    ["revealed_attrs"]["plan_type"]["raw"],
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
          name: 'Request For Carrier Credential',
          version: '1.0',
          requestedAttributes: RequestedAttributes(attributes: {
            "first_name": Attributes(
                restrictions: [Restrictions(schemaId: AgentSchemaID.carrier)],
                name: 'first_name'),
            "last_name": Attributes(
                restrictions: [Restrictions(schemaId: AgentSchemaID.carrier)],
                name: 'last_name'),
            "uid": Attributes(
                restrictions: [Restrictions(schemaId: AgentSchemaID.carrier)],
                name: 'uid'),
            "plan_type": Attributes(
                restrictions: [Restrictions(schemaId: AgentSchemaID.carrier)],
                name: 'plan_type'),
          }),
          requestedPredicates: RequestedPredicates(predicates: {}),
        ),
        connectionId: connectionID,
        comment: 'Carrier Agent');
    var resp =
        await ServiceAgentPresentProof.sendRequest(AgentURL.carrier, payload);
    proofExchangeID = resp["presentation_exchange_id"];
  }

  Future<void> createConnection() async {
    timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    var u = await ServiceAgentConnection.sendConnectionRequest(
        AgentURL.carrier, timestamp);
    ModelInitConnection con = ModelInitConnection(
        agentType: AgentType.carrier,
        agentName: "Carrier Agent",
        invitation: jsonEncode(u["invitation"]),
        qrType: QRType.connectionRequest);
    u = await ServiceAgentConnection.getSingleConnectionDataViaAlias(
        AgentURL.carrier, timestamp);
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
          AgentURL.carrier, connectionID);
      if (res["state"] == "active") {
        setState(() {
          messageProgress = "Successfully Connected";
        });
        var box = Util.getBox();
        await box.put(HiveBox.connectionCarrier, connectionID);
        break;
      }
    }
  }

  void initRun() {
    createConnection()
        .then((_) => _checkConnection())
        .then((_) => _sendCredentialPresentProofRequest())
        .then((_) => _checkPresentProofRequest())
        .then((requestType) {
      switch (requestType) {
        case ProofType.notExist:
          context.beamToNamed(ScreenCarrierSignUp.path);
          break;
        case ProofType.exist:
          context.beamToNamed(ScreenCarrierHome.path);
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
    initRun();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Carrier System"),
      ),
      body: WidgetCenterScreenLayout(
        child: Column(
          children: [
            const SizedBox(height: 30),
            Align(
              alignment: Alignment.center,
              child: Text(
                "Welcome to Carrier System",
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
            Align(
              alignment: Alignment.center,
              child: Text(
                "Please Scan the barcode to establish connection between the Carrier System Agent",
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
