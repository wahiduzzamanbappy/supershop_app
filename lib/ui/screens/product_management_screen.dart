// ──────────────────────────────────────────────────────────────────────────────
// PRODUCT MANAGEMENT (Responsive + SL + full scrolling)
// ──────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import '../../model/product_model.dart';
import '../../store/ui/data/store_data.dart';
import '../widgets/product_update_widget.dart';

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  String q = '';
  String cat = 'All';
  String sortBy = 'Name';
  bool asc = true;

  final cats = const [
    'All',
    'Grocery',
    'Dairy',
    'Poultry',
    'Cosmetics',
    'Bakery',
    'Meat'
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;

        // Breakpoints
        final isMobile = w <= 600;
        final isSmallTablet = w > 600 && w <= 900;
        final isTablet = w > 900 && w <= 1200;
        final isDesktop = w > 1200 && w <= 1600;
        final isBig = w > 1600;

        final filtered = _applySort(_filter());
        final padding = EdgeInsets.all(isMobile ? 12 : 16);

        return Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _FiltersBar(
                cats: cats,
                selectedCat: cat,
                onCatChanged: (v) => setState(() => cat = v),
                query: q,
                onQueryChanged: (v) => setState(() => q = v.trim().toLowerCase()),
                sortBy: sortBy,
                onSortByChanged: (v) => setState(() => sortBy = v),
                asc: asc,
                onToggleAsc: () => setState(() => asc = !asc),
                onAdd: _openAddDialog,
                compact: isMobile || isSmallTablet,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _ResponsiveBody(
                  products: filtered,
                  onEdit: _openEditDialog,
                  onDelete: _confirmDelete,
                  onBarcode: _generateBarcode,
                  isMobile: isMobile,
                  isSmallTablet: isSmallTablet,
                  isTablet: isTablet,
                  isDesktop: isDesktop,
                  isBig: isBig,
                  theme: theme,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ──────────────────────────────────────────────────────────────────────────────
  // Helpers
  // ──────────────────────────────────────────────────────────────────────────────

  List<Product> _filter() {
    return store.products.where((p) {
      final mq = q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          (p.sku ?? '').toLowerCase().contains(q);
      final mc = cat == 'All' || p.category == cat;
      return mq && mc;
    }).toList();
  }

  List<Product> _applySort(List<Product> a) {
    a.sort((x, y) {
      int r;
      switch (sortBy) {
        case 'Price':
          r = x.price.compareTo(y.price);
          break;
        case 'Stock':
          r = x.stock.compareTo(y.stock);
          break;
        default:
          r = x.name.toLowerCase().compareTo(y.name.toLowerCase());
      }
      return asc ? r : -r;
    });
    return a;
  }

  Future<void> _openAddDialog() async {
    final created = await showDialog<Product>(
      context: context,
      builder: (_) => const ProductEditorDialog(),
    );
    if (created != null) {
      setState(() => store.addProduct(created));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product added')),
      );
    }
  }

  Future<void> _openEditDialog(Product p) async {
    final updated = await showDialog<Product>(
      context: context,
      builder: (_) => ProductEditorDialog(product: p),
    );
    if (updated != null) {
      setState(() => store.updateProduct(updated));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product updated')),
      );
    }
  }

  Future<void> _confirmDelete(Product p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Product?'),
        content: Text('Are you sure you want to delete "${p.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) {
      setState(() => store.deleteProduct(p.id));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product deleted')),
      );
    }
  }

  void _generateBarcode(Product p) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Barcode for ${p.sku ?? p.id} (demo only)')),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Filters bar (chips + compact mode)
// ──────────────────────────────────────────────────────────────────────────────
class _FiltersBar extends StatelessWidget {
  const _FiltersBar({
    required this.cats,
    required this.selectedCat,
    required this.onCatChanged,
    required this.query,
    required this.onQueryChanged,
    required this.sortBy,
    required this.onSortByChanged,
    required this.asc,
    required this.onToggleAsc,
    required this.onAdd,
    this.compact = false,
  });

  final List<String> cats;
  final String selectedCat;
  final ValueChanged<String> onCatChanged;

  final String query;
  final ValueChanged<String> onQueryChanged;

  final String sortBy;
  final ValueChanged<String> onSortByChanged;

  final bool asc;
  final VoidCallback onToggleAsc;

  final VoidCallback onAdd;

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final sortItems = const [
      DropdownMenuItem(value: 'Name', child: Text('Name')),
      DropdownMenuItem(value: 'Price', child: Text('Price')),
      DropdownMenuItem(value: 'Stock', child: Text('Stock')),
    ];

