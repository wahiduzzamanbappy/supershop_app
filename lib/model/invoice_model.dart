class InvoiceInfo {
  const InvoiceInfo({
    required this.name,
    required this.address,
    required this.phone,
    required this.vatTin,
    required this.vat, // keep for compatibility (unused label text if you want)
    this.city = '',
  });

  final String name;
  final String address;
  final String phone;
  final String vatTin;
  final String vat;
  final String city;
}

class InvoiceLine {
  const InvoiceLine({
    required this.name,
    required this.qty,
    required this.unitPrice,
  });

  final String name;
  final int qty;
  final double unitPrice;

  double get amount => qty * unitPrice;
}
