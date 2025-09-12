/*
// ──────────────────────────────────────────────────────────────────────────────
// POS SCREEN (VAT/Tax breakdown + Invoice PDF)
// ──────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../../model/product_model.dart';
import '../../service/invoice_generator_info.dart';
import '../../store/ui/data/store_data.dart';
import '../widgets/cart_table_widget.dart';

class POSScreen extends StatefulWidget {
  const POSScreen({super.key});

  @override
  State<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends State<POSScreen> {
  String query = '';
  String category = 'All';
  final categories = const [
    'All',
    'Grocery',
    'Dairy',
    'Poultry',
    'Cosmetics',
    'Bakery',
    'Meat'
  ];
  final discountCtrl = TextEditingController();
  final vatCtrl = TextEditingController(text: '5');

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(builder: (context, c) {
        final isWide = c.maxWidth > 900;

        // ── LEFT SIDE: PRODUCT GRID ──────────────────────────────────────────────
        final left = Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search products here',
                    ),
                    onChanged: (v) => setState(() => query = v.trim().toLowerCase()),
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: category,
                  onChanged: (v) => setState(() => category = v ?? 'All'),
                  items: categories
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                ),
              ]),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isWide ? 4 : 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.25,
                  ),
                  itemCount: _filtered().length,
                  itemBuilder: (context, i) {
                    final p = _filtered()[i];
                    final low = p.stock <= 5;
                    return Card(
                      child: InkWell(
                        onTap: () => setState(() => store.addToCart(p)),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Spacer(),
                              Icon(Icons.shopping_basket_outlined,
                                  size: 42, color: Colors.grey.shade500),
                              const SizedBox(height: 8),
                              Text(p.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('৳${p.price.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Badge(
                                    label: Text('${p.stock}'),
                                    backgroundColor:
                                    low ? Colors.orange : Colors.green,
                                    child: const Icon(Icons.inventory_2_outlined),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );


        // ── RIGHT SIDE: CART + POS ACTIONS ───────────────────────────────────

        final right = _cartAndPOSSection();

        return isWide
            ? Row(children: [left, const SizedBox(width: 16), right])
            : Column(
          children: [
            Expanded(child: left),
            const SizedBox(height: 16),
            SizedBox(height: 420, child: right),
          ],
        );
      }),
    );
  }

  _cartAndPOSSection() {
    return Expanded(
        flex: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // make this part scrollable to avoid overflow
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Cart & POS',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18)),
                                IconButton(
                                  onPressed: () =>
                                      setState(store.clearCart),
                                  icon: const Icon(Icons.delete_sweep_outlined),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 280),
                              child: CartTable(
                                  onChanged: () => setState(() {})),
                            ),
                            const SizedBox(height: 8),
                            Row(children: [
                              Expanded(
                                child: TextField(
                                  controller: discountCtrl,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    prefixIcon:
                                    Icon(Icons.local_offer_outlined),
                                    labelText: 'Discount (৳)',
                                  ),
                                  onChanged: (v) => setState(() => store
                                      .applyDiscount(double.tryParse(v) ?? 0)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton.icon(
                                onPressed: () => setState(() {
                                  discountCtrl.clear();
                                  store.applyDiscount(0);
                                }),
                                icon: const Icon(Icons.close),
                                label: const Text('Reset'),
                              ),
                            ]),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Subtotal'),
                                Text('৳${store.subTotal.toStringAsFixed(0)}'),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Row(children: [
                                  const Text('VAT '),
                                  SizedBox(
                                    width: 64,
                                    child: TextField(
                                      controller: vatCtrl,
                                      decoration: const InputDecoration(
                                          suffixText: '%', isDense: true),
                                      keyboardType: TextInputType.number,
                                      onChanged: (v) {
                                        final r =
                                            (double.tryParse(v) ?? 5) / 100.0;
                                        setState(() => store.vatRate = r);
                                      },
                                    ),
                                  ),
                                ]),
                                Text('৳${store.vatTk.toStringAsFixed(0)}'),
                              ],
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600)),
                                Text('৳${store.cartTotal.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            FilledButton.icon(
                              onPressed:
                              store.cart.isEmpty ? null : _confirmSale,
                              icon: const Icon(Icons.check_circle_outline),
                              label: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Text('Confirm & Print Invoice'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Quick Actions',
                                style: TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: const [
                                ActionChip(
                                  label: Text('Hold Bill'),
                                  avatar: Icon(Icons.pause_circle_outline),
                                ),
                                ActionChip(
                                  label: Text('Retrieve Bill'),
                                  avatar: Icon(Icons.history),
                                ),
                                ActionChip(
                                  label: Text('Select Customer'),
                                  avatar: Icon(Icons.person_outline),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
  }

  List<Product> _filtered() {
    final q = query;
    return store.products.where((p) {
      final mq = q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          (p.sku ?? '').toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q);
      final mc = category == 'All' || p.category == category;
      return mq && mc;
    }).toList();
  }

  Future<void> _confirmSale() async {
    final bytes = await InvoicePDFService.generate(
      shop: const ShopInfo(
        name: 'SuperShop',
        address: 'Sector 12, Uttara, Dhaka',
        phone: '+8801XXXXXXXXX',
        vatTin: 'TIN-123456789',
      ),
      logoBytes: null,
      items: [
        for (final c in store.cart)
          InvoiceLine(
              name: c.product.name, qty: c.qty, unitPrice: c.product.price)
      ],
      discount: store.discountTk,
      vatRate: store.vatRate,
      customer: store.selectedCustomer?.name ?? 'Walk-in',
      invoiceNo: 'INV-${DateTime.now().millisecondsSinceEpoch}',
      date: DateTime.now(),
    );
    await Printing.layoutPdf(onLayout: (_) async => bytes);

    if (store.selectedCustomer != null) {
      final earn = (store.cartTotal / 100).floor();
      store.addPoints(store.selectedCustomer!, earn);
    }
    store.clearCart();
    setState(() {});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sale successful & invoice ready.')),
      );
    }
  }
}
*/
/*
// ──────────────────────────────────────────────────────────────────────────────
// POS SCREEN (Bottom-sheet Category Picker + VAT/Tax + Invoice PDF)
// ──────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../../model/category_model.dart';
import '../../model/product_model.dart';
import '../../service/invoice_generator_info.dart';
import '../../store/ui/data/store_data.dart';
import '../widgets/cart_table_widget.dart';
import '../widgets/category_list_widget.dart';


class POSScreen extends StatefulWidget {
  const POSScreen({super.key});

  @override
  State<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends State<POSScreen> {
  String query = '';
  String category = 'All';

  // New: categories with icons/colors for the picker
  final List<CategoryItem> categories = const [
    CategoryItem('All', Icons.grid_view_rounded),
    CategoryItem('Grocery', Icons.local_grocery_store, Colors.green),
    CategoryItem('Dairy', Icons.icecream, Colors.indigo),
    CategoryItem('Poultry', Icons.egg, Colors.orange),
    CategoryItem('Cosmetics', Icons.brush, Colors.pink),
    CategoryItem('Bakery', Icons.bakery_dining, Colors.brown),
    CategoryItem('Meat', Icons.set_meal, Colors.red),
  ];

  final discountCtrl = TextEditingController();
  final vatCtrl = TextEditingController(text: '5');

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(builder: (context, c) {
        final isWide = c.maxWidth > 900;

        final left = Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search products here',
                    ),
                    onChanged: (v) => setState(() => query = v.trim().toLowerCase()),
                  ),
                ),
                const SizedBox(width: 12),
                // REPLACED: DropdownButton -> CategorySelector
                CategorySelector(
                  items: categories,
                  value: category,
                  onChanged: (v) => setState(() => category = v),
                ),
              ]),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isWide ? 4 : 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.25,
                  ),
                  itemCount: _filtered().length,
                  itemBuilder: (context, i) {
                    final p = _filtered()[i];
                    final low = p.stock <= 5;
                    return Card(
                      child: InkWell(
                        onTap: () => setState(() => store.addToCart(p)),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Spacer(),
                              Icon(Icons.shopping_basket_outlined,
                                  size: 42, color: Colors.grey.shade500),
                              const SizedBox(height: 8),
                              Text(p.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('৳${p.price.toStringAsFixed(0)}',
                                      style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Badge(
                                    label: Text('${p.stock}'),
                                    backgroundColor: low ? Colors.orange : Colors.green,
                                    child: const Icon(Icons.inventory_2_outlined),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );

        final right = _cartAndPOSSection();

        return isWide
            ? Row(children: [left, const SizedBox(width: 16), right])
            : Column(children: [
          Expanded(child: left),
          const SizedBox(height: 16),
          SizedBox(height: 420, child: right),
        ]);
      }),
    );
  }

  Widget _cartAndPOSSection() {
    return Expanded(
      flex: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Cart & POS',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                              IconButton(
                                onPressed: () => setState(store.clearCart),
                                icon: const Icon(Icons.delete_sweep_outlined),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 280),
                            child: CartTable(onChanged: () => setState(() {})),
                          ),
                          const SizedBox(height: 8),
                          Row(children: [
                            Expanded(
                              child: TextField(
                                controller: discountCtrl,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.local_offer_outlined),
                                  labelText: 'Discount (৳)',
                                ),
                                onChanged: (v) =>
                                    setState(() => store.applyDiscount(double.tryParse(v) ?? 0)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton.icon(
                              onPressed: () => setState(() {
                                discountCtrl.clear();
                                store.applyDiscount(0);
                              }),
                              icon: const Icon(Icons.close),
                              label: const Text('Reset'),
                            ),
                          ]),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Subtotal'),
                              Text('৳${store.subTotal.toStringAsFixed(0)}'),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(children: [
                                const Text('VAT '),
                                SizedBox(
                                  width: 64,
                                  child: TextField(
                                    controller: vatCtrl,
                                    decoration: const InputDecoration(suffixText: '%', isDense: true),
                                    keyboardType: TextInputType.number,
                                    onChanged: (v) {
                                      final r = (double.tryParse(v) ?? 5) / 100.0;
                                      setState(() => store.vatRate = r);
                                    },
                                  ),
                                ),
                              ]),
                              Text('৳${store.vatTk.toStringAsFixed(0)}'),
                            ],
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                              Text('৳${store.cartTotal.toStringAsFixed(0)}',
                                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          FilledButton.icon(
                            onPressed: store.cart.isEmpty ? null : _confirmSale,
                            icon: const Icon(Icons.check_circle_outline),
                            label: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Text('Confirm & Print Invoice'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Quick Actions',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          const Wrap(
                            spacing: 8,
                            children: [
                              ActionChip(
                                label: Text('Hold Bill'),
                                avatar: Icon(Icons.pause_circle_outline),
                              ),
                              ActionChip(
                                label: Text('Retrieve Bill'),
                                avatar: Icon(Icons.history),
                              ),
                              ActionChip(
                                label: Text('Select Customer'),
                                avatar: Icon(Icons.person_outline),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Product> _filtered() {
    final q = query;
    return store.products.where((p) {
      final mq = q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          (p.sku ?? '').toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q);
      final mc = category == 'All' || p.category == category;
      return mq && mc;
    }).toList();
  }

  Future<void> _confirmSale() async {
    final bytes = await InvoicePDFService.generate(
      shop: const ShopInfo(
        name: 'SuperShop',
        address: 'Sector 12, Uttara, Dhaka',
        phone: '+8801XXXXXXXXX',
        vatTin: 'TIN-123456789',
      ),
      logoBytes: null,
      items: [
        for (final c in store.cart)
          InvoiceLine(name: c.product.name, qty: c.qty, unitPrice: c.product.price)
      ],
      discount: store.discountTk,
      vatRate: store.vatRate,
      customer: store.selectedCustomer?.name ?? 'Walk-in',
      invoiceNo: 'INV-${DateTime.now().millisecondsSinceEpoch}',
      date: DateTime.now(),
    );
    await Printing.layoutPdf(onLayout: (_) async => bytes);

    if (store.selectedCustomer != null) {
      final earn = (store.cartTotal / 100).floor();
      store.addPoints(store.selectedCustomer!, earn);
    }
    store.clearCart();
    setState(() {});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sale successful & invoice ready.')),
      );
    }
  }
}
*/
// ──────────────────────────────────────────────────────────────────────────────
// POS SCREEN (Chips Category Filter + VAT/Tax + Invoice PDF)
// ──────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../../model/product_model.dart';
import '../../model/invoice_model.dart';
import '../../service/invoice_generator_info.dart';
import '../../store/ui/data/store_data.dart';
import '../widgets/cart_table_widget.dart';
import '../widgets/category_list_widget.dart';

