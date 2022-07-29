import 'package:graphql/client.dart';

import '../model/ModelUserData.dart';
import '../util.dart';

class ServiceUser {
  static Future<Map<String, dynamic>> checkUserApplication(String token) async {
    var client = Util.getGraphqlClient();
    final query = gql(r"""
    query checkApplicationUser($token: String!) {
    checkApplicationUser(token:$token)  {
       rejectMessage
       status
    }
}
    """);
    final result = await client
        .query(QueryOptions(document: query, variables: {"token": token}));
    if (result.exception != null) {
      throw Exception(result.exception?.graphqlErrors.first.message);
    }
    return result.data!["checkApplicationUser"];
  }

  static Future<String> signInUser(String username, String password) async {
    var client = Util.getGraphqlClient();
    final query = gql(r"""
    query loginUser ($username: String!, $password: String!) {
    loginUser (username: $username, password: $password)
}
    """);
    try {
      final result = await client.query(QueryOptions(
          document: query,
          variables: {"username": username, "password": password}));
      if (result.exception != null) {
        throw Exception(result.exception?.graphqlErrors.first.message);
      }
      return result.data!["loginUser"];
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getUser(String token) async {
    var client = Util.getGraphqlClient();
    final query = gql(r"""
    query($token:String!){
      getUserData(token: $token){
      did
      walletID
      }
      }
    """);
    try {
      final result = await client
          .query(QueryOptions(document: query, variables: {"token": token}));
      if (result.exception != null) {
        throw Exception(result.exception?.graphqlErrors.toString());
      }

      return result.data!["getUserData"];
    } catch (e) {
      rethrow;
    }
  }

  static Future<ModelUserData> getUserData(String token) async {
    var client = Util.getGraphqlClient();
    final query = gql(r"""
    query($token:String!){
      getUserData(token: $token){
      username
data{
userID
icCard
firstName
lastName
gender
dob
address
city
state
postcode
}}}
    """);
    try {
      final result = await client
          .query(QueryOptions(document: query, variables: {"token": token}));
      if (result.exception != null) {
        throw Exception(result.exception?.graphqlErrors.toString());
      }

      var data = ModelUserData.fromJson(result.data!["getUserData"]["data"],
          result.data!["getUserData"]["username"]);

      return data;
    } catch (e) {
      rethrow;
    }
  }
}
