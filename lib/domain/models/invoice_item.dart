class InvoiceItem {
  final String id;
  String invoiceId;
  String? productId;
  String nameSnapshot;
  String? skuSnapshot;
  double unitPrice;
  int qty;
  double lineTotal;

  InvoiceItem({
    required this.id,
    required this.invoiceId,
    this.productId,
    required this.nameSnapshot,
    this.skuSnapshot,
    required this.unitPrice,
    this.qty = 1,
  }) : lineTotal = unitPrice * qty;

  Map<String, dynamic> toJson() => {
    'id': id,
    'invoiceId': invoiceId,
    'productId': productId,
    'nameSnapshot': nameSnapshot,
    'skuSnapshot': skuSnapshot,
    'unitPrice': unitPrice,
    'qty': qty,
    'lineTotal': lineTotal,
  };

  static InvoiceItem fromJson(Map<String, dynamic> m) => InvoiceItem(
    id: m['id'],
    invoiceId: m['invoiceId'],
    productId: m['productId'],
    nameSnapshot: m['nameSnapshot'],
    skuSnapshot: m['skuSnapshot'],
    unitPrice: (m['unitPrice'] as num).toDouble(),
    qty: (m['qty'] as num).toInt(),
  );
}
