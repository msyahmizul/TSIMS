import 'dart:convert';

import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:frontend_admin/screen/service/university/ScreenUniversityHome.dart';
import 'package:frontend_admin/screen/service/university/ScreenUniversityLogin.dart';
import 'package:frontend_admin/widget/WidgetCenterScreenLayout.dart';

import '../../../Util.dart';
import '../../../const.dart';
import '../../../model/Agent/ModelPresentProofSendRequest.dart';
import '../../../service/ServiceAgent.dart';

class ScreenUniversitySignUp extends StatefulWidget {
  static const path = "/service/uni/create";

  static page() {
    return const BeamPage(
        child: ScreenUniversitySignUp(), key: ValueKey("university-create"));
  }

  const ScreenUniversitySignUp({Key? key}) : super(key: key);

  @override
  State<ScreenUniversitySignUp> createState() => _ScreenUniversitySignUpState();
}

class _ScreenUniversitySignUpState extends State<ScreenUniversitySignUp> {
  List<String> degreeChoiceList = [
    "Select Choice",
    "Bachelor Of Computer Science (Computer Networks And Security) Computing",
    "Bachelor Of Computer Science Software Engineering Computing",
    "Design Aviation Technology and The Future",
    "Crowdsourced Engineering Systems Research, and Management",
    "Quantum Edge Computing Research, and Collaboration"
  ];

  String connectionID = "";
  String proofExchangeID = "";
  String messageProgress = "";
  int steps = 1;
  bool passSteps1 = false;
  bool passSteps2 = false;

  String firstName = "";
  String lastName = "";
  String degreeChoice = "";

  Future<void> _sendPresentProofRequest() async {
    if (proofExchangeID.isNotEmpty) {
      return;
    }
    setState(() {
      messageProgress = "Sending Request to Agent";
    });
    var payload = ModelPresentProofSendRequest(
        proofRequest: ProofRequest(
          name: 'Request For Data Sign Up',
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
        comment: 'University Agent');
    var resp = await ServiceAgentPresentProof.sendRequest(
        AgentURL.university, payload);
    proofExchangeID = resp["presentation_exchange_id"];
  }

  Future<bool> _checkPresentRequest() async {
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
            AgentURL.university, proofExchangeID);
        if (respVerify["state"] == "verified" &&
            respVerify["verified"] == "true") {
          setState(() {
            messageProgress = "User Data has been validated and verified";
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

  Future<void> _sendCredential() async {
    assert(degreeChoice.isNotEmpty);
    List<Map<String, String>> proposalsData = [];
    proposalsData.add({"name": "first_name", "value": firstName});
    proposalsData.add({"name": "last_name", "value": lastName});
    proposalsData.add({"name": "degree", "value": degreeChoice});
    proposalsData.add({"name": "status", "value": "graduated"});
    setState(() {
      messageProgress = "Sending Credential Offer to Agent";
    });
    var credExchangeInformation =
        await ServiceAgentCredential.sendCredentialOffer(
            connectionID,
            AgentURL.university,
            AgentCredDefID.university,
            "University Agent",
            proposalsData);
    setState(() {
      messageProgress =
          "Agent has sent Credential Offer\nAwaiting Conformation";
    });
    await Future.delayed(const Duration(seconds: 3));
    while (true) {
      await Future.delayed(const Duration(seconds: 3));
      var currCredInfo = await ServiceAgentCredential.getCredentialSingle(
          AgentURL.university,
          credExchangeInformation["credential_exchange_id"]);
      if (currCredInfo["state"] == "request_received") {
        setState(() {
          messageProgress =
              "User Agent has accept the request issuing credential...";
        });
        await ServiceAgentCredential.issuesCredential(
            connectionID,
            AgentURL.university,
            credExchangeInformation["credential_exchange_id"]);

        var box = Util.getBox();

        await box.put(
            HiveBox.universityData,
            jsonEncode({
              "first_name": firstName,
              "last_name": lastName,
              "degree": degreeChoice,
              "status": "graduated"
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

  Future<void> _getDegreeType() async {
    String? val = await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          String currentValue = degreeChoiceList.first;
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Text("Select Following Degree"),
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
                            items: degreeChoiceList
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
                      if (currentValue != degreeChoiceList.first) {
                        Navigator.of(context).pop(currentValue);
                      }
                    },
                    child: Text("Select")),
              ],
            );
          });
        });
    if (val != null) {
      setState(() {
        degreeChoice = val;
        steps += 2;
      });
    }
  }

  void initPage() {
    var box = Util.getBox();
    String t = box.get(HiveBox.connectionUniversity, defaultValue: "");
    connectionID = t;
    _sendPresentProofRequest()
        .then((_) => _checkPresentRequest())
        .then((isApprove) {
      if (!isApprove) {
        var box = Util.getBox();
        box.put(HiveBox.connectionUniversity, "");
        context.beamToReplacementNamed(ScreenUniversityLogin.path);
        return null;
      } else {
        return _getDegreeType().then((_) => _sendCredential());
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
        title: Text("University System"),
      ),
      body: WidgetCenterScreenLayout(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Text(
                          "Requested Data Information",
                          style: TextStyle(
                              fontSize: 40, fontWeight: FontWeight.bold),
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
                        degreeChoice.isNotEmpty
                            ? Text(
                                "Degree : $degreeChoice",
                                style: Theme.of(context).textTheme.titleLarge,
                              )
                            : const SizedBox(),
                      ])
                : const SizedBox(),
            const SizedBox(height: 20),
            steps >= 3
                ? Row(
                    children: [
                      passSteps2
                          ? Icon(Icons.check)
                          : SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(),
                            ),
                      const SizedBox(width: 10),
                      Text(
                        passSteps2
                            ? "University Certificate Has Been Generated"
                            : "Generating University Certificate",
                        style: TextStyle(
                            fontSize: 40, fontWeight: FontWeight.bold),
                      )
                    ],
                  )
                : const SizedBox(),
            const SizedBox(height: 20),
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
                              context.beamToNamed(ScreenUniversityHome.path);
                            },
                            style: ElevatedButton.styleFrom(
                                fixedSize: Size(170, 40)),
                            icon: Text("To Account"),
                            label: Icon(Icons.arrow_forward_ios)),
                      ])
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
