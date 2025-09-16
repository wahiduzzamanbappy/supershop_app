// ──────────────────────────────────────────────────────────────────────────────
/* Narrow layout: Card list with badge */
// ──────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:supershop_app/ui/widgets/product_data_table.dart';

import '../../model/product_model.dart';

class ProductCardList extends StatelessWidget {
  const ProductCardList({super.key,
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
    if (products.isEmpty) {
      return const Center(child: Text('No products match your filters'));
    }

    return ListView.separated(
      itemCount: products.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final p = products[i];
        final lowStock = p.stock <= lowStockThreshold;

        return Material(
          color: lowStock
              ? Colors.orange.withOpacity(.06)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => onEdit(p),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Leading: name + chips
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                p.name,
                                style: Theme.of(context).textTheme.titleMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (lowStock) const LowBadge(text: 'LOW'),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            InfoChip(icon: Icons.category_outlined, text: p.category),
                            InfoChip(
                              icon: Icons.attach_money,
                              text: '৳${p.price.toStringAsFixed(0)}',
                            ),
                            InfoChip(
                              icon: Icons.inventory_2_outlined,
                              text: 'Stock: ${p.stock}',
                            ),
                            if ((p.sku ?? '').isNotEmpty)
                              InfoChip(
                                icon: Icons.confirmation_number_outlined,
                                text: p.sku!,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Actions
                  Row(
                    mainAxisSize: MainAxisSize.min,
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
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class InfoChip extends StatelessWidget {
  const InfoChip({super.key, required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.surfaceVariant.withOpacity(.6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}