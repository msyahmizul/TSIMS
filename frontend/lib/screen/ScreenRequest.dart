import 'dart:convert';

import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/const.dart';
import 'package:mobile/model/ModelSendProofPresentation.dart';
import 'package:mobile/provider/providerCredentialList.dart';
import 'package:mobile/provider/providerHoldData.dart';
import 'package:mobile/provider/providerReloadData.dart';
import 'package:mobile/service/ServiceAgent.dart';

import '../provider/providerNotificationList.dart';
import '../util.dart';

class ScreenRequest extends ConsumerStatefulWidget {
  const ScreenRequest({
    Key? key,
    required this.preExID,
  }) : super(key: key);
  static const path = "/home/credentialRequest/:$pathPreEXIDArgs";
  static const pathPreEXIDArgs = "preExID";
  final String preExID;

  static page(String preExID) {
    return BeamPage(
        child: ScreenRequest(preExID: preExID),
        key: const ValueKey("proof-request"));
  }

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _ScreenRequestState();
  }
}

class _ScreenRequestState extends ConsumerState<ScreenRequest> {
  Map<String, dynamic> preExchangeDataPayload = {};
  List<Widget> dataAttributesWidget = [];
  bool isLoading = false;

  Widget _dataAttributes(String attributes, String value) {
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

  void readData() {
    var d = ref.read(providerHoldData);
    var r = ref.read(providerCredentialListBrief);
    if (d.containsKey(widget.preExID)) {
      preExchangeDataPayload = jsonDecode(d[widget.preExID]);
    }
    Map<String, dynamic> l =
    preExchangeDataPayload["presentation_request"]["requested_attributes"];
    List<Widget> u = [];
    if (l.keys
        .toList()
        .isNotEmpty) {
      for (final element in l.values) {
        var credInfo = r[element["restrictions"][0]["schema_id"]]!;
        u.add(_dataAttributes(
            Util.resolveSchemaIDToSchemaKey(
                element["restrictions"][0]["schema_id"], element["name"]),
            credInfo.attrs[element["name"]!]!));
        u.add(const SizedBox(height: 5));
      }
    }
    l = preExchangeDataPayload["presentation_request"]["requested_predicates"];
    if (l.keys
        .toList()
        .isNotEmpty) {
      for (final element in l.values) {
        var credInfo = r[element["restrictions"][0]["schema_id"]]!;
        u.add(_dataAttributes(
            Util.resolveSchemaIDToSchemaKey(
                element["restrictions"][0]["schema_id"], element["name"]),
            "${element["p_value"]} ${element["p_type"]}  ${credInfo
                .attrs[element["name"]!]!}"));
      }
    }
    dataAttributesWidget = u;
  }

  Future<void> acceptRequest() async {
    String token = await ServiceAgentUtil.getMultiTenantAuthToken();
    var r = ref.read(providerCredentialListBrief);
    ModelSendProofPresentation proofExchangeDataPayload =
    ModelSendProofPresentation(
        requestedAttributes: RequestedAttributes(attributes: {}),
        requestedPredicates: RequestedPredicates(attributes: {}),
        selfAttestedAttributes: SelfAttestedAttributes());
    Map<String, dynamic> l =
    preExchangeDataPayload["presentation_request"]["requested_attributes"];
    if (l.keys
        .toList()
        .isNotEmpty) {
      for (final element in l.entries) {
        var credInfo = r[element.value["restrictions"][0]["schema_id"]]!;
        proofExchangeDataPayload.requestedAttributes.attributes[element.key] =
            Attribute(credId: credInfo.credentialID, revealed: true);
      }
    }
    l = preExchangeDataPayload["presentation_request"]["requested_predicates"];
    if (l.keys
        .toList()
        .isNotEmpty) {
      for (final element in l.entries) {
        var credInfo = r[element.value["restrictions"][0]["schema_id"]]!;
        proofExchangeDataPayload.requestedPredicates.attributes[element.key] =
            PredicateAttribute(credId: credInfo.credentialID);
      }
    }
    await ServiceAgentProof.sendApproveProofExchange(
        AgentURL.multiTenant,
        Util.getHeader(AgentType.multi, token),
        preExchangeDataPayload["presentation_exchange_id"],
        proofExchangeDataPayload);
    ref.read(providerNotificationList.notifier).deleteKey(widget.preExID);
    ref
        .read(providerReloadData.notifier)
        .update((state) => {"reloadNotification": "true"});
  }

  Future<void> rejectRequest() async {
    String token = await ServiceAgentUtil.getMultiTenantAuthToken();
    await ServiceAgentProof.sendRejectMessageProof(
        AgentURL.multiTenant,
        Util.getHeader(AgentType.multi, token),
        preExchangeDataPayload["presentation_exchange_id"],
        "User reject the request");
    ref.read(providerNotificationList.notifier).deleteKey(widget.preExID);
    ref
        .read(providerReloadData.notifier)
        .update((state) => {"reloadNotification": "true"});
  }

  @override
  void initState() {
    readData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Request Approval Page"),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${preExchangeDataPayload["presentation_request"]["name"]}",
              style: Theme
                  .of(context)
                  .textTheme
                  .headline6
                  ?.copyWith(color: Colors.black),
            ),
            const Divider(),
            const SizedBox(height: 10),
            Text(
              "${preExchangeDataPayload["presentation_request_dict"]["comment"]} has request for following Attributes Data",
              style: Theme
                  .of(context)
                  .textTheme
                  .headline6
                  ?.copyWith(color: Colors.black),
            ),
            const Divider(),
            const SizedBox(height: 15),
            ...dataAttributesWidget,
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  setState(() {
                    isLoading = true;
                  });
                  acceptRequest().then((value) =>
                      setState(() {
                        isLoading = false;
                      })
                  )
                      .then((_) {
                    context.beamBack();
                  })
                      .then((_) {})
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
                  rejectRequest().then((_) {
                    context.beamBack();
                  }).catchError((e) {
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
