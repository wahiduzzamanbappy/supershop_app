// ──────────────────────────────────────────────────────────────────────────────
// Wide layout: DataTable with Low-stock badge
// ──────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';

import '../../model/product_model.dart';

class ProductDataTable extends StatelessWidget {
  const ProductDataTable({super.key,
    required this.products,
    required this.onEdit,
    required this.onDelete,
    required this.onBarcode,
    required this.lowStockThreshold,
  });

  final List<Product> products;
  final void Function(Product) onEdit;
  final void Function(Product) onDelete;
  final void Function(Product) onBarcode;
  final int lowStockThreshold;

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 900),
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Category')),
              DataColumn(label: Text('Price')),
              DataColumn(label: Text('Stock')),
              DataColumn(label: Text('SKU')),
              DataColumn(label: Text('Actions')),
            ],
            rows: [
              for (final p in products)
                DataRow(
                  color: p.stock <= lowStockThreshold
                      ? MaterialStatePropertyAll(
                    Colors.orange.withOpacity(.08),
                  )
                      : null,
                  cells: [
                    DataCell(Text(p.name)),
                    DataCell(Text(p.category)),
                    DataCell(Text('৳${p.price.toStringAsFixed(0)}')),
                    DataCell(Row(
                      children: [
                        Text('${p.stock}'),
                        if (p.stock <= lowStockThreshold) ...[
                          const SizedBox(width: 6),
                          const LowBadge(text: 'LOW'),
                        ],
                      ],
                    )),
                    DataCell(Text(p.sku ?? '-')),
                    DataCell(Row(
                      children: [
                        IconButton(
                          tooltip: 'Edit',
                          onPressed: () => onEdit(p),
                          icon: const Icon(Icons.edit_outlined),
                        ),
                        IconButton(
                          tooltip: 'Delete',
                          onPressed: () => onDelete(p),
                          icon: const Icon(Icons.delete_outline),
                        ),
                        IconButton(
                          tooltip: 'Generate Barcode',
                          onPressed: () => onBarcode(p),
                          icon: const Icon(Icons.qr_code_2_outlined),
                        ),
                      ],
                    )),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class LowBadge extends StatelessWidget {
  const LowBadge({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.red.withOpacity(.35)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: scheme.error,
          fontWeight: FontWeight.w700,
          fontSize: 11,
          letterSpacing: .5,
        ),
      ),
    );
  }
}