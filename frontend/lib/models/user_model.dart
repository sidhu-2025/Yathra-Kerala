class UserModel {
  final int id;
  final String username;
  final String role;
  final String token;
  final int profileId;

  UserModel({
    required this.id,
    required this.username,
    required this.role,
    required this.token,
    required this.profileId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['user_id'] ?? 0,
      username: json['username'] ?? '',
      role: json['role'] ?? '',
      token: json['token'] ?? '',
      profileId: json['profile_id'] ?? 0,
    );
  }
}
