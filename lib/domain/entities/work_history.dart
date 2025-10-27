/// Work History Entity
/// Entity untuk history tempat kerja dan pajak yang sudah dibayarkan

class WorkHistory {
  final String id;
  final String userId;
  final String companyName; // Nama perusahaan
  final String position; // Posisi/jabatan
  final DateTime startDate; // Tanggal mulai bekerja
  final DateTime? endDate; // Tanggal selesai (null jika masih bekerja)
  final double monthlySalary; // Gaji per bulan
  final double totalTaxPaid; // Total pajak yang sudah dibayarkan dari tempat kerja ini
  final int totalReports; // Jumlah laporan pajak dari tempat kerja ini
  final String? companyAddress; // Alamat perusahaan
  final String? npwp; // NPWP perusahaan
  final DateTime createdAt;
  final DateTime updatedAt;

  WorkHistory({
    required this.id,
    required this.userId,
    required this.companyName,
    required this.position,
    required this.startDate,
    this.endDate,
    required this.monthlySalary,
    required this.totalTaxPaid,
    required this.totalReports,
    this.companyAddress,
    this.npwp,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check apakah masih bekerja di tempat ini
  bool get isCurrentJob => endDate == null;

  /// Get durasi kerja dalam bulan
  int get durationInMonths {
    final end = endDate ?? DateTime.now();
    final diff = end.difference(startDate);
    return (diff.inDays / 30).floor();
  }

  /// Get durasi kerja dalam format string (contoh: "2 tahun 3 bulan")
  String get durationString {
    final months = durationInMonths;
    final years = months ~/ 12;
    final remainingMonths = months % 12;

    if (years == 0) {
      return '$remainingMonths bulan';
    } else if (remainingMonths == 0) {
      return '$years tahun';
    } else {
      return '$years tahun $remainingMonths bulan';
    }
  }

  /// Get periode kerja dalam format string
  /// Contoh: "Jan 2020 - Des 2022" atau "Jan 2020 - Sekarang"
  String get periodString {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    
    final startMonth = months[startDate.month - 1];
    final startYear = startDate.year;
    
    if (isCurrentJob) {
      return '$startMonth $startYear - Sekarang';
    } else {
      final endMonth = months[endDate!.month - 1];
      final endYear = endDate!.year;
      return '$startMonth $startYear - $endMonth $endYear';
    }
  }

  /// Get estimasi pajak per bulan (asumsi 5% dari gaji)
  double get estimatedMonthlyTax {
    return monthlySalary * 0.05;
  }

  WorkHistory copyWith({
    String? id,
    String? userId,
    String? companyName,
    String? position,
    DateTime? startDate,
    DateTime? endDate,
    double? monthlySalary,
    double? totalTaxPaid,
    int? totalReports,
    String? companyAddress,
    String? npwp,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkHistory(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      companyName: companyName ?? this.companyName,
      position: position ?? this.position,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      monthlySalary: monthlySalary ?? this.monthlySalary,
      totalTaxPaid: totalTaxPaid ?? this.totalTaxPaid,
      totalReports: totalReports ?? this.totalReports,
      companyAddress: companyAddress ?? this.companyAddress,
      npwp: npwp ?? this.npwp,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'WorkHistory(id: $id, companyName: $companyName, position: $position)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkHistory && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
