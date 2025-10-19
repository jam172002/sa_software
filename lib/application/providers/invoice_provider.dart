import 'package:flutter/foundation.dart';
import '../../data/local/db.dart';
import '../../domain/models/invoice.dart';
import '../../domain/models/invoice_item.dart';
import '../../domain/models/product.dart';
import '../../core/utils/id.dart';

class InvoiceProvider extends ChangeNotifier {
  final AppDatabase db;
  InvoiceProvider(this.db);

  Invoice? current;
  final List<InvoiceItem> lines = [];

  void startNew() {
    current = Invoice(id: Id.ulid(), number: _nextNumber());
    lines.clear();
    notifyListeners();
  }

  void addProduct(Product p) {
    final idx = lines.indexWhere((l) => l.productId == p.id);
    if (idx >= 0) {
      lines[idx].qty += 1;
      lines[idx].lineTotal = lines[idx].qty * lines[idx].unitPrice;
    } else {
      lines.add(InvoiceItem(
        id: Id.ulid(),
        invoiceId: current!.id,
        productId: p.id,
        nameSnapshot: p.name,
        skuSnapshot: p.sku,
        unitPrice: p.price,
        qty: 1,
      ));
    }
    _recalc();
  }

  void editLine(int i, {String? name, double? price, int? qty}) {
    final l = lines[i];
    if (name != null) l.nameSnapshot = name;
    if (price != null) l.unitPrice = price;
    if (qty != null) l.qty = qty;
    l.lineTotal = l.qty * l.unitPrice;
    _recalc();
  }

  void removeAt(int i) {
    lines.removeAt(i);
    _recalc();
  }

  void _recalc() {
    if (current == null) return;
    final sub = lines.fold<double>(0, (s, l) => s + l.lineTotal);
    current!
      ..subtotal = sub
      ..tax = 0
      ..discount = 0
      ..total = sub
      ..updatedAt = DateTime.now();
    notifyListeners();
  }

  Future<void> saveDraft() async {
    if (current == null) startNew();
    current!.status = 'draft';
    await db.upsertInvoice(current!, lines);
  }

  Future<void> finalize() async {
    current!.status = 'final';
    await db.upsertInvoice(current!, lines);
  }

  String _nextNumber() => DateTime.now().millisecondsSinceEpoch.toString();
}
