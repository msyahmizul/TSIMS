import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../const.dart';
import '../model/modelCredential.dart';
import '../service/ServiceAgent.dart';
import '../util.dart';

final providerCredentialListBrief = StateNotifierProvider<
    CredentialListBriefNotifier,
    Map<String, ModelCredential>>((ref) => CredentialListBriefNotifier(ref));

class CredentialListBriefNotifier
    extends StateNotifier<Map<String, ModelCredential>> {
  final Ref ref;

  CredentialListBriefNotifier(this.ref) : super({});

  Future<void> getData() async {
    String token = await ServiceAgentUtil.getMultiTenantAuthToken();
    var data = await ServiceAgentCredential.getStoredCredentials(
        AgentURL.multiTenant, Util.getHeader(AgentType.multi, token));
    List<dynamic> credList = data["results"];
    assert(credList.isNotEmpty);
    Map<String, ModelCredential> t = {};
    for (final cred in credList) {
      var metadata = _credSchemaResolveTitle(cred["schema_id"]);

      t[cred["schema_id"]] = ModelCredential(
          type: metadata["title"] as String,
          origin: metadata["origin"] as String,
          attrs: (cred["attrs"] as Map<String, dynamic>)
              .map((key, value) => MapEntry(key, value.toString())),
          credentialID: cred["referent"],
          schemaID: cred["schema_id"]);
    }
    state = t;
  }

  static Map<String, String> _credSchemaResolveTitle(String schemaID) {
    switch (schemaID) {
      case AgentSchemaID.gov:
        return {"title": "User Data Credential", "origin": "Government"};
      case AgentSchemaID.banking:
        return {"title": "Bank Data Credential", "origin": "Jiro Bank"};
      case AgentSchemaID.carrier:
        return {"title": "Carrier Credential", "origin": "Jiro Carrier"};
      case AgentSchemaID.university:
        return {"title": "University Credential", "origin": "Jiro University"};

      default:
        throw Exception("Invalid Credential ID");
    }
  }
}
