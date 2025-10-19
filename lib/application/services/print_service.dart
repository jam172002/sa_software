import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../domain/models/invoice.dart';
import '../../domain/models/invoice_item.dart';

class PrintService {
  Future<Uint8List> buildReceipt(
      Invoice inv,
      List<InvoiceItem> items, {
        String? storeName,
        String? address,
      }) async {
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat:
        PdfPageFormat(80 * PdfPageFormat.mm, double.infinity, marginAll: 5),
        build: (_) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (storeName != null)
                pw.Text(storeName,
                    style: pw.TextStyle(
                        fontSize: 12, fontWeight: pw.FontWeight.bold)),
              if (address != null)
                pw.Text(address, style: const pw.TextStyle(fontSize: 9)),
              pw.SizedBox(height: 6),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Inv: ${inv.number}',
                      style: const pw.TextStyle(fontSize: 9)),
                  pw.Text(
                    DateFormat('yyyy-MM-dd HH:mm').format(inv.createdAt),
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ],
              ),
              pw.SizedBox(height: 6),
              ...items.map(
                    (it) => pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                        child: pw.Text(it.nameSnapshot,
                            style: const pw.TextStyle(fontSize: 9))),
                    pw.Text('${it.qty} x ${it.unitPrice.toStringAsFixed(0)}',
                        style: const pw.TextStyle(fontSize: 9)),
                    pw.Text(it.lineTotal.toStringAsFixed(0),
                        style: const pw.TextStyle(fontSize: 9)),
                  ],
                ),
              ),
              pw.Divider(),
              _kv('Subtotal', inv.subtotal),
              _kv('Discount', -inv.discount),
              _kv('Tax', inv.tax),
              _kv('Total', inv.total, big: true),
              pw.SizedBox(height: 8),
              pw.Text('Thank you for shopping!'),
            ],
          );
        },
      ),
    );
    return doc.save();
  }

  pw.Widget _kv(String k, num v, {bool big = false}) => pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      pw.Text(k,
          style: pw.TextStyle(
              fontSize: big ? 11 : 9,
              fontWeight: big ? pw.FontWeight.bold : null)),
      pw.Text(v.toStringAsFixed(0),
          style: pw.TextStyle(
              fontSize: big ? 11 : 9,
              fontWeight: big ? pw.FontWeight.bold : null)),
    ],
  );
}
