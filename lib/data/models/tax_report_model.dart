import '../../domain/entities/tax_report.dart';

/// Tax Report Model
/// Model untuk data laporan pajak dari API

class TaxReportModel {
  final String id;
  final String userId;
  final String workplaceId;
  final String workplaceName;
  final double amount;
  final String period; // Format: "2024-01-15" (bulan akan di-extract)
  final String? description;
  final String taxType; // String dari API: "pph21", "pph23", dll
  final String createdAt;
  final String updatedAt;

  TaxReportModel({
    required this.id,
    required this.userId,
    required this.workplaceId,
    required this.workplaceName,
    required this.amount,
    required this.period,
    this.description,
    required this.taxType,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert JSON dari API ke TaxReportModel
  /// 
  /// Contoh JSON:
  /// {
  ///   "id": "report_123",
  ///   "userId": "user_123",
  ///   "workplaceId": "work_123",
  ///   "workplaceName": "PT ABC",
  ///   "amount": 500000,
  ///   "period": "2024-01-15",
  ///   "description": "Pajak bulan Januari",
  ///   "taxType": "pph21",
  ///   "createdAt": "2024-01-20T10:30:00Z",
  ///   "updatedAt": "2024-01-20T10:30:00Z"
  /// }
  factory TaxReportModel.fromJson(Map<String, dynamic> json) {
    return TaxReportModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      workplaceId: json['workplaceId'] as String,
      workplaceName: json['workplaceName'] as String,
      amount: (json['amount'] as num).toDouble(),
      period: json['period'] as String,
      description: json['description'] as String?,
      taxType: json['taxType'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }

  /// Convert TaxReportModel ke JSON untuk dikirim ke API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'workplaceId': workplaceId,
      'workplaceName': workplaceName,
      'amount': amount,
      'period': period,
      'description': description,
      'taxType': taxType,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Convert TaxReportModel ke TaxReport Entity
  TaxReport toEntity() {
    return TaxReport(
      id: id,
      userId: userId,
      workplaceId: workplaceId,
      workplaceName: workplaceName,
      amount: amount,
      period: DateTime.parse(period),
      description: description,
      taxType: _stringToTaxType(taxType),
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }

  /// Convert Entity ke Model
  factory TaxReportModel.fromEntity(TaxReport report) {
    return TaxReportModel(
      id: report.id,
      userId: report.userId,
      workplaceId: report.workplaceId,
      workplaceName: report.workplaceName,
      amount: report.amount,
      period: report.period.toIso8601String(),
      description: report.description,
      taxType: _taxTypeToString(report.taxType),
      createdAt: report.createdAt.toIso8601String(),
      updatedAt: report.updatedAt.toIso8601String(),
    );
  }

  /// Helper: Convert string ke TaxType enum
  static TaxType _stringToTaxType(String type) {
    switch (type.toLowerCase()) {
      case 'pph21':
        return TaxType.pph21;
      case 'pph23':
        return TaxType.pph23;
      case 'pph26':
        return TaxType.pph26;
      default:
        return TaxType.other;
    }
  }

  /// Helper: Convert TaxType enum ke string
  static String _taxTypeToString(TaxType type) {
    switch (type) {
      case TaxType.pph21:
        return 'pph21';
      case TaxType.pph23:
        return 'pph23';
      case TaxType.pph26:
        return 'pph26';
      case TaxType.other:
        return 'other';
    }
  }

  @override
  String toString() {
    return 'TaxReportModel(id: $id, workplaceName: $workplaceName, amount: $amount)';
  }
}
