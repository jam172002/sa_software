import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../application/providers/product_provider.dart';
import '../../../application/providers/invoice_provider.dart';
import '../../../domain/models/product.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InvoiceProvider>().startNew();
    });
  }

  @override
  Widget build(BuildContext context) {
    final pp = context.watch<ProductProvider>();
    final ip = context.watch<InvoiceProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('POS Dashboard'),
        actions: [
          IconButton(onPressed: pp.addSample, icon: const Icon(Icons.add)),
        ],
      ),
      body: Row(
        children: [
          // Left: Product table
          Expanded(
            flex: 6,
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  onChanged: (v) => setState(() => pp.query = v),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search name or SKU',
                  ),
                ),
              ),
              Expanded(child: _productTable(pp.filtered, (p) => ip.addProduct(p))),
            ]),
          ),
          const VerticalDivider(width: 1),
          // Right: Invoice table
          Expanded(
            flex: 5,
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(children: [
                  Text('Invoice #${ip.current?.number ?? ''}', style: Theme.of(context).textTheme.titleMedium),
                  const Spacer(),
                  FilledButton(onPressed: ip.saveDraft, child: const Text('Save Draft')),
                  const SizedBox(width: 8),
                  FilledButton(onPressed: ip.finalize, child: const Text('Finalize')),
                ]),
              ),
              Expanded(child: _invoiceTable(ip)),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _productTable(List<Product> rows, void Function(Product) onAdd) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('SKU')),
            DataColumn(label: Text('Price')),
            DataColumn(label: Text('Stock')),
          ],
          rows: [
            for (final p in rows)
              DataRow(cells: [
                DataCell(Text(p.name), onTap: () => onAdd(p)),
                DataCell(Text(p.sku), onTap: () => onAdd(p)),
                DataCell(Text(p.price.toStringAsFixed(0)), onTap: () => onAdd(p)),
                const DataCell(Text('-')),
              ]),
          ],
        ),
      ),
    );
  }

  Widget _invoiceTable(InvoiceProvider ip) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: SingleChildScrollView(
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Qty')),
            DataColumn(label: Text('Unit')),
            DataColumn(label: Text('Total')),
            DataColumn(label: Text('')),
          ],
          rows: [
            for (var i = 0; i < ip.lines.length; i++)
              DataRow(cells: [
                DataCell(
                  TextFormField(
                    initialValue: ip.lines[i].nameSnapshot,
                    onChanged: (v) => ip.editLine(i, name: v),
                  ),
                ),
                DataCell(_qtyEditor(ip, i)),
                DataCell(Text(ip.lines[i].unitPrice.toStringAsFixed(0))),
                DataCell(Text(ip.lines[i].lineTotal.toStringAsFixed(0))),
                DataCell(IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => ip.removeAt(i))),
              ]),
          ],
        ),
      ),
    );
  }

  Widget _qtyEditor(InvoiceProvider ip, int i) {
    return Row(children: [
      IconButton(
        icon: const Icon(Icons.remove),
        onPressed: () => ip.editLine(i, qty: (ip.lines[i].qty - 1).clamp(1, 9999)),
      ),
      SizedBox(width: 40, child: Text(ip.lines[i].qty.toString(), textAlign: TextAlign.center)),
      IconButton(
        icon: const Icon(Icons.add),
        onPressed: () => ip.editLine(i, qty: ip.lines[i].qty + 1),
      ),
    ]);
  }
}
