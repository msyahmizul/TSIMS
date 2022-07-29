import 'dart:async';
import 'dart:convert';

import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/const.dart';
import 'package:mobile/provider/providerCredentialList.dart';
import 'package:mobile/provider/providerHoldData.dart';
import 'package:mobile/provider/providerNotificationList.dart';
import 'package:mobile/service/ServiceAgent.dart';

import '../provider/providerReloadData.dart';
import '../util.dart';

class ScreenCredentialNew extends ConsumerStatefulWidget {
  const ScreenCredentialNew({
    Key? key,
    required this.credExID,
  }) : super(key: key);
  static const path = "/home/credentialNew/:$pathArgs";
  static const pathArgs = "credExID";
  final String credExID;

  static page(String creExID) {
    return BeamPage(
        child: ScreenCredentialNew(credExID: creExID),
        key: ValueKey("credential-new-$creExID"));
  }

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _ScreenCredentialNewState();
  }
}

class _ScreenCredentialNewState extends ConsumerState<ScreenCredentialNew> {
  Map<String, dynamic> creExchangeDataPayload = {};
  List<Widget> attributesList = [];
  bool isLoading = false;

  Widget dataAttributes(String attributes, String value) {
    return Padding(
      padding: const EdgeInsets.only(left: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            attributes,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(value, style: const TextStyle(fontSize: 15, color: Colors.grey)),
        ],
      ),
    );
  }

  void initData() {
    var r = ref.read(providerHoldData);
    if (r.containsKey(widget.credExID)) {
      creExchangeDataPayload = jsonDecode(r[widget.credExID]);
    }
    loadData();
  }

  void loadData() {
    List<Widget> u = [];
    for (final attr in creExchangeDataPayload["credential_proposal_dict"]
        ["credential_proposal"]["attributes"]) {
      switch (creExchangeDataPayload["schema_id"]) {
        case AgentSchemaID.gov:
          u.add(dataAttributes(
              Util.resolveSchemaIDToSchemaKey(AgentSchemaID.gov, attr["name"]),
              attr["value"]));
          u.add(const SizedBox(height: 10));
          break;

        case AgentSchemaID.banking:
          u.add(dataAttributes(
              Util.resolveSchemaIDToSchemaKey(
                  AgentSchemaID.banking, attr["name"]),
              attr["value"]));
          u.add(const SizedBox(height: 10));
          break;
        case AgentSchemaID.carrier:
          u.add(dataAttributes(
              Util.resolveSchemaIDToSchemaKey(
                  AgentSchemaID.carrier, attr["name"]),
              attr["value"]));
          u.add(const SizedBox(height: 10));
          break;

        case AgentSchemaID.university:
          u.add(dataAttributes(
              Util.resolveSchemaIDToSchemaKey(
                  AgentSchemaID.university, attr["name"]),
              attr["value"]));
          u.add(const SizedBox(height: 10));
          break;
        default:
          throw Exception("Unknown Agent Schema");
      }
    }
    attributesList = u;
  }

  void runProviderCleanUp() {
    ref.read(providerHoldData.notifier).deleteKey(widget.credExID);
    ref.read(providerNotificationList.notifier).deleteKey(widget.credExID);
    ref
        .read(providerReloadData.notifier)
        .update((state) => {"reloadNotification": "true"});
  }

  Future<void> approveRequest() async {
    String token = await ServiceAgentUtil.getMultiTenantAuthToken();
    await ServiceAgentCredential.sendCredentialRequest(
        creExchangeDataPayload["connection_id"],
        AgentURL.multiTenant,
        Util.getHeader(AgentType.multi, token),
        creExchangeDataPayload["credential_exchange_id"]);
    while (true) {
      String token = await ServiceAgentUtil.getMultiTenantAuthToken();
      var resp = await ServiceAgentCredential.getCredentialSingle(
          AgentURL.multiTenant,
          creExchangeDataPayload["credential_exchange_id"],
          Util.getHeader(AgentType.multi, token));
      await Future.delayed(const Duration(seconds: 1));
      if (resp["state"] == "credential_received") {
        String token = await ServiceAgentUtil.getMultiTenantAuthToken();
        await ServiceAgentCredential.storeCredentialProposal(
          creExchangeDataPayload["connection_id"],
          AgentURL.multiTenant,
          creExchangeDataPayload["credential_exchange_id"],
          Util.getHeader(AgentType.multi, token),
        );
        ref.read(providerCredentialListBrief.notifier).getData();
        break;
      }
    }
    runProviderCleanUp();
  }

  Future<void> rejectRequest() async {
    String token = await ServiceAgentUtil.getMultiTenantAuthToken();
    await ServiceAgentCredential.sendRejectCredentialRequestMessage(
        AgentURL.multiTenant,
        Util.getHeader(AgentType.multi, token),
        creExchangeDataPayload["credential_exchange_id"],
        "User reject the request credential");
    runProviderCleanUp();
  }

  @override
  void initState() {
    initData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Request Credential Approval"),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${creExchangeDataPayload["credential_proposal_dict"]["comment"]} has request to approve following attributes",
              style: Theme.of(context)
                  .textTheme
                  .headline6
                  ?.copyWith(color: Colors.black),
            ),
            const Divider(),
            ...attributesList,
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    isLoading = true;
                  });
                  approveRequest()
                      .then((value) => setState(() {
                            isLoading = false;
                          }))
                      .then((value) => context.beamBack())
                      .catchError((e) {
                    setState(() {
                      isLoading = false;
                    });
                    Util.runSnackBarMessage(context, e.toString());
                  });
                },
                style: ElevatedButton.styleFrom(primary: Colors.green),
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Approve"),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  rejectRequest()
                      .then((value) => context.beamBack())
                      .catchError((e) {
                    Util.runSnackBarMessage(context, e.toString());
                  });
                },
                style: ElevatedButton.styleFrom(primary: Colors.red),
                child: const Text("Reject"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
