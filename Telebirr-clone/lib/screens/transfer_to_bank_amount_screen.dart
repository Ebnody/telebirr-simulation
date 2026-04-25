import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:telebirr/data/balance_store.dart';
import 'package:telebirr/data/bank_data.dart';
import 'package:telebirr/screens/success_screen.dart';
import 'package:telebirr/widgets/transfer_loading_overlay.dart';

/// Second step of the Transfer-to-Bank flow.
/// Displays the selected bank as a brand-colored header card and lets the
/// user enter the amount before submitting the transfer.
class TransferToBankAmountScreen extends StatefulWidget {
  final BankInfo bank;
  final String accountNumber;
  final String receiverName;

  const TransferToBankAmountScreen({
    super.key,
    required this.bank,
    required this.accountNumber,
    required this.receiverName,
  });

  @override
  State<TransferToBankAmountScreen> createState() =>
      _TransferToBankAmountScreenState();
}

class _TransferToBankAmountScreenState
    extends State<TransferToBankAmountScreen> {
  final TextEditingController _amountController = TextEditingController();
  final FocusNode _amountFocusNode = FocusNode();
  bool _isLoading = false;
  String? _errorText;
  bool _showKeypad = false;

  @override
  void initState() {
    super.initState();
    _amountFocusNode.addListener(() {
      if (!mounted) return;
      setState(() => _showKeypad = _amountFocusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  void _onKeyTap(String key) {
    final current = _amountController.text;
    String next = current;
    if (key == 'back') {
      if (current.isNotEmpty) {
        next = current.substring(0, current.length - 1);
      }
    } else if (key == '.') {
      if (!current.contains('.') && current.isNotEmpty) {
        next = '$current.';
      } else if (current.isEmpty) {
        next = '0.';
      }
    } else {
      next = '$current$key';
    }
    _amountController.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: next.length),
    );
    if (_errorText != null) {
      setState(() => _errorText = null);
    }
  }

  /// Generates a unique 9-character alphanumeric transaction ID
  /// (matches telebirr's real format e.g. GAC9FLK43)
  String _generateTransactionId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random();
    return List.generate(9, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  void _submit() {
    final raw = _amountController.text.trim();
    final parsed = double.tryParse(raw);
    if (raw.isEmpty || parsed == null || parsed <= 0) {
      setState(() => _errorText = 'Please enter a valid amount');
      return;
    }

    setState(() {
      _errorText = null;
      _isLoading = true;
    });

    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SuccessScreen(
            amount: raw,
            receiver: widget.receiverName,
            transactionId: _generateTransactionId(),
            transactionType: 'Transfer to Bank',
            bankName: widget.bank.name,
            bankAccountNumber: widget.accountNumber,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarIconBrightness: Brightness.dark,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Transfer to Bank',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _amountFocusNode.unfocus(),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildBody(),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              left: 0,
              right: 0,
              bottom: _showKeypad ? 0 : -360,
              child: _buildKeypad(),
            ),
            TransferLoadingOverlay(visible: _isLoading),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(12, 12, 12, _showKeypad ? 320 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBankHeader(),
          const SizedBox(height: 12),
          _buildAmountCard(),
          const SizedBox(height: 14),
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              foregroundColor: const Color.fromRGBO(140, 199, 63, 1),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () {},
            child: const Text(
              'Add notes(optional)',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankHeader() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: widget.bank.brandColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _buildLogo(widget.bank),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.receiverName.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${widget.bank.name} (${widget.accountNumber})',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo(BankInfo bank) {
    final box = Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(3),
      child: bank.logoAsset != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.asset(
                bank.logoAsset!,
                fit: BoxFit.contain,
              ),
            )
          : Icon(
              Icons.account_balance,
              color: bank.brandColor,
              size: 26,
            ),
    );
    return box;
  }

  Widget _buildAmountCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Amount',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: _amountController,
                  focusNode: _amountFocusNode,
                  showCursor: true,
                  keyboardType: TextInputType.none,
                  textAlign: TextAlign.left,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      if ('.'.allMatches(newValue.text).length > 1) {
                        return oldValue;
                      }
                      return newValue;
                    }),
                  ],
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    hintText: '',
                  ),
                  onTap: () => _amountFocusNode.requestFocus(),
                  onChanged: (_) {
                    if (_errorText != null) {
                      setState(() => _errorText = null);
                    }
                  },
                ),
              ),
              const SizedBox(width: 6),
              const Padding(
                padding: EdgeInsets.only(bottom: 2),
                child: Text(
                  '(ETB)',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Divider(height: 1),
          const SizedBox(height: 8),
          Text(
            'Balance: ${BalanceStore.mainBalance}.00 (ETB)',
            style: const TextStyle(
              color: Color(0xFF1F75BB),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          if (_errorText != null) ...[
            const SizedBox(height: 6),
            Text(
              _errorText!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildKeypad() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F5),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _amountFocusNode.unfocus(),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.black54,
                  size: 22,
                ),
              ),
            ),
            SizedBox(
              height: 280,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(6, 0, 6, 6),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          Expanded(child: _digitRow(['1', '2', '3'])),
                          Expanded(child: _digitRow(['4', '5', '6'])),
                          Expanded(child: _digitRow(['7', '8', '9'])),
                          Expanded(child: _digitRow(['', '0', '.'])),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          Expanded(flex: 1, child: _backspaceKey()),
                          Expanded(flex: 3, child: _transferKey()),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _digitRow(List<String> keys) {
    return Row(
      children: keys
          .map((k) => Expanded(
                child: k.isEmpty
                    ? const SizedBox.shrink()
                    : _digitKey(k),
              ))
          .toList(),
    );
  }

  Widget _digitKey(String label) {
    return Padding(
      padding: const EdgeInsets.all(3),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: () => _onKeyTap(label),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _backspaceKey() {
    return Padding(
      padding: const EdgeInsets.all(3),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: () => _onKeyTap('back'),
          child: const Center(
            child: Icon(
              Icons.backspace_outlined,
              color: Colors.black87,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }

  Widget _transferKey() {
    return Padding(
      padding: const EdgeInsets.all(3),
      child: Material(
        color: const Color(0xFFCDE9B5),
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: _isLoading ? null : _submit,
          child: const Center(
            child: Text(
              'Transfer',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
