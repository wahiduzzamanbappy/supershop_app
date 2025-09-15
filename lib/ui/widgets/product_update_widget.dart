// ──────────────────────────────────────────────────────────────────────────────
// Product Editor Dialog
// ──────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import '../../model/product_model.dart';

class ProductEditorDialog extends StatefulWidget {
  final Product? product;

  const ProductEditorDialog({super.key, this.product});

  @override
  State<ProductEditorDialog> createState() => _ProductEditorDialogState();
}

class _ProductEditorDialogState extends State<ProductEditorDialog> {
  late final TextEditingController nameCtrl =
  TextEditingController(text: widget.product?.name ?? '');
  late final TextEditingController priceCtrl = TextEditingController(
      text: widget.product != null
          ? widget.product!.price.toStringAsFixed(0)
          : '0');
  late final TextEditingController stockCtrl = TextEditingController(
      text: widget.product != null ? '${widget.product!.stock}' : '0');
  late final TextEditingController skuCtrl =
  TextEditingController(text: widget.product?.sku ?? '');
  String category = 'Grocery';

  @override
  void initState() {
    super.initState();
    category = widget.product?.category ?? 'Grocery';
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    priceCtrl.dispose();
    stockCtrl.dispose();
    skuCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;
    return AlertDialog(
      title: Text(isEdit ? 'Edit Product' : 'Add Product'),
      content: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: nameCtrl,
                    decoration:
                    const InputDecoration(labelText: 'Product Name'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: category,
                    decoration:
                    const InputDecoration(labelText: 'Category'),
                    items: const [
                      DropdownMenuItem(value: 'Grocery', child: Text('Grocery')),
                      DropdownMenuItem(value: 'Dairy', child: Text('Dairy')),
                      DropdownMenuItem(value: 'Poultry', child: Text('Poultry')),
                      DropdownMenuItem(
                          value: 'Cosmetics', child: Text('Cosmetics')),
                      DropdownMenuItem(value: 'Bakery', child: Text('Bakery')),
                      DropdownMenuItem(value: 'Meat', child: Text('Meat')),
                    ],
                    onChanged: (v) =>
                        setState(() => category = v ?? 'Grocery'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: priceCtrl,
                    keyboardType: TextInputType.number,
                    decoration:
                    const InputDecoration(labelText: 'Price (৳)'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: stockCtrl,
                    keyboardType: TextInputType.number,
                    decoration:
                    const InputDecoration(labelText: 'Stock Qty'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: skuCtrl,
                    decoration:
                    const InputDecoration(labelText: 'SKU / Barcode'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Image picker not implemented in demo.')),
                  );
                },
                icon: const Icon(Icons.image_outlined),
                label: const Text('Upload Image'),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _save,
          child: Text(isEdit ? 'Save' : 'Create'),
        ),
      ],
    );
  }

  void _save() {
    final name = nameCtrl.text.trim();
    final price = double.tryParse(priceCtrl.text) ?? -1;
    final stock = int.tryParse(stockCtrl.text) ?? -1;
    if (name.isEmpty || price < 0 || stock < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide valid name, price and stock.')),
      );
      return;
    }
    final id = widget.product?.id ?? UniqueKey().toString();
    final p = Product(
      id: id,
      name: name,
      category: category,
      price: price,
      stock: stock,
      sku: skuCtrl.text.trim().isEmpty ? null : skuCtrl.text.trim(),
    );
    Navigator.pop(context, p);
  }
}