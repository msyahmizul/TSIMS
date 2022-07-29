class ModelCredential {
  final String credentialID;
  final String schemaID;
  final String type;
  final String origin;
  final Map<String, String> attrs;

  @override
  String toString() {
    return 'ModelCredential{credentialID: $credentialID, schemaID: $schemaID, type: $type, origin: $origin}';
  }

  ModelCredential.empty(
      {this.type = "",
      this.origin = "",
      this.attrs = const {},
      this.schemaID = "",
      this.credentialID = ""});

  ModelCredential(
      {required this.type,
      required this.origin,
      required this.attrs,
      required this.credentialID,
      required this.schemaID});
}
