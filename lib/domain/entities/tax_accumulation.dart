/// Tax Accumulation Entity
/// Entity untuk akumulasi total pajak yang sudah dibayarkan

class TaxAccumulation {
  final String userId;
  final double totalAmount; // Total semua pajak yang dibayarkan
  final double thisYearAmount; // Total pajak tahun ini
  final double thisMonthAmount; // Total pajak bulan ini
  final int totalReports; // Total jumlah laporan pajak
  final DateTime updatedAt;
  
  // Breakdown per jenis pajak
  final double pph21Amount;
  final double pph23Amount;
  final double pph26Amount;
  final double otherAmount;

  TaxAccumulation({
    required this.userId,
    required this.totalAmount,
    required this.thisYearAmount,
    required this.thisMonthAmount,
    required this.totalReports,
    required this.updatedAt,
    required this.pph21Amount,
    required this.pph23Amount,
    required this.pph26Amount,
    required this.otherAmount,
  });

  /// Get rata-rata pajak per bulan (dari total)
  double get averageMonthlyTax {
    if (totalReports == 0) return 0;
    return totalAmount / totalReports;
  }

  /// Get persentase pajak tahun ini dari total
  double get thisYearPercentage {
    if (totalAmount == 0) return 0;
    return (thisYearAmount / totalAmount) * 100;
  }

  /// Get breakdown per jenis pajak dalam Map
  Map<String, double> get breakdownByType {
    return {
      'PPh 21': pph21Amount,
      'PPh 23': pph23Amount,
      'PPh 26': pph26Amount,
      'Lainnya': otherAmount,
    };
  }

  /// Get jenis pajak terbesar
  String get largestTaxType {
    final breakdown = {
      'PPh 21': pph21Amount,
      'PPh 23': pph23Amount,
      'PPh 26': pph26Amount,
      'Lainnya': otherAmount,
    };
    
    var largest = 'PPh 21';
    var largestAmount = pph21Amount;
    
    breakdown.forEach((type, amount) {
      if (amount > largestAmount) {
        largest = type;
        largestAmount = amount;
      }
    });
    
    return largest;
  }

  TaxAccumulation copyWith({
    String? userId,
    double? totalAmount,
    double? thisYearAmount,
    double? thisMonthAmount,
    int? totalReports,
    DateTime? updatedAt,
    double? pph21Amount,
    double? pph23Amount,
    double? pph26Amount,
    double? otherAmount,
  }) {
    return TaxAccumulation(
      userId: userId ?? this.userId,
      totalAmount: totalAmount ?? this.totalAmount,
      thisYearAmount: thisYearAmount ?? this.thisYearAmount,
      thisMonthAmount: thisMonthAmount ?? this.thisMonthAmount,
      totalReports: totalReports ?? this.totalReports,
      updatedAt: updatedAt ?? this.updatedAt,
      pph21Amount: pph21Amount ?? this.pph21Amount,
      pph23Amount: pph23Amount ?? this.pph23Amount,
      pph26Amount: pph26Amount ?? this.pph26Amount,
      otherAmount: otherAmount ?? this.otherAmount,
    );
  }

  @override
  String toString() {
    return 'TaxAccumulation(userId: $userId, totalAmount: $totalAmount, totalReports: $totalReports)';
  }
}
