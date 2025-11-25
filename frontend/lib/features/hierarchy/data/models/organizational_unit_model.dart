class OrganizationalUnitModel {
  final String? id;
  final String? companyId;
  final String name;
  final String? description;
  final String? parentId;
  final List<OrganizationalUnitModel>? children;
  final int? userCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  OrganizationalUnitModel({
    this.id,
    this.companyId,
    required this.name,
    this.description,
    this.parentId,
    this.children,
    this.userCount,
    this.createdAt,
    this.updatedAt,
  });

  factory OrganizationalUnitModel.fromJson(Map<String, dynamic> json) {
    return OrganizationalUnitModel(
      id: json['id'] as String?,
      companyId: json['companyId'] as String?,
      name: json['name'] as String,
      description: json['description'] as String?,
      parentId: json['parentId'] as String?,
      children: json['children'] != null
          ? (json['children'] as List)
              .map((e) => OrganizationalUnitModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      userCount: json['_count']?['users'] as int?,
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
      if (description != null) 'description': description,
      if (parentId != null) 'parentId': parentId,
      if (children != null) 'children': children!.map((e) => e.toJson()).toList(),
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  OrganizationalUnitModel copyWith({
    String? id,
    String? companyId,
    String? name,
    String? description,
    String? parentId,
    List<OrganizationalUnitModel>? children,
    int? userCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrganizationalUnitModel(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      description: description ?? this.description,
      parentId: parentId ?? this.parentId,
      children: children ?? this.children,
      userCount: userCount ?? this.userCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isRoot => parentId == null;
  bool get hasChildren => children != null && children!.isNotEmpty;
}
