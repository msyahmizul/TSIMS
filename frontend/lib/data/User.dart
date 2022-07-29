class Name {
  final String firstName;
  final String lastName;

  const Name({required this.firstName, required this.lastName});
}

class User {
  final String username;
  final Name displayName;

  const User({required this.username, required this.displayName});
}

class Users {
  Users._();

  static User getLogonUser() {
    return const User(
      username: 'syahmi',
      displayName: Name(firstName: 'Syahmi', lastName: 'Zulkifli'),
    );
  }
}
