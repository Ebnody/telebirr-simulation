import 'package:flutter/material.dart';

/// Information about a destination bank, including its display name,
/// brand color (used for the transfer header) and an optional logo asset.
class BankInfo {
  final String name;
  final Color brandColor;
  final String? logoAsset;

  const BankInfo({
    required this.name,
    required this.brandColor,
    this.logoAsset,
  });
}

/// All supported destination banks, kept alphabetically sorted.
/// Logo assets live in the `images/` folder. Banks for which we could not
/// source a real logo fall back to a generic icon rendered on top of the
/// bank's brand color.
const List<BankInfo> ethiopianBanks = [
  BankInfo(
    name: 'Abay Bank',
    brandColor: Color(0xFF1F4870),
    logoAsset: 'images/abay_bank.png',
  ),
  BankInfo(
    name: 'Ahadu Bank',
    brandColor: Color(0xFFA8082E),
    logoAsset: 'images/ahadu_bank.png',
  ),
  BankInfo(
    name: 'Amhara Bank',
    brandColor: Color(0xFF0E68A8),
    logoAsset: 'images/amhara_bank.png',
  ),
  BankInfo(
    name: 'Awash Bank',
    brandColor: Color(0xFFF18A1F),
    logoAsset: 'images/awash.jpg',
  ),
  BankInfo(
    name: 'Bank of Abyssinia',
    brandColor: Color(0xFFEDA224),
    logoAsset: 'images/bank_of_abyssinia.png',
  ),
  BankInfo(
    name: 'Berhan Bank',
    brandColor: Color(0xFFE5A60A),
    logoAsset: 'images/berhan_bank.png',
  ),
  BankInfo(
    name: 'Bunna Bank',
    brandColor: Color(0xFF7A1F22),
    logoAsset: 'images/bunna_bank.png',
  ),
  BankInfo(
    name: 'Commercial Bank of Ethiopia',
    brandColor: Color(0xFF7E1F8B),
    logoAsset: 'images/cbe.png',
  ),
  BankInfo(
    name: 'Cooperative Bank of Oromia',
    brandColor: Color(0xFF0AA8E8),
    logoAsset: 'images/cooperative_bank_of_oromia.png',
  ),
  BankInfo(
    name: 'Dashen Bank',
    brandColor: Color(0xFF233377),
    logoAsset: 'images/dashen.png',
  ),
  BankInfo(
    name: 'Debub Global Bank',
    brandColor: Color(0xFFE5A917),
    logoAsset: 'images/debub_global_bank.png',
  ),
  BankInfo(
    name: 'Hibret Bank',
    brandColor: Color(0xFF45176B),
    logoAsset: 'images/hibret_bank.png',
  ),
  BankInfo(
    name: 'Hijra Bank',
    brandColor: Color(0xFF2070F0),
    logoAsset: 'images/hijra_bank.png',
  ),
  BankInfo(
    name: 'Nib International Bank',
    brandColor: Color(0xFF8A4815),
    logoAsset: 'images/nib_international_bank.png',
  ),
  BankInfo(
    name: 'Oromia Bank',
    brandColor: Color(0xFF14C708),
    logoAsset: 'images/oromia_international_bank.png',
  ),
  BankInfo(
    name: 'Sidama Bank',
    brandColor: Color(0xFF259425),
    logoAsset: 'images/sidama_bank.png',
  ),
  BankInfo(
    name: 'Tsehay Bank',
    brandColor: Color(0xFFF8C508),
    logoAsset: 'images/tsehay_bank.png',
  ),
  BankInfo(
    name: 'Wegagen Bank',
    brandColor: Color(0xFFF85928),
    logoAsset: 'images/wegagen_bank.png',
  ),
  BankInfo(
    name: 'Zemen Bank',
    brandColor: Color(0xFFC8203F),
    logoAsset: 'images/zemen_bank.png',
  ),
];
