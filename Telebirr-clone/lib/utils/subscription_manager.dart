import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages subscription codes and activation state using SharedPreferences.
/// Cross-platform (works on Android, iOS, Web, Windows, etc.)
/// Pre-defined code pools for three tiers: daily, weekly, monthly.
class SubscriptionManager {
  static const String _kExpiryKey = 'telebirr_sub_expiry';
  static const String _kUsedCodesKey = 'telebirr_sub_used_codes';
  static const String _kPlanKey = 'telebirr_sub_plan';

  /// Pre-defined DAILY codes (1 day subscription)
  static const List<String> dailyCodes = [
    '481726', '903451', '276894', '158732', '647029',
    '392148', '817563', '524901', '736285', '105478',
    '659382', '841027', '293675', '518460', '732916',
    '084591', '467283', '915840', '358729', '672145',
  ];

  /// Pre-defined WEEKLY codes (7 days subscription)
  static const List<String> weeklyCodes = [
    '713804', '256931', '489107', '638245', '527108',
    '391486', '804529', '652073', '178394', '945261',
    '307815', '562148', '873024', '219637', '458091',
    '691753', '027489', '834256', '145938', '573620',
  ];

  /// Pre-defined MONTHLY codes (30 days subscription)
  static const List<String> monthlyCodes = [
    '926473', '158064', '745219', '382615', '509841',
    '671293', '248057', '913486', '564720', '037198',
    '826359', '491605', '753084', '168927', '430872',
    '592416', '087354', '619508', '234971', '785203',
  ];

  /// Returns the current subscription expiry date (null if not subscribed)
  static Future<DateTime?> getExpiryDate() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kExpiryKey);
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  /// Returns the active plan name (null if not subscribed)
  static Future<String?> getActivePlan() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kPlanKey);
  }

  /// Checks if the subscription is currently active
  static Future<bool> isActive() async {
    final expiry = await getExpiryDate();
    if (expiry == null) return false;
    return DateTime.now().isBefore(expiry);
  }

  /// Returns the set of codes that have already been used on this device
  static Future<Set<String>> getUsedCodes() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kUsedCodesKey);
    if (raw == null || raw.isEmpty) return <String>{};
    try {
      final list = (jsonDecode(raw) as List).cast<String>();
      return list.toSet();
    } catch (_) {
      return <String>{};
    }
  }

  /// Persists the set of used codes
  static Future<void> _saveUsedCodes(Set<String> used) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUsedCodesKey, jsonEncode(used.toList()));
  }

  /// Validates and activates the code. Returns the activation result.
  static Future<ActivationResult> activate(String code) async {
    final trimmed = code.trim();
    if (trimmed.length != 6 || int.tryParse(trimmed) == null) {
      return ActivationResult.invalidFormat;
    }

    final used = await getUsedCodes();
    if (used.contains(trimmed)) {
      return ActivationResult.alreadyUsed;
    }

    SubscriptionPlan? plan;
    if (dailyCodes.contains(trimmed)) {
      plan = SubscriptionPlan.daily;
    } else if (weeklyCodes.contains(trimmed)) {
      plan = SubscriptionPlan.weekly;
    } else if (monthlyCodes.contains(trimmed)) {
      plan = SubscriptionPlan.monthly;
    }

    if (plan == null) return ActivationResult.notFound;

    // Compute expiry: extend from existing expiry if still active
    final now = DateTime.now();
    final stillActive = await isActive();
    final existing = await getExpiryDate();
    final base = stillActive ? (existing ?? now) : now;
    final expiry = base.add(plan.duration);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kExpiryKey, expiry.toIso8601String());
    await prefs.setString(_kPlanKey, plan.label);

    // Mark code as used
    used.add(trimmed);
    await _saveUsedCodes(used);

    return ActivationResult.success(plan, expiry);
  }

  /// Clears the current subscription (for testing/reset)
  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kExpiryKey);
    await prefs.remove(_kPlanKey);
    await prefs.remove(_kUsedCodesKey);
  }
}

/// Subscription tier definition
class SubscriptionPlan {
  final String label;
  final Duration duration;
  final String priceLabel;

  const SubscriptionPlan._(this.label, this.duration, this.priceLabel);

  static const daily = SubscriptionPlan._('Daily', Duration(days: 1), '1 Day');
  static const weekly = SubscriptionPlan._('Weekly', Duration(days: 7), '1 Week');
  static const monthly = SubscriptionPlan._('Monthly', Duration(days: 30), '1 Month');
}

/// Activation outcomes
class ActivationResult {
  final bool isSuccess;
  final String message;
  final SubscriptionPlan? plan;
  final DateTime? expiresAt;

  const ActivationResult._(this.isSuccess, this.message,
      {this.plan, this.expiresAt});

  factory ActivationResult.success(SubscriptionPlan plan, DateTime expiresAt) {
    return ActivationResult._(
      true,
      '${plan.label} subscription activated until ${_formatDate(expiresAt)}',
      plan: plan,
      expiresAt: expiresAt,
    );
  }

  static const invalidFormat = ActivationResult._(
    false,
    'Please enter a valid 6-digit code.',
  );
  static const notFound = ActivationResult._(
    false,
    'Invalid code. Please check and try again.',
  );
  static const alreadyUsed = ActivationResult._(
    false,
    'This code has already been used.',
  );

  static String _formatDate(DateTime d) {
    return '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')} '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}
