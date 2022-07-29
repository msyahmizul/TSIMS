class GraphqlQueryModel {
  String query;
  String variables;

  GraphqlQueryModel(this.query, {this.variables = ""});

  Map<String, String> toJson() {
    if (variables == "") {
      return {"query": query};
    } else {
      return {"query": query, "variables": variables};
    }
  }
}
