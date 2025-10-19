import 'dart:convert';
import '../domain/models/product.dart';
import '../data/local/db.dart';

class ProductRepository {
  final AppDatabase db;
  ProductRepository(this.db);

  Future<List<Product>> list() => db.getAllProducts();

  Future<void> upsert(Product p, {bool enqueueSync = true}) async {
    await db.upsertProduct(p);
    if (enqueueSync) {
      await db.enqueue('products', 'upsert', jsonEncode(p.toJson()));
    }
  }

  Future<void> deleteHard(String id) => db.deleteProductHard(id);
}
