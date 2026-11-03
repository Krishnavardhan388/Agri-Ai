class ProductModel {
  final String id;
  final String farmerId;
  final String farmerName;
  final String farmerLocation;
  final String title;
  final String description;
  final String category;
  final double pricePerKg;
  final double originalPricePerKg;
  final double availableStockKg;
  final String harvestDate;
  final String? imageUrl;
  final double rating;
  final int totalReviews;
  final bool isOrganic;

  const ProductModel({
    required this.id,
    required this.farmerId,
    required this.farmerName,
    required this.farmerLocation,
    required this.title,
    required this.description,
    required this.category,
    required this.pricePerKg,
    required this.originalPricePerKg,
    required this.availableStockKg,
    required this.harvestDate,
    this.imageUrl,
    this.rating = 4.8,
    this.totalReviews = 25,
    this.isOrganic = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'farmerLocation': farmerLocation,
      'title': title,
      'description': description,
      'category': category,
      'pricePerKg': pricePerKg,
      'originalPricePerKg': originalPricePerKg,
      'availableStockKg': availableStockKg,
      'harvestDate': harvestDate,
      'imageUrl': imageUrl,
      'rating': rating,
      'totalReviews': totalReviews,
      'isOrganic': isOrganic,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    return ProductModel(
      id: docId ?? map['id'] ?? 'crop-${DateTime.now().millisecondsSinceEpoch}',
      farmerId: map['farmerId'] ?? 'farmer-default',
      farmerName: map['farmerName'] ?? 'Ramesh Farm',
      farmerLocation: map['farmerLocation'] ?? 'Warangal, Telangana',
      title: map['title'] ?? 'Farm Produce',
      description: map['description'] ?? 'Fresh farm harvested produce',
      category: map['category'] ?? 'Vegetables',
      pricePerKg: (map['pricePerKg'] as num?)?.toDouble() ?? 30.0,
      originalPricePerKg: (map['originalPricePerKg'] as num?)?.toDouble() ?? 45.0,
      availableStockKg: (map['availableStockKg'] as num?)?.toDouble() ?? 100.0,
      harvestDate: map['harvestDate'] ?? 'Harvested recently',
      imageUrl: map['imageUrl'],
      rating: (map['rating'] as num?)?.toDouble() ?? 4.8,
      totalReviews: (map['totalReviews'] as num?)?.toInt() ?? 25,
      isOrganic: map['isOrganic'] ?? true,
    );
  }

  ProductModel copyWith({
    String? id,
    String? farmerId,
    String? farmerName,
    String? farmerLocation,
    String? title,
    String? description,
    String? category,
    double? pricePerKg,
    double? originalPricePerKg,
    double? availableStockKg,
    String? harvestDate,
    String? imageUrl,
    double? rating,
    int? totalReviews,
    bool? isOrganic,
  }) {
    return ProductModel(
      id: id ?? this.id,
      farmerId: farmerId ?? this.farmerId,
      farmerName: farmerName ?? this.farmerName,
      farmerLocation: farmerLocation ?? this.farmerLocation,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      pricePerKg: pricePerKg ?? this.pricePerKg,
      originalPricePerKg: originalPricePerKg ?? this.originalPricePerKg,
      availableStockKg: availableStockKg ?? this.availableStockKg,
      harvestDate: harvestDate ?? this.harvestDate,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      isOrganic: isOrganic ?? this.isOrganic,
    );
  }
}

