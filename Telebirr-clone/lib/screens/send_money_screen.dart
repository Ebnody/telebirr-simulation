import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:telebirr/screens/success_screen.dart';
import 'package:telebirr/widgets/transfer_loading_overlay.dart';

class SendMoneyScreen extends StatefulWidget {
  const SendMoneyScreen({super.key});

  @override
  State<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen> {
  final TextEditingController _receiverController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _receiverController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _sendMoney() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulate sending money — overlay stays visible for 5 seconds
      Future.delayed(const Duration(seconds: 5), () {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        _navigateToSuccess();
      });
    }
  }

  /// Generates a unique 9-character alphanumeric transaction ID
  /// (matches telebirr's real format e.g. GAC9FLK43)
  String _generateTransactionId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random();
    return List.generate(9, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  void _navigateToSuccess() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SuccessScreen(
          amount: _amountController.text,
          receiver: _receiverController.text,
          transactionId: _generateTransactionId(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Color.fromRGBO(140, 199, 63, 1),
          statusBarIconBrightness: Brightness.dark,
        ),
        backgroundColor: const Color.fromRGBO(140, 199, 63, 1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Send Money',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildBody(),
          TransferLoadingOverlay(visible: _isLoading),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Container(
        color: const Color.fromRGBO(245, 245, 245, 1),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.wallet,
                        size: 60,
                        color: Color.fromRGBO(140, 199, 63, 1),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _receiverController,
                        decoration: InputDecoration(
                          labelText: 'Receiver Name',
                          hintText: 'Enter receiver name',
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter receiver name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(
                          labelText: 'Amount (ETB)',
                          hintText: 'Enter amount',
                          prefixIcon: const Icon(Icons.money),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter amount';
                          }
                          if (double.tryParse(value) == null || double.parse(value) <= 0) {
                            return 'Please enter a valid amount';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _sendMoney,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(140, 199, 63, 1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'SEND',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }
}
