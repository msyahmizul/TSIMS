import 'dart:convert';

import 'package:frontend_admin/model/Agent/ModelPresentProofSendRequest.dart';
import 'package:http/http.dart' as http;

import '../const.dart';

class ServiceAgentConnection {
  static Future<Map<String, dynamic>> getSingleConnectionInfo(
      String url, String connectionID) async {
    var response =
        await http.get(Uri.parse("$url/connections/$connectionID"), headers: {
      "X-API-KEY": AgentURL.agentAPIKey,
      "Content-Type": "application/json",
      "Accept": "application/json"
    });
    if (response.statusCode != 200) {
      throw Exception("internal http error ${response.body}");
    }
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> sendConnectionRequest(
      String url, String alias) async {
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
        headers: {
          "X-API-KEY": AgentURL.agentAPIKey,
          "Content-Type": "application/json",
          "Accept": "application/json"
        });
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
      String url, String alias) async {
    var response =
        await http.get(Uri.parse("$url/connections?alias=$alias"), headers: {
      "X-API-KEY": AgentURL.agentAPIKey,
      "Content-Type": "application/json",
      "Accept": "application/json"
    });
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
  static Future<Map<String, dynamic>> getCredentialSingle(
      String agentURL, String credentialExID) async {
    var response = await http.get(
        Uri.parse("$agentURL/issue-credential/records/$credentialExID"),
        headers: ServiceAgentUtil.getDefaultAgentHeader());
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

  // static Future<Map<String, dynamic>> sendCredentialOffer(
  //     String connectionID,
  //     String agentURL,
  //     Map<String, String> headers,
  //     String credentialExchangeId) async {
  //   var response = await http.post(
  //       Uri.parse(
  //           "$agentURL/issue-credential/records/$credentialExchangeId/send-offer"),
  //       headers: headers);
  //   if (response.statusCode != 200) {
  //     throw Exception("internal http error ${response.body}");
  //   }
  //   return jsonDecode(response.body);
  // }

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
      String connectionID, String agentURL, String credentialExchangeId) async {
    var response = await http.post(
        Uri.parse(
            "$agentURL/issue-credential/records/$credentialExchangeId/issue"),
        headers: ServiceAgentUtil.getDefaultAgentHeader(),
        body: jsonEncode({"comment": "Credential for User"}));
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

  static Future<Map<String, dynamic>> sendCredentialOffer(
      String connectionID,
      String agentURL,
      String credDefId,
      String comment,
      List<Map<String, String>> proposalsData) async {
    var query = jsonDecode("""
{
	"connection_id": "$connectionID",
	"cred_def_id": "$credDefId",
	"comment": "$comment",
	"credential_preview": {
		"attributes": []
	}	
}    """);
    for (final data in proposalsData) {
      if (!data.containsKey("name") || !data.containsKey("value")) {
        throw Exception("invalid key value for proposals Data");
      }
      query["credential_preview"]["attributes"].add({
        "name": data["name"],
        "value": data["value"],
      });
    }
    var response = await http.post(
        Uri.parse("$agentURL/issue-credential/send-offer"),
        body: jsonEncode(query),
        headers: ServiceAgentUtil.getDefaultAgentHeader());
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

class ServiceAgentPresentProof {
  static Future<Map<String, dynamic>> sendRequest(
      String agentURL, ModelPresentProofSendRequest presentProof) async {
    var response = await http.post(
        Uri.parse("$agentURL/present-proof/send-request"),
        body: jsonEncode(presentProof),
        headers: ServiceAgentUtil.getDefaultAgentHeader());
    if (response.statusCode != 200) {
      throw Exception("internal http error ${response.body}");
    }
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getSingleProofRequest(
      String agentURL, String presExId) async {
    var response = await http.get(
        Uri.parse("$agentURL/present-proof/records/$presExId"),
        headers: ServiceAgentUtil.getDefaultAgentHeader());
    if (response.statusCode != 200) {
      throw Exception("internal http error ${response.body}");
    }
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> verifyProofRequest(
      String agentURL, String presExId) async {
    var response = await http.post(
        Uri.parse(
            "$agentURL/present-proof/records/$presExId/verify-presentation"),
        headers: ServiceAgentUtil.getDefaultAgentHeader());
    if (response.statusCode != 200) {
      throw Exception("internal http error ${response.body}");
    }
    return jsonDecode(response.body);
  }
}

class ServiceAgentUtil {
  static Map<String, String> getDefaultAgentHeader() {
    return {
      "X-API-KEY": AgentURL.agentAPIKey,
      "Content-Type": "application/json",
      "Accept": "application/json"
    };
  }
}
