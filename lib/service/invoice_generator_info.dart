// lib/service/retail_invoice.dart
import 'dart:math';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../model/invoice_model.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// PDF GENERATOR (BD VAT, clean 4 cols, auto Order/Bill)
/// ─────────────────────────────────────────────────────────────────────────────
class RetailInvoice {
  static Future<Uint8List> generate({
    required InvoiceInfo shop,
    required List<InvoiceLine> items,
    required double discount, // flat discount (currency)
    required double vatRate,  // 0.05 or 5 (both mean 5%)
    required String customer,
    required String invoiceNo,
    required DateTime date,

    // Optional (auto-generated if blank)
    String orderNo = '',
    String billNo = '',
    DateTime? dateTime,
    Uint8List? logoBytes,

    // Layout
    String currency = ' ',
    double widthMm = 80,
    String footerThanks = 'Thank you for your visit!',
  }) async {
    final pdf = pw.Document();

    // normalize VAT
    final double vatFraction = vatRate > 1 ? (vatRate / 100.0) : vatRate;

    final pageFormat = PdfPageFormat(
      widthMm * PdfPageFormat.mm,
      double.infinity,
      marginAll: 8 * PdfPageFormat.mm,
    );

    final fontBase = pw.Font.helvetica();
    final fontBold = pw.Font.helveticaBold();
    final logo = logoBytes != null ? pw.MemoryImage(logoBytes) : null;

    String money(double v) => '$currency${v.toStringAsFixed(2)}';
    String two(int n) => n.toString().padLeft(2, '0');
    String fmtDateTime(DateTime d) =>
        '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)} ${d.hour >= 12 ? 'PM' : 'AM'}';

    // ── Auto IDs when blank
    String _autoId(String current, String prefix) {
      if (current.trim().isNotEmpty) return current;
      final now = DateTime.now();
      final y = now.year, m = two(now.month), d = two(now.day);
      final tail = now.millisecondsSinceEpoch.toString().substring(8);
      final rnd = (Random().nextInt(900) + 100); // 100..999
      return '$prefix-$y$m$d-$tail$rnd';
    }
    final resolvedOrderNo = _autoId(orderNo, 'ORD');
    final resolvedBillNo  = _autoId(billNo,  'BILL');

    // Totals (BD style: discount → VAT → total)
    final double subTotal = items.fold(0.0, (p, e) => p + e.amount);
    final double discountClamped =
    discount <= 0 ? 0.0 : (discount > subTotal ? subTotal : discount);
    final double taxableBase = subTotal - discountClamped;
    final double vat = taxableBase * vatFraction;
    final double grandTotal = taxableBase + vat;

    pw.Widget separator() => pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 6),
      child: pw.Container(height: 0.8, color: PdfColors.grey700),
    );

    pdf.addPage(
      pw.Page(
        pageFormat: pageFormat,
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            // ── Header
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                if (logo != null)
                  pw.Container(
                    width: 56,
                    height: 56,
                    margin: const pw.EdgeInsets.only(bottom: 6),
                    child: pw.Image(logo, fit: pw.BoxFit.contain),
                  ),
                pw.Text(shop.name,
                    style: pw.TextStyle(font: fontBold, fontSize: 18)),
                if (shop.city?.isNotEmpty == true)
                  pw.Text(shop.city!,
                      style: pw.TextStyle(font: fontBase, fontSize: 11)),
                pw.Text(shop.address,
                    style: pw.TextStyle(font: fontBase, fontSize: 10),
                    textAlign: pw.TextAlign.center),
                pw.Text('Phone: ${shop.phone}',
                    style: pw.TextStyle(font: fontBase, fontSize: 10)),
                pw.Text('VAT: ${shop.vatTin}',
                    style: pw.TextStyle(font: fontBase, fontSize: 10)),
                pw.SizedBox(height: 10),
                pw.Text('Retail Invoice',
                    style: pw.TextStyle(font: fontBold, fontSize: 16)),
              ],
            ),
            pw.SizedBox(height: 8),

            // ── Meta Info
            _meta('Order#',   resolvedOrderNo, fontBase),
            _meta('Bill#',    resolvedBillNo,  fontBase),
            _meta('Date',     fmtDateTime(dateTime ?? date), fontBase),
            _meta('Invoice#', invoiceNo, fontBase),
            _meta('Customer', customer, fontBase),

            separator(),

            // ── Table Header (4 columns)
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 4),
              child: pw.Row(children: [
                pw.Expanded(
                  flex: 7,
                  child: pw.Text('Item',
                      style: pw.TextStyle(font: fontBold, fontSize: 10)),
                ),
                pw.Expanded(
                  flex: 3,
                  child: pw.Text('Rate',
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(font: fontBold, fontSize: 10)),
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Text('Qty',
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(font: fontBold, fontSize: 10)),
                ),
                pw.Expanded(
                  flex: 4,
                  child: pw.Text('Amount',
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(font: fontBold, fontSize: 10)),
                ),
              ]),
            ),

            // ── Table Body (NO tax column here)
            ...items.map((it) => pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 2),
              child: pw.Row(children: [
                pw.Expanded(
                  flex: 7,
                  child: pw.Text(it.name,
                      style: pw.TextStyle(font: fontBase, fontSize: 10)),
                ),
                pw.Expanded(
                  flex: 3,
                  child: pw.Text(money(it.unitPrice),
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(font: fontBase, fontSize: 10)),
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Text('${it.qty}',
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(font: fontBase, fontSize: 10)),
                ),
                pw.Expanded(
                  flex: 4,
                  child: pw.Text(money(it.amount),
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(font: fontBase, fontSize: 10)),
                ),
              ]),
            )),

            separator(),

            // ── Totals (Bangladesh style)
            _kv('Sub Total', money(subTotal), fontBase, fontBold),
            if (discountClamped > 0)
              _kv('Discount', '- ${money(discountClamped)}', fontBase, fontBold),
            _kv('VAT (${(vatFraction * 100).toStringAsFixed(2)}%)',
                money(vat), fontBase, fontBold),

            // Total row
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 6),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('TOTAL',
                      style: pw.TextStyle(font: fontBold, fontSize: 14)),
                  pw.Text(money(grandTotal),
                      style: pw.TextStyle(font: fontBold, fontSize: 14)),
                ],
              ),
            ),

            separator(),

            // ── Footer counts
            pw.Text(
              'No of Items: ${items.length},  Total Quantity: '
                  '${items.fold<int>(0, (p, e) => p + e.qty)}',
              style: pw.TextStyle(font: fontBase, fontSize: 10),
            ),
            pw.SizedBox(height: 14),

            // ── Thank you + Powered by
            pw.Center(
              child: pw.Text(
                footerThanks,
                style: pw.TextStyle(font: fontBold, fontSize: 12),
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Text(
                  'Powered by Appnix IT',
                  style: pw.TextStyle(
                    font: fontBase,
                    fontSize: 9,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    return pdf.save();
  }

  static pw.Widget _meta(String k, String v, pw.Font base) => pw.Row(
    children: [
      pw.Text('$k  ', style: pw.TextStyle(font: base, fontSize: 10)),
      pw.Text(v, style: pw.TextStyle(font: base, fontSize: 10)),
    ],
  );

  static pw.Widget _kv(String k, String v, pw.Font base, pw.Font boldFont) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(k, style: pw.TextStyle(font: base, fontSize: 11)),
          pw.Text(v, style: pw.TextStyle(font: boldFont, fontSize: 11)),
        ],
      ),
    );
  }
}
