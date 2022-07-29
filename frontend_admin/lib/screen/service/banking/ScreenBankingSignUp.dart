import 'dart:async';
import 'dart:convert';

import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_admin/Util.dart';
import 'package:frontend_admin/const.dart';
import 'package:frontend_admin/model/Agent/ModelPresentProofSendRequest.dart';
import 'package:frontend_admin/screen/service/banking/ScreenBankingHome.dart';
import 'package:frontend_admin/screen/service/banking/ScreenBankingLogin.dart';
import 'package:frontend_admin/service/ServiceAgent.dart';
import 'package:frontend_admin/widget/WidgetCenterScreenLayout.dart';

class ScreenBankingSignUp extends ConsumerStatefulWidget {
  static const path = "/service/bank/create";

  static page() {
    return const BeamPage(
        child: ScreenBankingSignUp(), key: ValueKey("bank-create"));
  }

  const ScreenBankingSignUp({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _ScreenSignUpBankingState();
  }
}

class _ScreenSignUpBankingState extends ConsumerState<ScreenBankingSignUp> {
  String connectionID = "";
  String proofExchangeID = "";
  String messageProgress = "";
  int steps = 1;
  bool passSteps1 = false;
  bool passSteps2 = false;
  String firstName = "";
  String lastName = "";

  @override
  void initState() {
    var box = Util.getBox();
    String t = box.get(HiveBox.connectionBank, defaultValue: "");
    connectionID = t;
    _sendPresentProofRequest()
        .then((_) => _checkPresentRequest())
        .catchError((e) {
      Util.runSnackBarMessage(context, e.toString());
    });
    super.initState();
  }

  Future<void> _sendPresentProofRequest() async {
    if (proofExchangeID.isNotEmpty) {
      return;
    }
    setState(() {
      messageProgress = "Sending Request to Agent";
    });
    var payload = ModelPresentProofSendRequest(
        proofRequest: ProofRequest(
          name: 'Request For Data Attributes',
          version: '1.0',
          requestedAttributes: RequestedAttributes(attributes: {
            "first_name": Attributes(
                restrictions: [Restrictions(schemaId: AgentSchemaID.gov)],
                name: 'first_name'),
            "last_name": Attributes(
                restrictions: [Restrictions(schemaId: AgentSchemaID.gov)],
                name: 'last_name')
          }),
          requestedPredicates: RequestedPredicates(predicates: {
            "age": Predicate(
                name: "dob",
                pType: ">",
                pValue: 18,
                restrictions: [Restrictions(schemaId: AgentSchemaID.gov)])
          }),
        ),
        connectionId: connectionID,
        comment: 'Bank Agent');
    var resp =
        await ServiceAgentPresentProof.sendRequest(AgentURL.banking, payload);
    proofExchangeID = resp["presentation_exchange_id"];
  }

  Future<void> sendCredential() async {
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    List<Map<String, String>> proposalsData = [];
    proposalsData.add({"name": "first_name", "value": firstName});
    proposalsData.add({"name": "last_name", "value": lastName});
    proposalsData.add({"name": "uid", "value": timestamp});
    setState(() {
      messageProgress = "Sending Credential Offer to Agent";
    });
    var credExchangeInformation =
        await ServiceAgentCredential.sendCredentialOffer(
            connectionID,
            AgentURL.banking,
            AgentCredDefID.banking,
            "Bank Agent",
            proposalsData);
    setState(() {
      messageProgress =
          "Agent has sent Credential Offer\nAwaiting Conformation";
    });
    await Future.delayed(const Duration(seconds: 3));
    while (true) {
      await Future.delayed(const Duration(seconds: 3));
      var currCredInfo = await ServiceAgentCredential.getCredentialSingle(
          AgentURL.banking, credExchangeInformation["credential_exchange_id"]);
      if (currCredInfo["state"] == "request_received") {
        setState(() {
          messageProgress =
              "User Agent has accept the request issuing credential...";
        });
        await ServiceAgentCredential.issuesCredential(
            connectionID,
            AgentURL.banking,
            credExchangeInformation["credential_exchange_id"]);

        var box = Util.getBox();

        await box.put(
            HiveBox.bankData,
            jsonEncode({
              "first_name": firstName,
              "last_name": lastName,
              "uid": timestamp
            }));
        setState(() {
          messageProgress = "";
          passSteps2 = true;
        });

        break;
      } else if (currCredInfo["state"] == "abandoned") {
        setState(() {
          messageProgress =
              "Failed to issues credential to user\nMessage: ${currCredInfo["error_msg"]}";
        });
        break;
      }
    }
  }

  Future<void> _checkPresentRequest() async {
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
          messageProgress =
              "Agent has decline the request, redirecting back to login page";
        });
        context.beamToReplacementNamed(ScreenBankingLogin.path);
        break;
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
            messageProgress = "User Data has been validated and verified";
            steps += 2;
            passSteps1 = true;
            firstName = respVerify["presentation"]["requested_proof"]
                ["revealed_attrs"]["first_name"]["raw"];
            lastName = respVerify["presentation"]["requested_proof"]
                ["revealed_attrs"]["last_name"]["raw"];
          });
          await sendCredential();
        } else {
          setState(() {
            messageProgress =
                "Failed to validate user data\nMessage: ${respVerify["error_msg"]}";
          });
        }
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Banking System"),
      ),
      body: WidgetCenterScreenLayout(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            "Let's Get Your Account",
            style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              "Eligibility",
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                passSteps1
                    ? Icon(Icons.check)
                    : SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(),
                      ),
                const SizedBox(width: 10),
                Text(
                  "Valid Government Credential",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                passSteps1
                    ? Icon(Icons.check)
                    : SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(),
                      ),
                const SizedBox(width: 10),
                Text(
                  "Over 18 Years old",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 20),
          ]),
          steps >= 2
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Requested Data Information",
                      style:
                          TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "First Name: $firstName",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Last Name: $lastName",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 20),
                  ],
                )
              : const SizedBox(),
          steps >= 3
              ? Column(
                  children: [
                    Row(
                      children: [
                        passSteps2
                            ? Icon(Icons.check, size: 40)
                            : SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(),
                              ),
                        const SizedBox(width: 10),
                        Text(
                          passSteps2
                              ? "Banking Certificate Has Been Generated"
                              : "Generating Banking Certificate",
                          style: TextStyle(
                              fontSize: 40, fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                )
              : const SizedBox(),
          passSteps1 && passSteps2
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check, size: 40),
                        const SizedBox(width: 10),
                        Text(
                          "Sign Up Complete",
                          style: TextStyle(
                              fontSize: 40, fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                        onPressed: () {
                          context
                              .beamToReplacementNamed(ScreenBankingHome.path);
                        },
                        style:
                            ElevatedButton.styleFrom(fixedSize: Size(170, 40)),
                        icon: Text("To Account"),
                        label: Icon(Icons.arrow_forward_ios)),
                  ],
                )
              : const SizedBox(),
          messageProgress.isNotEmpty ? Text(messageProgress) : const SizedBox(),
        ]),
      ),
    );
  }
}
