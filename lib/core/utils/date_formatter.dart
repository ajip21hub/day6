import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../constants/app_constants.dart';

/// Date Formatter
/// Class ini berisi utility untuk format tanggal
/// Mendukung format Indonesia (id_ID)

class DateFormatter {
  // Initialize locale Indonesia
  static Future<void> initialize() async {
    await initializeDateFormatting('id_ID', null);
  }

  // ====================
  // DISPLAY FORMAT
  // ====================
  
  /// Format tanggal untuk display: 15 Jan 2024
  /// Contoh: DateFormatter.toDisplayDate(DateTime.now()) -> "15 Jan 2024"
  static String toDisplayDate(DateTime date) {
    final formatter = DateFormat(AppConstants.displayDateFormat, 'id_ID');
    return formatter.format(date);
  }

  /// Format tanggal lengkap: 15 Januari 2024
  /// Contoh: DateFormatter.toFullDate(DateTime.now()) -> "15 Januari 2024"
  static String toFullDate(DateTime date) {
    final formatter = DateFormat(AppConstants.fullDateFormat, 'id_ID');
    return formatter.format(date);
  }

  /// Format tanggal dan waktu: 15 Jan 2024, 14:30
  /// Contoh: DateFormatter.toDateTime(DateTime.now()) -> "15 Jan 2024, 14:30"
  static String toDateTime(DateTime date) {
    final formatter = DateFormat(AppConstants.dateTimeFormat, 'id_ID');
    return formatter.format(date);
  }

  /// Format waktu saja: 14:30
  /// Contoh: DateFormatter.toTime(DateTime.now()) -> "14:30"
  static String toTime(DateTime date) {
    final formatter = DateFormat(AppConstants.timeFormat, 'id_ID');
    return formatter.format(date);
  }

  // ====================
  // API FORMAT
  // ====================
  
  /// Format tanggal untuk API: 2024-01-15
  /// Digunakan saat mengirim data ke backend
  /// Contoh: DateFormatter.toApiFormat(DateTime.now()) -> "2024-01-15"
  static String toApiFormat(DateTime date) {
    final formatter = DateFormat(AppConstants.apiDateFormat);
    return formatter.format(date);
  }

  // ====================
  // PARSING
  // ====================
  
  /// Parse string tanggal dari API ke DateTime
  /// Format yang diterima: 2024-01-15 atau 2024-01-15T14:30:00Z
  /// Contoh: DateFormatter.fromApiFormat("2024-01-15") -> DateTime object
  static DateTime? fromApiFormat(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  // ====================
  // RELATIVE TIME
  // ====================
  
  /// Format relative time: "Baru saja", "5 menit lalu", "2 jam lalu", dll
  /// Berguna untuk menampilkan waktu update terakhir
  static String toRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari lalu';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks minggu lalu';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months bulan lalu';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years tahun lalu';
    }
  }

  // ====================
  // DATE RANGE
  // ====================
  
  /// Format range tanggal: 15 - 20 Jan 2024
  /// Contoh: DateFormatter.toDateRange(start, end) -> "15 - 20 Jan 2024"
  static String toDateRange(DateTime startDate, DateTime endDate) {
    // Jika bulan dan tahun sama
    if (startDate.month == endDate.month && startDate.year == endDate.year) {
      final start = DateFormat('dd', 'id_ID').format(startDate);
      final end = DateFormat('dd MMM yyyy', 'id_ID').format(endDate);
      return '$start - $end';
    }
    
    // Jika tahun sama tapi bulan berbeda
    if (startDate.year == endDate.year) {
      final start = DateFormat('dd MMM', 'id_ID').format(startDate);
      final end = DateFormat('dd MMM yyyy', 'id_ID').format(endDate);
      return '$start - $end';
    }
    
    // Jika tahun berbeda
    final start = DateFormat('dd MMM yyyy', 'id_ID').format(startDate);
    final end = DateFormat('dd MMM yyyy', 'id_ID').format(endDate);
    return '$start - $end';
  }

  // ====================
  // PERIOD FORMAT
  // ====================
  
  /// Format periode untuk tax report: Januari 2024
  /// Digunakan untuk menampilkan periode pelaporan pajak
  static String toPeriodFormat(DateTime date) {
    final formatter = DateFormat('MMMM yyyy', 'id_ID');
    return formatter.format(date);
  }

  /// Format periode untuk tax report short: Jan 2024
  static String toPeriodShortFormat(DateTime date) {
    final formatter = DateFormat('MMM yyyy', 'id_ID');
    return formatter.format(date);
  }

  // ====================
  // HELPERS
  // ====================
  
  /// Check apakah tanggal adalah hari ini
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
           date.month == now.month &&
           date.day == now.day;
  }

  /// Check apakah tanggal adalah kemarin
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
           date.month == yesterday.month &&
           date.day == yesterday.day;
  }

  /// Get first day of month
  static DateTime getFirstDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Get last day of month
  static DateTime getLastDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }
}
