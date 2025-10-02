class UserModel {
  final int id;
  final String username;
  final String email;
  final String? firstName;
  final String? lastName;

  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.firstName,
    this.lastName,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as int,
        username: json['username'] as String? ?? '',
        email: json['email'] as String? ?? '',
        firstName: json['first_name'] as String?,
        lastName: json['last_name'] as String?,
      );
}


