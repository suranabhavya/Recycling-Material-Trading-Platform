import 'package:recycling_platform/features/scrap/data/models/material_model.dart';

class BatchLeadInfo {
  final String id;
  final String name;
  final String email;

  BatchLeadInfo({
    required this.id,
    required this.name,
    required this.email,
  });

  factory BatchLeadInfo.fromJson(Map<String, dynamic> json) {
    return BatchLeadInfo(
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

class BatchModel {
  final String id;
  final String name;
  final String? description;
  final String leadId;
  final BatchLeadInfo? lead;
  final String companyId;
  final String status;
  final List<MaterialModel> materials;
  final int materialCount;
  final DateTime? submittedAt;
  final DateTime? reviewedAt;
  final String? reviewedBy;
  final UserInfo? reviewer;
  final DateTime createdAt;
  final DateTime updatedAt;

  BatchModel({
    required this.id,
    required this.name,
    this.description,
    required this.leadId,
    this.lead,
    required this.companyId,
    required this.status,
    this.materials = const [],
    this.materialCount = 0,
    this.submittedAt,
    this.reviewedAt,
    this.reviewedBy,
    this.reviewer,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BatchModel.fromJson(Map<String, dynamic> json) {
    return BatchModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      leadId: json['leadId'] as String,
      lead: json['lead'] != null
          ? BatchLeadInfo.fromJson(json['lead'] as Map<String, dynamic>)
          : null,
      companyId: json['companyId'] as String,
      status: json['status'] as String,
      materials: json['materials'] != null
          ? (json['materials'] as List)
              .map((m) => MaterialModel.fromJson(m as Map<String, dynamic>))
              .toList()
          : [],
      materialCount: json['_count']?['materials'] ?? json['materials']?.length ?? 0,
      submittedAt: json['submittedAt'] != null
          ? DateTime.parse(json['submittedAt'] as String)
          : null,
      reviewedAt: json['reviewedAt'] != null
          ? DateTime.parse(json['reviewedAt'] as String)
          : null,
      reviewedBy: json['reviewedBy'] as String?,
      reviewer: json['reviewer'] != null
          ? UserInfo.fromJson(json['reviewer'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (description != null) 'description': description,
      'leadId': leadId,
      if (lead != null) 'lead': lead!.toJson(),
      'companyId': companyId,
      'status': status,
      'materials': materials.map((m) => m.toJson()).toList(),
      '_count': {'materials': materialCount},
      if (submittedAt != null) 'submittedAt': submittedAt!.toIso8601String(),
      if (reviewedAt != null) 'reviewedAt': reviewedAt!.toIso8601String(),
      if (reviewedBy != null) 'reviewedBy': reviewedBy,
      if (reviewer != null) 'reviewer': reviewer!.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Helper methods for status checking
  bool get isDraft => status == 'DRAFT';
  bool get isSubmitted => status == 'SUBMITTED';
  bool get isApproved => status == 'APPROVED';
  bool get isRejected => status == 'REJECTED';

  String get statusDisplayName {
    switch (status) {
      case 'DRAFT':
        return 'Draft';
      case 'SUBMITTED':
        return 'Pending Admin Approval';
      case 'APPROVED':
        return 'Approved';
      case 'REJECTED':
        return 'Rejected';
      default:
        return 'Unknown';
    }
  }

  // Calculate total quantity across all materials
  double get totalQuantity {
    return materials.fold(0.0, (sum, material) => sum + material.quantity);
  }

  // Calculate total price if available
  double? get totalPrice {
    if (materials.any((m) => m.price == null)) return null;
    return materials.fold<double>(0.0, (sum, material) => sum + (material.price ?? 0));
  }
}

