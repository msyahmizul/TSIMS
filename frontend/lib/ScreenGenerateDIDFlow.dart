import 'dart:convert';

import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:mobile/screen/ScreenSplash.dart';
import 'package:mobile/service/ServiceAgent.dart';
import 'package:mobile/util.dart';

import 'const.dart';
import 'model/ModelUserData.dart';
import 'model/ModelWallet.dart';

class ScreenGenerateDIDFlow extends ConsumerStatefulWidget {
  static const path = "/home/genDID";

  static page() {
    return BeamPage(
        child: ScreenGenerateDIDFlow(), key: const ValueKey("gen-did"));
  }

  const ScreenGenerateDIDFlow({Key? key}) : super(key: key);

  @override
  ConsumerState<ScreenGenerateDIDFlow> createState() {
    return _ScreenGenerateDIDFlowState();
  }
}

class _ScreenGenerateDIDFlowState extends ConsumerState<ScreenGenerateDIDFlow> {
  String jwtToken = "";
  ModelWallet wallet = ModelWallet();

  String connLocalID = "";
  String connGovID = "";

  String messageLoading = "";
  String walletToken = "";

  String creExchangeLocalID = "";
  String creExchangeGovID = "";
  bool isDone = false;
  bool isLoading = false;

  @override
  void initState() {
    final box = Hive.box(BoxName.name);
    jwtToken = box.get(BoxName.jwtKey);
    super.initState();
  }

  generateWalletDID(Box box) async {
    setState(() {
      messageLoading = "Generating User Wallet";
    });
    var dataWallet = await ServiceAgentUtil.generateDID(jwtToken);
    setState(() {
      wallet = ModelWallet(
          wallet: dataWallet["wallet"] as String,
          did: dataWallet["did"] as String);
    });
    String token =
        await ServiceAgentUtil.getMultiTenantAuthToken(wallet.wallet);
    walletToken = token;
  }

  generateConnectionAgent() async {
    setState(() {
      messageLoading = "Generating Connection Between Agent";
    });
    assert(walletToken.isNotEmpty);
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

    var connInvitationRequest =
        await ServiceAgentConnection.sendConnectionRequest(AgentURL.multiTenant,
            timestamp, Util.getHeader(AgentType.multi, walletToken));
    await Future.delayed(const Duration(seconds: 3));

    var conGovData = await ServiceAgentConnection.receiveConnectionRequest(
        AgentURL.gov,
        connInvitationRequest["invitation"],
        Util.getHeader(AgentType.gov));
    await Future.delayed(const Duration(seconds: 3));

    var conLocalData =
        await ServiceAgentConnection.getSingleConnectionDataViaAlias(
            AgentURL.multiTenant,
            timestamp,
            Util.getHeader(AgentType.multi, walletToken));
    await Future.delayed(const Duration(seconds: 3));
    setState(() {
      connGovID = conGovData["connection_id"];
      connLocalID = conLocalData["connection_id"];
    });
  }

