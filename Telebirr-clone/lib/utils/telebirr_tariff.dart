/// Telebirr Transfer Tariff (VAT Inclusive)
/// Based on the official Telebirr tariff structure
class TelebirrTariff {
  /// Returns the total tariff (VAT-inclusive) for a given amount.
  ///
  /// P2P bands:
  ///   - <= 100: 1 Birr
  ///   - 101 to 500: 2 Birr
  ///   - 501 to 1500: 4 Birr
  ///   - 1501 to 5000: 6 Birr
  ///   - 5001 to 75000: 8 Birr
  ///
  /// Bank transfer bands (when [isBankTransfer] is true):
  ///   - <= 100: 1 Birr
  ///   - 101 to 500: 3 Birr
  ///   - 501 to 1500: 6 Birr
  ///   - 1501 to 5000: 9 Birr
  ///   - 5001 to 75000: 15 Birr
  static double calculateTariff(double amount,
      {bool isBankTransfer = false}) {
    if (isBankTransfer) {
      if (amount <= 100) return 1.0;
      if (amount <= 500) return 3.0;
      if (amount <= 1500) return 6.0;
      if (amount <= 5000) return 9.0;
      return 15.0;
    }
    if (amount <= 100) return 1.0;
    if (amount <= 500) return 2.0;
    if (amount <= 1500) return 4.0;
    if (amount <= 5000) return 6.0;
    return 8.0;
  }

  /// Service Fee = Tariff / 1.15 (VAT exclusive portion)
  static double calculateServiceFee(double amount,
      {bool isBankTransfer = false}) {
    final tariff = calculateTariff(amount, isBankTransfer: isBankTransfer);
    return tariff / 1.15;
  }

  /// VAT (15%) portion of the tariff
  static double calculateVat(double amount, {bool isBankTransfer = false}) {
    final tariff = calculateTariff(amount, isBankTransfer: isBankTransfer);
    return tariff - (tariff / 1.15);
  }

  /// Total paid amount = amount + tariff
  static double calculateTotalPaid(double amount,
      {bool isBankTransfer = false}) {
    return amount + calculateTariff(amount, isBankTransfer: isBankTransfer);
  }

  /// Format as a string with 2 decimals
  static String formatCurrency(double value) => value.toStringAsFixed(2);
}
