import 'package:flutter/material.dart';
import 'package:supershop_app/ui/screens/pos_screen.dart';
import 'package:supershop_app/ui/screens/product_management_screen.dart';
import 'package:supershop_app/ui/screens/supplier_purchase_Screen.dart';
import '../screens/customer_loyalty_Screen.dart';

class MainNavBar extends StatefulWidget {
  const MainNavBar({super.key});

  @override
  State<MainNavBar> createState() => _MainNavBarState();
}

class _MainNavBarState extends State<MainNavBar> {
  int _index = 0;
  final _pages = const [
    POSScreen(),
    ProductManagementScreen(),
    SupplierPurchaseScreen(),
    CustomerLoyaltyScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SuperShop Management'),
        centerTitle: true,
        actions: const [
          _AvatarChip(name: 'Mi'),
          SizedBox(width: 12),
        ],
      ),
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.point_of_sale_outlined), label: 'POS'),
          NavigationDestination(
              icon: Icon(Icons.inventory_2_outlined), label: 'Products'),
          NavigationDestination(
              icon: Icon(Icons.local_shipping_outlined), label: 'Purchase'),
          NavigationDestination(
              icon: Icon(Icons.card_membership_outlined), label: 'Loyalty'),
        ],
      ),
    );
  }
}

class _AvatarChip extends StatelessWidget {
  final String name;

  const _AvatarChip({required this.name});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(name),
      avatar: const CircleAvatar(child: Icon(Icons.person, size: 16)),
      shape: StadiumBorder(side: BorderSide(color: Theme
          .of(context)
          .dividerColor)),
    );
  }
}