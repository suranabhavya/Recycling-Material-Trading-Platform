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
  final DateTime? createdAt;
  final DateTime? updatedAt;

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
    this.createdAt,
    this.updatedAt,
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
      'name': name,
      if (description != null) 'description': description,
      'quantity': quantity,
      'unit': unit,
      if (price != null) 'price': price,
      'images': images,
      if (status != null) 'status': status,
      if (userId != null) 'userId': userId,
      if (companyId != null) 'companyId': companyId,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
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
    DateTime? createdAt,
    DateTime? updatedAt,
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

