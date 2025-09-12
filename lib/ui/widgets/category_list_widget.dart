/*
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../model/category_model.dart';

/// Pill button that opens a draggable bottom sheet with a searchable list.
class CategorySelector extends StatefulWidget {
  final List<CategoryItem> items;
  final String value;
  final ValueChanged<String> onChanged;
  final EdgeInsets padding;
  final double borderRadius;

  const CategorySelector({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    this.borderRadius = 12,
  });

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  late String _value = widget.value;

  @override
  void didUpdateWidget(covariant CategorySelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _value = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final selected =
    widget.items.firstWhere((e) => e.name == _value, orElse: () => widget.items.first);

    return InkWell(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      onTap: () async {
        HapticFeedback.selectionClick();
        final picked = await showModalBottomSheet<String>(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          backgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(widget.borderRadius + 8),
            ),
          ),
          builder: (ctx) => _CategorySheet(
            items: widget.items,
            initial: _value,
          ),
        );
        if (picked != null && picked != _value) {
          setState(() => _value = picked);
          widget.onChanged(picked);
        }
      },
      child: Container(
        padding: widget.padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(color: theme.dividerColor),
          color: theme.colorScheme.surface,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(selected.icon, size: 18),
            const SizedBox(width: 8),
            Text(selected.name, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(width: 6),
            const Icon(Icons.expand_more, size: 18),
          ],
        ),
      ),
    );
  }
}

class _CategorySheet extends StatefulWidget {
  final List<CategoryItem> items;
  final String initial;
  const _CategorySheet({required this.items, required this.initial});

  @override
  State<_CategorySheet> createState() => _CategorySheetState();
}

class _CategorySheetState extends State<_CategorySheet> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = widget.items
        .where((e) => e.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      builder: (context, scrollCtrl) {
        return Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search categories',
                  filled: true,
                  isDense: true,
                ),
                onChanged: (v) => setState(() => query = v),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                controller: scrollCtrl,
                itemCount: filtered.length,
                separatorBuilder: (_, __) =>
                    Divider(indent: 64, height: 1, color: theme.dividerColor.withOpacity(.4)),
                itemBuilder: (context, i) {
                  final item = filtered[i];
                  final selected = item.name == widget.initial;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                      (item.color ?? theme.colorScheme.primary).withOpacity(0.12),
                      child: Icon(item.icon, color: item.color ?? theme.colorScheme.primary),
                    ),
                    title: Text(item.name),
                    trailing:
                    selected ? Icon(Icons.check_circle, color: theme.colorScheme.primary) : null,
                    onTap: () => Navigator.pop(context, item.name),
                  );
                },
              ),
            )
          ],
        );
      },
    );
  }
}
*/
import 'package:flutter/material.dart';

class CategoryChips extends StatelessWidget {
  final List<String> items;
  final String value;
  final ValueChanged<String> onChanged;
  final EdgeInsets padding;
  final bool showIcons;

  const CategoryChips({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    this.padding = const EdgeInsets.symmetric(horizontal: 8),
    this.showIcons = true,
  });

  IconData _iconFor(String name) {
    switch (name) {
      case 'All':
        return Icons.grid_view_rounded;
      case 'Grocery':
        return Icons.local_grocery_store;
      case 'Dairy':
        return Icons.icecream;
      case 'Poultry':
        return Icons.egg;
      case 'Cosmetics':
        return Icons.brush;
      case 'Bakery':
        return Icons.bakery_dining;
      case 'Meat':
        return Icons.set_meal;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: padding,
      child: SizedBox(
        height: 44,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, i) {
            final label = items[i];
            final selected = label == value;

            return ChoiceChip(
              avatar: showIcons ? Icon(_iconFor(label), size: 18) : null,
              label: Text(label),
              selected: selected,
              labelStyle: TextStyle(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
              ),
              selectedColor: theme.colorScheme.primary,
              backgroundColor:
              theme.colorScheme.surfaceContainerHighest.withOpacity(.6),
              side: BorderSide(
                color: selected
                    ? theme.colorScheme.primary
                    : theme.dividerColor.withOpacity(.6),
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onSelected: (_) => onChanged(label),
            );
          },
        ),
      ),
    );
  }
}
