/// Tax Report Entity
/// Entity untuk laporan pajak yang sudah dibayarkan

class TaxReport {
  final String id;
  final String userId;
  final String workplaceId;
  final String workplaceName; // Nama perusahaan tempat bekerja
  final double amount; // Jumlah pajak yang dibayarkan
  final DateTime period; // Periode pembayaran (bulan-tahun)
  final String? description; // Deskripsi tambahan
  final TaxType taxType; // Jenis pajak (PPh21, PPh23, dll)
  final DateTime createdAt;
  final DateTime updatedAt;

  TaxReport({
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

  /// Get periode dalam format string (contoh: "Januari 2024")
  String get periodString {
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${months[period.month - 1]} ${period.year}';
  }

  /// Get nama jenis pajak
  String get taxTypeName {
    switch (taxType) {
      case TaxType.pph21:
        return 'PPh 21';
      case TaxType.pph23:
        return 'PPh 23';
      case TaxType.pph26:
        return 'PPh 26';
      case TaxType.other:
        return 'Lainnya';
    }
  }

  TaxReport copyWith({
    String? id,
    String? userId,
    String? workplaceId,
    String? workplaceName,
    double? amount,
    DateTime? period,
    String? description,
    TaxType? taxType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaxReport(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      workplaceId: workplaceId ?? this.workplaceId,
      workplaceName: workplaceName ?? this.workplaceName,
      amount: amount ?? this.amount,
      period: period ?? this.period,
      description: description ?? this.description,
      taxType: taxType ?? this.taxType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'TaxReport(id: $id, workplaceName: $workplaceName, amount: $amount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaxReport && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Enum untuk jenis pajak
enum TaxType {
  pph21,  // Pajak Penghasilan Pasal 21 (karyawan)
  pph23,  // Pajak Penghasilan Pasal 23 (jasa)
  pph26,  // Pajak Penghasilan Pasal 26 (luar negeri)
  other,  // Lainnya
}
