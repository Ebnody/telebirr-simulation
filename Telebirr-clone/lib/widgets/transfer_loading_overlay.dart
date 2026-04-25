import 'package:flutter/material.dart';
import 'package:telebirr/widgets/dot_spinner.dart';

/// Full-screen overlay shown while a transfer is being processed.
/// Place inside a [Stack] above the page content and toggle with [visible].
class TransferLoadingOverlay extends StatelessWidget {
  final bool visible;

  const TransferLoadingOverlay({
    super.key,
    required this.visible,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.25),
        alignment: Alignment.center,
        child: Container(
          padding: const EdgeInsets.all(20),
          color: Colors.white,
          child: const DotSpinner(size: 80),
        ),
      ),
    );
  }
}
