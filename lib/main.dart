import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// If you used FlutterFire CLI, uncomment the next line and call with options:
// import 'firebase_options.dart';

import 'app.dart';
import 'application/providers/app_provider.dart';
import 'application/providers/auth_provider.dart';
import 'application/providers/product_provider.dart';
import 'application/providers/customer_provider.dart';
import 'application/providers/invoice_provider.dart';
import 'application/providers/settings_provider.dart';
import 'data/local/db.dart';
import 'core/utils/id.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
     options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize per-device ID used for device-scoped ULIDs
  await Id.init();

  final db = await AppDatabase.create();

  runApp(MultiProvider(
    providers: [
      Provider<AppDatabase>.value(value: db),
      ChangeNotifierProvider(create: (_) => AppProvider()),
      ChangeNotifierProvider(create: (_) => AuthProvider()),
      ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ChangeNotifierProvider(create: (_) => ProductProvider(db)),
      ChangeNotifierProvider(create: (_) => CustomerProvider(db)),
      ChangeNotifierProvider(create: (_) => InvoiceProvider(db)),
    ],
    child: const ShahidAutosPOSApp(),
  ));
}
