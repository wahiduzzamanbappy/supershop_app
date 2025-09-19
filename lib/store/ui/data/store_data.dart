// ──────────────────────────────────────────────────────────────────────────────
// STORE (In-memory for demo)
// ──────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import '../../../model/product_model.dart';

class Store extends ChangeNotifier {
  final List<Product> products = [
    Product(id: 'p1',
        name: 'Rice 5kg',
        category: 'Grocery',
        price: 550,
        stock: 24,
        sku: '8901001001'),
    Product(id: 'p2',
        name: 'Milk 1L',
        category: 'Dairy',
        price: 110,
        stock: 6,
        sku: '8901001002'),
    Product(id: 'p3',
        name: 'Egg (Dozen)',
        category: 'Poultry',
        price: 165,
        stock: 2,
        sku: '8901001003'),
    Product(id: 'p4',
        name: 'Olive Oil 1L',
        category: 'Grocery',
        price: 980,
        stock: 10,
        sku: '8901001004'),
    Product(id: 'p5',
        name: 'Shampoo 200ml',
        category: 'Cosmetics',
        price: 210,
        stock: 18,
        sku: '8901001005'),
    Product(id: 'p6',
        name: 'Bread',
        category: 'Bakery',
        price: 70,
        stock: 12,
        sku: '8901001006'),
    Product(id: 'p7',
        name: 'Soap',
        category: 'Cosmetics',
        price: 45,
        stock: 80,
        sku: '8901001007'),
    Product(id: 'p8',
        name: 'Chicken 1kg',
        category: 'Meat',
        price: 350,
        stock: 5,
        sku: '8901001008'),
  ];

  final List<Customer> customers = [
    Customer(id: 'c1', name: 'Walk-in', phone: '-', points: 0),
    Customer(id: 'c2', name: 'Alif Khan', phone: '01XXXXXXXXX', points: 120),
    Customer(id: 'c3', name: 'Rupa Sultana', phone: '01XXXXXXXXX', points: 380),
  ];

  final List<Supplier> suppliers = [
    Supplier(id: 's1', name: 'Fresh Distributors', phone: '02-XXXXXXX', due: 0),
    Supplier(
        id: 's2', name: 'Daily Dairy Ltd', phone: '02-YYYYYYY', due: 12500),
  ];

  final List<PurchaseOrder> purchases = [];

  final List<CartItem> cart = [];
  double discountTk = 0;
  double vatRate = 0.05; // 5%
  Customer? selectedCustomer;

  double get subTotal => cart.fold(0, (p, e) => p + e.subtotal);

  double get vatTk => subTotal * vatRate;

  double get cartTotal => subTotal + vatTk - discountTk;

  // CART OPS
  void addToCart(Product p) {
    final i = cart.indexWhere((c) => c.product.id == p.id);
    if (i >= 0) {
      cart[i].qty += 1;
    } else {
      cart.add(CartItem(product: p, qty: 1));
    }
    notifyListeners();
  }

  void removeFromCart(Product p) {
    cart.removeWhere((c) => c.product.id == p.id);
    notifyListeners();
  }

  void updateQty(Product p, int qty) {
    final i = cart.indexWhere((c) => c.product.id == p.id);
    if (i >= 0) {
      cart[i].qty = qty.clamp(1, 999);
      notifyListeners();
    }
  }

  void clearCart() {
    cart.clear();
    discountTk = 0;
    selectedCustomer = null;
    notifyListeners();
  }

  void applyDiscount(double amount) {
    discountTk = amount.clamp(0, 1e9);
    notifyListeners();
  }

  // PRODUCT CRUD
  void addProduct(Product p) {
    products.add(p);
    notifyListeners();
  }

  void updateProduct(Product p) {
    final i = products.indexWhere((e) => e.id == p.id);
    if (i >= 0) {
      products[i] = p;
      notifyListeners();
    }
  }

  void deleteProduct(String id) {
    products.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  // CUSTOMER
  void addCustomer(Customer c) {
    customers.add(c);
    notifyListeners();
  }

  void addPoints(Customer c, int pts) {
    c.points += pts;
    notifyListeners();
  }

  void redeemPoints(Customer c, int pts) {
    c.points = (c.points - pts).clamp(0, 1 << 31);
    notifyListeners();
  }

  // SUPPLIER / PURCHASE
  void addSupplier(Supplier s) {
    suppliers.add(s);
    notifyListeners();
  }

  void createPurchase(PurchaseOrder po) {
    purchases.add(po);
    for (final it in po.items) {
      final i = products.indexWhere((p) => p.id == it.product.id);
      if (i >= 0) products[i].stock += it.qty;
    }
    final si = suppliers.indexWhere((s) => s.id == po.supplier.id);
    if (si >= 0) suppliers[si].due += po.total;
    notifyListeners();
  }
}

final store = Store();