class UserModel {
  final int id;
  final String username;
  final String email;
  final String fullName;
  final String role;
  final String token;
  final int profileId;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.role,
    required this.token,
    required this.profileId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['user_id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      role: json['role'] ?? '',
      token: json['token'] ?? '',
      profileId: json['profile_id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': id,
      'username': username,
      'email': email,
      'full_name': fullName,
      'role': role,
      'token': token,
      'profile_id': profileId,
    };
  }
}
