import 'dart:convert';
import '../domain/models/customer.dart';
import '../data/local/db.dart';

class CustomerRepository {
  final AppDatabase db;
  CustomerRepository(this.db);

  Future<List<Customer>> list() => db.getAllCustomers();

  Future<void> upsert(Customer c, {bool enqueueSync = true}) async {
    await db.upsertCustomer(c);
    if (enqueueSync) {
      await db.enqueue('customers', 'upsert', jsonEncode(c.toJson()));
    }
  }
}
