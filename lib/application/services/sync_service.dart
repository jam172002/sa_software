import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../core/utils/logger.dart';
import '../../data/local/db.dart';
import '../../data/remote/firestore_service.dart';
import '../../domain/models/product.dart';
import '../../domain/models/customer.dart';

class SyncService {
  final AppDatabase db;
  final FirestoreService fs;
  bool _busy = false;

  SyncService(this.db, this.fs);

  /// Push local queue to Firestore in small batches.
  Future<void> push() async {
    if (_busy) return;
    _busy = true;
    try {
      while (true) {
        final batch = await db.dequeueBatch(50);
        if (batch.isEmpty) break;
        final ids = <String>[];
        for (final q in batch) {
          try {
            final m = jsonDecode(q.payload) as Map<String, dynamic>;
            if (q.op == 'upsert') {
              await fs.upsert(q.entity, m);
            } else if (q.op == 'delete') {
              await fs.delete(q.entity, m['id'] as String);
            }
            ids.add(q.id);
          } catch (e) {
            Log.e('Sync push error', e);
          }
        }
        if (ids.isNotEmpty) await db.removeQueueIds(ids);
      }
    } finally {
      _busy = false;
    }
  }

  /// Pulls updates since last pull timestamp (kept in KVs).
  Future<void> pull() async {
    final kv = await (db.select(db.kVs)..where((t) => t.k.equals('last_pull')))
        .getSingleOrNull();
    final since = kv == null
        ? DateTime.fromMillisecondsSinceEpoch(0)
        : DateTime.parse(kv.v);
    final now = DateTime.now();
    for (final c in ['products', 'customers']) {
      try {
        final rows = await fs.since(c, since);
        for (final r in rows) {
          if (c == 'products') {
            await db.upsertProduct(Product.fromJson(r));
          } else if (c == 'customers') {
            await db.upsertCustomer(Customer.fromJson(r));
          }
        }
      } catch (e) {
        Log.e('Pull $c failed', e);
      }
    }
    await db.into(db.kVs).insertOnConflictUpdate(
      KVsCompanion.insert(k: 'last_pull', v: now.toIso8601String()),
    );
  }

  /// Call on app start and whenever connectivity indicates online.
  Future<void> autoSync() async {
    final conn = await Connectivity().checkConnectivity();
    if (conn != ConnectivityResult.none) {
      await push();
      await pull();
    }
  }
}
