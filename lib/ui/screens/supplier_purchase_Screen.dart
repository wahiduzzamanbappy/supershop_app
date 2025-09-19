// ─────────────────────────────────────────────────────────────────────────────
// SUPPLIER / PURCHASE
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../model/product_model.dart';
import '../../store/ui/data/store_data.dart';

class SupplierPurchaseScreen extends StatefulWidget {
  const SupplierPurchaseScreen({super.key});

  @override State<SupplierPurchaseScreen> createState() =>
      _SupplierPurchaseScreenState();
}

class _SupplierPurchaseScreenState extends State<SupplierPurchaseScreen> {
  Supplier? selected;
  final List<PurchaseItem> draft = [];
  final qtyCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  Product? selectedProduct;

  @override
  Widget build(BuildContext context) {
    final total = draft.fold(0.0, (p, e) => p + e.lineTotal);
    return Padding(padding: const EdgeInsets.all(16), child: Row(children: [
      Expanded(flex: 3,
          child: Card(child: Padding(padding: const EdgeInsets.all(12),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Create Purchase Order',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: DropdownButtonFormField<Supplier>(
                      decoration: const InputDecoration(labelText: 'Supplier'),
                      value: selected,
                      items: [
                        for(final s in store.suppliers) DropdownMenuItem(
                            value: s, child: Text(s.name))
                      ],
                      onChanged: (v) => setState(() => selected = v))),
                  const SizedBox(width: 12),
                  Expanded(child: DropdownButtonFormField<Product>(
                      decoration: const InputDecoration(labelText: 'Product'),
                      value: selectedProduct,
                      items: [
                        for(final p in store.products) DropdownMenuItem(
                            value: p, child: Text(p.name))
                      ],
                      onChanged: (v) => setState(() => selectedProduct = v))),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: TextField(controller: qtyCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Qty'))),
                  const SizedBox(width: 8),
                  Expanded(child: TextField(controller: priceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Unit Cost (৳)'))),
                  const SizedBox(width: 8),
                  FilledButton.icon(onPressed: _addLine,
                      icon: const Icon(Icons.add),
                      label: const Text('Add')),
                ]),
                const SizedBox(height: 12),
                Expanded(child: SingleChildScrollView(
                    child: DataTable(columns: const [
                      DataColumn(label: Text('Item')),
                      DataColumn(label: Text('Qty')),
                      DataColumn(label: Text('Unit Cost')),
                      DataColumn(label: Text('Line Total')),
                      DataColumn(label: Text('')),
                    ], rows: [for(final it in draft) DataRow(cells: [
                      DataCell(Text(it.product.name)),
                      DataCell(Text('${it.qty}')),
                      DataCell(Text('৳${it.unitCost.toStringAsFixed(0)}')),
                      DataCell(Text('৳${it.lineTotal.toStringAsFixed(0)}')),
                      DataCell(IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () {
                            setState(() => draft.remove(it));
                          })),
                    ])
                    ]))),
              ])))), const SizedBox(width: 16),
      Expanded(child: Card(child: Padding(padding: const EdgeInsets.all(12),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const Text(
                'Summary', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total'),
                  Text('৳${total.toStringAsFixed(0)}')
                ]),
            const Spacer(),
            FilledButton.icon(
                onPressed: selected == null || draft.isEmpty ? null : _submit,
                icon: const Icon(Icons.save_outlined),
                label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Create Purchase'))),
          ]))))
    ]));
  }

  void _addLine() {
    final q = int.tryParse(qtyCtrl.text) ?? 0;
    final uc = double.tryParse(priceCtrl.text) ?? -1;
    if (selectedProduct == null || q <= 0 || uc < 0) return;
    setState(() => draft.add(
        PurchaseItem(product: selectedProduct!, qty: q, unitCost: uc)));
    qtyCtrl.clear();
    priceCtrl.clear();
  }

  void _submit() {
    final po = PurchaseOrder(id: 'PO-${DateTime
        .now()
        .millisecondsSinceEpoch}',
        supplier: selected!,
        items: List.of(draft),
        date: DateTime.now());
    store.createPurchase(po);
    setState(() => draft.clear());
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Purchase created & stock updated.')));
  }
}
