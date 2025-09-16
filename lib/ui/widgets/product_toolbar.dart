// ──────────────────────────────────────────────────────────────────────────────
// Responsive Toolbar (wraps on small screens, CSV button added)
// ──────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';

class Toolbar extends StatelessWidget {
  const Toolbar({super.key,
    required this.q,
    required this.cat,
    required this.sortBy,
    required this.asc,
    required this.cats,
    required this.onQuery,
    required this.onCategory,
    required this.onSortBy,
    required this.onToggleAsc,
    required this.onAdd,
    required this.onExportCsv,
    required this.isCompact,
  });

  final String q;
  final String cat;
  final String sortBy;
  final bool asc;
  final List<String> cats;
  final ValueChanged<String> onQuery;
  final ValueChanged<String?> onCategory;
  final ValueChanged<String?> onSortBy;
  final VoidCallback onToggleAsc;
  final VoidCallback onAdd;
  final VoidCallback onExportCsv;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final spacing = isCompact ? 8.0 : 12.0;

    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: isCompact ? 220 : 380,
            maxWidth: isCompact ? 480 : 560,
          ),
          child: TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search by name here',
            ),
            onChanged: (v) => onQuery(v),
          ),
        ),
        _Dropdown<String>(
          value: cat,
          items:
          cats.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onCategory,
          label: 'All',
        ),
        _Dropdown<String>(
          value: sortBy,
          items: const [
            DropdownMenuItem(value: 'Name', child: Text('Sort: Name')),
            DropdownMenuItem(value: 'Price', child: Text('Sort: Price')),
            DropdownMenuItem(value: 'Stock', child: Text('Sort: Stock')),
          ],
          onChanged: onSortBy,
          label: 'Sort',
        ),
        IconButton(
          tooltip: asc ? 'Ascending' : 'Descending',
          onPressed: onToggleAsc,
          icon: Icon(asc ? Icons.arrow_upward : Icons.arrow_downward),
        ),
        const SizedBox(width: 8),
        FilledButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add),
          label: const Text('Add Product'),
        ),
        OutlinedButton.icon(
          onPressed: onExportCsv,
          icon: const Icon(Icons.file_download),
          label: const Text('Export CSV'),
        ),
      ],
    );
  }
}

class _Dropdown<T> extends StatelessWidget {
  const _Dropdown({
    required this.value,
    required this.items,
    required this.onChanged,
    required this.label,
  });

  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<T>(
      value: value,
      onChanged: onChanged,
      items: items,
    );
  }
}