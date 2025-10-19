import 'package:drift/drift.dart';
import 'package:drift/web.dart';

Future<QueryExecutor> openAppDatabase() async {
  // IndexedDB-backed database in the browser
  return WebDatabase('shahid_pos_web');
}
