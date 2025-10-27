import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

/// Currency Formatter
/// Class ini berisi utility untuk format mata uang Indonesia (Rupiah)
/// Mendukung format dengan dan tanpa desimal

class CurrencyFormatter {
  // ====================
  // FORMAT CURRENCY
  // ====================
  
  /// Format angka ke format Rupiah: Rp 1.000.000
  /// Contoh: CurrencyFormatter.format(1000000) -> "Rp 1.000.000"
  static String format(double amount, {bool withSymbol = true}) {
    final formatter = NumberFormat.currency(
      locale: AppConstants.currencyLocale,
      symbol: withSymbol ? AppConstants.currencySymbol : '',
      decimalDigits: 0, // Tidak pakai desimal untuk Rupiah
    );
    
    return formatter.format(amount).trim();
  }

  /// Format angka ke format Rupiah dengan desimal: Rp 1.000.000,50
  /// Contoh: CurrencyFormatter.formatWithDecimal(1000000.50) -> "Rp 1.000.000,50"
  static String formatWithDecimal(double amount, {bool withSymbol = true}) {
    final formatter = NumberFormat.currency(
      locale: AppConstants.currencyLocale,
      symbol: withSymbol ? AppConstants.currencySymbol : '',
      decimalDigits: 2,
    );
    
    return formatter.format(amount).trim();
  }

  // ====================
  // COMPACT FORMAT
  // ====================
  
  /// Format angka ke format compact: Rp 1,2 Jt atau Rp 1,5 M
  /// Berguna untuk display di card atau summary
  /// Contoh: 
  /// - 1.200.000 -> "Rp 1,2 Jt"
  /// - 1.500.000.000 -> "Rp 1,5 M"
  static String formatCompact(double amount, {bool withSymbol = true}) {
    final symbol = withSymbol ? '${AppConstants.currencySymbol} ' : '';
    
    if (amount >= 1000000000) {
      // Milyar
      final value = amount / 1000000000;
      return '$symbol${value.toStringAsFixed(1)} M';
    } else if (amount >= 1000000) {
      // Juta
      final value = amount / 1000000;
      return '$symbol${value.toStringAsFixed(1)} Jt';
    } else if (amount >= 1000) {
      // Ribu
      final value = amount / 1000;
      return '$symbol${value.toStringAsFixed(1)} Rb';
    } else {
      return '$symbol${amount.toStringAsFixed(0)}';
    }
  }

  // ====================
  // PARSING
  // ====================
  
  /// Parse string currency ke double
  /// Contoh: 
  /// - "Rp 1.000.000" -> 1000000.0
  /// - "1.000.000" -> 1000000.0
  /// - "1000000" -> 1000000.0
  static double? parse(String currencyString) {
    try {
      // Remove currency symbol, spaces, dan dots
      String cleaned = currencyString
          .replaceAll(AppConstants.currencySymbol, '')
          .replaceAll('.', '')
          .replaceAll(',', '.')
          .trim();
      
      return double.parse(cleaned);
    } catch (e) {
      return null;
    }
  }

  // ====================
  // HELPERS
  // ====================
  
  /// Format dengan tanda plus/minus untuk menunjukkan penambahan/pengurangan
  /// Contoh:
  /// - 1000000 -> "+Rp 1.000.000"
  /// - -500000 -> "-Rp 500.000"
  static String formatWithSign(double amount) {
    final sign = amount >= 0 ? '+' : '-';
    final formatted = format(amount.abs());
    return '$sign$formatted';
  }

  /// Format range currency: Rp 1.000.000 - Rp 5.000.000
  static String formatRange(double minAmount, double maxAmount) {
    final min = format(minAmount);
    final max = format(maxAmount);
    return '$min - $max';
  }

  /// Check apakah string adalah format currency yang valid
  static bool isValidCurrency(String value) {
    return parse(value) != null;
  }

  /// Format untuk input field (tanpa symbol, dengan separator)
  /// Berguna untuk real-time formatting di TextField
  /// Contoh: 1000000 -> "1.000.000"
  static String formatForInput(String value) {
    // Remove non-numeric characters
    String cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (cleaned.isEmpty) return '';
    
    // Parse ke number
    final number = double.tryParse(cleaned);
    if (number == null) return value;
    
    // Format dengan separator tapi tanpa symbol
    return format(number, withSymbol: false);
  }

  // ====================
  // TAX CALCULATION HELPERS
  // ====================
  
  /// Calculate percentage dari amount
  /// Contoh: calculatePercentage(1000000, 5) -> 50000 (5% dari 1jt)
  static double calculatePercentage(double amount, double percentage) {
    return amount * (percentage / 100);
  }

  /// Format dengan percentage
  /// Contoh: formatWithPercentage(1000000, 5) -> "Rp 50.000 (5%)"
  static String formatWithPercentage(double amount, double percentage) {
    final taxAmount = calculatePercentage(amount, percentage);
    return '${format(taxAmount)} ($percentage%)';
  }
}
