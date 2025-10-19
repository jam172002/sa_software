import 'dart:convert';
import 'package:csv/csv.dart';

import '../../core/utils/id.dart';
import '../../data/local/db.dart';
import '../../domain/models/product.dart';

/// Basic CSV import with a provided header map: appField -> csvHeader
class ImportService {
  final AppDatabase db;
  ImportService(this.db);

  Future<int> importProductsCSV(String csv, Map<String, String> headerMap) async {
    final rows =
    const CsvToListConverter(eol: '\n', shouldParseNumbers: false).convert(csv);
    if (rows.isEmpty) return 0;

    final headers = rows.first.map((e) => e.toString().trim()).toList();
    final idx = {for (var i = 0; i < headers.length; i++) headers[i]: i};

    var count = 0;
    for (var r = 1; r < rows.length; r++) {
      final row = rows[r];
      String getField(String field, [String def = '']) {
        final h = headerMap[field];
        if (h == null) return def;
        final i = idx[h];
        if (i == null || i >= row.length) return def;
        return row[i].toString();
      }

      final p = Product(
        id: Id.ulid(),
        name: getField('name'),
        sku: getField('sku'),
        barcode: getField('barcode').isEmpty ? null : getField('barcode'),
        price: double.tryParse(getField('price', '0')) ?? 0,
      );

      await db.upsertProduct(p);
      await db.enqueue('products', 'upsert', jsonEncode(p.toJson()));
      count++;
    }
    return count;
  }
}
