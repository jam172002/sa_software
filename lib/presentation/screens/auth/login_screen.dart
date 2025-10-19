import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Image.asset('assets/logo.png', height: 64, errorBuilder: (_, __, ___) => const SizedBox(height: 64)),
                const SizedBox(height: 12),
                TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
                const SizedBox(height: 8),
                TextField(controller: _pass, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _busy
                      ? null
                      : () async {
                    setState(() => _busy = true);
                    await Future.delayed(const Duration(milliseconds: 300));
                    if (context.mounted) context.goNamed(Routes.dashboardName);
                  },
                  child: const Text('Continue'),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
