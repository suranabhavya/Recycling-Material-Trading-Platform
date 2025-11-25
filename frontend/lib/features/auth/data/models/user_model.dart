import '../../../hierarchy/data/models/role_template_model.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final bool isVerified;
  final String? companyId;
  final String? companyApprovalStatus;
  final String? roleTemplateId;
  final String? managerId;
  final String? orgUnitId;
  final bool? isOrgUnitHead;
  final CompanyModel? company;
  final RoleTemplateModel? roleTemplate;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.isVerified,
    this.companyId,
    this.companyApprovalStatus,
    this.roleTemplateId,
    this.managerId,
    this.orgUnitId,
    this.isOrgUnitHead,
    this.company,
    this.roleTemplate,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      isVerified: json['isVerified'] as bool? ?? false,
      companyId: json['companyId'] as String?,
      companyApprovalStatus: json['companyApprovalStatus'] as String?,
      roleTemplateId: json['roleTemplateId'] as String?,
      managerId: json['managerId'] as String?,
      orgUnitId: json['orgUnitId'] as String?,
      isOrgUnitHead: json['isOrgUnitHead'] as bool?,
      company: json['company'] != null ? CompanyModel.fromJson(json['company'] as Map<String, dynamic>) : null,
      roleTemplate: json['roleTemplate'] != null ? RoleTemplateModel.fromJson(json['roleTemplate'] as Map<String, dynamic>) : null,
    );
  }

  bool get isAdmin => roleTemplate?.isAdmin ?? false;
  bool get hasCompany => companyId != null;
  bool get isApproved => companyApprovalStatus == 'APPROVED';
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
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? '',
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
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] as String? ?? '',
    );
  }
}