  generateCredential(Box box) async {
    setState(() {
      messageLoading = "Generating Credential Exchange";
    });
    final box = Hive.box(BoxName.name);
    var u = jsonDecode(box.get(BoxName.userData));
    ModelUserData userData = ModelUserData.fromJson(u, u["username"]);
    await Future.delayed(const Duration(seconds: 3));
    var credentialProposalDataLocal =
        await ServiceAgentCredential.sendCredentialProposal(
            connLocalID,
            AgentURL.multiTenant,
            AgentSchemaID.gov,
            userData.toSchema(),
            Util.getHeader(AgentType.multi, walletToken));
    await Future.delayed(const Duration(seconds: 3));
    var credentialProposalDataGov =
        await ServiceAgentCredential.getCredentialProposalViaThreadID(
            connGovID,
            AgentURL.gov,
            credentialProposalDataLocal["thread_id"],
            Util.getHeader(AgentType.gov));
    setState(() {
      creExchangeGovID = credentialProposalDataGov["credential_exchange_id"];
      creExchangeLocalID =
          credentialProposalDataLocal["credential_exchange_id"];
      messageLoading = "Issuing Credential";
    });

    assert(creExchangeGovID.isNotEmpty);
    assert(creExchangeLocalID.isNotEmpty);
    assert(walletToken.isNotEmpty);

    setState(() {
      messageLoading = "User Sending Credential Offer";
    });

    await Future.delayed(const Duration(seconds: 3));
    await ServiceAgentCredential.sendCredentialOffer(connGovID, AgentURL.gov,
        Util.getHeader(AgentType.gov), creExchangeGovID);

    setState(() {
      messageLoading = "Issuer Sending Credential Request";
    });
    await Future.delayed(const Duration(seconds: 3));
    await ServiceAgentCredential.sendCredentialRequest(
        connLocalID,
        AgentURL.multiTenant,
        Util.getHeader(AgentType.multi, walletToken),
        creExchangeLocalID);
    setState(() {
      messageLoading = "Issuer issues Credential";
    });
    await Future.delayed(const Duration(seconds: 3));
    await ServiceAgentCredential.issuesCredential(connGovID, AgentURL.gov,
        Util.getHeader(AgentType.gov), creExchangeGovID);

    setState(() {
      messageLoading = "User Store Credential";
    });
    await Future.delayed(const Duration(seconds: 3));
    await ServiceAgentCredential.storeCredentialProposal(
      connLocalID,
      AgentURL.multiTenant,
      creExchangeLocalID,
      Util.getHeader(AgentType.multi, walletToken),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Generate DID Flow')),
      body: SingleChildScrollView(
        child: Padding(
            padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 5),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                "Step 1 Generate Wallet & DID",
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(color: Colors.black),
              ),
              const SizedBox(height: 5),
              Text(
                "\nWallet ID: ${wallet.wallet}",
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: Colors.black),
              ),
              Text(
                "Decentralised DID : ${wallet.did}",
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: Colors.black),
              ),
              const SizedBox(height: 20),
              Text(
                "Step 2 Generate connection with the Government Agent",
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(color: Colors.black),
              ),
              const SizedBox(height: 5),
              Text(
                "Your Connection ID : \n$connLocalID\n",
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: Colors.black),
              ),
              Text(
                "Government Connection ID : \n$connGovID\n",
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: Colors.black),
              ),
              const SizedBox(height: 15),
              Text(
                "Step 3 Get Verifiable Credential from Government Agent",
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(color: Colors.black),
              ),
              const SizedBox(height: 5),
              Text(
                "Your Credential Exchange ID : \n$creExchangeLocalID\n",
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: Colors.black),
              ),
              Text(
                "Government Credential Exchange ID : \n$creExchangeGovID\n",
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: Colors.black),
              ),
              isDone
                  ? OutlinedButton(
                      onPressed: () {
                        // ref
                        //     .read(providerReloadData.notifier)
                        //     .update((state) => {"didAcceptDelete": "true"});
                        context.beamToReplacementNamed(ScreenSplash.path);
                      },
                      child: const Text("Done"))
                  : OutlinedButton(
                      onPressed: () async {
                        try {
                          var box = Hive.box(BoxName.name);
                          setState(() {
                            messageLoading = "Getting DID from System";
                            isLoading = true;
                          });
                          await generateWalletDID(box);
                          await generateConnectionAgent();
                          await Future.delayed(const Duration(seconds: 5));
                          await generateCredential(box);

                          setState(() {
                            isDone = true;
                          });
                          await box.put(
                              BoxName.walletData, jsonEncode(wallet.toJson()));
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())));
                        } finally {
                          setState(() {
                            messageLoading = "";
                            isLoading = false;
                          });
                        }
                      },
                      child: isLoading
                          ? CircularProgressIndicator()
                          : Text("Run Generate DID Flow")),
              Text(messageLoading)
            ])),
      ),
    );
  }
}
