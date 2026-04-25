import 'dart:math';

import 'package:flutter/material.dart';
import 'package:telebirr/data/balance_store.dart';

class BalanceInfo extends StatefulWidget {
  final String label;
  final double labelFontSize;
  final double balanceFontSize;
  final CrossAxisAlignment crossAxisAlignment;
  final int minAmount;
  final int maxAmount;
  final String? persistKey;

  const BalanceInfo({
    super.key,
    required this.label,
    required this.labelFontSize,
    required this.balanceFontSize,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.minAmount = 40000,
    this.maxAmount = 50000,
    this.persistKey,
  });

  @override
  State<BalanceInfo> createState() => _BalanceInfoState();
}

class _BalanceInfoState extends State<BalanceInfo> {
  bool showBalance = false;
  late final int _balance;

  @override
  void initState() {
    super.initState();
    if (widget.persistKey != null) {
      _balance = BalanceStore.getOrCreate(
        widget.persistKey!,
        min: widget.minAmount,
        max: widget.maxAmount,
      );
    } else {
      final range = widget.maxAmount - widget.minAmount;
      _balance = widget.minAmount + Random().nextInt(range > 0 ? range : 1);
    }
  }

  void toggleBalanceVisibility() {
    setState(() {
      showBalance = !showBalance;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String balance = showBalance ? _balance.toString() : '******';
    return Column(
      crossAxisAlignment: widget.crossAxisAlignment,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.label,
              style: TextStyle(
                color: const Color.fromRGBO(247, 255, 234, 1),
                fontSize: widget.labelFontSize,
              ),
            ),
            InkWell(
              onTap: toggleBalanceVisibility,
              child: Icon(
                !showBalance
                    ? Icons.remove_red_eye_sharp
                    : Icons.visibility_off,
                size: 13,
                color: const Color.fromRGBO(247, 255, 234, 1),
              ),
            ),
          ],
        ),
        Text(
          balance,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: widget.balanceFontSize,
          ),
        ),
      ],
    );
  }
}