    if (compact) {
      // Mobile / Tight layout
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search by name or SKU',
            ),
            onChanged: onQueryChanged,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final c in cats)
                ChoiceChip(
                  label: Text(c),
                  selected: selectedCat == c,
                  onSelected: (_) => onCatChanged(c),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              DropdownButton<String>(
                value: sortBy,
                items: sortItems,
                onChanged: (v) => onSortByChanged(v ?? 'Name'),
              ),
              IconButton(
                tooltip: asc ? 'Ascending' : 'Descending',
                onPressed: onToggleAsc,
                icon: Icon(asc ? Icons.arrow_upward : Icons.arrow_downward),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                label: const Text('Add'),
              ),
            ],
          ),
        ],
      );
    }

    // Wider layouts
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search by name or SKU',
            ),
            onChanged: onQueryChanged,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final c in cats) ...[
                  ChoiceChip(
                    label: Text(c),
                    selected: selectedCat == c,
                    onSelected: (_) => onCatChanged(c),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        DropdownButton<String>(
          value: sortBy,
          items: sortItems,
          onChanged: (v) => onSortByChanged(v ?? 'Name'),
        ),
        IconButton(
          tooltip: asc ? 'Ascending' : 'Descending',
          onPressed: onToggleAsc,
          icon: Icon(asc ? Icons.arrow_upward : Icons.arrow_downward),
        ),
        const Spacer(),
        FilledButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add),
          label: const Text('Add Product'),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
class _ResponsiveBody extends StatelessWidget {
  const _ResponsiveBody({
    required this.products,
    required this.onEdit,
    required this.onDelete,
    required this.onBarcode,
    required this.isMobile,
    required this.isSmallTablet,
    required this.isTablet,
    required this.isDesktop,
    required this.isBig,
    required this.theme,
  });

  final List<Product> products;
  final ValueChanged<Product> onEdit;
  final ValueChanged<Product> onDelete;
  final ValueChanged<Product> onBarcode;

  final bool isMobile;
  final bool isSmallTablet;
  final bool isTablet;
  final bool isDesktop;
  final bool isBig;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return _MobileCardList(
        products: products,
        onEdit: onEdit,
        onDelete: onDelete,
        onBarcode: onBarcode,
      );
    }

    if (isSmallTablet) {
      return _MobileCardList(
        products: products,
        onEdit: onEdit,
        onDelete: onDelete,
        onBarcode: onBarcode,
        dense: true,
      );
    }

    if (isTablet) {
      // DataTable (no pagination), H + V scroll so all rows show
      return _WideTable(
        products: products,
        onEdit: onEdit,
        onDelete: onDelete,
        onBarcode: onBarcode,
        minWidth: 900,
        usePagination: false,
        rowsPerPage: 10,
      );
    }

    // Desktop & Big screen: PaginatedDataTable
    return _WideTable(
      products: products,
      onEdit: onEdit,
      onDelete: onDelete,
      onBarcode: onBarcode,
      minWidth: isBig ? 1100 : 1000,
      usePagination: true,
      rowsPerPage: isBig ? 15 : 10,
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Mobile/List cards (with SL)
// ──────────────────────────────────────────────────────────────────────────────
class _MobileCardList extends StatelessWidget {
  const _MobileCardList({
    required this.products,
    required this.onEdit,
    required this.onDelete,
    required this.onBarcode,
    this.dense = false,
  });

  final List<Product> products;
  final ValueChanged<Product> onEdit;
  final ValueChanged<Product> onDelete;
  final ValueChanged<Product> onBarcode;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const Center(child: Text('No products found'));
    }

    return ListView.separated(
      itemCount: products.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final p = products[i];
        final low = p.stock <= 5;
        return Card(
          color: low ? Colors.orange.withOpacity(.06) : null,
          child: ListTile(
            leading: CircleAvatar( // SL
              radius: 14,
              child: Text('${i + 1}', style: const TextStyle(fontSize: 12)),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12,
              vertical: dense ? 6 : 10,
            ),
            title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _InfoChip(icon: Icons.category, text: p.category),
                    _InfoChip(icon: Icons.price_check, text: '৳${p.price.toStringAsFixed(0)}'),
                    _InfoChip(icon: Icons.inventory_2, text: 'Stock: ${p.stock}'),
                    _InfoChip(icon: Icons.qr_code_2, text: p.sku ?? '-'),
                  ],
                ),
                if (low) ...[
                  const SizedBox(height: 6),
                  const Text('Low stock', style: TextStyle(color: Colors.orange))
                ],
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () => _showActionsSheet(context, p),
            ),
            onTap: () => _showActionsSheet(context, p),
          ),
        );
      },
    );
  }

  void _showActionsSheet(BuildContext context, Product p) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  onEdit(p);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Delete'),
                onTap: () {
                  Navigator.pop(context);
                  onDelete(p);
                },
              ),
              ListTile(
                leading: const Icon(Icons.qr_code_2_outlined),
                title: const Text('Generate Barcode'),
                onTap: () {
                  Navigator.pop(context);
                  onBarcode(p);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 6),
          Text(text),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      visualDensity: VisualDensity.compact,
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Wide/Table layouts (DataTable / PaginatedDataTable) with SL
// ──────────────────────────────────────────────────────────────────────────────
class _WideTable extends StatelessWidget {
  const _WideTable({
    required this.products,
    required this.onEdit,
    required this.onDelete,
    required this.onBarcode,
    required this.minWidth,
    required this.usePagination,
    required this.rowsPerPage,
  });

  final List<Product> products;
  final ValueChanged<Product> onEdit;
  final ValueChanged<Product> onDelete;
  final ValueChanged<Product> onBarcode;

  final double minWidth;
  final bool usePagination;
  final int rowsPerPage;

  @override
  Widget build(BuildContext context) {
    if (!usePagination) {
      // Tablet: Simple DataTable with both horizontal + vertical scroll
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Scrollbar(
            thumbVisibility: true,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: minWidth),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    columnSpacing: 24,
                    headingRowHeight: 44,
                    dataRowMinHeight: 38,
                    dataRowMaxHeight: 58,
                    columns: const [
                      DataColumn(label: Text('SL')),
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Category')),
                      DataColumn(label: Text('Price')),
                      DataColumn(label: Text('Stock')),
                      DataColumn(label: Text('SKU')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: [
                      for (int i = 0; i < products.length; i++)
                        DataRow(
                          color: products[i].stock <= 5
                              ? MaterialStatePropertyAll(
                            Colors.orange.withOpacity(.08),
                          )
                              : null,
                          cells: [
                            DataCell(Text('${i + 1}')), // SL
                            DataCell(Text(products[i].name)),
                            DataCell(Text(products[i].category)),
                            DataCell(Text('৳${products[i].price.toStringAsFixed(0)}')),
                            DataCell(Text('${products[i].stock}')),
                            DataCell(Text(products[i].sku ?? '-')),
                            DataCell(Row(
                              children: [
                                IconButton(
                                  tooltip: 'Edit',
                                  onPressed: () => onEdit(products[i]),
                                  icon: const Icon(Icons.edit_outlined),
                                ),
                                IconButton(
                                  tooltip: 'Delete',
                                  onPressed: () => onDelete(products[i]),
                                  icon: const Icon(Icons.delete_outline),
                                ),
                                IconButton(
                                  tooltip: 'Generate Barcode',
                                  onPressed: () => onBarcode(products[i]),
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
            ),
          ),
        ),
      );
    }

    // Desktop/Big: PaginatedDataTable
    final source = _ProductDataSource(
      data: products,
      onEdit: onEdit,
      onDelete: onDelete,
      onBarcode: onBarcode,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: minWidth),
            child: PaginatedDataTable(
              header: const Text('Products'),
              columns: const [
                DataColumn(label: Text('SL')),
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Category')),
                DataColumn(label: Text('Price')),
                DataColumn(label: Text('Stock')),
                DataColumn(label: Text('SKU')),
                DataColumn(label: Text('Actions')),
              ],
              source: source,
              rowsPerPage: rowsPerPage.clamp(5, 50),
              showCheckboxColumn: false,
              columnSpacing: 24,
              dataRowMinHeight: 40,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductDataSource extends DataTableSource {
  _ProductDataSource({
    required this.data,
    required this.onEdit,
    required this.onDelete,
    required this.onBarcode,
  });

  final List<Product> data;
  final ValueChanged<Product> onEdit;
  final ValueChanged<Product> onDelete;
  final ValueChanged<Product> onBarcode;

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) return null;
    final p = data[index];
    return DataRow.byIndex(
      index: index,
      color: p.stock <= 5
          ? MaterialStatePropertyAll(Colors.orange.withOpacity(.08))
          : null,
      cells: [
        DataCell(Text('${index + 1}')), // SL (global index across all pages)
        DataCell(Text(p.name)),
        DataCell(Text(p.category)),
        DataCell(Text('৳${p.price.toStringAsFixed(0)}')),
        DataCell(Text('${p.stock}')),
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
      onSelectChanged: (_) {},
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;
}
