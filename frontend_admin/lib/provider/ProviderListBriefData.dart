import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../const.dart';
import '../model/brief_data_model.dart';
import '../model/graphqlQueryModel.dart';

final providerlistBriefData =
    StateNotifierProvider<ListBriefDataService, List<BriefDataModel>>(
        (ref) => ListBriefDataService(ref));

class ListBriefDataService extends StateNotifier<List<BriefDataModel>> {
  final Ref ref;

  ListBriefDataService(this.ref) : super(<BriefDataModel>[]);

  Future<void> fetchData(String token) async {
    var query = """
    query {
    getAllUserApplications (token: "$token") {
        username
        name
        applicantStatus
        did
    }
}      """;
    var result = await http.post(Uri.parse(Backend.graphQLAPI),
        body: jsonEncode(GraphqlQueryModel(query.replaceAll("\n", ""))),
        headers: {HttpHeaders.contentTypeHeader: "application/json"});
    var data = jsonDecode(result.body);
    var usersData = data["data"]["getAllUserApplications"];
    if (usersData == null) {
      state = [];
    } else {
      state = usersData
          .map<BriefDataModel>((data) => BriefDataModel(
              data["name"], data["username"], data["applicantStatus"]))
          .toList();
    }
  }
}
