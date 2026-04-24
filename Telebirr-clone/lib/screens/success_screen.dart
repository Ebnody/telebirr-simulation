import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:telebirr/utils/receipt_pdf.dart';
import 'package:telebirr/utils/telebirr_tariff.dart';

class SuccessScreen extends StatelessWidget {
  final String amount;
  final String receiver;
  final String transactionId;
  final String transactionType;
  final String? bankName;
  final String? bankAccountNumber;

  const SuccessScreen({
    super.key,
    required this.amount,
    required this.receiver,
    required this.transactionId,
    this.transactionType = 'Transfer Money',
    this.bankName,
    this.bankAccountNumber,
  });

  bool get _isBankTransfer =>
      bankName != null && bankAccountNumber != null;

  String get _currentTimestamp {
    final now = DateTime.now();
    return '${now.year}/${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
  }

  /// Parses the amount string safely as a double
  double get _amountValue => double.tryParse(amount) ?? 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(245, 245, 245, 1),
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarIconBrightness: Brightness.dark,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => _downloadPdf(context),
              child: const Row(
                children: [
                  Icon(
                    Icons.download,
                    color: Color.fromRGBO(140, 199, 63, 1),
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Download',
                    style: TextStyle(
                      color: Color.fromRGBO(140, 199, 63, 1),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _sharePdf(context),
              child: const Row(
                children: [
                  Icon(
                    Icons.share,
                    color: Color.fromRGBO(140, 199, 63, 1),
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Share',
                    style: TextStyle(
                      color: Color.fromRGBO(140, 199, 63, 1),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Success Icon
            Container(
              color: Colors.white,
              width: double.infinity,
              padding: const EdgeInsets.only(top: 20, bottom: 10),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(140, 199, 63, 1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Successfully',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            // Amount (Total Paid: amount + tariff)
            Container(
              color: Colors.white,
              width: double.infinity,
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '-${TelebirrTariff.formatCurrency(TelebirrTariff.calculateTotalPaid(_amountValue, isBankTransfer: _isBankTransfer))}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 6),
                    child: Text(
                      ' (ETB)',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Transaction Details
            Container(
              color: Colors.white,
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: _isBankTransfer
                    ? [
                        _buildDetailRow('Transaction Number', transactionId),
                        const Divider(height: 1, color: Color(0xFFEEEEEE)),
                        _buildDetailRow(
                            'Transaction Time', _currentTimestamp),
                        const Divider(height: 1, color: Color(0xFFEEEEEE)),
                        _buildDetailRow('Transaction Type', transactionType),
                        const Divider(height: 1, color: Color(0xFFEEEEEE)),
                        _buildDetailRow(
                            'Transaction To', receiver.toUpperCase()),
                        const Divider(height: 1, color: Color(0xFFEEEEEE)),
                        _buildDetailRow(
                            'Bank Account Number', bankAccountNumber!),
                        const Divider(height: 1, color: Color(0xFFEEEEEE)),
                        _buildDetailRow('Bank Name', bankName!),
                      ]
                    : [
                        _buildDetailRow(
                            'Transaction Time', _currentTimestamp),
                        const Divider(height: 1, color: Color(0xFFEEEEEE)),
                        _buildDetailRow('Transaction Type', transactionType),
                        const Divider(height: 1, color: Color(0xFFEEEEEE)),
                        _buildDetailRow(
                            'Transaction To', receiver.toUpperCase()),
                        const Divider(height: 1, color: Color(0xFFEEEEEE)),
                        _buildDetailRow('Transaction Number', transactionId),
                      ],
              ),
            ),

            // QR Code Button
            Container(
              color: Colors.white,
              margin: const EdgeInsets.only(top: 8),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.qr_code,
                    color: const Color.fromRGBO(140, 199, 63, 1),
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'QR Code',
                    style: TextStyle(
                      color: const Color.fromRGBO(140, 199, 63, 1),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Advertisement Banner
            Container(
              margin: const EdgeInsets.all(12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'images/banner-1.jpg',
                  width: double.infinity,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // Finished Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(140, 199, 63, 1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Finished',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadPdf(BuildContext context) async {
    try {
      final serviceFee = TelebirrTariff.calculateServiceFee(_amountValue,
          isBankTransfer: _isBankTransfer);
      final vat = TelebirrTariff.calculateVat(_amountValue,
          isBankTransfer: _isBankTransfer);
      final totalPaid = TelebirrTariff.calculateTotalPaid(_amountValue,
          isBankTransfer: _isBankTransfer);

      await ReceiptPdf.generateAndShare(
        payerName: 'Fikir Abebe Alayu',
        payerPhone: '2519****697',
        payerAccountType: 'Individual Customer',
        creditedPartyName: receiver.toUpperCase(),
        creditedPartyAccount: '2519****5506',
        transactionStatus: 'Completed',
        invoiceNo: transactionId,
        paymentDate: _currentTimestamp,
        settledAmount: TelebirrTariff.formatCurrency(_amountValue),
        stampDuty: '0.00',
        discountAmount: '0.00',
        serviceFee: TelebirrTariff.formatCurrency(serviceFee),
        serviceFeeVat: TelebirrTariff.formatCurrency(vat),
        totalPaidAmount: TelebirrTariff.formatCurrency(totalPaid),
        amountInWords: _numberToWords(totalPaid),
        paymentMode: 'telebirr',
        paymentReason: 'Send Money to Registered Customer',
        paymentChannel: 'API/App',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating PDF: $e')),
        );
      }
    }
  }

  Future<void> _sharePdf(BuildContext context) async {
    await _downloadPdf(context);
  }

  String _numberToWords(double number) {
    final wholePart = number.toInt();
    final decimalPart = ((number - wholePart) * 100).round();

    final ones = [
      '', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine',
      'ten', 'eleven', 'twelve', 'thirteen', 'fourteen', 'fifteen',
      'sixteen', 'seventeen', 'eighteen', 'nineteen'
    ];
    final tens = ['', '', 'twenty', 'thirty', 'forty', 'fifty',
        'sixty', 'seventy', 'eighty', 'ninety'];

    String convertLessThanThousand(int n) {
      if (n == 0) return '';
      if (n < 20) return ones[n];
      if (n < 100) {
        return tens[n ~/ 10] + (n % 10 != 0 ? ' ${ones[n % 10]}' : '');
      }
      return ones[n ~/ 100] + ' hundred' +
          (n % 100 != 0 ? ' ${convertLessThanThousand(n % 100)}' : '');
    }

    String convert(int n) {
      if (n == 0) return 'zero';
      if (n < 1000) return convertLessThanThousand(n);
      if (n < 1000000) {
        return convertLessThanThousand(n ~/ 1000) + ' thousand' +
            (n % 1000 != 0 ? ' ${convertLessThanThousand(n % 1000)}' : '');
      }
      return 'number too large';
    }

    String result = convert(wholePart) + ' birr';
    if (decimalPart > 0) {
      result += ' and ${convert(decimalPart)} cent';
    } else {
      result += ' and zero cent';
    }
    return result;
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.black87,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: isBold
                  ? const Color.fromRGBO(140, 199, 63, 1)
                  : Colors.black87,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
