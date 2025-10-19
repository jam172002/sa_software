import 'package:flutter/foundation.dart';
import '../../data/local/db.dart';
import '../../domain/models/customer.dart';
import '../../core/utils/id.dart';

class CustomerProvider extends ChangeNotifier {
  final AppDatabase db;
  CustomerProvider(this.db) {
    refresh();
  }

  List<Customer> customers = [];

  Future<void> refresh() async {
    customers = await db.getAllCustomers();
    notifyListeners();
  }

  Future<void> addQuick(String name) async {
    if (name.trim().isEmpty) return;
    final c = Customer(id: Id.ulid(), name: name.trim());
    await db.upsertCustomer(c);
    await refresh();
  }
}
