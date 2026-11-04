enum AdminTimeframe {
  thisWeek,
  thisMonth,
  allTime;

  String get label {
    switch (this) {
      case AdminTimeframe.thisWeek:
        return 'Last 7 Days';
      case AdminTimeframe.thisMonth:
        return 'This Month';
      case AdminTimeframe.allTime:
        return 'All Time';
    }
  }
}

class DailyRevenuePoint {
  final String dayName;
  final double amount;
  final int orderCount;

  const DailyRevenuePoint({
    required this.dayName,
    required this.amount,
    required this.orderCount,
  });
}

class CropDiseaseMetric {
  final String cropName;
  final String diseaseName;
  final int casesCount;
  final double percentage;
  final String riskLevel;

  const CropDiseaseMetric({
    required this.cropName,
    required this.diseaseName,
    required this.casesCount,
    required this.percentage,
    required this.riskLevel,
  });
}

class AdminAnalyticsSummary {
  final double totalGmv;
  final double weekOverWeekGmvGrowth;
  final int totalOrders;
  final int inTransitOrders;
  final int deliveredOrders;
  final int verifiedFarmers;
  final int registeredCustomers;
  final int activeDeliveryFleet;
  final int totalAiScans;
  final double healthyDiagnosisRate;
  final List<DailyRevenuePoint> weeklyRevenue;
  final List<CropDiseaseMetric> topDiseases;
  final Map<String, int> orderStatusDistribution;

  const AdminAnalyticsSummary({
    required this.totalGmv,
    required this.weekOverWeekGmvGrowth,
    required this.totalOrders,
    required this.inTransitOrders,
    required this.deliveredOrders,
    required this.verifiedFarmers,
    required this.registeredCustomers,
    required this.activeDeliveryFleet,
    required this.totalAiScans,
    required this.healthyDiagnosisRate,
    required this.weeklyRevenue,
    required this.topDiseases,
    required this.orderStatusDistribution,
  });

  factory AdminAnalyticsSummary.mockInitial() {
    return const AdminAnalyticsSummary(
      totalGmv: 148250.0,
      weekOverWeekGmvGrowth: 18.4,
      totalOrders: 142,
      inTransitOrders: 8,
      deliveredOrders: 128,
      verifiedFarmers: 1248,
      registeredCustomers: 3890,
      activeDeliveryFleet: 164,
      totalAiScans: 5820,
      healthyDiagnosisRate: 78.5,
      weeklyRevenue: [
        DailyRevenuePoint(dayName: 'Mon', amount: 16400, orderCount: 16),
        DailyRevenuePoint(dayName: 'Tue', amount: 21500, orderCount: 22),
        DailyRevenuePoint(dayName: 'Wed', amount: 19800, orderCount: 19),
        DailyRevenuePoint(dayName: 'Thu', amount: 24600, orderCount: 25),
        DailyRevenuePoint(dayName: 'Fri', amount: 28900, orderCount: 29),
        DailyRevenuePoint(dayName: 'Sat', amount: 33450, orderCount: 35),
        DailyRevenuePoint(dayName: 'Sun', amount: 23600, orderCount: 24),
      ],
      topDiseases: [
        CropDiseaseMetric(
          cropName: 'Cotton',
          diseaseName: 'Pink Bollworm (Pectinophora)',
          casesCount: 42,
          percentage: 42.0,
          riskLevel: 'HIGH',
        ),
        CropDiseaseMetric(
          cropName: 'Tomato',
          diseaseName: 'Tomato Early Blight (Alternaria)',
          casesCount: 26,
          percentage: 26.0,
          riskLevel: 'MEDIUM',
        ),
        CropDiseaseMetric(
          cropName: 'Paddy / Rice',
          diseaseName: 'Bacterial Leaf Blight (Xanthomonas)',
          casesCount: 18,
          percentage: 18.0,
          riskLevel: 'MEDIUM',
        ),
        CropDiseaseMetric(
          cropName: 'Chilli',
          diseaseName: 'Chilli Leaf Curl Virus (Gemini Virus)',
          casesCount: 14,
          percentage: 14.0,
          riskLevel: 'LOW',
        ),
      ],
      orderStatusDistribution: {
        'Delivered': 128,
        'In Transit': 8,
        'Accepted': 4,
        'Pending': 2,
      },
    );
  }
}
