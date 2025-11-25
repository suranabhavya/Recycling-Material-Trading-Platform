import '../../../hierarchy/data/models/role_template_model.dart';
import '../../../hierarchy/data/models/organizational_unit_model.dart';

class CompanyModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? address;
  final String type;
  final String hierarchyMode;
  final List<RoleTemplateModel>? roleTemplates;
  final List<OrganizationalUnitModel>? orgUnits;

  CompanyModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    required this.type,
    required this.hierarchyMode,
    this.roleTemplates,
    this.orgUnits,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      type: json['type'] as String? ?? '',
      hierarchyMode: json['hierarchyMode'] as String? ?? 'SIMPLE',
      roleTemplates: json['roleTemplates'] != null
          ? (json['roleTemplates'] as List)
              .map((e) => RoleTemplateModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      orgUnits: json['orgUnits'] != null
          ? (json['orgUnits'] as List)
              .map((e) => OrganizationalUnitModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      'type': type,
      'hierarchyMode': hierarchyMode,
      if (roleTemplates != null) 'roleTemplates': roleTemplates!.map((e) => e.toJson()).toList(),
      if (orgUnits != null) 'orgUnits': orgUnits!.map((e) => e.toJson()).toList(),
    };
  }

  bool get isSimpleHierarchy => hierarchyMode == 'SIMPLE';
  bool get isAdvancedHierarchy => hierarchyMode == 'ADVANCED';
}

