import 'dart:convert';
import '../domain/models/invoice.dart';
import '../domain/models/invoice_item.dart';
import '../data/local/db.dart';

class InvoiceRepository {
  final AppDatabase db;
  InvoiceRepository(this.db);

  Future<void> save(Invoice inv, List<InvoiceItem> items, {bool enqueueSync = true}) async {
    await db.upsertInvoice(inv, items);
    if (enqueueSync) {
      await db.enqueue('invoices', 'upsert', jsonEncode(inv.toJson()));
      for (final it in items) {
        await db.enqueue('invoiceItems', 'upsert', jsonEncode(it.toJson()));
      }
    }
  }

  Future<(Invoice, List<InvoiceItem>)?> getById(String id) => db.loadInvoice(id);
}
