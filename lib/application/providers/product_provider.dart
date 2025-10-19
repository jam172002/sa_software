import 'package:flutter/foundation.dart';
import '../../data/local/db.dart';
import '../../domain/models/product.dart';
import '../../core/utils/id.dart';

class ProductProvider extends ChangeNotifier {
  final AppDatabase db;
  ProductProvider(this.db) {
    refresh();
  }

  List<Product> products = [];
  String query = '';

  Future<void> refresh() async {
    products = await db.getAllProducts();
    notifyListeners();
  }

  List<Product> get filtered {
    if (query.isEmpty) return products;
    final q = query.toLowerCase();
    return products
        .where((p) => p.name.toLowerCase().contains(q) || p.sku.toLowerCase().contains(q))
        .toList();
  }

  Future<void> addSample() async {
    final p = Product(id: Id.ulid(), name: 'Plug Wrench', sku: 'SMJ-001', price: 450);
    await db.upsertProduct(p);
    await refresh();
  }
}
