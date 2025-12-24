class UserDetailModel {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final bool isVerified;
  final String userType; // OWNER, ADMIN, USER
  final String? companyId;
  final String? branchId;
  final String? roleId;
  final String? directManagerId;
  final BranchModel? branch;
  final RoleModel? role;
  final UserDetailModel? directManager;
  final int directReportsCount;
  final DateTime createdAt;

  UserDetailModel({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    required this.isVerified,
    required this.userType,
    this.companyId,
    this.branchId,
    this.roleId,
    this.directManagerId,
    this.branch,
    this.role,
    this.directManager,
    this.directReportsCount = 0,
    required this.createdAt,
  });

  factory UserDetailModel.fromJson(Map<String, dynamic> json) {
    return UserDetailModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
      userType: json['userType'] as String? ?? 'USER',
      companyId: json['companyId'] as String?,
      branchId: json['branchId'] as String?,
      roleId: json['roleId'] as String?,
      directManagerId: json['directManagerId'] as String?,
      branch: json['branch'] != null
          ? BranchModel.fromJson(json['branch'] as Map<String, dynamic>)
          : null,
      role: json['role'] != null
          ? RoleModel.fromJson(json['role'] as Map<String, dynamic>)
          : null,
      directManager: json['directManager'] != null
          ? UserDetailModel.fromJson(json['directManager'] as Map<String, dynamic>)
          : null,
      directReportsCount: json['_count']?['directReports'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'isVerified': isVerified,
      'userType': userType,
      'companyId': companyId,
      'branchId': branchId,
      'roleId': roleId,
      'directManagerId': directManagerId,
    };
  }
}

class BranchModel {
  final String id;
  final String name;
  final String? description;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? zipCode;
  final String? phoneNumber;
  final String? email;
  final String? managerId;
  final bool isHeadquarters;
  final bool isActive;
  final int userCount;
  final int materialCount;

  BranchModel({
    required this.id,
    required this.name,
    this.description,
    this.address,
    this.city,
    this.state,
    this.country,
    this.zipCode,
    this.phoneNumber,
    this.email,
    this.managerId,
    this.isHeadquarters = false,
    this.isActive = true,
    this.userCount = 0,
    this.materialCount = 0,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String?,
      zipCode: json['zipCode'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      email: json['email'] as String?,
      managerId: json['managerId'] as String?,
      isHeadquarters: json['isHeadquarters'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      userCount: json['_count']?['users'] as int? ?? 0,
      materialCount: json['_count']?['materials'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'zipCode': zipCode,
      'phoneNumber': phoneNumber,
      'email': email,
      'managerId': managerId,
      'isHeadquarters': isHeadquarters,
      'isActive': isActive,
    };
  }

  String get fullAddress {
    final parts = <String>[];
    if (address != null && address!.isNotEmpty) parts.add(address!);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (state != null && state!.isNotEmpty) parts.add(state!);
    if (country != null && country!.isNotEmpty) parts.add(country!);
    return parts.join(', ');
  }
}

class RoleModel {
  final String id;
  final String name;
  final String? description;
  final String companyId;
  final int userCount;

  RoleModel({
    required this.id,
    required this.name,
    this.description,
    required this.companyId,
    this.userCount = 0,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      companyId: json['companyId'] as String,
      userCount: json['_count']?['users'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'companyId': companyId,
    };
  }
}
