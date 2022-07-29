import 'package:flutter/material.dart';
import 'package:graphql/client.dart';
import 'package:hive/hive.dart';

import 'const.dart';

enum AgentType { gov, multi, banking, carrier, university, invalid }

class Util {
  static GraphQLClient getGraphqlClient() {
    return GraphQLClient(
        link: HttpLink(Backend.graphQLAPI), cache: GraphQLCache());
  }

  static Box getBox() {
    return Hive.box(BoxName.name);
  }

  static Map<String, String> getHeader(AgentType type, [String token = ""]) {
    switch (type) {
      case AgentType.gov:
        return {
          "X-API-KEY": AgentURL.agentAPIKey,
          "Content-Type": "application/json",
          "Accept": "application/json"
        };
      case AgentType.multi:
        if (token.isEmpty) {
          throw Exception("token cannot be empty");
        }
        return {
          "Authorization": "Bearer $token",
          "X-API-KEY": AgentURL.agentAPIKey,
          "Content-Type": "application/json",
          "Accept": "application/json"
        };
      case AgentType.banking:
        return {
          "X-API-KEY": AgentURL.agentAPIKey,
          "Content-Type": "application/json",
          "Accept": "application/json"
        };
      case AgentType.carrier:
        return {
          "X-API-KEY": AgentURL.agentAPIKey,
          "Content-Type": "application/json",
          "Accept": "application/json"
        };
      case AgentType.university:
        return {
          "X-API-KEY": AgentURL.agentAPIKey,
          "Content-Type": "application/json",
          "Accept": "application/json"
        };
      case AgentType.invalid:
        return {
          "X-API-KEY": AgentURL.agentAPIKey,
          "Content-Type": "application/json",
          "Accept": "application/json"
        };
    }
  }

  static QRType strToQRType(String value) {
    switch (value) {
      case "connectionRequest":
        return QRType.connectionRequest;
      default:
        throw Exception("Invalid QR Type");
    }
  }

  static AgentType strToAgentType(String value) {
    switch (value) {
      case "multi":
        return AgentType.multi;
      case "banking":
        return AgentType.banking;
      case "carrier":
        return AgentType.carrier;
      case "university":
        return AgentType.university;
      case "invalid":
        throw Exception("Invalid Agent Type");
      default:
        throw Exception("Invalid Agent Type");
    }
  }

  static void runSnackBarMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message.replaceAll("Exception:", ""))));
  }

  static String resolveSchemaIDToSchemaKey(String schemaKey, String keyName) {
    switch (schemaKey) {
      case AgentSchemaID.gov:
        switch (keyName) {
          case "state":
            return "State";
          case "city":
            return "City";
          case "first_name":
            return "First Name";
          case "postcode":
            return "Postcode";
          case "address":
            return "Address";
          case "last_name":
            return "Last Name";
          case "dob":
            return "Age";
          default:
            throw Exception("Invalid Key Type");
        }
      case AgentSchemaID.banking:
        switch (keyName) {
          case "first_name":
            return "First Name";
          case "last_name":
            return "Last Name";
          case "uid":
            return "User ID";
          default:
            throw Exception("Invalid Key Type $keyName");
        }
      case AgentSchemaID.carrier:
        switch (keyName) {
          case "first_name":
            return "First Name";
          case "last_name":
            return "Last Name";
          case "plan_type":
            return "Plan Type";
          case "uid":
            return "User ID";
          default:
            throw Exception("Invalid Key Type $keyName");
        }
      case AgentSchemaID.university:
        switch (keyName) {
          case "first_name":
            return "First Name";
          case "last_name":
            return "Last Name";
          case "degree":
            return "Degree";
          case "status":
            return "Status";
          default:
            throw Exception("Invalid Key Type $keyName");
        }

      default:
        throw Exception("Invalid Schema ID");
    }
  }

  static String resolveKeyToSchemaKey(AgentType type, String keyName) {
    switch (type) {
      case AgentType.gov:
        switch (keyName) {
          case "state":
            return "State";
          case "city":
            return "City";
          case "first_name":
            return "First Name";
          case "postcode":
            return "Postcode";
          case "address":
            return "Address";
          case "last_name":
            return "Last Name";
          case "dob":
            return "Age";
          default:
            throw Exception("Invalid Key Type");
        }
      case AgentType.banking:
        switch (keyName) {
          case "first_name":
            return "First Name";
          case "last_name":
            return "Last Name";
          case "uid":
            return "User ID";
          default:
            throw Exception("Invalid Key Type $keyName");
        }
      case AgentType.carrier:
        switch (keyName) {
          case "first_name":
            return "First Name";
          case "last_name":
            return "Last Name";
          case "plan_type":
            return "Plan Type";
          case "uid":
            return "User ID";
          default:
            throw Exception("Invalid Key Type $keyName");
        }
      case AgentType.university:
        switch (keyName) {
          case "first_name":
            return "First Name";
          case "last_name":
            return "Last Name";
          case "degree":
            return "Degree";
          case "status":
            return "Status";
          default:
            throw Exception("Invalid Key Type $keyName");
        }
      case AgentType.multi:
        throw Exception("Invalid Agent Type");

      case AgentType.invalid:
        throw Exception("Invalid Key Type");
    }
  }
}
