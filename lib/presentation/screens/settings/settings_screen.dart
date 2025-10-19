import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../application/providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SettingsProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(children: [
        SwitchListTile(
          value: sp.clearAfterPrint,
          title: const Text('Clear invoice after printing'),
          onChanged: sp.toggleClearAfterPrint,
        ),
      ]),
    );
  }
}
