import 'dart:io';
import 'package:drift/drift.dart';
import 'connection/connection.dart' show openAppDatabase;

import '../../domain/models/product.dart' as domain;  // alias to avoid confusion
import '../../domain/models/customer.dart' as domain;
import '../../domain/models/invoice.dart' as domain;
import '../../domain/models/invoice_item.dart' as domain;
import '../../core/utils/id.dart';

part 'db.g.dart';

// ------------------ Tables ------------------
// NOTE: @DataClassName prevents Drift from generating names that collide
// with your domain models (Product, Customer, Invoice, ...).

@DataClassName('ProductsData')
class Products extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get sku => text()();
  TextColumn get barcode => text().nullable()();
  RealColumn get price => real()();
  RealColumn get cost => real().nullable()();
  TextColumn get categoryId => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get rev => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('CustomersData')
class Customers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get address => text().nullable()();
  IntColumn get rev => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('InvoicesData')
class Invoices extends Table {
  TextColumn get id => text()();
  TextColumn get number => text()();
  TextColumn get status => text()(); // draft | final
  TextColumn get customerId => text().nullable()();
  RealColumn get subtotal => real().withDefault(const Constant(0))();
  RealColumn get discount => real().withDefault(const Constant(0))();
  RealColumn get tax => real().withDefault(const Constant(0))();
  RealColumn get total => real().withDefault(const Constant(0))();
  TextColumn get note => text().nullable()();
  IntColumn get rev => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('InvoiceItemsData')
class InvoiceItems extends Table {
  TextColumn get id => text()();
  TextColumn get invoiceId => text()();
  TextColumn get productId => text().nullable()();
  TextColumn get nameSnapshot => text()();
  TextColumn get skuSnapshot => text().nullable()();
  RealColumn get unitPrice => real()();
  IntColumn get qty => integer()();
  RealColumn get lineTotal => real()();
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SyncQueueData')
class SyncQueue extends Table {
  TextColumn get id => text()();
  TextColumn get entity => text()(); // products/customers/invoices/invoiceItems
  TextColumn get op => text()(); // upsert/delete
  TextColumn get payload => text()(); // json
  DateTimeColumn get ts => dateTime()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('KVsData')
class KVs extends Table {
  TextColumn get k => text()();
  TextColumn get v => text()();
  @override
  Set<Column> get primaryKey => {k};
}

// ------------------ Database ------------------
@DriftDatabase(tables: [Products, Customers, Invoices, InvoiceItems, SyncQueue, KVs])
class AppDatabase extends _$AppDatabase {
  AppDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;

  static Future<AppDatabase> create() async {
    final executor = await openAppDatabase();   // <-- platform-specific
    return AppDatabase(executor);
  }

  // -------- Products DAO --------
  Future<List<domain.Product>> getAllProducts() async {
    final rows = await (select(products)..where((p) => p.deletedAt.isNull())).get();
    return rows.map(_toProduct).toList();
  }

  Future<void> upsertProduct(domain.Product p) async {
    await into(products).insertOnConflictUpdate(_fromProduct(p));
  }

  Future<void> deleteProductHard(String id) async {
    await (delete(products)..where((t) => t.id.equals(id))).go();
  }

  // -------- Customers DAO --------
  Future<List<domain.Customer>> getAllCustomers() async {
    final rows = await (select(customers)..where((p) => p.deletedAt.isNull())).get();
    return rows.map(_toCustomer).toList();
  }

  Future<void> upsertCustomer(domain.Customer c) async {
    await into(customers).insertOnConflictUpdate(_fromCustomer(c));
  }

  // -------- Invoices DAO --------
  Future<void> upsertInvoice(domain.Invoice i, List<domain.InvoiceItem> items) async {
    await transaction(() async {
      await into(invoices).insertOnConflictUpdate(_fromInvoice(i));
      await (delete(invoiceItems)..where((t) => t.invoiceId.equals(i.id))).go();
      for (final it in items) {
        await into(invoiceItems).insertOnConflictUpdate(_fromInvoiceItem(it));
      }
    });
  }

  Future<(domain.Invoice, List<domain.InvoiceItem>)?> loadInvoice(String id) async {
    final row = await (select(invoices)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) return null;
    final items = await (select(invoiceItems)..where((t) => t.invoiceId.equals(id))).get();
    return (_toInvoice(row), items.map(_toInvoiceItem).toList());
  }

