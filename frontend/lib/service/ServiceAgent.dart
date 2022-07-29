import 'dart:convert';

import 'package:graphql/client.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/model/ModelSendProofPresentation.dart';
import 'package:mobile/model/ModelWallet.dart';

import '../const.dart';
import '../util.dart';

class ServiceAgentConnection {
  static Future<Map<String, dynamic>> sendConnectionRequest(
      String url, String alias, Map<String, String> headers) async {
    String query = """
    {
  "handshake_protocols": [
    "did:sov:BzCbsNYhMrjHiqZDTUASHg;spec/didexchange/1.0"
  ],
  "use_public_did": false,
  "alias":"$alias"
}
    """;

    var response = await http.post(
        Uri.parse("$url/out-of-band/create-invitation"),
        body: query,
        headers: headers);
    if (response.statusCode != 200) {
      throw Exception("internal http error ${response.body}");
    }
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> receiveConnectionRequest(String url,
      Map<String, dynamic> bodyData, Map<String, String> headers) async {
    var response = await http.post(
        Uri.parse("$url/out-of-band/receive-invitation"),
        body: jsonEncode(bodyData),
        headers: headers);
    if (response.statusCode != 200) {
      throw Exception("internal http error ${response.body}");
    }
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getSingleConnectionDataViaAlias(
      String url, String alias, Map<String, String> headers) async {
    var response = await http.get(Uri.parse("$url/connections?alias=$alias"),
        headers: headers);
    if (response.statusCode != 200) {
      throw Exception("internal http error ${response.body}");
    }
    var res = jsonDecode(response.body);
    if ((res["results"] as List<dynamic>).length != 1) {
      throw Exception("Empty connection");
    }
    return res["results"][0];
  }
}

class ServiceAgentCredential {
  static Future<Map<String, dynamic>> sendRejectCredentialRequestMessage(
      String agentURL,
      Map<String, String> headers,
      String credExID,
      String message) async {
    var response = await http.post(
        Uri.parse(
            "$agentURL/issue-credential/records/$credExID/problem-report"),
        body: jsonEncode({"description": message}),
        headers: headers);
    if (response.statusCode != 200) {
      throw Exception("internal http error ${response.body}");
    }
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getStoredCredentials(
      String agentURL, Map<String, String> headers) async {
    var response =
        await http.get(Uri.parse("$agentURL/credentials"), headers: headers);
    if (response.statusCode != 200) {
      throw Exception("internal http error ${response.body}");
    }
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> sendCredentialOffer(
      String connectionID,
      String agentURL,
      Map<String, String> headers,
      String credentialExchangeId) async {
    var response = await http.post(
        Uri.parse(
            "$agentURL/issue-credential/records/$credentialExchangeId/send-offer"),
        headers: headers);
    if (response.statusCode != 200) {
      throw Exception("internal http error ${response.body}");
    }
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> sendCredentialRequest(
      String connectionID,
      String agentURL,
      Map<String, String> headers,
      String credentialExchangeId) async {
    var response = await http.post(
        Uri.parse(
            "$agentURL/issue-credential/records/$credentialExchangeId/send-request"),
        headers: headers);
    if (response.statusCode != 200) {
      throw Exception("internal http error ${response.body}");
    }
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> issuesCredential(
      String connectionID,
      String agentURL,
      Map<String, String> headers,
      String credentialExchangeId) async {
    var response = await http.post(
        Uri.parse(
            "$agentURL/issue-credential/records/$credentialExchangeId/issue"),
        headers: headers,
        body: jsonEncode({"comment": "Credential for User"}));
    if (response.statusCode != 200) {
      throw Exception("internal http error ${response.body}");
    }
    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> getCredentialProposalViaState(
      String agentURL, String state, Map<String, String> headers) async {
    var response = await http.get(
        Uri.parse("$agentURL/issue-credential/records?state=$state"),
        headers: headers);
    if (response.statusCode != 200) {
      throw Exception("internal http error ${response.body}");
    }
    var res = jsonDecode(response.body);
    return res["results"] as List<dynamic>;
  }

  static Future<Map<String, dynamic>> getCredentialSingle(String agentURL,
      String credentialExID, Map<String, String> headers) async {
    var response = await http.get(
        Uri.parse("$agentURL/issue-credential/records/$credentialExID"),
        headers: headers);
    if (response.statusCode != 200) {
      throw Exception("internal http error ${response.body}");
    }
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getCredentialProposalViaThreadID(
      String connectionID,
      String agentURL,
      String threadID,
      Map<String, String> headers) async {
    var response = await http.get(
        Uri.parse("$agentURL/issue-credential/records?thread_id=$threadID"),
        headers: headers);
    if (response.statusCode != 200) {
      throw Exception("internal http error ${response.body}");
    }
    var res = jsonDecode(response.body);
    if ((res["results"] as List<dynamic>).length != 1) {
      throw Exception("Empty connection");
    }
    return res["results"][0];
  }

  static Future<Map<String, dynamic>> sendCredentialProposal(
      String connectionID,
      String agentURL,
      String schemaID,
      List<Map<String, String>> proposalsData,
      Map<String, String> headers) async {
    var query = jsonDecode("""
{
	"connection_id": "$connectionID",
	"schema_id": "$schemaID",
	"auto_remove":false,
	"credential_proposal": {
		"attributes": []
	}	
}    """);
    for (final data in proposalsData) {
      if (!data.containsKey("name") || !data.containsKey("value")) {
        throw Exception("invalid key value for proposals Data");
      }
      query["credential_proposal"]["attributes"].add({
        "name": data["name"],
        "value": data["value"],
      });
    }
    var response = await http.post(
        Uri.parse("$agentURL/issue-credential/send-proposal"),
        body: jsonEncode(query),
        headers: headers);
    if (response.statusCode != 200) {
      throw Exception("internal http error ${response.body}");
    }
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> issuesCredentialProposal(
      String connectionID,
      String agentURL,
      String credentialExchangeId,
      Map<String, String> headers) async {
    var response = await http.post(
        Uri.parse(
            "$agentURL/issue-credential/records/$credentialExchangeId/issue"),
        headers: headers);
    if (response.statusCode != 200) {
      throw Exception("internal http error ${response.body}");
    }
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> storeCredentialProposal(
      String connectionID,
      String agentURL,
      String credentialExchangeId,
      Map<String, String> headers) async {
    var response = await http.post(
        Uri.parse(
            "$agentURL/issue-credential/records/$credentialExchangeId/store"),
        headers: headers);
    if (response.statusCode != 200) {
      throw Exception("internal http error ${response.body}");
    }
    return jsonDecode(response.body);
  }
}

class ServiceAgentUtil {
  static Future<Map<String, String>> generateDID(String token) async {
    var client = Util.getGraphqlClient();
    final query = gql(r"""
    mutation ($token: String!) {
    generateUserDID(token: $token){
    did
     walletID
    }
}
    """);
    try {
      final result = await client.mutate(
          MutationOptions(document: query, variables: {"token": token}));
      if (result.exception != null) {
        throw Exception(result.exception?.graphqlErrors.first.message);
      }
      return {
        "did": result.data!["generateUserDID"]["did"],
        "wallet": result.data!["generateUserDID"]["walletID"]
      };
    } catch (e) {
      rethrow;
    }
  }

  static Future<String> getMultiTenantAuthToken([String? w]) async {
    var box = Hive.box(BoxName.name);
    String walletID;
    if (w != null) {
      walletID = w;
    } else {
      String walletRaw = box.get(BoxName.walletData, defaultValue: "");
      assert(walletRaw.isNotEmpty);
      ModelWallet wallet = ModelWallet.fromJson(jsonDecode(walletRaw));
      walletID = wallet.wallet;
    }
    String auth = box.get(BoxName.walletAutToken, defaultValue: "");
    if (auth.isEmpty) {
      String token = await _getMultiTenantAuthToken(walletID);
      await box.put(BoxName.walletAutToken, token);
      return token;
    } else {
      return auth;
    }
  }

  static Future<String> _getMultiTenantAuthToken(String walletID) async {
    var response = await http.post(
        Uri.parse(
            "${AgentURL.multiTenant}/multitenancy/wallet/$walletID/token"),
        headers: {"X-API-KEY": AgentURL.agentAPIKey});
    if (response.statusCode != 200) {
      throw Exception("internal http error ${response.body}");
    }
    return jsonDecode(response.body)["token"];
  }
}

class ServiceAgentProof {
  static Future<List<dynamic>> getPresentProofExchange(
      String agentURL, Map<String, String> headers, String state) async {
    var response = await http.get(
        Uri.parse("$agentURL/present-proof/records?state=$state"),
        headers: headers);
    if (response.statusCode != 200) {
      throw Exception("internal http error ${response.body}");
    }
    return jsonDecode(response.body)["results"] as List<dynamic>;
  }

  static Future<Map<String, dynamic>> sendApproveProofExchange(
      String agentURL,
      Map<String, String> headers,
      String preExID,
      ModelSendProofPresentation proofPresentation) async {
    var response = await http.post(
        Uri.parse("$agentURL/present-proof/records/$preExID/send-presentation"),
        body: jsonEncode(proofPresentation),
        headers: headers);
    if (response.statusCode != 200) {
      throw Exception("internal http error ${response.body}");
    }
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> sendRejectMessageProof(String agentURL,
      Map<String, String> headers, String preExID, String message) async {
    var response = await http.post(
        Uri.parse("$agentURL/present-proof/records/$preExID/problem-report"),
        body: jsonEncode({"description": message}),
        headers: headers);
    if (response.statusCode != 200) {
      throw Exception("internal http error ${response.body}");
    }
    return jsonDecode(response.body);
  }
}
