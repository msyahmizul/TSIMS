import 'dart:io';

import 'package:graphql/client.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mobile/model/ModelUserData.dart';

import '../util.dart';

class ServiceUserSignUp {
  static Future<void> signUpUserData(
      String token, ModelUserData userData) async {
    GraphQLClient client = Util.getGraphqlClient();
    var query = gql(r"""
mutation($token: String!, $user: InputNewUserDataInformation!){
	 createDataUser(token:$token, user: $user){
	firstName}}
    """);
    try {
      var result =
          await client.mutate(MutationOptions(document: query, variables: {
        "token": token,
        "user": {
          "icCard": userData.icCard,
          "firstName": userData.firstName,
          "lastName": userData.lastName,
          "gender": userData.gender,
          "dob": userData.age,
          "address": userData.address,
          "city": userData.city,
          "state": userData.state,
          "postcode": userData.postcode
        }
      }));
      if (result.exception != null) {
        throw Exception(result.exception?.graphqlErrors.toString());
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> uploadUserData(String token, List<File> files) async {
    GraphQLClient client = Util.getGraphqlClient();
    int waitRetry = 0;

    for (final file in files) {
      while (true) {
        var multipartFile = http.MultipartFile.fromBytes(
            "0", file.readAsBytesSync(),
            filename: file.uri.pathSegments.last,
            contentType:
                MediaType("image", file.uri.pathSegments.last.split(".").last));
        try {
          final result = await client.mutate(MutationOptions(
              document: gql(r"""
            mutation($file: Upload!,$token: String!) {
  uploadDocumentUser(file: $file, token: $token)}"""),
              variables: {"file": multipartFile, "token": token}));
          if (result.exception != null) {
            throw Exception(result.exception?.graphqlErrors.toString());
          }
          break;
        } catch (e) {
          waitRetry += 1;
          if (waitRetry >= 3) {
            rethrow;
          }
        }
      }
    }
  }

  static Future<String> signUpUser(String username, String password) async {
    GraphQLClient client = Util.getGraphqlClient();
    var query = gql(r"""
    mutation($username:String!,$password:String!) { 
		 signUpUser(user: {
		 username: $username,
	  password: $password,
	})
	}""");
    try {
      var result = await client.mutate(MutationOptions(
          document: query,
          variables: {"username": username, "password": password}));
      if (result.exception != null) {
        if (result.exception?.graphqlErrors.first.message ==
            "status returned Error 409 Conflict") {
          throw Exception("username already exist");
        } else {
          throw Exception(result.exception?.graphqlErrors.first.message);
        }
      } else {
        return result.data?["signUpUser"] as String;
      }
    } catch (e) {
      rethrow;
    }
  }
}
