import 'dart:math';

/// In-memory store for balances that must stay consistent across
/// different screens (e.g. the main account balance shown on the home
/// page and reused on the transfer-amount page).
///
/// Values are generated lazily on first access, keyed by a caller-provided
/// identifier, and cached for the lifetime of the app session.
class BalanceStore {
  BalanceStore._();

  static final Map<String, int> _cache = {};
  static final Random _random = Random();

  /// Returns the cached value for [key], generating a random integer in
  /// `[min, max)` on first access.
  static int getOrCreate(
    String key, {
    int min = 40000,
    int max = 50000,
  }) {
    final existing = _cache[key];
    if (existing != null) return existing;
    final range = max - min;
    final fresh = min + _random.nextInt(range > 0 ? range : 1);
    _cache[key] = fresh;
    return fresh;
  }

  /// Convenience getter for the main account balance used across screens.
  static int get mainBalance => getOrCreate('main_balance');
}
