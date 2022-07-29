class ModelUserData {
  final String username;
  final String icCard;
  final String firstName;
  final String lastName;
  final String gender;
  final String address;
  final String city;
  final String state;
  final String postcode;
  final String age;

  const ModelUserData(
      {this.username = "",
      this.icCard = "",
      this.firstName = "",
      this.lastName = "",
      this.gender = "",
      this.address = "",
      this.city = "",
      this.state = "",
      this.age = "",
      this.postcode = ""});

  ModelUserData copyWith(
          {String? username,
          String? icCard,
          String? firstName,
          String? lastName,
          String? gender,
          String? address,
          String? city,
          String? state,
          String? age,
          String? postcode}) =>
      ModelUserData(
          username: username ?? this.username,
          icCard: icCard ?? this.icCard,
          firstName: firstName ?? this.firstName,
          lastName: lastName ?? this.lastName,
          gender: gender ?? this.gender,
          address: address ?? this.address,
          city: city ?? this.city,
          state: state ?? this.state,
          age: age ?? this.age,
          postcode: postcode ?? this.postcode);

  @override
  String toString() {
    return 'ModelUserData{username: $username, icCard: $icCard, firstName: $firstName, lastName: $lastName, gender: $gender, address: $address, city: $city, state: $state, postcode: $postcode}';
  }

  Map<String, dynamic> toJson() => {
        "username": username,
        "icCard": icCard,
        "firstName": firstName,
        "lastName": lastName,
        "gender": gender,
        "address": address,
        "age": age,
        "city": city,
        "state": state,
        "postcode": postcode,
      };

  List<Map<String, String>> toSchema() {
    List<Map<String, String>> t = [];
    t.add({"name": "address", "value": address.trim()});
    t.add({"name": "city", "value": city.trim()});
    t.add({"name": "state", "value": state.trim()});
    t.add({"name": "first_name", "value": firstName.trim()});
    t.add({"name": "last_name", "value": lastName.trim()});
    t.add({"name": "postcode", "value": postcode.trim()});
    // var date = DateTime.now().year;
    // int year = int.parse(icCard.substring(1, 3));
    // int age = 0;
    // if (year <= 15) {
    //   age = date - (year + 2000);
    // } else {
    //   age = date - (year + 1900);
    // }
    var dateNow = DateTime.now();
    t.add({
      "name": "dob",
      "value": (dateNow.year - int.parse(age)).toString().trim()
    });
    return t;
  }

  ModelUserData.fromJson(Map<String, dynamic> json, this.username)
      : icCard = json["icCard"],
        firstName = json["firstName"],
        lastName = json["lastName"],
        gender = json["gender"],
        address = json["address"],
        city = json["city"],
        state = json["state"],
        age = json["age"],
        postcode = json["postcode"];
}
