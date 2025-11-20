class UserModel {
  final String id;
  final String email;
  final String name;
  final String role;
  final CompanyModel? company;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.company,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      role: json['role'],
      company: json['company'] != null ? CompanyModel.fromJson(json['company']) : null,
    );
  }
}

class CompanyModel {
  final String id;
  final String name;
  final String type;

  CompanyModel({
    required this.id,
    required this.name,
    required this.type,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['id'],
      name: json['name'],
      type: json['type'],
    );
  }
}

class AuthResponse {
  final UserModel user;
  final String token;

  AuthResponse({
    required this.user,
    required this.token,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: UserModel.fromJson(json['user']),
      token: json['token'],
    );
  }
}

