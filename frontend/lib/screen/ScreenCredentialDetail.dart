import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/const.dart';
import 'package:mobile/model/modelCredential.dart';
import 'package:mobile/provider/providerCredentialList.dart';
import 'package:mobile/util.dart';

class ScreenCredentialDetail extends ConsumerStatefulWidget {
  static const path = "/home/credentials/:$pathArgs";
  static const pathArgs = "index";

  final String credID;

  static page(String index) {
    return BeamPage(
        child: ScreenCredentialDetail(index),
        key: ValueKey("credentials-$index"));
  }

  const ScreenCredentialDetail(this.credID, {Key? key}) : super(key: key);

  @override
  ConsumerState<ScreenCredentialDetail> createState() {
    return _ScreenCredentialDetailState();
  }
}

class _ScreenCredentialDetailState
    extends ConsumerState<ScreenCredentialDetail> {
  ModelCredential credentialDetail = ModelCredential.empty();

  @override
  void initState() {
    var credDataList = ref.read(providerCredentialListBrief);
    credentialDetail = credDataList[widget.credID]!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<_Property> t = [];
    credentialDetail.attrs.forEach((key, value) {
      if (credentialDetail.schemaID == AgentSchemaID.banking) {
        t.add(_Property(
            propertyTitle: Util.resolveKeyToSchemaKey(AgentType.banking, key),
            valueTitle: value));
      } else if (credentialDetail.schemaID == AgentSchemaID.carrier) {
        t.add(_Property(
            propertyTitle: Util.resolveKeyToSchemaKey(AgentType.carrier, key),
            valueTitle: value));
      } else if (credentialDetail.schemaID == AgentSchemaID.university) {
        t.add(_Property(
            propertyTitle:
                Util.resolveKeyToSchemaKey(AgentType.university, key),
            valueTitle: value));
      } else if (credentialDetail.schemaID == AgentSchemaID.gov) {
        t.add(_Property(
            propertyTitle: Util.resolveKeyToSchemaKey(AgentType.gov, key),
            valueTitle: value));
      } else {
        throw Exception("Error Load Data");
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Credential Details'),
        backgroundColor: const Color(0xF4ECF1F4),
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _CardHolder(
                title: credentialDetail.type,
                subtitle: credentialDetail.origin,
              ),
              Container(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: t,
                ),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardHolder extends StatelessWidget {
  final String title;
  final String subtitle;

  const _CardHolder({Key? key, required this.title, required this.subtitle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: Container(
        width: double.infinity,
        height: 120,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 20,
              margin: const EdgeInsets.only(top: 20),
              color: const Color(0xff767171),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      subtitle,
                      textAlign: TextAlign.start,
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Property extends StatelessWidget {
  final String propertyTitle;
  final String valueTitle;

  const _Property({
    Key? key,
    required this.propertyTitle,
    required this.valueTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 4, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            propertyTitle,
            textAlign: TextAlign.start,
            style: TextStyle(fontSize: 16),
          ),
          Text(
            valueTitle,
            textAlign: TextAlign.start,
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
