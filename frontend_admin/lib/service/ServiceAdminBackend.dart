import 'package:graphql/client.dart';

import '../const.dart';

class ServiceAdminBackend {
  static GraphQLClient _getGraphqlClient() {
    return GraphQLClient(
        link: HttpLink(Backend.graphQLAPI), cache: GraphQLCache());
  }

  static Future<void> updateUserStatus(String status, String token,
      String username, String rejectMessage) async {
    final client = _getGraphqlClient();
    final query = gql(r"""
  mutation updateApplicationStatus($token:String!,$username:String!,$status: ApplicationStatus!,$rejectMessage: String!){
    updateApplicationStatus (token: $token, username: $username status: $status,rejectMessage:$rejectMessage) {
        applicantStatus
    }
}
  """);

    final result =
        await client.mutate(MutationOptions(document: query, variables: {
      "token": token,
      "username": username,
      "status": status,
      "rejectMessage": rejectMessage
    }));
    if (result.exception != null) {
      var ex = result.exception!;
      throw (Exception(ex.graphqlErrors.first.message));
    }
  }

  static Future<Map<String, dynamic>> getUserDataDetailByUsername(
      String token, String username) async {
    final client = _getGraphqlClient();
    final query = gql(r"""
    query getUserApplication($token: String!, $username: String!){
			getUserApplication(token: $token,username: $username){
			    applicantStatus 
			     files
			     rejectMessage
           userDetail{
                icCard
                firstName
                lastName
                gender
                dob
                address
                city
                state
				}}}     """);

    final result = await client.query(QueryOptions(
        document: query, variables: {"token": token, "username": username}));
    if (result.exception != null) {
      var ex = result.exception!;
      throw Exception({"error": ex.graphqlErrors.first.message});
    }

    return result.data!["getUserApplication"];
  }

  static Future<Map<String, String>> loginUser(
      String username, String password) async {
    final client = _getGraphqlClient();
    final query = gql(r"""
    query loginUser ($username: String!, $password: String!) {
    loginUser (username: $username, password: $password)
}
    """);
    final result = await client.query(QueryOptions(
        document: query,
        variables: {"username": username, "password": password}));
    if (result.exception != null) {
      var ex = result.exception!;
      return {"error": ex.graphqlErrors.first.message};
    }
    return {"data": result.data!["loginUser"]};
  }
}
