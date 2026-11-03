class MandiCropItem {
  final String id;
  final String cropName;
  final String variety;
  final String category;
  final String marketName;
  final double distanceKm;
  final double minPrice;
  final double maxPrice;
  final double modalPrice; // Official benchmark price per Quintal (100 kg)
  final double priceChange;
  final bool isPriceUp;
  final DateTime lastUpdated;

  const MandiCropItem({
    required this.id,
    required this.cropName,
    required this.variety,
    required this.category,
    required this.marketName,
    required this.distanceKm,
    required this.minPrice,
    required this.maxPrice,
    required this.modalPrice,
    required this.priceChange,
    required this.isPriceUp,
    required this.lastUpdated,
  });

  double get pricePerKg => modalPrice / 100.0;

  String get formattedModalPrice => '₹${modalPrice.toInt()} / Quintal';
  String get formattedPerKg => '₹${pricePerKg.toStringAsFixed(1)} / kg';
}

class MandiComparisonItem {
  final String mandiName;
  final String district;
  final double distanceKm;
  final double modalPricePerQuintal;
  final bool isHighestPrice;

  const MandiComparisonItem({
    required this.mandiName,
    required this.district,
    required this.distanceKm,
    required this.modalPricePerQuintal,
    this.isHighestPrice = false,
  });
}
