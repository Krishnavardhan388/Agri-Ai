class AdminMandiCropRate {
  final String id;
  final String cropName;
  final String marketName;
  final String district;
  final double modalPricePerQuintal;
  final double minPricePerQuintal;
  final double maxPricePerQuintal;
  final double trendPercentage;
  final bool isRising;
  final DateTime lastBroadcastAt;

  const AdminMandiCropRate({
    required this.id,
    required this.cropName,
    required this.marketName,
    required this.district,
    required this.modalPricePerQuintal,
    required this.minPricePerQuintal,
    required this.maxPricePerQuintal,
    required this.trendPercentage,
    required this.isRising,
    required this.lastBroadcastAt,
  });

  double get pricePerKg => modalPricePerQuintal / 100.0;

  AdminMandiCropRate copyWith({
    String? id,
    String? cropName,
    String? marketName,
    String? district,
    double? modalPricePerQuintal,
    double? minPricePerQuintal,
    double? maxPricePerQuintal,
    double? trendPercentage,
    bool? isRising,
    DateTime? lastBroadcastAt,
  }) {
    return AdminMandiCropRate(
      id: id ?? this.id,
      cropName: cropName ?? this.cropName,
      marketName: marketName ?? this.marketName,
      district: district ?? this.district,
      modalPricePerQuintal: modalPricePerQuintal ?? this.modalPricePerQuintal,
      minPricePerQuintal: minPricePerQuintal ?? this.minPricePerQuintal,
      maxPricePerQuintal: maxPricePerQuintal ?? this.maxPricePerQuintal,
      trendPercentage: trendPercentage ?? this.trendPercentage,
      isRising: isRising ?? this.isRising,
      lastBroadcastAt: lastBroadcastAt ?? this.lastBroadcastAt,
    );
  }
}
