import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../application/providers/product_provider.dart';
import '../../../domain/models/product.dart';
import '../../../core/utils/id.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pp = context.watch<ProductProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      floatingActionButton:
      FloatingActionButton(onPressed: () => _edit(context), child: const Icon(Icons.add)),
      body: Card(
        margin: const EdgeInsets.all(12),
        child: ListView(children: [
          DataTable(
            columns: const [
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('SKU')),
              DataColumn(label: Text('Price')),
            ],
            rows: [
              for (final p in pp.products)
                DataRow(cells: [
                  DataCell(Text(p.name), onTap: () => _edit(context, p: p)),
                  DataCell(Text(p.sku), onTap: () => _edit(context, p: p)),
                  DataCell(Text(p.price.toStringAsFixed(0)), onTap: () => _edit(context, p: p)),
                ]),
            ],
          ),
        ]),
      ),
    );
  }

  Future<void> _edit(BuildContext context, {Product? p}) async {
    final name = TextEditingController(text: p?.name);
    final sku = TextEditingController(text: p?.sku);
    final price = TextEditingController(text: p?.price.toString());
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(p == null ? 'New Product' : 'Edit Product'),
        content: SizedBox(
          width: 420,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')),
            const SizedBox(height: 8),
            TextField(controller: sku, decoration: const InputDecoration(labelText: 'SKU')),
            const SizedBox(height: 8),
            TextField(
              controller: price,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
        ],
      ),
    );
    if (ok != true) return;

    final db = context.read<ProductProvider>().db;
    final model = Product(
      id: p?.id ?? Id.ulid(),
      name: name.text.trim(),
      sku: sku.text.trim(),
      price: double.tryParse(price.text) ?? 0,
      rev: (p?.rev ?? 0) + 1,
      createdAt: p?.createdAt,
      updatedAt: DateTime.now(),
    );
    await db.upsertProduct(model);
    await context.read<ProductProvider>().refresh();
  }
}
