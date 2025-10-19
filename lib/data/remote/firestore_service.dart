import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;
  String tenantId;
  FirestoreService(this.tenantId);

  CollectionReference<Map<String, dynamic>> _col(String name) =>
      _db.collection('tenants').doc(tenantId).collection(name);

  Future<void> upsert(String collection, Map<String, dynamic> json) async {
    final id = json['id'] as String;
    json['updatedAt'] = FieldValue.serverTimestamp();
    await _col(collection).doc(id).set(json, SetOptions(merge: true));
  }

  Future<void> delete(String collection, String id) async {
    await _col(collection).doc(id).update({'deletedAt': FieldValue.serverTimestamp()});
  }

  Future<List<Map<String, dynamic>>> since(String collection, DateTime since) async {
    final snap = await _col(collection)
        .where('updatedAt', isGreaterThan: Timestamp.fromDate(since))
        .get();
    return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
  }
}
