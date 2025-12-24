class OrgUnitModel {
  final String? id;
  final String? companyId;
  final String name;
  final String? parentId;
  final Map<String, dynamic>? metadata;
  final List<OrgUnitModel> children;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // For UI state management
  final bool isExpanded;
  final String tempId; // Temporary ID for frontend before backend creation

  OrgUnitModel({
    this.id,
    this.companyId,
    required this.name,
    this.parentId,
    this.metadata,
    List<OrgUnitModel>? children,
    this.createdAt,
    this.updatedAt,
    this.isExpanded = false,
    String? tempId,
  })  : children = children ?? [],
        tempId = tempId ?? DateTime.now().millisecondsSinceEpoch.toString();

  factory OrgUnitModel.fromJson(Map<String, dynamic> json) {
    return OrgUnitModel(
      id: json['id'] as String?,
      companyId: json['companyId'] as String?,
      name: json['name'] as String,
      parentId: json['parentId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      children: (json['children'] as List<dynamic>?)
              ?.map((e) => OrgUnitModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
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
      if (parentId != null) 'parentId': parentId,
      if (metadata != null) 'metadata': metadata,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  // For backend submission - converts tree to Prisma nested create format
  static List<Map<String, dynamic>> flattenForBackend(List<OrgUnitModel> orgUnits) {
    // Recursive helper to convert children
    List<Map<String, dynamic>> convertChildren(List<OrgUnitModel> children) {
      return children.map((child) {
        final childData = <String, dynamic>{
          'name': child.name,
          if (child.metadata != null) 'metadata': child.metadata,
        };
        
        // Recursively handle grandchildren
        if (child.children.isNotEmpty) {
          childData['children'] = {
            'create': convertChildren(child.children),
          };
        }
        
        return childData;
      }).toList();
    }
    
    // Convert all root-level units
    return orgUnits.map((unit) {
      final unitData = <String, dynamic>{
        'name': unit.name,
        if (unit.metadata != null) 'metadata': unit.metadata,
      };
      
      if (unit.children.isNotEmpty) {
        unitData['children'] = {
          'create': convertChildren(unit.children),
        };
      }
      
      return unitData;
    }).toList();
  }

  OrgUnitModel copyWith({
    String? id,
    String? companyId,
    String? name,
    String? parentId,
    Map<String, dynamic>? metadata,
    List<OrgUnitModel>? children,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isExpanded,
    String? tempId,
  }) {
    return OrgUnitModel(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      metadata: metadata ?? this.metadata,
      children: children ?? this.children,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isExpanded: isExpanded ?? this.isExpanded,
      tempId: tempId ?? this.tempId,
    );
  }

  // Get depth in tree (for indentation)
  int getDepth() {
    if (parentId == null) return 0;
    return 1; // Will be calculated based on parent reference
  }

  // Check if has children
  bool get hasChildren => children.isNotEmpty;

  // Get total count including children recursively
  int getTotalCount() {
    int count = 1;
    for (var child in children) {
      count += child.getTotalCount();
    }
    return count;
  }
}

