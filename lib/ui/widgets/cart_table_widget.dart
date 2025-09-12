/*
import 'package:flutter/material.dart';
import '../../store/ui/data/store_data.dart';

class CartTable extends StatefulWidget {
  const CartTable({super.key, required this.onChanged});

  final VoidCallback onChanged;

  @override
  State<CartTable> createState() => _CartTableState();
}

class _CartTableState extends State<CartTable> {
  @override
  Widget build(BuildContext context) {
    if (store.cart.isEmpty) {
      return const Center(
        child: Text('Cart is empty'),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(Colors.grey.shade200),
        columns: const [
          DataColumn(label: Text('Item')),
          DataColumn(label: Text('Qty')),
          DataColumn(label: Text('Price')),
          DataColumn(label: Text('Subtotal')),
          DataColumn(label: Text('Action')),
        ],
        rows: [
          for (final c in store.cart)
            DataRow(
              cells: [
                // Item Name
                DataCell(
                  SizedBox(
                    width: 120,
                    child: Text(
                      c.product.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),

                // Quantity with buttons
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            c.qty = (c.qty - 1).clamp(1, 999);
                          });
                          widget.onChanged();
                        },
                        icon: const Icon(Icons.remove_circle_outline),
                        visualDensity: VisualDensity.compact,
                      ),
                      SizedBox(
                        width: 36,
                        child: Text(
                          '${c.qty}',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            c.qty += 1;
                          });
                          widget.onChanged();
                        },
                        icon: const Icon(Icons.add_circle_outline),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ),

                // Price
                DataCell(
                  Text('৳${c.product.price.toStringAsFixed(0)}'),
                ),

                // Subtotal
                DataCell(
                  Text('৳${c.subtotal.toStringAsFixed(0)}'),
                ),

                // Delete button
                DataCell(
                  IconButton(
                    onPressed: () {
                      setState(() {
                        store.removeFromCart(c.product);
                      });
                      widget.onChanged();
                    },
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
*/
import 'package:flutter/material.dart';
import '../../store/ui/data/store_data.dart';

class CartTable extends StatefulWidget {
  const CartTable({super.key, required this.onChanged});

  final VoidCallback onChanged;

  @override
  State<CartTable> createState() => _CartTableState();
}

class _CartTableState extends State<CartTable> {
  @override
  Widget build(BuildContext context) {
    if (store.cart.isEmpty) {
      return const Center(
        child: Text('Cart is empty'),
      );
    }

    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal, // ✅ side scroll
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical, // ✅ up-down scroll
          child: DataTable(
            columnSpacing: 20, // ✅ একটু gap বাড়ানো হলো
            headingRowColor: WidgetStateProperty.all(Colors.grey.shade200),
            columns: const [
              DataColumn(label: Text('SL')),
              DataColumn(label: Text('Item')),
              DataColumn(label: Text('Qty')),
              DataColumn(label: Text('Price')),
              DataColumn(label: Text('Subtotal')),
              DataColumn(label: Text('Action')), // ✅ Delete column
            ],
            rows: [
              for (int i = 0; i < store.cart.length; i++)
                DataRow(
                  cells: [
                    // Serial Number
                    DataCell(Text('${i + 1}')),

                    // Item Name
                    DataCell(
                      SizedBox(
                        width: 120,
                        child: Text(
                          store.cart[i].product.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),

                    // Quantity
                    DataCell(
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                store.cart[i].qty =
                                    (store.cart[i].qty - 1).clamp(1, 999);
                              });
                              widget.onChanged();
                            },
                            icon: const Icon(Icons.remove_circle_outline),
                            visualDensity: VisualDensity.compact,
                          ),
                          SizedBox(
                            width: 36,
                            child: Text(
                              '${store.cart[i].qty}',
                              textAlign: TextAlign.center,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                store.cart[i].qty += 1;
                              });
                              widget.onChanged();
                            },
                            icon: const Icon(Icons.add_circle_outline),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                    ),

                    // Price
                    DataCell(
                      Text('৳${store.cart[i].product.price.toStringAsFixed(0)}'),
                    ),

                    // Subtotal
                    DataCell(
                      Text('৳${store.cart[i].subtotal.toStringAsFixed(0)}'),
                    ),

                    // ✅ Delete Button (minimum width set করা হলো)
                    DataCell(
                      SizedBox(
                        width: 60,
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              store.removeFromCart(store.cart[i].product);
                            });
                            widget.onChanged();
                          },
                          icon: const Icon(Icons.delete, color: Colors.red),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

