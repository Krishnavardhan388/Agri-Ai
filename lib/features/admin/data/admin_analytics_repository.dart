import '../domain/admin_analytics_summary.dart';

class AdminAnalyticsRepository {
  final List<Map<String, dynamic>> _broadcastAlerts = [];

  Future<AdminAnalyticsSummary> getAnalyticsSummary({
    AdminTimeframe timeframe = AdminTimeframe.thisWeek,
  }) async {
    // Simulate real-time async aggregation calculation
    await Future.delayed(const Duration(milliseconds: 150));

    final base = AdminAnalyticsSummary.mockInitial();
    double multiplier = 1.0;
    if (timeframe == AdminTimeframe.thisMonth) {
      multiplier = 3.8;
    } else if (timeframe == AdminTimeframe.allTime) {
      multiplier = 12.5;
    }

    return AdminAnalyticsSummary(
      totalGmv: base.totalGmv * multiplier,
      weekOverWeekGmvGrowth: base.weekOverWeekGmvGrowth,
      totalOrders: (base.totalOrders * multiplier).toInt(),
      inTransitOrders: base.inTransitOrders,
      deliveredOrders: (base.deliveredOrders * multiplier).toInt(),
      verifiedFarmers: (base.verifiedFarmers * (multiplier > 1 ? 1.4 : 1.0)).toInt(),
      registeredCustomers: (base.registeredCustomers * (multiplier > 1 ? 2.1 : 1.0)).toInt(),
      activeDeliveryFleet: base.activeDeliveryFleet,
      totalAiScans: (base.totalAiScans * multiplier).toInt(),
      healthyDiagnosisRate: base.healthyDiagnosisRate,
      weeklyRevenue: base.weeklyRevenue.map((point) {
        return DailyRevenuePoint(
          dayName: point.dayName,
          amount: point.amount * multiplier,
          orderCount: (point.orderCount * multiplier).toInt(),
        );
      }).toList(),
      topDiseases: base.topDiseases,
      orderStatusDistribution: base.orderStatusDistribution,
    );
  }

  Future<bool> sendDistrictBroadcastAlert({
    required String district,
    required String crop,
    required String advisory,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _broadcastAlerts.add({
      'district': district,
      'crop': crop,
      'advisory': advisory,
      'timestamp': DateTime.now(),
      'reachCount': 680,
    });
    return true;
  }

  List<Map<String, dynamic>> get broadcastAlerts => List.unmodifiable(_broadcastAlerts);

  String generateExportReport(AdminAnalyticsSummary summary) {
    final buffer = StringBuffer();
    buffer.writeln('====================================================');
    buffer.writeln('AGRI AI — OPERATIONS EXECUTIVE AUDIT SUMMARY');
    buffer.writeln('Generated at: ${DateTime.now().toIso8601String()}');
    buffer.writeln('====================================================');
    buffer.writeln('Total Platform GMV: ₹${summary.totalGmv.toStringAsFixed(2)}');
    buffer.writeln('Total Orders Processed: ${summary.totalOrders}');
    buffer.writeln('Delivered Orders: ${summary.deliveredOrders}');
    buffer.writeln('In-Transit Trips: ${summary.inTransitOrders}');
    buffer.writeln('Verified Farmers: ${summary.verifiedFarmers}');
    buffer.writeln('Registered Customers: ${summary.registeredCustomers}');
    buffer.writeln('Active Delivery Fleet: ${summary.activeDeliveryFleet}');
    buffer.writeln('Total AI Crop Doctor Scans: ${summary.totalAiScans}');
    buffer.writeln('Plant Health Accuracy Rate: ${summary.healthyDiagnosisRate}%');
    buffer.writeln('----------------------------------------------------');
    buffer.writeln('Top Pathologies Identified:');
    for (final d in summary.topDiseases) {
      buffer.writeln('- ${d.cropName} (${d.diseaseName}): ${d.casesCount} cases (${d.percentage}%) [${d.riskLevel}]');
    }
    buffer.writeln('====================================================');
    return buffer.toString();
  }
}
