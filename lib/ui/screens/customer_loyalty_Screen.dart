// ──────────────────────────────────────────────────────────────────────────────
// CUSTOMER LOYALTY (tiers & points)
// ──────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';

import '../../store/ui/data/store_data.dart';

class CustomerLoyaltyScreen extends StatefulWidget {
  const CustomerLoyaltyScreen({super.key});

  @override State<CustomerLoyaltyScreen> createState() =>
      _CustomerLoyaltyScreenState();
}

class _CustomerLoyaltyScreenState extends State<CustomerLoyaltyScreen> {
  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.all(16),
        child: Card(child: Padding(padding: const EdgeInsets.all(12),
            child: SingleChildScrollView(scrollDirection: Axis.horizontal,
                child: DataTable(columns: const [
                  DataColumn(label: Text('Customer')),
                  DataColumn(label: Text('Phone')),
                  DataColumn(label: Text('Points')),
                  DataColumn(label: Text('Tier')),
                  DataColumn(label: Text('Actions')),
                ], rows: [for(final c in store.customers) DataRow(cells: [
                  DataCell(Text(c.name)),
                  DataCell(Text(c.phone)),
                  DataCell(Text('${c.points}')),
                  DataCell(Text(_tier(c.points))),
                  DataCell(Row(children: [
                    IconButton(onPressed: () {
                      setState(() => store.addPoints(c, 10));
                    },
                        icon: const Icon(Icons.add_circle_outline),
                        tooltip: 'Add 10 pts'),
                    IconButton(onPressed: () {
                      setState(() => store.redeemPoints(c, 50));
                    },
                        icon: const Icon(Icons.redeem_outlined),
                        tooltip: 'Redeem 50 pts'),
                  ])),
                ])
                ])))));
  }

  String _tier(int pts) {
    if (pts >= 500) return 'Platinum';
    if (pts >= 300) return 'Gold';
    if (pts >= 100) return 'Silver';
    return 'Bronze';
  }
}
