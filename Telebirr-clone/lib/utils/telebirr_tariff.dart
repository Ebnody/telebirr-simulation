/// Telebirr P2P Transfer Tariff (VAT Inclusive)
/// Based on the official Telebirr tariff structure
class TelebirrTariff {
  /// Returns the total tariff (VAT-inclusive) for a given amount
  /// Bands:
  ///   - < 100: 1 Birr
  ///   - 101 to 500: 2 Birr
  ///   - 501 to 1500: 4 Birr
  ///   - 1501 to 5000: 6 Birr
  ///   - 5001 to 75000: 8 Birr
  static double calculateTariff(double amount) {
    if (amount <= 100) return 1.0;
    if (amount <= 500) return 2.0;
    if (amount <= 1500) return 4.0;
    if (amount <= 5000) return 6.0;
    if (amount <= 75000) return 8.0;
    return 8.0; // default fallback for amounts above 75000
  }

  /// Service Fee = Tariff / 1.15 (VAT exclusive portion)
  static double calculateServiceFee(double amount) {
    final tariff = calculateTariff(amount);
    return tariff / 1.15;
  }

  /// VAT (15%) portion of the tariff
  static double calculateVat(double amount) {
    final tariff = calculateTariff(amount);
    return tariff - (tariff / 1.15);
  }

  /// Total paid amount = amount + tariff
  static double calculateTotalPaid(double amount) {
    return amount + calculateTariff(amount);
  }

  /// Format as a string with 2 decimals
  static String formatCurrency(double value) => value.toStringAsFixed(2);
}
