class ModelGraphqlQuery {
  final String query;
  final String variables;

  ModelGraphqlQuery(this.query, {this.variables = ""});

  Map<String, String> toJson() {
    if (variables == "") {
      return {"query": query.replaceAll("\n", "").replaceAll("\t", "")};
    } else {
      return {
        "query": query.replaceAll("\n", "").replaceAll("\t", ""),
        "variables": variables.replaceAll("\n", "").replaceAll("\t", "")
      };
    }
  }
}
