import '../../../hierarchy/data/models/approval_chain_model.dart';
import '../../../hierarchy/data/models/role_template_model.dart';

class UserInfo {
  final String id;
  final String name;
  final String email;
  final RoleTemplateModel? roleTemplate;

  UserInfo({
    required this.id,
    required this.name,
    required this.email,
    this.roleTemplate,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      roleTemplate: json['roleTemplate'] != null
          ? RoleTemplateModel.fromJson(json['roleTemplate'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      if (roleTemplate != null) 'roleTemplate': roleTemplate!.toJson(),
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
  final String? creatorId;
  final String? companyId;
  final int? currentApprovalLevel;
  final List<ApprovalChainEntry>? approvalChain;
  final String? lastApproverId;
  final DateTime? lastApprovedAt;
  final String? rejectionReason;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final UserInfo? creator;
  final UserInfo? lastApprover;

  MaterialModel({
    this.id,
    required this.name,
    this.description,
    required this.quantity,
    required this.unit,
    this.price,
    this.images = const [],
    this.status,
    this.creatorId,
    this.companyId,
    this.currentApprovalLevel,
    this.approvalChain,
    this.lastApproverId,
    this.lastApprovedAt,
    this.rejectionReason,
    this.createdAt,
    this.updatedAt,
    this.creator,
    this.lastApprover,
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
      creatorId: json['creatorId'] as String?,
      companyId: json['companyId'] as String?,
      currentApprovalLevel: json['currentApprovalLevel'] as int?,
      approvalChain: json['approvalChain'] != null
          ? (json['approvalChain'] as List)
              .map((e) => ApprovalChainEntry.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      lastApproverId: json['lastApproverId'] as String?,
      lastApprovedAt: json['lastApprovedAt'] != null
          ? DateTime.parse(json['lastApprovedAt'] as String)
          : null,
      rejectionReason: json['rejectionReason'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      creator: json['creator'] != null
          ? UserInfo.fromJson(json['creator'] as Map<String, dynamic>)
          : null,
      lastApprover: json['lastApprover'] != null
          ? UserInfo.fromJson(json['lastApprover'] as Map<String, dynamic>)
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
      if (creatorId != null) 'creatorId': creatorId,
      if (companyId != null) 'companyId': companyId,
      if (currentApprovalLevel != null) 'currentApprovalLevel': currentApprovalLevel,
      if (approvalChain != null) 'approvalChain': approvalChain!.map((e) => e.toJson()).toList(),
      if (lastApproverId != null) 'lastApproverId': lastApproverId,
      if (lastApprovedAt != null) 'lastApprovedAt': lastApprovedAt!.toIso8601String(),
      if (rejectionReason != null) 'rejectionReason': rejectionReason,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      if (creator != null) 'creator': creator!.toJson(),
      if (lastApprover != null) 'lastApprover': lastApprover!.toJson(),
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
    String? creatorId,
    String? companyId,
    int? currentApprovalLevel,
    List<ApprovalChainEntry>? approvalChain,
    String? lastApproverId,
    DateTime? lastApprovedAt,
    String? rejectionReason,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserInfo? creator,
    UserInfo? lastApprover,
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
      creatorId: creatorId ?? this.creatorId,
      companyId: companyId ?? this.companyId,
      currentApprovalLevel: currentApprovalLevel ?? this.currentApprovalLevel,
      approvalChain: approvalChain ?? this.approvalChain,
      lastApproverId: lastApproverId ?? this.lastApproverId,
      lastApprovedAt: lastApprovedAt ?? this.lastApprovedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      creator: creator ?? this.creator,
      lastApprover: lastApprover ?? this.lastApprover,
    );
  }

  // Helper methods for status checking
  bool get isPending => status == 'PENDING';
  bool get isApproved => status == 'APPROVED';
  bool get isRejected => status == 'REJECTED';
  bool get requiresApproval => currentApprovalLevel != null;

  String get statusDisplayName {
    switch (status) {
      case 'PENDING':
        return 'Pending Approval';
      case 'APPROVED':
        return 'Approved';
      case 'REJECTED':
        return 'Rejected';
      default:
        return 'Unknown';
    }
  }

  String? get currentApprovalLevelName {
    if (currentApprovalLevel == null) return null;
    return 'Level $currentApprovalLevel';
  }

  int get approvalProgress {
    if (approvalChain == null || approvalChain!.isEmpty) return 0;
    return approvalChain!.where((e) => e.isApproved).length;
  }
}

