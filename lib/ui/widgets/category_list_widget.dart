
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
