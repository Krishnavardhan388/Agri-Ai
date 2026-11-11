import '../../../core/services/api_client.dart';
import '../domain/delivery_task_model.dart';

class DeliveryRepository {
  final ApiClient _apiClient;

  double _walletBalance = 1180.0;
  int _tripsCompletedCount = 11;

  final List<DeliveryTask> _tasks = [
    DeliveryTask(
      id: 'TASK-101',
      orderId: 'AGRI-1092',
      farmName: 'Ramesh Farm (Gate 2)',
      farmAddress: 'Village Nallabelli, Warangal Rural',
      farmLat: 17.9689,
      farmLng: 79.5941,
      farmPhone: '+91 98765 43210',
      customerName: 'Priya Sharma',
      customerAddress: 'Flat 402, Green Meadows, Hanamkonda',
      customerLat: 18.0072,
      customerLng: 79.5583,
      customerPhone: '+91 98765 12345',
      cropSummary: '5 kg Fresh Organic Tomatoes',
      totalWeightKg: 5.0,
      distanceKm: 6.5,
      tripPayout: 95.0,
      requiredOtp: '4821',
      status: DeliveryTaskStatus.accepted,
      createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
    ),
    DeliveryTask(
      id: 'TASK-102',
      orderId: 'AGRI-1088',
      farmName: 'Krishna Valley Farms',
      farmAddress: 'Wardhannapet Agro Cluster, Warangal',
      farmLat: 17.8812,
      farmLng: 79.6105,
      farmPhone: '+91 98480 22334',
      customerName: 'Anand Rao',
      customerAddress: 'Subedari, Kazipet',
      customerLat: 17.9814,
      customerLng: 79.5298,
      customerPhone: '+91 98765 99999',
      cropSummary: '50 kg Sona Masoori Raw Rice Bag',
      totalWeightKg: 50.0,
      distanceKm: 4.8,
      tripPayout: 115.0,
      requiredOtp: '7192',
      status: DeliveryTaskStatus.available,
      createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
    ),
    DeliveryTask(
      id: 'TASK-103',
      orderId: 'AGRI-1095',
      farmName: 'Lakshmi Chilli Nursery',
      farmAddress: 'Parkal Highway, Warangal',
      farmLat: 18.0820,
      farmLng: 79.6890,
      farmPhone: '+91 94401 55667',
      customerName: 'Srikanth Traders',
      customerAddress: 'Station Road, Warangal',
      customerLat: 17.9780,
      customerLng: 79.6010,
      customerPhone: '+91 98490 11223',
      cropSummary: '20 kg Guntur Teja Red Chilli',
      totalWeightKg: 20.0,
      distanceKm: 8.2,
      tripPayout: 140.0,
      requiredOtp: '5319',
      status: DeliveryTaskStatus.available,
      createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
  ];

  final List<DeliveryWalletRecord> _transactions = [
    DeliveryWalletRecord(
      id: 'TXN-401',
      title: 'Trip Payout #TASK-098',
      orderId: 'AGRI-1075',
      amount: 95.0,
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      isCredit: true,
    ),
    DeliveryWalletRecord(
      id: 'TXN-402',
      title: 'Trip Payout #TASK-099',
      orderId: 'AGRI-1077',
      amount: 110.0,
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      isCredit: true,
    ),
  ];

  DeliveryRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  DeliveryTask _taskFromApi(Map<String, dynamic> map) {
    DeliveryTaskStatus parsed = DeliveryTaskStatus.available;
    try {
      parsed = DeliveryTaskStatus.values.byName(map['status']?.toString() ?? 'available');
    } catch (_) {
      parsed = DeliveryTaskStatus.available;
    }
    return DeliveryTask(
      id: map['id']?.toString() ?? 'TASK-0',
      orderId: map['order_id']?.toString() ?? '',
      farmName: map['farm_name']?.toString() ?? 'Partner Farm',
      farmAddress: map['farm_address']?.toString() ?? '',
      farmLat: (map['farm_lat'] as num?)?.toDouble() ?? 17.9689,
      farmLng: (map['farm_lng'] as num?)?.toDouble() ?? 79.5941,
      farmPhone: map['farm_phone']?.toString() ?? '',
      customerName: map['customer_name']?.toString() ?? 'Customer',
      customerAddress: map['customer_address']?.toString() ?? '',
      customerLat: (map['customer_lat'] as num?)?.toDouble() ?? 18.0072,
      customerLng: (map['customer_lng'] as num?)?.toDouble() ?? 79.5583,
      customerPhone: map['customer_phone']?.toString() ?? '',
      cropSummary: map['crop_summary']?.toString() ?? '',
      totalWeightKg: (map['total_weight_kg'] as num?)?.toDouble() ?? 5.0,
      distanceKm: (map['distance_km'] as num?)?.toDouble() ?? 5.0,
      tripPayout: (map['trip_payout'] as num?)?.toDouble() ?? 90.0,
      requiredOtp: map['required_otp']?.toString() ?? '0000',
      status: parsed,
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? '') ?? DateTime.now(),
      pickedUpAt: DateTime.tryParse(map['picked_up_at']?.toString() ?? ''),
      deliveredAt: DateTime.tryParse(map['delivered_at']?.toString() ?? ''),
    );
  }