  // -------- Sync Queue --------
  Future<void> enqueue(String entity, String op, String payload) async {
    await into(syncQueue).insert(SyncQueueCompanion.insert(
      id: Id.ulid(),
      entity: entity,
      op: op,
      payload: payload,
      ts: DateTime.now(),
    ));
  }

  Future<List<SyncQueueData>> dequeueBatch(int n) => (select(syncQueue)
    ..orderBy([(t) => OrderingTerm.asc(t.ts)])
    ..limit(n))
      .get();

  Future<void> removeQueueIds(List<String> ids) async {
    await (delete(syncQueue)..where((t) => t.id.isIn(ids))).go();
  }

  // -------- Mappers (DB <-> Domain) --------
  domain.Product _toProduct(ProductsData r) => domain.Product(
    id: r.id,
    name: r.name,
    sku: r.sku,
    barcode: r.barcode,
    price: r.price,
    cost: r.cost,
    categoryId: r.categoryId,
    isActive: r.isActive,
    rev: r.rev,
    createdAt: r.createdAt,
    updatedAt: r.updatedAt,
    deletedAt: r.deletedAt,
  );

  ProductsCompanion _fromProduct(domain.Product p) => ProductsCompanion.insert(
    id: p.id,
    name: p.name,
    sku: p.sku,
    barcode: Value(p.barcode),
    price: p.price,
    cost: Value(p.cost),
    categoryId: Value(p.categoryId),
    isActive: Value(p.isActive),
    rev: Value(p.rev),
    createdAt: p.createdAt,
    updatedAt: p.updatedAt,
    deletedAt: Value(p.deletedAt),
  );

  domain.Customer _toCustomer(CustomersData r) => domain.Customer(
    id: r.id,
    name: r.name,
    phone: r.phone,
    email: r.email,
    address: r.address,
    rev: r.rev,
    createdAt: r.createdAt,
    updatedAt: r.updatedAt,
    deletedAt: r.deletedAt,
  );

  CustomersCompanion _fromCustomer(domain.Customer c) => CustomersCompanion.insert(
    id: c.id,
    name: c.name,
    phone: Value(c.phone),
    email: Value(c.email),
    address: Value(c.address),
    rev: Value(c.rev),
    createdAt: c.createdAt,
    updatedAt: c.updatedAt,
    deletedAt: Value(c.deletedAt),
  );

  domain.Invoice _toInvoice(InvoicesData r) => domain.Invoice(
    id: r.id,
    number: r.number,
    status: r.status,
    customerId: r.customerId,
    subtotal: r.subtotal,
    discount: r.discount,
    tax: r.tax,
    total: r.total,
    note: r.note,
    rev: r.rev,
    createdAt: r.createdAt,
    updatedAt: r.updatedAt,
    deletedAt: r.deletedAt,
  );

  InvoicesCompanion _fromInvoice(domain.Invoice i) => InvoicesCompanion.insert(
    id: i.id,
    number: i.number,
    status: i.status,
    customerId: Value(i.customerId),
    subtotal: Value(i.subtotal),
    discount: Value(i.discount),
    tax: Value(i.tax),
    total: Value(i.total),
    note: Value(i.note),
    rev: Value(i.rev),
    createdAt: i.createdAt,
    updatedAt: i.updatedAt,
    deletedAt: Value(i.deletedAt),
  );


  domain.InvoiceItem _toInvoiceItem(InvoiceItemsData r) => domain.InvoiceItem(
    id: r.id,
    invoiceId: r.invoiceId,
    productId: r.productId,
    nameSnapshot: r.nameSnapshot,
    skuSnapshot: r.skuSnapshot,
    unitPrice: r.unitPrice,
    qty: r.qty,
  );

  InvoiceItemsCompanion _fromInvoiceItem(domain.InvoiceItem it) => InvoiceItemsCompanion.insert(
    id: it.id,
    invoiceId: it.invoiceId,
    productId: Value(it.productId),
    nameSnapshot: it.nameSnapshot,
    skuSnapshot: Value(it.skuSnapshot),
    unitPrice: it.unitPrice,
    qty: it.qty,
    lineTotal: it.lineTotal,
  );
}
