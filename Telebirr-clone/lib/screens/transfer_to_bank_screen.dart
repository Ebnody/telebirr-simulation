import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:telebirr/data/bank_data.dart';
import 'package:telebirr/screens/transfer_to_bank_amount_screen.dart';

class TransferToBankScreen extends StatefulWidget {
  const TransferToBankScreen({super.key});

  @override
  State<TransferToBankScreen> createState() => _TransferToBankScreenState();
}

class _TransferToBankScreenState extends State<TransferToBankScreen> {
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _receiverController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  BankInfo? _selectedBank;

  @override
  void dispose() {
    _accountController.dispose();
    _receiverController.dispose();
    super.dispose();
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  void _continue() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBank == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a bank')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TransferToBankAmountScreen(
          bank: _selectedBank!,
          accountNumber: _accountController.text,
          receiverName: _receiverController.text,
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Transfer to Bank',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
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
                        Icons.account_balance,
                        size: 60,
                        color: Color.fromRGBO(140, 199, 63, 1),
                      ),
                      const SizedBox(height: 20),
                      _fieldLabel('Select Bank'),
                      DropdownButtonFormField<BankInfo>(
                        value: _selectedBank,
                        isExpanded: true,
                        decoration: InputDecoration(
                          hintText: 'Please Choose',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: ethiopianBanks
                            .map(
                              (bank) => DropdownMenuItem<BankInfo>(
                                value: bank,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: bank.brandColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        bank.name,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedBank = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a bank';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _fieldLabel('Account No'),
                      TextFormField(
                        controller: _accountController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          hintText: 'Enter Account Number',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter account number';
                          }
                          if (value.length < 6) {
                            return 'Account number is too short';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _fieldLabel("Receiver's Name"),
                      TextFormField(
                        controller: _receiverController,
                        decoration: InputDecoration(
                          hintText: "Enter Receiver's Name",
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
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _continue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(140, 199, 63, 1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'CONTINUE',
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
      ),
    );
  }
}