  Future<List<DeliveryTask>> getTasks() async {
    try {
      final resp = await _apiClient.get('/api/v1/delivery/tasks');
      if (resp is List && resp.isNotEmpty) {
        return resp
            .whereType<Map>()
            .map((e) => _taskFromApi(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (_) {}
    return List.unmodifiable(_tasks);
  }

  Future<DeliveryTask?> acceptTask(String taskId) async {
    try {
      final resp = await _apiClient.post('/api/v1/delivery/tasks/$taskId/accept');
      if (resp is Map<String, dynamic>) {
        return _taskFromApi(resp);
      }
    } catch (_) {}

    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return null;
    final updated = _tasks[index].copyWith(status: DeliveryTaskStatus.accepted);
    _tasks[index] = updated;
    return updated;
  }

  Future<DeliveryTask?> markTaskPickedUp(String taskId) async {
    try {
      final resp = await _apiClient.post('/api/v1/delivery/tasks/$taskId/pickup');
      if (resp is Map<String, dynamic>) {
        return _taskFromApi(resp);
      }
    } catch (_) {}

    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return null;
    final updated = _tasks[index].copyWith(
      status: DeliveryTaskStatus.pickedUp,
      pickedUpAt: DateTime.now(),
    );
    _tasks[index] = updated;
    return updated;
  }

  Future<bool> verifyAndCompleteTask(String taskId, String otp) async {
    try {
      final resp = await _apiClient.post(
        '/api/v1/delivery/tasks/$taskId/verify-otp',
        body: {'otp': otp.trim()},
      );
      if (resp is Map<String, dynamic> && resp['verified'] == true) {
        return true;
      }
    } on ApiException catch (e) {
      if (e.fromServer) return false;
    } catch (_) {}

    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return false;

    final task = _tasks[index];
    if (task.requiredOtp.trim() != otp.trim()) {
      return false;
    }

    final now = DateTime.now();
    _tasks[index] = task.copyWith(
      status: DeliveryTaskStatus.delivered,
      deliveredAt: now,
    );
    _walletBalance += task.tripPayout;
    _tripsCompletedCount += 1;
    _transactions.insert(
      0,
      DeliveryWalletRecord(
        id: 'TXN-${DateTime.now().millisecondsSinceEpoch % 10000}',
        title: 'Trip Payout #${task.id} (${task.cropSummary})',
        orderId: task.orderId,
        amount: task.tripPayout,
        timestamp: now,
        isCredit: true,
      ),
    );
    return true;
  }

  Future<double> getWalletBalance() async {
    try {
      final resp = await _apiClient.get('/api/v1/delivery/wallet');
      if (resp is Map<String, dynamic> && resp['balance'] != null) {
        return (resp['balance'] as num).toDouble();
      }
    } catch (_) {}
    return _walletBalance;
  }

  Future<int> getTripsCompletedCount() async {
    try {
      final resp = await _apiClient.get('/api/v1/delivery/wallet');
      if (resp is Map<String, dynamic> && resp['trips_completed'] != null) {
        return (resp['trips_completed'] as num).toInt();
      }
    } catch (_) {}
    return _tripsCompletedCount;
  }

  Future<List<DeliveryWalletRecord>> getTransactions() async {
    try {
      final resp = await _apiClient.get('/api/v1/delivery/wallet');
      if (resp is Map<String, dynamic> && resp['transactions'] is List) {
        return (resp['transactions'] as List).whereType<Map>().map((t) {
          return DeliveryWalletRecord(
            id: t['id']?.toString() ?? '',
            title: t['title']?.toString() ?? 'Payout',
            orderId: t['order_id']?.toString(),
            amount: (t['amount'] as num?)?.toDouble() ?? 0.0,
            timestamp: DateTime.tryParse(t['created_at']?.toString() ?? '') ?? DateTime.now(),
            isCredit: t['is_credit'] != false,
            status: t['status']?.toString() ?? 'Completed',
          );
        }).toList();
      }
    } catch (_) {}
    return List.unmodifiable(_transactions);
  }

  Future<bool> requestBankPayout(double amount, String upiOrBank) async {
    try {
      await _apiClient.post(
        '/api/v1/delivery/payout',
        body: {'amount': amount, 'upi_or_bank': upiOrBank},
      );
      return true;
    } on ApiException catch (e) {
      if (e.fromServer) return false;
    } catch (_) {}

    if (amount <= 0 || amount > _walletBalance) return false;
    _walletBalance -= amount;
    _transactions.insert(
      0,
      DeliveryWalletRecord(
        id: 'PAYOUT-${DateTime.now().millisecondsSinceEpoch % 10000}',
        title: 'Withdrawal to $upiOrBank',
        amount: amount,
        timestamp: DateTime.now(),
        isCredit: false,
        status: 'Processing',
      ),
    );
    return true;
  }
}
