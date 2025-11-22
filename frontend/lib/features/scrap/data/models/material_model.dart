class UserInfo {
  final String id;
  final String name;
  final String email;

  UserInfo({
    required this.id,
    required this.name,
    required this.email,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}

class MaterialModel {
  final String? id;
  final String name;
  final String? description;
  final double quantity;
  final String unit;
  final double? price;
  final List<String> images;
  final String? status;
  final String? userId;
  final String? companyId;
  final String? leadId;
  final DateTime? leadApprovedAt;
  final String? batchId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final UserInfo? user;

  MaterialModel({
    this.id,
    required this.name,
    this.description,
    required this.quantity,
    required this.unit,
    this.price,
    this.images = const [],
    this.status,
    this.userId,
    this.companyId,
    this.leadId,
    this.leadApprovedAt,
    this.batchId,
    this.createdAt,
    this.updatedAt,
    this.user,
  });

  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    return MaterialModel(
      id: json['id'] as String?,
      name: json['name'] as String,
      description: json['description'] as String?,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      images: json['images'] != null
          ? List<String>.from(json['images'] as List)
          : [],
      status: json['status'] as String?,
      userId: json['userId'] as String?,
      companyId: json['companyId'] as String?,
      leadId: json['leadId'] as String?,
      leadApprovedAt: json['leadApprovedAt'] != null
          ? DateTime.parse(json['leadApprovedAt'] as String)
          : null,
      batchId: json['batchId'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      user: json['user'] != null
          ? UserInfo.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      if (description != null) 'description': description,
      'quantity': quantity,
      'unit': unit,
      if (price != null) 'price': price,
      'images': images,
      if (status != null) 'status': status,
      if (userId != null) 'userId': userId,
      if (companyId != null) 'companyId': companyId,
      if (leadId != null) 'leadId': leadId,
      if (leadApprovedAt != null) 'leadApprovedAt': leadApprovedAt!.toIso8601String(),
      if (batchId != null) 'batchId': batchId,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      if (user != null) 'user': user!.toJson(),
    };
  }

  MaterialModel copyWith({
    String? id,
    String? name,
    String? description,
    double? quantity,
    String? unit,
    double? price,
    List<String>? images,
    String? status,
    String? userId,
    String? companyId,
    String? leadId,
    DateTime? leadApprovedAt,
    String? batchId,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserInfo? user,
  }) {
    return MaterialModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      price: price ?? this.price,
      images: images ?? this.images,
      status: status ?? this.status,
      userId: userId ?? this.userId,
      companyId: companyId ?? this.companyId,
      leadId: leadId ?? this.leadId,
      leadApprovedAt: leadApprovedAt ?? this.leadApprovedAt,
      batchId: batchId ?? this.batchId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
    );
  }

  // Helper methods for status checking
  bool get isPendingLeadApproval => status == 'PENDING_LEAD_APPROVAL';
  bool get isApprovedByLead => status == 'APPROVED_BY_LEAD';
  bool get isRejectedByLead => status == 'REJECTED_BY_LEAD';
  bool get isPendingAdminApproval => status == 'PENDING_ADMIN_APPROVAL';
  bool get isApprovedByAdmin => status == 'APPROVED_BY_ADMIN';
  bool get isRejectedByAdmin => status == 'REJECTED_BY_ADMIN';

  String get statusDisplayName {
    switch (status) {
      case 'PENDING_LEAD_APPROVAL':
        return 'Pending Lead Approval';
      case 'APPROVED_BY_LEAD':
        return 'Approved by Lead';
      case 'REJECTED_BY_LEAD':
        return 'Rejected by Lead';
      case 'PENDING_ADMIN_APPROVAL':
        return 'Pending Admin Approval';
      case 'APPROVED_BY_ADMIN':
        return 'Approved by Admin';
      case 'REJECTED_BY_ADMIN':
        return 'Rejected by Admin';
      default:
        return 'Unknown';
    }
  }
}

