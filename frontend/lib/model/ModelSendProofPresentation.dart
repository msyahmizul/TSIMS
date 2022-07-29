class ModelSendProofPresentation {
  ModelSendProofPresentation({
    required this.requestedAttributes,
    required this.requestedPredicates,
    required this.selfAttestedAttributes,
  });

  late final RequestedAttributes requestedAttributes;
  late final RequestedPredicates requestedPredicates;
  late final SelfAttestedAttributes selfAttestedAttributes;

  ModelSendProofPresentation.fromJson(Map<String, dynamic> json) {
    requestedAttributes =
        RequestedAttributes.fromJson(json['requested_attributes']);
    requestedPredicates =
        RequestedPredicates.fromJson(json['requested_predicates']);
    selfAttestedAttributes =
        SelfAttestedAttributes.fromJson(json['self_attested_attributes']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['requested_attributes'] = requestedAttributes.toJson();
    _data['requested_predicates'] = requestedPredicates.toJson();
    _data['self_attested_attributes'] = selfAttestedAttributes.toJson();
    return _data;
  }
}

class RequestedAttributes {
  RequestedAttributes({
    required this.attributes,
  });

  late final Map<String, Attribute> attributes;

  RequestedAttributes.fromJson(Map<String, dynamic> json) {
    Map<String, Attribute> a = {};
    json.forEach((key, value) {
      a[key] = Attribute.fromJson(value);
    });
    attributes = a;
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    return _data["requested_attributes"] = attributes;
  }
}

class Attribute {
  Attribute({
    required this.credId,
    required this.revealed,
  });

  late final String credId;
  late final bool revealed;

  Attribute.fromJson(Map<String, dynamic> json) {
    credId = json['cred_id'];
    revealed = json['revealed'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['cred_id'] = credId;
    if (revealed) {
      _data['revealed'] = revealed;
    }
    return _data;
  }
}

class PredicateAttribute {
  PredicateAttribute({
    required this.credId,
  });

  late final String credId;

  PredicateAttribute.fromJson(Map<String, dynamic> json) {
    credId = json['cred_id'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['cred_id'] = credId;
    return _data;
  }
}

class RequestedPredicates {
  RequestedPredicates({
    required this.attributes,
  });

  late final Map<String, PredicateAttribute> attributes;

  RequestedPredicates.fromJson(Map<String, dynamic> json) {
    Map<String, PredicateAttribute> a = {};
    json.forEach((key, value) {
      a[key] = PredicateAttribute.fromJson(value);
    });
    attributes = a;
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    return _data["requested_predicates"] = attributes;
  }
}

class SelfAttestedAttributes {
  SelfAttestedAttributes();

  SelfAttestedAttributes.fromJson(Map json);

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    return _data;
  }
}
