class Product {
  final String id;
  String name;
  String sku;
  String? barcode;
  double price;
  double? cost;
  String? categoryId;
  bool isActive;
  int rev;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime? deletedAt;
  Product({
    required this.id,
    required this.name,
    required this.sku,
    this.barcode,
    required this.price,
    this.cost,
    this.categoryId,
    this.isActive = true,
    this.rev = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.deletedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'sku': sku,
    'barcode': barcode,
    'price': price,
    'cost': cost,
    'categoryId': categoryId,
    'isActive': isActive,
    'rev': rev,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'deletedAt': deletedAt?.toIso8601String(),
  };

  static Product fromJson(Map<String, dynamic> m) => Product(
    id: m['id'],
    name: m['name'],
    sku: m['sku'],
    barcode: m['barcode'],
    price: (m['price'] as num).toDouble(),
    cost: (m['cost'] as num?)?.toDouble(),
    categoryId: m['categoryId'],
    isActive: m['isActive'] ?? true,
    rev: m['rev'] ?? 0,
    createdAt: DateTime.parse(m['createdAt']),
    updatedAt: DateTime.parse(m['updatedAt']),
    deletedAt: m['deletedAt'] != null ? DateTime.parse(m['deletedAt']) : null,
  );
}
