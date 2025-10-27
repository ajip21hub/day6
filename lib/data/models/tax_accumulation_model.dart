import '../../domain/entities/tax_accumulation.dart';

/// Tax Accumulation Model
/// Model untuk data akumulasi pajak dari API

class TaxAccumulationModel {
  final String userId;
  final double totalAmount;
  final double thisYearAmount;
  final double thisMonthAmount;
  final int totalReports;
  final String updatedAt;
  final double pph21Amount;
  final double pph23Amount;
  final double pph26Amount;
  final double otherAmount;

  TaxAccumulationModel({
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

  /// Convert JSON dari API ke TaxAccumulationModel
  /// 
  /// Contoh JSON:
  /// {
  ///   "userId": "user_123",
  ///   "totalAmount": 50000000,
  ///   "thisYearAmount": 6000000,
  ///   "thisMonthAmount": 500000,
  ///   "totalReports": 100,
  ///   "updatedAt": "2024-01-20T10:30:00Z",
  ///   "breakdown": {
  ///     "pph21": 40000000,
  ///     "pph23": 8000000,
  ///     "pph26": 1000000,
  ///     "other": 1000000
  ///   }
  /// }
  factory TaxAccumulationModel.fromJson(Map<String, dynamic> json) {
    final breakdown = json['breakdown'] as Map<String, dynamic>? ?? {};
    
    return TaxAccumulationModel(
      userId: json['userId'] as String,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      thisYearAmount: (json['thisYearAmount'] as num).toDouble(),
      thisMonthAmount: (json['thisMonthAmount'] as num).toDouble(),
      totalReports: json['totalReports'] as int,
      updatedAt: json['updatedAt'] as String,
      pph21Amount: (breakdown['pph21'] as num?)?.toDouble() ?? 0,
      pph23Amount: (breakdown['pph23'] as num?)?.toDouble() ?? 0,
      pph26Amount: (breakdown['pph26'] as num?)?.toDouble() ?? 0,
      otherAmount: (breakdown['other'] as num?)?.toDouble() ?? 0,
    );
  }

  /// Convert TaxAccumulationModel ke JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'totalAmount': totalAmount,
      'thisYearAmount': thisYearAmount,
      'thisMonthAmount': thisMonthAmount,
      'totalReports': totalReports,
      'updatedAt': updatedAt,
      'breakdown': {
        'pph21': pph21Amount,
        'pph23': pph23Amount,
        'pph26': pph26Amount,
        'other': otherAmount,
      },
    };
  }

  /// Convert TaxAccumulationModel ke TaxAccumulation Entity
  TaxAccumulation toEntity() {
    return TaxAccumulation(
      userId: userId,
      totalAmount: totalAmount,
      thisYearAmount: thisYearAmount,
      thisMonthAmount: thisMonthAmount,
      totalReports: totalReports,
      updatedAt: DateTime.parse(updatedAt),
      pph21Amount: pph21Amount,
      pph23Amount: pph23Amount,
      pph26Amount: pph26Amount,
      otherAmount: otherAmount,
    );
  }

  /// Convert Entity ke Model
  factory TaxAccumulationModel.fromEntity(TaxAccumulation accumulation) {
    return TaxAccumulationModel(
      userId: accumulation.userId,
      totalAmount: accumulation.totalAmount,
      thisYearAmount: accumulation.thisYearAmount,
      thisMonthAmount: accumulation.thisMonthAmount,
      totalReports: accumulation.totalReports,
      updatedAt: accumulation.updatedAt.toIso8601String(),
      pph21Amount: accumulation.pph21Amount,
      pph23Amount: accumulation.pph23Amount,
      pph26Amount: accumulation.pph26Amount,
      otherAmount: accumulation.otherAmount,
    );
  }

  @override
  String toString() {
    return 'TaxAccumulationModel(userId: $userId, totalAmount: $totalAmount, totalReports: $totalReports)';
  }
}
