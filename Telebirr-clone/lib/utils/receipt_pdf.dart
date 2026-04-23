import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Cross-platform receipt PDF generator using the `pdf` package.
/// Works on Android, iOS, Web, Windows, and macOS.
class ReceiptPdf {
  static const PdfColor _green = PdfColor.fromInt(0xFF8CC63F);
  static const PdfColor _blue = PdfColor.fromInt(0xFF0089D0);
  static const PdfColor _stampBlue = PdfColor.fromInt(0xFF1F4A9C);
  static const PdfColor _darkGreen = PdfColor.fromInt(0xFF17B877);
  static const PdfColor _greyBorder = PdfColor.fromInt(0xFFB5B5B5);
  static const PdfColor _greyHeader = PdfColor.fromInt(0xFFE8E8E8);
  static const PdfColor _lightGrey = PdfColor.fromInt(0xFFECECEC);
  static const PdfColor _yellow = PdfColor.fromInt(0xFFFFC107);
  static const PdfColor _red = PdfColor.fromInt(0xFFE7332C);

  static Future<void> generateAndShare({
    required String payerName,
    required String payerPhone,
    required String payerAccountType,
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
  }) async {
    final pdf = pw.Document();

    // Load Amharic-capable font
    final ttfReg =
        await rootBundle.load('packages/printing/assets/NotoKufiArabic-Regular.ttf');
    final fontReg = pw.Font.ttf(ttfReg);
    pw.Font fontBold;
    try {
      final ttfBold =
          await rootBundle.load('packages/printing/assets/NotoKufiArabic-Bold.ttf');
      fontBold = pw.Font.ttf(ttfBold);
    } catch (_) {
      fontBold = fontReg;
    }

    // Attempt to load Amharic font from Google Fonts via printing
    pw.Font amharicFont = fontReg;
    try {
      amharicFont = await PdfGoogleFonts.notoSansEthiopicRegular();
    } catch (_) {}

    pw.Font amharicFontBold = fontBold;
    try {
      amharicFontBold = await PdfGoogleFonts.notoSansEthiopicBold();
    } catch (_) {}

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(30, 25, 30, 25),
        theme: pw.ThemeData.withFont(
          base: amharicFont,
          bold: amharicFontBold,
        ),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // TOP HEADER
              _buildHeader(),
              pw.SizedBox(height: 6),
              pw.Container(height: 1.5, color: _green),
              pw.SizedBox(height: 6),

              // Title
              pw.Center(
                child: pw.Text(
                  'የቴሌብር ግብይት መረጃ / telebirr Transaction information',
                  style: pw.TextStyle(
                    fontSize: 12,
                    color: _green,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Container(height: 1.5, color: _green),
              pw.SizedBox(height: 10),

              // Transaction info
              _buildTransactionInfo(
                payerName: payerName,
                payerPhone: payerPhone,
                payerAccountType: payerAccountType,
                creditedPartyName: creditedPartyName,
                creditedPartyAccount: creditedPartyAccount,
                transactionStatus: transactionStatus,
              ),

              pw.SizedBox(height: 10),

              // Invoice header bar
              pw.Container(
                color: _greyHeader,
                padding: const pw.EdgeInsets.symmetric(vertical: 4),
                decoration: pw.BoxDecoration(
                  color: _greyHeader,
                  border: pw.Border.all(color: _greyBorder, width: 0.5),
                ),
                child: pw.Center(
                  child: pw.Text(
                    'የክፍያ ዝርዝር / Invoice details',
                    style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // Invoice table + fees
              _buildInvoiceTable(
                invoiceNo: invoiceNo,
                paymentDate: paymentDate,
                settledAmount: settledAmount,
                stampDuty: stampDuty,
                discountAmount: discountAmount,
                serviceFee: serviceFee,
                serviceFeeVat: serviceFeeVat,
                totalPaidAmount: totalPaidAmount,
              ),

              pw.SizedBox(height: 16),

              // Payment details + stamp
              _buildPaymentDetails(
                amountInWords: amountInWords,
                paymentMode: paymentMode,
                paymentReason: paymentReason,
                paymentChannel: paymentChannel,
              ),

              pw.SizedBox(height: 16),

              // QR label
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Container(
                      width: 90,
                      height: 90,
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.black, width: 0.5),
                      ),
                      child: pw.BarcodeWidget(
                        data: 'telebirr_$invoiceNo',
                        barcode: pw.Barcode.qrCode(),
                        drawText: false,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Scan the QR using telebirr SuperApp to verify the payment',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 12),

              pw.Text(
                'ቴሌብርን ስለተጠቀሙ እናመሰግናለን / Thank you for using telebirr',
                style: const pw.TextStyle(fontSize: 10),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'ለተጨማሪ መረጃ / Please contact us:',
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'https://www.facebook.com/telebirr   https://x.com/telebirr   telebirr@ethiotel.et   https://t.me/telebirr',
                style: pw.TextStyle(fontSize: 8, color: _blue),
              ),

              pw.Spacer(),

              // Bottom green bar
              _buildBottomBar(),
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

  static pw.Widget _buildHeader() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Container(
              width: 28,
              height: 28,
              decoration: pw.BoxDecoration(
                color: _green,
                shape: pw.BoxShape.circle,
              ),
              alignment: pw.Alignment.center,
              child: pw.Text(
                'e',
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
            ),
            pw.SizedBox(width: 6),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'ethio',
                  style: pw.TextStyle(
                    color: _green,
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text('telecom',
                    style: const pw.TextStyle(fontSize: 9)),
              ],
            ),
            pw.SizedBox(width: 12),
            pw.Text(
              'telebirr',
              style: pw.TextStyle(
                color: _blue,
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
                fontStyle: pw.FontStyle.italic,
              ),
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Ethio telecom Share Company',
                style: pw.TextStyle(
                    fontSize: 9, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 3),
            _kv('TIN No.', '0000030603'),
            _kv('VAT Reg. No.', '012700'),
            _kv('VAT Reg. Date', '01/01/2005'),
            _kv('P.O.Box', 'K047 Addis Ababa, Ethiopia'),
            _kv('Tel.', '25111 55 505 678'),
          ],
        ),
      ],
    );
  }

  static pw.Widget _kv(String k, String v) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 0.5),
      child: pw.Row(
        children: [
          pw.SizedBox(
              width: 80, child: pw.Text(k, style: const pw.TextStyle(fontSize: 8))),
          pw.Text(v, style: const pw.TextStyle(fontSize: 8)),
        ],
      ),
    );
  }

