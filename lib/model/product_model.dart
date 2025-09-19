// ──────────────────────────────────────────────────────────────────────────────
// DATA MODELS
// ──────────────────────────────────────────────────────────────────────────────
class Product {
  Product(
      {required this.id, required this.name, required this.category, required this.price, required this.stock, this.imageUrl, this.sku});

  final String id;
  String name;
  String category;
  double price;
  int stock;
  String? imageUrl;
  String? sku;
}

class CartItem {
  CartItem({required this.product, required this.qty});

  final Product product;
  int qty;

  double get subtotal => product.price * qty;
}

class Customer {
  Customer(
      {required this.id, required this.name, required this.phone, this.points = 0});

  final String id;
  String name;
  String phone;
  int points;
}

class Supplier {
  Supplier(
      {required this.id, required this.name, required this.phone, this.due = 0});

  final String id;
  String name;
  String phone;
  double due;
}

class PurchaseItem {
  PurchaseItem(
      {required this.product, required this.qty, required this.unitCost});

  final Product product;
  int qty;
  double unitCost;

  double get lineTotal => qty * unitCost;
}

class PurchaseOrder {
  PurchaseOrder(
      {required this.id, required this.supplier, required this.items, required this.date});

  final String id;
  final Supplier supplier;
  final List<PurchaseItem> items;
  final DateTime date;

  double get total => items.fold(0, (p, e) => p + e.lineTotal);
}


