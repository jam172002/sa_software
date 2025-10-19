import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'routes.dart';
import 'theme/app_theme.dart';
import 'application/providers/auth_provider.dart';

import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/dashboard/dashboard_screen.dart';
import 'presentation/screens/products/products_screen.dart';
import 'presentation/screens/customers/customers_screen.dart';
import 'presentation/screens/settings/settings_screen.dart';

class ShahidAutosPOSApp extends StatefulWidget {
  const ShahidAutosPOSApp({super.key});

  @override
  State<ShahidAutosPOSApp> createState() => _ShahidAutosPOSAppState();
}

class _ShahidAutosPOSAppState extends State<ShahidAutosPOSApp> {
  late final GoRouter _router;
  late final AuthRouterListenable _refresh;

  @override
  void initState() {
    super.initState();
    _refresh = AuthRouterListenable();
    _router = GoRouter(
      initialLocation: Routes.login,
      routes: [
        GoRoute(path: Routes.login, name: Routes.loginName, builder: (_, __) => const LoginScreen()),
        GoRoute(path: Routes.dashboard, name: Routes.dashboardName, builder: (_, __) => const DashboardScreen()),
        GoRoute(path: Routes.products, name: Routes.productsName, builder: (_, __) => const ProductsScreen()),
        GoRoute(path: Routes.customers, name: Routes.customersName, builder: (_, __) => const CustomersScreen()),
        GoRoute(path: Routes.settings, name: Routes.settingsName, builder: (_, __) => const SettingsScreen()),
      ],
      redirect: (context, state) {
        final authed = context.read<AuthProvider>().isAuthenticated;
        final loggingIn = state.matchedLocation == Routes.login;
        if (!authed && !loggingIn) return Routes.login;
        if (authed && loggingIn) return Routes.dashboard;
        return null;
      },
      refreshListenable: _refresh,
    );
  }

  @override
  void dispose() {
    _refresh.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Shahid Autos POS',
      theme: buildAppTheme(),
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Listenable that pings GoRouter whenever Auth state changes.
class AuthRouterListenable extends ChangeNotifier {
  late final StreamSubscription<void> _sub;
  AuthRouterListenable() {
    _sub = AuthProvider.stream.listen((_) => notifyListeners());
  }
  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
