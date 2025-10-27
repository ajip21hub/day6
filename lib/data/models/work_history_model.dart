import '../../domain/entities/work_history.dart';

/// Work History Model
/// Model untuk data riwayat pekerjaan dari API

class WorkHistoryModel {
  final String id;
  final String userId;
  final String companyName;
  final String position;
  final String startDate;
  final String? endDate; // null jika masih bekerja
  final double monthlySalary;
  final double totalTaxPaid;
  final int totalReports;
  final String? companyAddress;
  final String? npwp;
  final String createdAt;
  final String updatedAt;

  WorkHistoryModel({
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

  /// Convert JSON dari API ke WorkHistoryModel
  /// 
  /// Contoh JSON:
  /// {
  ///   "id": "work_123",
  ///   "userId": "user_123",
  ///   "companyName": "PT ABC Indonesia",
  ///   "position": "Software Engineer",
  ///   "startDate": "2020-01-15",
  ///   "endDate": "2022-12-31",  // atau null
  ///   "monthlySalary": 10000000,
  ///   "totalTaxPaid": 6000000,
  ///   "totalReports": 36,
  ///   "companyAddress": "Jakarta",
  ///   "npwp": "12.345.678.9-012.000",
  ///   "createdAt": "2020-01-15T10:30:00Z",
  ///   "updatedAt": "2024-01-20T10:30:00Z"
  /// }
  factory WorkHistoryModel.fromJson(Map<String, dynamic> json) {
    return WorkHistoryModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      companyName: json['companyName'] as String,
      position: json['position'] as String,
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String?,
      monthlySalary: (json['monthlySalary'] as num).toDouble(),
      totalTaxPaid: (json['totalTaxPaid'] as num).toDouble(),
      totalReports: json['totalReports'] as int,
      companyAddress: json['companyAddress'] as String?,
      npwp: json['npwp'] as String?,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }

  /// Convert WorkHistoryModel ke JSON untuk dikirim ke API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'companyName': companyName,
      'position': position,
      'startDate': startDate,
      'endDate': endDate,
      'monthlySalary': monthlySalary,
      'totalTaxPaid': totalTaxPaid,
      'totalReports': totalReports,
      'companyAddress': companyAddress,
      'npwp': npwp,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Convert WorkHistoryModel ke WorkHistory Entity
  WorkHistory toEntity() {
    return WorkHistory(
      id: id,
      userId: userId,
      companyName: companyName,
      position: position,
      startDate: DateTime.parse(startDate),
      endDate: endDate != null ? DateTime.parse(endDate!) : null,
      monthlySalary: monthlySalary,
      totalTaxPaid: totalTaxPaid,
      totalReports: totalReports,
      companyAddress: companyAddress,
      npwp: npwp,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }

  /// Convert Entity ke Model
  factory WorkHistoryModel.fromEntity(WorkHistory history) {
    return WorkHistoryModel(
      id: history.id,
      userId: history.userId,
      companyName: history.companyName,
      position: history.position,
      startDate: history.startDate.toIso8601String(),
      endDate: history.endDate?.toIso8601String(),
      monthlySalary: history.monthlySalary,
      totalTaxPaid: history.totalTaxPaid,
      totalReports: history.totalReports,
      companyAddress: history.companyAddress,
      npwp: history.npwp,
      createdAt: history.createdAt.toIso8601String(),
      updatedAt: history.updatedAt.toIso8601String(),
    );
  }

  @override
  String toString() {
    return 'WorkHistoryModel(id: $id, companyName: $companyName, position: $position)';
  }
}