  static pw.Widget _buildTransactionInfo({
    required String payerName,
    required String payerPhone,
    required String payerAccountType,
    required String creditedPartyName,
    required String creditedPartyAccount,
    required String transactionStatus,
  }) {
    final rows = <List<String>>[
      ['የከፋይ ስም / Payer Name', payerName],
      ['የከፋይ ቴሌብር ቁ. / Payer telebirr no.', payerPhone],
      ['የከፋይ አካውንት አይነት / Payer account type', payerAccountType],
      ['የከፋይ ቲ.አ.ን ቁ. / Payer TIN No', ''],
      ['የከፋይ ቫ.ት.መ.ቁ / Payer VAT Reg. No', ''],
      ['የከፋይ ቫ.ት.መ.ቀን / Payer VAT Reg. Date', ''],
      ['ገንዘብ ተቀባይ ስም / Credited Party name', creditedPartyName],
      ['ገንዘብ ተቀባይ አካውንት ቁ. / Credited party account no', creditedPartyAccount],
      ['የግብይት ሁኔታ / transaction status', transactionStatus],
    ];

    return pw.Column(
      children: rows.map((row) {
        final isStatus = row[0].contains('transaction status');
        return pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
          child: pw.Row(
            children: [
              pw.Expanded(
                flex: 5,
                child: pw.Text(row[0],
                    style: const pw.TextStyle(fontSize: 9)),
              ),
              pw.Expanded(
                flex: 4,
                child: pw.Text(
                  row[1],
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: isStatus ? _darkGreen : PdfColors.black,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  static pw.Widget _buildInvoiceTable({
    required String invoiceNo,
    required String paymentDate,
    required String settledAmount,
    required String stampDuty,
    required String discountAmount,
    required String serviceFee,
    required String serviceFeeVat,
    required String totalPaidAmount,
  }) {
    final cellStyle = const pw.TextStyle(fontSize: 9);
    final boldStyle =
        pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold);
    final border = pw.TableBorder.all(color: _greyBorder, width: 0.5);

    return pw.Column(children: [
      pw.Table(
        border: border,
        columnWidths: {
          0: const pw.FlexColumnWidth(1),
          1: const pw.FlexColumnWidth(1),
          2: const pw.FlexColumnWidth(1),
        },
        children: [
          pw.TableRow(children: [
            _tableCell('የክፍያ ቁጥር / Invoice No.', cellStyle, center: true),
            _tableCell('የክፍያ ቀን / Payment date', cellStyle, center: true),
            _tableCell('የተከፈለው መጠን / Settled Amount', cellStyle, center: true),
          ]),
          pw.TableRow(children: [
            _tableCell(invoiceNo, cellStyle, center: true),
            _tableCell(paymentDate, cellStyle, center: true),
            _tableCell('$settledAmount Birr', cellStyle, center: true),
          ]),
        ],
      ),
      pw.Table(
        border: border,
        columnWidths: {
          0: const pw.FlexColumnWidth(2),
          1: const pw.FlexColumnWidth(1),
        },
        children: [
          _feeRow('የቴምብር ቀረጥ / Stamp Duty', '$stampDuty Birr', cellStyle),
          _feeRow('ቅናሽ / Discount Amount', '$discountAmount Birr', cellStyle),
          _feeRow('የአገልግሎት ክፍያ / Service fee', '$serviceFee Birr', cellStyle),
          _feeRow(
              'የአገልግሎት ክፍያ ቫት / Service fee VAT', '$serviceFeeVat Birr', cellStyle),
          _feeRow('ጠቅላላ የተከፈለ መጠን / Total Paid Amount',
              '$totalPaidAmount Birr', boldStyle),
        ],
      ),
    ]);
  }

  static pw.TableRow _feeRow(String label, String value, pw.TextStyle style) {
    return pw.TableRow(children: [
      _tableCell(label, style, alignRight: true),
      _tableCell(value, style, center: true),
    ]);
  }

  static pw.Widget _tableCell(String text, pw.TextStyle style,
      {bool center = false, bool alignRight = false}) {
    pw.Alignment align = pw.Alignment.centerLeft;
    if (center) align = pw.Alignment.center;
    if (alignRight) align = pw.Alignment.centerRight;
    return pw.Container(
      alignment: align,
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(text, style: style),
    );
  }

  static pw.Widget _buildPaymentDetails({
    required String amountInWords,
    required String paymentMode,
    required String paymentReason,
    required String paymentChannel,
  }) {
    final rows = <List<String>>[
      ['ጠቅላላ የተከፈለ ገንዘብ በፊደል / Total Amount in word', amountInWords],
      ['የክፍያ ዘዴ / Payment Mode', paymentMode],
      ['የክፍያ ምክንያት / Payment Reason', paymentReason],
      ['የክፍያ መንገድ / Payment channel', paymentChannel],
      ['ደንበኛ መልዕክት / Customer Note', ''],
    ];

    return pw.Stack(children: [
      // Water-mark "telebirr" faded
      pw.Positioned(
        left: 40,
        top: 20,
        child: pw.Transform.rotate(
          angle: -0.35,
          child: pw.Text(
            'telebirr',
            style: pw.TextStyle(
              fontSize: 56,
              color: _lightGrey,
              fontStyle: pw.FontStyle.italic,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
      ),
      // Details rows
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 3,
            child: pw.Column(
              children: rows
                  .map((row) => pw.Container(
                        margin: const pw.EdgeInsets.only(bottom: 2),
                        decoration: pw.BoxDecoration(
                          border: pw.Border(
                            bottom: pw.BorderSide(
                              color: PdfColors.grey400,
                              width: 0.5,
                              style: pw.BorderStyle.dashed,
                            ),
                          ),
                        ),
                        padding: const pw.EdgeInsets.symmetric(vertical: 2),
                        child: pw.Row(children: [
                          pw.Expanded(
                            flex: 3,
                            child: pw.Text(row[0],
                                style: const pw.TextStyle(fontSize: 9)),
                          ),
                          pw.Expanded(
                            flex: 3,
                            child: pw.Text(
                              row[1],
                              style: pw.TextStyle(
                                fontSize: 9,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                        ]),
                      ))
                  .toList(),
            ),
          ),
          // Stamp on right
          pw.Container(
            width: 120,
            height: 120,
            alignment: pw.Alignment.center,
            child: _buildStamp(),
          ),
        ],
      ),
    ]);
  }

  static pw.Widget _buildStamp() {
    return pw.Transform.rotate(
      angle: -0.14,
      child: pw.Container(
        width: 110,
        height: 110,
        decoration: pw.BoxDecoration(
          shape: pw.BoxShape.circle,
          border: pw.Border.all(color: _stampBlue, width: 2.5),
        ),
        child: pw.Stack(
          alignment: pw.Alignment.center,
          children: [
            pw.Container(
              width: 95,
              height: 95,
              decoration: pw.BoxDecoration(
                shape: pw.BoxShape.circle,
                border: pw.Border.all(color: _stampBlue, width: 0.8),
              ),
            ),
            pw.Container(
              width: 55,
              height: 55,
              decoration: pw.BoxDecoration(
                shape: pw.BoxShape.circle,
                border: pw.Border.all(color: _stampBlue, width: 1.8),
              ),
              alignment: pw.Alignment.center,
              child: pw.Text(
                'e',
                style: pw.TextStyle(
                  fontSize: 34,
                  color: _stampBlue,
                  fontWeight: pw.FontWeight.bold,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
            ),
            pw.Positioned(
              top: 10,
              child: pw.Text('Ethio Telecom Head Office',
                  style: pw.TextStyle(
                      fontSize: 5.5,
                      color: _stampBlue,
                      fontWeight: pw.FontWeight.bold)),
            ),
            pw.Positioned(
              bottom: 10,
              child: pw.Text('Federal Democratic Republic of Ethiopia',
                  style: pw.TextStyle(
                      fontSize: 5.5,
                      color: _stampBlue,
                      fontWeight: pw.FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildBottomBar() {
    return pw.Row(children: [
      pw.Expanded(
        child: pw.Container(
          height: 26,
          decoration: pw.BoxDecoration(
            color: _green,
            borderRadius: pw.BorderRadius.circular(13),
          ),
          alignment: pw.Alignment.center,
          child: pw.Text(
            'Bringing new possibilities',
            style: pw.TextStyle(
              color: PdfColors.white,
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
      ),
      pw.SizedBox(width: 8),
      pw.Container(
        width: 70,
        height: 36,
        child: pw.Stack(
          children: [
            _diagStripe(4, _green),
            _diagStripe(10, _yellow),
            _diagStripe(16, _red),
            _diagStripe(22, _blue),
          ],
        ),
      ),
    ]);
  }

  static pw.Widget _diagStripe(double top, PdfColor color) {
    return pw.Positioned(
      top: top,
      right: -5,
      child: pw.Transform.rotate(
        angle: -0.78,
        child: pw.Container(
          width: 70,
          height: 5,
          decoration: pw.BoxDecoration(
            color: color,
            borderRadius: pw.BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}
