class RoleTemplateModel {
  final String? id;
  final String? companyId;
  final String name;
  final int level;
  final Map<String, dynamic> permissions;
  final bool requiresApproval;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  RoleTemplateModel({
    this.id,
    this.companyId,
    required this.name,
    required this.level,
    required this.permissions,
    this.requiresApproval = false,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory RoleTemplateModel.fromJson(Map<String, dynamic> json) {
    return RoleTemplateModel(
      id: json['id'] as String?,
      companyId: json['companyId'] as String?,
      name: json['name'] as String,
      level: json['level'] as int,
      permissions: json['permissions'] as Map<String, dynamic>? ?? {},
      requiresApproval: json['requiresApproval'] as bool? ?? false,
      description: json['description'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (companyId != null) 'companyId': companyId,
      'name': name,
      'level': level,
      'permissions': permissions,
      'requiresApproval': requiresApproval,
      if (description != null) 'description': description,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  RoleTemplateModel copyWith({
    String? id,
    String? companyId,
    String? name,
    int? level,
    Map<String, dynamic>? permissions,
    bool? requiresApproval,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RoleTemplateModel(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      level: level ?? this.level,
      permissions: permissions ?? this.permissions,
      requiresApproval: requiresApproval ?? this.requiresApproval,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isAdmin => level == 1;

  bool hasPermission(String permission) {
    return permissions[permission] == true;
  }
}
