import 'package:recycling_platform/features/company/data/models/lead_model.dart';
import 'package:recycling_platform/features/company/data/models/team_member_model.dart';

class AdminModel {
  final String id;
  final String name;
  final String email;

  AdminModel({
    required this.id,
    required this.name,
    required this.email,
  });

  factory AdminModel.fromJson(Map<String, dynamic> json) {
    return AdminModel(
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

class CompanyHierarchyModel {
  final List<AdminModel> admins;
  final List<LeadModel> leads;
  final List<TeamMemberModel> unassignedMembers;

  CompanyHierarchyModel({
    required this.admins,
    required this.leads,
    required this.unassignedMembers,
  });

  factory CompanyHierarchyModel.fromJson(Map<String, dynamic> json) {
    return CompanyHierarchyModel(
      admins: (json['admins'] as List)
          .map((a) => AdminModel.fromJson(a))
          .toList(),
      leads: (json['leads'] as List)
          .map((l) => LeadModel.fromJson(l))
          .toList(),
      unassignedMembers: (json['unassignedMembers'] as List)
          .map((m) => TeamMemberModel.fromJson(m))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'admins': admins.map((a) => a.toJson()).toList(),
      'leads': leads.map((l) => l.toJson()).toList(),
      'unassignedMembers': unassignedMembers.map((m) => m.toJson()).toList(),
    };
  }
}