class POSScreen extends StatefulWidget {
  const POSScreen({super.key});

  @override
  State<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends State<POSScreen> {
  String query = '';
  String category = 'All';

  final List<String> categories = const [
    'All',
    'Grocery',
    'Dairy',
    'Poultry',
    'Cosmetics',
    'Bakery',
    'Meat',
  ];

  final discountCtrl = TextEditingController();
  final vatCtrl = TextEditingController(text: '5');

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, c) {
          final isWide = c.maxWidth > 900;

          // LEFT: Search + Chips + Products
          final left = Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search
                TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search products here',
                  ),
                  onChanged: (v) =>
                      setState(() => query = v.trim().toLowerCase()),
                ),
                const SizedBox(height: 10),

                // NEW: Category chips (replaces Dropdown)
                CategoryChips(
                  items: categories,
                  value: category,
                  onChanged: (v) => setState(() => category = v),
                ),
                const SizedBox(height: 8),

                // Product grid
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isWide ? 4 : 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.25,
                    ),
                    itemCount: _filtered().length,
                    itemBuilder: (context, i) {
                      final p = _filtered()[i];
                      final low = p.stock <= 5;
                      return Card(
                        child: InkWell(
                          onTap: () => setState(() => store.addToCart(p)),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Spacer(),
                                Icon(Icons.shopping_basket_outlined,
                                    size: 42, color: Colors.grey.shade500),
                                const SizedBox(height: 8),
                                Text(
                                  p.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('৳${p.price.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Badge(
                                      label: Text('${p.stock}'),
                                      backgroundColor:
                                      low ? Colors.orange : Colors.green,
                                      child: const Icon(
                                          Icons.inventory_2_outlined),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );

          // RIGHT: Cart & POS section (unchanged from your last version)
          final right = _cartAndPOSSection();

          return isWide
              ? Row(children: [left, const SizedBox(width: 16), right])
              : Column(children: [
            Expanded(child: left),
            const SizedBox(height: 16),
            SizedBox(height: 420, child: right),
          ]);
        },
      ),
    );
  }

  // ── RIGHT SIDE: CART + POS ACTIONS ───────────────────────────────────────────
  Widget _cartAndPOSSection() {
    return Expanded(
      flex: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Cart & POS',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18)),
                              IconButton(
                                onPressed: () => setState(store.clearCart),
                                icon:
                                const Icon(Icons.delete_sweep_outlined),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ConstrainedBox(
                            constraints:
                            const BoxConstraints(maxHeight: 280),
                            child: CartTable(
                                onChanged: () => setState(() {})),
                          ),
                          const SizedBox(height: 8),
                          Row(children: [
                            Expanded(
                              child: TextField(
                                controller: discountCtrl,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  prefixIcon:
                                  Icon(Icons.local_offer_outlined),
                                  labelText: 'Discount (৳)',
                                ),
                                onChanged: (v) => setState(() => store
                                    .applyDiscount(double.tryParse(v) ?? 0)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton.icon(
                              onPressed: () => setState(() {
                                discountCtrl.clear();
                                store.applyDiscount(0);
                              }),
                              icon: const Icon(Icons.close),
                              label: const Text('Reset'),
                            ),
                          ]),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Subtotal'),
                              Text(
                                  '৳${store.subTotal.toStringAsFixed(0)}'),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Row(children: [
                                const Text('VAT '),
                                SizedBox(
                                  width: 64,
                                  child: TextField(
                                    controller: vatCtrl,
                                    decoration: const InputDecoration(
                                        suffixText: '%', isDense: true),
                                    keyboardType: TextInputType.number,
                                    onChanged: (v) {
                                      final r =
                                          (double.tryParse(v) ?? 5) / 100.0;
                                      setState(() => store.vatRate = r);
                                    },
                                  ),
                                ),
                              ]),
                              Text('৳${store.vatTk.toStringAsFixed(0)}'),
                            ],
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600)),
                              Text(
                                '৳${store.cartTotal.toStringAsFixed(0)}',
                                style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          FilledButton.icon(
                            onPressed: store.cart.isEmpty
                                ? null
                                : _confirmSale,
                            icon: const Icon(Icons.check_circle_outline),
                            label: const Padding(
                              padding:
                              EdgeInsets.symmetric(vertical: 12),
                              child: Text('Confirm & Print Invoice'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Quick Actions',
                              style:
                              TextStyle(fontWeight: FontWeight.w600)),
                          SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [
                              ActionChip(
                                label: Text('Hold Bill'),
                                avatar:
                                Icon(Icons.pause_circle_outline),
                              ),
                              ActionChip(
                                label: Text('Retrieve Bill'),
                                avatar: Icon(Icons.history),
                              ),
                              ActionChip(
                                label: Text('Select Customer'),
                                avatar: Icon(Icons.person_outline),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── FILTER LOGIC ─────────────────────────────────────────────────────────────
  List<Product> _filtered() {
    final q = query;
    return store.products.where((p) {
      final mq = q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          (p.sku ?? '').toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q);
      final mc = category == 'All' || p.category == category;
      return mq && mc;
    }).toList();
  }

  // ── CONFIRM SALE / PRINT ─────────────────────────────────────────────────────
  Future<void> _confirmSale() async {
    final bytes = await RetailInvoice.generate(
      shop: const InvoiceInfo(
        name: 'SuperShop',
        address: 'Sector 12, Uttara, Dhaka',
        phone: '+8801XXXXXXXXX',
        vatTin: 'TIN-123456789', vat: '',
      ),
      logoBytes: null,
      items: [
        for (final c in store.cart)
          InvoiceLine(
              name: c.product.name,
              qty: c.qty,
              unitPrice: c.product.price)
      ],
      discount: store.discountTk,
      vatRate: store.vatRate,
      customer: store.selectedCustomer?.name ?? 'Walk-in',
      invoiceNo: 'INV-${DateTime.now().millisecondsSinceEpoch}',
      date: DateTime.now(), orderNo: '', billNo: '', dateTime: null,
    );
    await Printing.layoutPdf(onLayout: (_) async => bytes);

    if (store.selectedCustomer != null) {
      final earn = (store.cartTotal / 100).floor();
      store.addPoints(store.selectedCustomer!, earn);
    }
    store.clearCart();
    setState(() {});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sale successful & invoice ready.')),
      );
    }
  }
}
