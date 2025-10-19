class Customer {
  final String id;
  String name;
  String? phone;
  String? email;
  String? address;
  int rev;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime? deletedAt;
  Customer({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.address,
    this.rev = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.deletedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'email': email,
    'address': address,
    'rev': rev,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'deletedAt': deletedAt?.toIso8601String(),
  };

  static Customer fromJson(Map<String, dynamic> m) => Customer(
    id: m['id'],
    name: m['name'],
    phone: m['phone'],
    email: m['email'],
    address: m['address'],
    rev: m['rev'] ?? 0,
    createdAt: DateTime.parse(m['createdAt']),
    updatedAt: DateTime.parse(m['updatedAt']),
    deletedAt: m['deletedAt'] != null ? DateTime.parse(m['deletedAt']) : null,
  );
}
