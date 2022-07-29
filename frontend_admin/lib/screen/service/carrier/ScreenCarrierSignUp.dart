import 'dart:convert';

import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:frontend_admin/screen/service/carrier/ScreenCarrierHome.dart';
import 'package:frontend_admin/widget/WidgetCenterScreenLayout.dart';

import '../../../Util.dart';
import '../../../const.dart';
import '../../../model/Agent/ModelPresentProofSendRequest.dart';
import '../../../service/ServiceAgent.dart';
import 'ScreenCarrierLogin.dart';

class ScreenCarrierSignUp extends StatefulWidget {
  static const path = "/service/carrier/create";

  static page() {
    return const BeamPage(
        child: ScreenCarrierSignUp(), key: ValueKey("carrier-create"));
  }

  const ScreenCarrierSignUp({Key? key}) : super(key: key);

  @override
  State<ScreenCarrierSignUp> createState() => _ScreenCarrierSignUpState();
}

class _ScreenCarrierSignUpState extends State<ScreenCarrierSignUp> {
  List<String> carrierPlanChoice = [
    "No Choice",
    "Unlimited Plan",
    "Blue Package Plan",
    "Yellow Package Plan"
  ];

  String connectionID = "";
  String proofExchangeID = "";
  String messageProgress = "";
  int steps = 1;
  bool passSteps1 = false;
  bool passSteps2 = false;

  String firstName = "";
  String lastName = "";
  String carrierPlanType = "";

  Future<void> _getCarrierType() async {
    final value = await showDialog<String>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          String currentValue = carrierPlanChoice.first;
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Text("Select Plan"),
              content: SizedBox(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Text("Status:"),
                        const SizedBox(width: 5),
                        DropdownButton(
                            value: currentValue,
                            items: carrierPlanChoice
                                .map((e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ))
                                .toList(),
                            onChanged: (String? newVal) {
                              setState(() {
                                if (newVal != null) {
                                  currentValue = newVal;
                                }
                              });
                            })
                      ],
                    ),
                    const SizedBox(height: 5),
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      if (currentValue != carrierPlanChoice.first) {
                        Navigator.of(context).pop(currentValue);
                      }
                    },
                    child: Text("Choose")),
              ],
            );
          });
        });
    if (value != null) {
      carrierPlanType = value;
    }
  }

  Future<void> _sendCredential() async {
    assert(carrierPlanType.isNotEmpty);
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    List<Map<String, String>> proposalsData = [];
    proposalsData.add({"name": "first_name", "value": firstName});
    proposalsData.add({"name": "last_name", "value": lastName});
    proposalsData.add({"name": "uid", "value": timestamp});
    proposalsData.add({"name": "plan_type", "value": carrierPlanType});
    setState(() {
      messageProgress = "Sending Credential Offer to Agent";
    });
    var credExchangeInformation =
        await ServiceAgentCredential.sendCredentialOffer(
            connectionID,
            AgentURL.carrier,
            AgentCredDefID.carrier,
            "Carrier Agent",
            proposalsData);
    setState(() {
      messageProgress =
          "Agent has sent Credential Offer\nAwaiting Conformation";
    });
    await Future.delayed(const Duration(seconds: 3));
    while (true) {
      await Future.delayed(const Duration(seconds: 3));
      var currCredInfo = await ServiceAgentCredential.getCredentialSingle(
          AgentURL.carrier, credExchangeInformation["credential_exchange_id"]);
      if (currCredInfo["state"] == "request_received") {
        setState(() {
          messageProgress =
              "User Agent has accept the request issuing credential...";
        });
        await ServiceAgentCredential.issuesCredential(
            connectionID,
            AgentURL.carrier,
            credExchangeInformation["credential_exchange_id"]);

        var box = Util.getBox();

        await box.put(
            HiveBox.carrierData,
            jsonEncode({
              "first_name": firstName,
              "last_name": lastName,
              "uid": timestamp,
              "plan_type": carrierPlanType
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

  Future<bool> _checkPresentRequest() async {
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
          messageProgress =
              "Agent has decline the request, redirecting back to login page";
        });
        return false;
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
            messageProgress = "User Data has been validated and verified";
            steps += 2;
            passSteps1 = true;
            firstName = respVerify["presentation"]["requested_proof"]
                ["revealed_attrs"]["first_name"]["raw"];
            lastName = respVerify["presentation"]["requested_proof"]
                ["revealed_attrs"]["last_name"]["raw"];
          });
          return true;
        } else {
          setState(() {
            messageProgress =
                "Failed to validate user data\nMessage: ${respVerify["error_msg"]}";
          });
          return false;
        }
      }
    }
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
        comment: 'Carrier Agent');
    var resp =
        await ServiceAgentPresentProof.sendRequest(AgentURL.carrier, payload);
    proofExchangeID = resp["presentation_exchange_id"];
  }

  void initPage() {
    var box = Util.getBox();
    String t = box.get(HiveBox.connectionCarrier, defaultValue: "");
    connectionID = t;
    _sendPresentProofRequest()
        .then((_) => _checkPresentRequest())
        .then((isApprove) {
      if (!isApprove) {
        var box = Util.getBox();
        box.put(HiveBox.connectionCarrier, "");
        context.beamToReplacementNamed(ScreenCarrierLogin.path);
        return null;
      } else {
        return _getCarrierType().then((_) => _sendCredential());
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
        title: Text("Carrier System"),
      ),
      body: WidgetCenterScreenLayout(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            "Let's Get Your Account",
            style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
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
              )
            ],
          ),
          const SizedBox(height: 20),
          steps >= 2
              ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    "Requested Data Information",
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
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
                  const SizedBox(height: 5),
                  Text(
                    "Carrier Type: $carrierPlanType",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 20),
                ])
              : const SizedBox(),
          steps >= 3
              ? Row(
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
                          ? "Carrier Certificate Has Been Generated"
                          : "Generating Carrier Certificate",
                      style:
                          TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                    )
                  ],
                )
              : const SizedBox(),
          passSteps1 && passSteps2
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
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
                          context.beamToNamed(ScreenCarrierHome.path);
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
