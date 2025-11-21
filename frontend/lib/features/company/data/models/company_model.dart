class CompanyModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? address;
  final String type;

  CompanyModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    required this.type,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      type: json['type'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'type': type,
    };
  }
}

