class UserDetailModel {
  String status = "";
  String username = "";
  String icCard = "";
  String firstName = "";
  String lastName = "";
  String gender = "";
  String dob = "";
  String address = "";
  String city = "";
  String state = "";
  String rejectMessage = "";
  List<String> files = [];

  UserDetailModel();

  UserDetailModel.loadData(Map<String, dynamic> data, this.username) {
    files = data["files"].cast<String>();
    status = data["applicantStatus"];
    icCard = data["userDetail"]["icCard"];
    firstName = data["userDetail"]["firstName"];
    lastName = data["userDetail"]["lastName"];
    gender = data["userDetail"]["gender"];
    dob = data["userDetail"]["dob"];
    address = data["userDetail"]["address"];
    city = data["userDetail"]["city"];
    state = data["userDetail"]["state"];
    rejectMessage = data["rejectMessage"];
  }
}
