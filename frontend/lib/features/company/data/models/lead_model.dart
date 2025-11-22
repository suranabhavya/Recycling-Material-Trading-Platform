import 'package:recycling_platform/features/company/data/models/team_member_model.dart';

class LeadModel {
  final String id;
  final String name;
  final String email;
  final int memberCount;
  final List<TeamMemberModel>? teamMembers;

  LeadModel({
    required this.id,
    required this.name,
    required this.email,
    this.memberCount = 0,
    this.teamMembers,
  });

  factory LeadModel.fromJson(Map<String, dynamic> json) {
    return LeadModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      memberCount: json['_count']?['teamMembers'] ?? 0,
      teamMembers: json['teamMembers'] != null
          ? (json['teamMembers'] as List)
              .map((m) => TeamMemberModel.fromJson(m))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      '_count': {'teamMembers': memberCount},
      if (teamMembers != null)
        'teamMembers': teamMembers!.map((m) => m.toJson()).toList(),
    };
  }
}

