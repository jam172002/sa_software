class Invoice {
  final String id;
  String number;
  String status; // draft | final
  String? customerId;
  double subtotal;
  double discount;
  double tax;
  double total;
  String? note;
  int rev;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime? deletedAt;
  Invoice({
    required this.id,
    required this.number,
    this.status = 'draft',
    this.customerId,
    this.subtotal = 0,
    this.discount = 0,
    this.tax = 0,
    this.total = 0,
    this.note,
    this.rev = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.deletedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'number': number,
    'status': status,
    'customerId': customerId,
    'subtotal': subtotal,
    'discount': discount,
    'tax': tax,
    'total': total,
    'note': note,
    'rev': rev,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'deletedAt': deletedAt?.toIso8601String(),
  };

  static Invoice fromJson(Map<String, dynamic> m) => Invoice(
    id: m['id'],
    number: m['number'],
    status: m['status'],
    customerId: m['customerId'],
    subtotal: (m['subtotal'] as num).toDouble(),
    discount: (m['discount'] as num).toDouble(),
    tax: (m['tax'] as num).toDouble(),
    total: (m['total'] as num).toDouble(),
    note: m['note'],
    rev: m['rev'] ?? 0,
    createdAt: DateTime.parse(m['createdAt']),
    updatedAt: DateTime.parse(m['updatedAt']),
    deletedAt: m['deletedAt'] != null ? DateTime.parse(m['deletedAt']) : null,
  );
}
