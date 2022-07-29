class ModelWallet {
  final String wallet, did;

  @override
  String toString() {
    return 'ModelWallet{wallet: $wallet, did: $did}';
  }

  ModelWallet({this.wallet = "", this.did = ""});

  Map<String, dynamic> toJson() => {"wallet": wallet, "did": did};

  ModelWallet.fromJson(Map<String, dynamic> json)
      : wallet = json["wallet"],
        did = json["did"];
}
