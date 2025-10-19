import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../application/providers/customer_provider.dart';

class CustomersScreen extends StatelessWidget {
  const CustomersScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final cp = context.watch<CustomerProvider>();
    final name = TextEditingController();
    return Scaffold(
      appBar: AppBar(title: const Text('Customers')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(children: [
            Expanded(child: TextField(controller: name, decoration: const InputDecoration(labelText: 'Quick add by name'))),
            const SizedBox(width: 8),
            FilledButton(onPressed: () => cp.addQuick(name.text), child: const Text('Add')),
          ]),
        ),
        Expanded(
          child: Card(
            margin: const EdgeInsets.all(8),
            child: ListView(children: [
              DataTable(
                columns: const [
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Phone')),
                ],
                rows: [
                  for (final c in cp.customers)
                    DataRow(cells: [
                      DataCell(Text(c.name)),
                      DataCell(Text(c.phone ?? '-')),
                    ]),
                ],
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}
