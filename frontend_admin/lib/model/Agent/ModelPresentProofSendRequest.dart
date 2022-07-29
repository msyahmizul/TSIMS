class ModelPresentProofSendRequest {
  ModelPresentProofSendRequest(
      {required this.connectionId,
      required this.proofRequest,
      required this.comment});

  late final String connectionId;
  late final String comment;
  late final ProofRequest proofRequest;

  ModelPresentProofSendRequest.fromJson(Map<String, dynamic> json) {
    connectionId = json['connection_id'];
    proofRequest = ProofRequest.fromJson(json['proof_request']);
    comment = json['comment'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['connection_id'] = connectionId;
    data['comment'] = comment;
    data['proof_request'] = proofRequest.toJson();
    return data;
  }
}

class ProofRequest {
  ProofRequest({
    required this.name,
    required this.version,
    required this.requestedAttributes,
    required this.requestedPredicates,
  });

  late final String name;
  late final String version;
  late final RequestedAttributes requestedAttributes;
  late final RequestedPredicates requestedPredicates;

  ProofRequest.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    version = json['version'];
    requestedAttributes =
        RequestedAttributes.fromJson(json['requested_attributes']);
    requestedPredicates =
        RequestedPredicates.fromJson(json['requested_predicates']);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['version'] = version;
    data['requested_attributes'] = requestedAttributes.toJson();
    data['requested_predicates'] = requestedPredicates.toJson();
    return data;
  }
}

class RequestedAttributes {
  RequestedAttributes({
    required this.attributes,
  });

  late final Map<String, Attributes> attributes;

  RequestedAttributes.fromJson(Map<String, dynamic> json) {
    Map<String, Attributes> a = {};
    json.forEach((key, value) {
      a[key] = Attributes.fromJson(value);
    });
    attributes = a;
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    return _data["requested_attributes"] = attributes;
  }
}

class Attributes {
  Attributes({
    required this.name,
    required this.restrictions,
  });

  late final String name;
  late final List<Restrictions> restrictions;

  Attributes.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    restrictions = List.from(json['restrictions'])
        .map((e) => Restrictions.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['name'] = name;
    _data['restrictions'] = restrictions.map((e) => e.toJson()).toList();
    return _data;
  }
}

class Restrictions {
  Restrictions({
    required this.schemaId,
  });

  late final String schemaId;

  Restrictions.fromJson(Map<String, dynamic> json) {
    schemaId = json['schema_id'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['schema_id'] = schemaId;
    return _data;
  }
}

class RequestedPredicates {
  RequestedPredicates({
    required this.predicates,
  });

  late final Map<String, Predicate> predicates;

  RequestedPredicates.fromJson(Map<String, dynamic> json) {
    Map<String, Predicate> a = {};
    json.forEach((key, value) {
      a[key] = Predicate.fromJson(value);
    });
    predicates = a;
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    return _data["requested_predicates"] = predicates;
  }
}

class Predicate {
  Predicate({
    required this.name,
    required this.pType,
    required this.pValue,
    required this.restrictions,
  });

  late final String name;
  late final String pType;
  late final int pValue;
  late final List<Restrictions> restrictions;

  Predicate.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    pType = json['p_type'];
    pValue = json['p_value'];
    restrictions = List.from(json['restrictions'])
        .map((e) => Restrictions.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['name'] = name;
    _data['p_type'] = pType;
    _data['p_value'] = pValue;
    _data['restrictions'] = restrictions.map((e) => e.toJson()).toList();
    return _data;
  }
}
