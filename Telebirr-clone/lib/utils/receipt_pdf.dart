import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Cross-platform receipt PDF generator matching the official telebirr format.
class ReceiptPdf {
  static const PdfColor _green = PdfColor.fromInt(0xFF5AB034); // telebirr green
  static const PdfColor _darkGreen = PdfColor.fromInt(0xFF17B877);
  static const PdfColor _greyHeader = PdfColor.fromInt(0xFFEFEFEF);
  static const PdfColor _lightGrey = PdfColor.fromInt(0xFFF9F9F9);
  static const PdfColor _blue = PdfColor.fromInt(0xFF0089D0);
  static const PdfColor _stampBlue = PdfColor.fromInt(0xFF1F4A9C);

  static Future<void> generateAndShare({
    required String payerName,
    required String payerPhone,
    required String payerAccountType,
    String payerTin = '',
    String vatRegNo = '',
    String vatRegDate = '',
    required String creditedPartyName,
    required String creditedPartyAccount,
    required String transactionStatus,
    required String invoiceNo,
    required String paymentDate,
    required String settledAmount,
    required String stampDuty,
    required String discountAmount,
    required String serviceFee,
    required String serviceFeeVat,
    required String totalPaidAmount,
    required String amountInWords,
    required String paymentMode,
    required String paymentReason,
    required String paymentChannel,
    String? bankAccountNumber,
  }) async {
    final pdf = pw.Document();

    // Load fonts
    final ttfReg = await rootBundle.load('assets/fonts/NotoSansEthiopic-Regular.ttf');
    final fontReg = pw.Font.ttf(ttfReg);
    final ttfBold = await rootBundle.load('assets/fonts/NotoSansEthiopic-Bold.ttf');
    final fontBold = pw.Font.ttf(ttfBold);

    // Try to load images (fallback to empty if missing)
    pw.MemoryImage? ethioLogo;
    pw.MemoryImage? telebirrLogo;
    pw.MemoryImage? stampImg;
    pw.MemoryImage? stripesImg;
    pw.MemoryImage? bannerImg;

    try { ethioLogo = pw.MemoryImage((await rootBundle.load('images/ethio-logo.png')).buffer.asUint8List()); } catch (_) {}
    try { telebirrLogo = pw.MemoryImage((await rootBundle.load('images/telebirr.png')).buffer.asUint8List()); } catch (_) {}
    // Custom images the user will drop into images/ folder
    try { stampImg = pw.MemoryImage((await rootBundle.load('images/stamp.png')).buffer.asUint8List()); } catch (_) {}
    try { stripesImg = pw.MemoryImage((await rootBundle.load('images/stripes.png')).buffer.asUint8List()); } catch (_) {}
    try { bannerImg = pw.MemoryImage((await rootBundle.load('images/bringing_new_possibilities.png')).buffer.asUint8List()); } catch (_) {}

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(40, 30, 40, 20),
        theme: pw.ThemeData.withFont(
          base: fontReg,
          bold: fontBold,
        ),
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // --- 1. HEADER ---
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Logos
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          if (ethioLogo != null) pw.Image(ethioLogo, width: 90),
                          pw.SizedBox(width: 10),
                          if (telebirrLogo != null) pw.Image(telebirrLogo, width: 70),
                        ],
                      ),
                      // Company Info
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Ethio telecom Share Company', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
                          _headerRow('TIN No.', '0000030603'),
                          _headerRow('VAT Reg. No.', '012700'),
                          _headerRow('VAT Reg. Date', '01/01/2003'),
                          _headerRow('P.O.Box', '1047 Addis Ababa, Ethiopia'),
                          _headerRow('Tel.', '251(0) 115 505 678'),
                        ],
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 5),
                  pw.Divider(color: _green, thickness: 1.5),

                  // --- 2. TITLE ---
                  pw.Center(
                    child: pw.Text(
                      'የቴሌብር ክፈያ መረጃ/telebirr Transaction information',
                      style: pw.TextStyle(color: _green, fontWeight: pw.FontWeight.bold, fontSize: 9),
                    ),
                  ),
                  pw.SizedBox(height: 5),

                  // --- 3. PAYER/RECEIVER INFO ---
                  _infoRow('የከፋይ ስም/Payer Name', payerName),
                  _infoRow('የከፋይ ቴሌብር ቁ./Payer telebirr no.', payerPhone),
                  _infoRow('የከፋይ አካውንት አይነት/Payer account type', payerAccountType),
                  _infoRow('የከፋይ ቲን ቁ. / Payer TIN No', payerTin),
                  _infoRow('የከፋይ ተ.እ.ታ.ቁ./VAT Reg. No', vatRegNo),
                  _infoRow('የከፋይ ተ.እ.ታ.ቁ. ምዝገባ ቀን/VAT Reg. Date', vatRegDate),
                  _infoRow('ገንዘብ ተቀባይ ስም/Credited Party name', creditedPartyName),
                  _infoRow('ገንዘብ ተቀባይ ቴሌብር ቁ./Credited party account no', creditedPartyAccount),
                  _infoRow('የክፍያው ሁኔታ/Transaction status', transactionStatus),
                  if (bankAccountNumber != null)
                    _infoRow('የባንክ አካውንት ቁጥር/Bank account number', bankAccountNumber),

                  pw.SizedBox(height: 15),

                  // --- 4. TABLE ---
                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.grey500, width: 0.5),
                    children: [
                      // Table Header
                      pw.TableRow(
                        decoration: const pw.BoxDecoration(color: _greyHeader),
                        children: [
                          _tableCell('የክፍያ ዝርዝር/ Invoice details', isHeader: true, colSpan: 3),
                        ],
                      ),
                      pw.TableRow(
                        children: [
                          _tableCell('የክፍያ ቁጥር/Invoice No.', isHeader: true),
                          _tableCell('የክፍያ ቀን/Payment date', isHeader: true),
                          _tableCell('የተከፈለው መጠን/Settled Amount', isHeader: true),
                        ],
                      ),
                      // Table Data
                      pw.TableRow(
                        children: [
                          _tableCell(invoiceNo),
                          _tableCell(paymentDate),
                          _tableCell('$settledAmount Birr'),
                        ],
                      ),
                    ],
                  ),

                  // --- 5. RIGHT ALIGNED SUMMARY ---
                  pw.Container(
                    width: double.infinity,
                    decoration: pw.BoxDecoration(
                      border: pw.Border(
                        left: const pw.BorderSide(color: PdfColors.grey500, width: 0.5),
                        right: const pw.BorderSide(color: PdfColors.grey500, width: 0.5),
                        bottom: const pw.BorderSide(color: PdfColors.grey500, width: 0.5),
                      ),
                    ),
                    child: pw.Row(
                      children: [
                        pw.Expanded(flex: 2, child: pw.SizedBox()), // Empty space on left
                        pw.Expanded(
                          flex: 1,
                          child: pw.Column(
                            children: [
                              _summaryRow('የቴምብር ካርድ/Stamp Duty', '$stampDuty Birr'),
                              _summaryRow('ቅናሽ/Discount Amount', '$discountAmount Birr'),
                              _summaryRow('የአገልግሎት ክፍያ/Service fee', '$serviceFee Birr'),
                              _summaryRow('የአገልግሎት ክፍያ ተ.እ.ታ/Service fee VAT', '$serviceFeeVat Birr'),
                              _summaryRow('ጠቅላላ የተከፈለ/Total Paid Amount', '$totalPaidAmount Birr', isBold: true),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  pw.SizedBox(height: 25),

                  // --- 6. BOTTOM INFO ---
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            _bottomInfoRow('የገንዘቡ ልክ በፊደል/Total Amount in word', amountInWords),
                            _bottomInfoRow('የክፍያ ዘዴ/Payment Mode', paymentMode),
                            _bottomInfoRow('የክፍያ ምክንያት/Payment Reason', paymentReason),
                            _bottomInfoRow('የክፍያ መንገድ/Payment channel', paymentChannel),
                            _bottomInfoRow('የደንበኛ ማስታወሻ/Customer Note', ''),
                          ],
                        ),
                      ),
                      // Stamp overlay area (handled by Stack, so we leave space here)
                      pw.SizedBox(width: 120),
                    ],
                  ),

                  pw.Spacer(),

                  // --- 7. QR CODE ---
                  pw.Center(
                    child: pw.Column(
                      children: [
                        pw.Container(
                          padding: const pw.EdgeInsets.all(3),
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: _green, width: 1.5),
                            borderRadius: pw.BorderRadius.circular(4),
                          ),
                          child: pw.BarcodeWidget(
                            data: 'telebirr_$invoiceNo',
                            barcode: pw.Barcode.qrCode(),
                            width: 60,
                            height: 60,
                            color: PdfColors.black,
                          ),
                        ),
                        pw.SizedBox(height: 5),
                        pw.Text('Scan the QR using telebirr SuperApp to verify the payment', style: const pw.TextStyle(fontSize: 6, color: PdfColors.grey700)),
                      ],
                    ),
                  ),

                  pw.SizedBox(height: 15),

                  // --- 8. FOOTER ---
                  pw.Text('ቴሌብርን ስለተጠቀሙ እናመሰግናለን/ Thank you for using telebirr', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
                  pw.SizedBox(height: 2),
                  pw.Text('ለተጨማሪ መረጃ/Please contact us:', style: const pw.TextStyle(fontSize: 7)),
                  pw.SizedBox(height: 15),

                  // Footer Banner
                  pw.Center(
                    child: bannerImg != null 
                        ? pw.Image(bannerImg, height: 25)
                        : pw.Container(
                            padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                            decoration: pw.BoxDecoration(
                              color: _green,
                              borderRadius: pw.BorderRadius.circular(12),
                            ),
                            child: pw.Text('Bringing new possibilities ⏩', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 10)),
                          ),
                  ),
                ],
              ),

              // --- 9. STAMP OVERLAY ---
              // Placed exactly like the screenshot over the bottom-right corner of the table/info
              if (stampImg != null)
                pw.Positioned(
                  right: 30,
                  bottom: 180,
                  child: pw.Image(stampImg, width: 110, height: 110),
                ),
              // Fallback fake stamp if no image provided
              if (stampImg == null)
                pw.Positioned(
                  right: 30,
                  bottom: 180,
                  child: pw.Transform.rotate(
                    angle: -0.15,
                    child: pw.Container(
                      width: 100,
                      height: 100,
                      decoration: pw.BoxDecoration(
                        shape: pw.BoxShape.circle,
                        border: pw.Border.all(color: _stampBlue, width: 1.5),
                      ),
                      alignment: pw.Alignment.center,
                      child: pw.Text(
                        'Ethio telecom Head Office',
                        style: pw.TextStyle(color: _stampBlue, fontSize: 8),
                      ),
                    ),
                  ),
                ),

              // --- 10. DIAGONAL STRIPES ---
              if (stripesImg != null)
                pw.Positioned(
                  right: -40,
                  bottom: -20,
                  child: pw.Image(stripesImg, width: 80),
                ),
            ],
          );
        },
      ),
    );

    final bytes = await pdf.save();
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'telebirr_receipt_$invoiceNo.pdf',
    );
  }

  static pw.Widget _headerRow(String label, String value) {
    return pw.Container(
      width: 160,
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 8)),
          pw.Text(value, style: const pw.TextStyle(fontSize: 8)),
        ],
      ),
    );
  }

  static pw.Widget _infoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
      child: pw.Row(
        children: [
          pw.Expanded(flex: 3, child: pw.Text(label, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey800))),
          pw.Expanded(flex: 4, child: pw.Text(value, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold))),
        ],
      ),
    );
  }

  static pw.Widget _bottomInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(width: 130, child: pw.Text(label, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey800))),
          pw.Expanded(
            child: pw.Container(
              decoration: const pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey400, width: 0.5)),
              ),
              child: pw.Text(value, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _tableCell(String text, {bool isHeader = false, int colSpan = 1}) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 4),
      alignment: pw.Alignment.center,
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 8,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static pw.Widget _summaryRow(String label, String value, {bool isBold = false}) {
    return pw.Container(
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.grey500, width: 0.5),
          left: pw.BorderSide(color: PdfColors.grey500, width: 0.5),
        ),
      ),
      padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 8, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
          pw.Text(value, style: pw.TextStyle(fontSize: 8, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
        ],
      ),
    );
  }
}
