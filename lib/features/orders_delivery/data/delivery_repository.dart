import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/firebase_service.dart';
import '../domain/delivery_task_model.dart';

class DeliveryRepository {
  FirebaseFirestore? _firestore;

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
    DeliveryTask(
      id: 'TASK-104',
      orderId: 'AGRI-1099',
      farmName: 'Godavari Organic Turmeric',
      farmAddress: 'Mulugu Road, Warangal',
      farmLat: 18.0315,
      farmLng: 79.6180,
      farmPhone: '+91 99890 33445',
      customerName: 'Green Grocers Hub',
      customerAddress: 'Collectorate Colony, Subedari',
      customerLat: 17.9940,
      customerLng: 79.5390,
      customerPhone: '+91 97000 44556',
      cropSummary: '15 kg Pure Organic Turmeric Powder',
      totalWeightKg: 15.0,
      distanceKm: 5.5,
      tripPayout: 85.0,
      requiredOtp: '6408',
      status: DeliveryTaskStatus.available,
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
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
    DeliveryWalletRecord(
      id: 'TXN-403',
      title: 'Trip Payout #TASK-100',
      orderId: 'AGRI-1080',
      amount: 80.0,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isCredit: true,
    ),
    DeliveryWalletRecord(
      id: 'TXN-404',
      title: 'Peak Morning Incentive Bonus',
      amount: 50.0,
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      isCredit: true,
    ),
  ];

  DeliveryRepository({FirebaseFirestore? firestore}) {
    if (firestore != null) _firestore = firestore;
  }

  FirebaseFirestore? get firestore {
    if (_firestore != null) return _firestore;
    if (FirebaseService.isInitialized) {
      _firestore = FirebaseFirestore.instance;
      return _firestore;
    }
    return null;
  }

  Future<List<DeliveryTask>> getTasks() async {
    final fs = firestore;
    if (FirebaseService.isInitialized && fs != null) {
      try {
        final snapshot = await fs.collection('delivery_tasks').get();
        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs
              .map((doc) => DeliveryTask.fromMap(doc.data(), doc.id))
              .toList();
        }
      } catch (_) {}
    }
    return List.unmodifiable(_tasks);
  }

  Future<DeliveryTask?> acceptTask(String taskId) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return null;

    final updated = _tasks[index].copyWith(
      status: DeliveryTaskStatus.accepted,
    );
    _tasks[index] = updated;

    final fs = firestore;
    if (FirebaseService.isInitialized && fs != null) {
      try {
        await fs.collection('delivery_tasks').doc(taskId).update({
          'status': DeliveryTaskStatus.accepted.name,
        });
      } catch (_) {}
    }
    return updated;
  }

  Future<DeliveryTask?> markTaskPickedUp(String taskId) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return null;

    final updated = _tasks[index].copyWith(
      status: DeliveryTaskStatus.pickedUp,
      pickedUpAt: DateTime.now(),
    );
    _tasks[index] = updated;

    final fs = firestore;
    if (FirebaseService.isInitialized && fs != null) {
      try {
        await fs.collection('delivery_tasks').doc(taskId).update({
          'status': DeliveryTaskStatus.pickedUp.name,
          'pickedUpAt': updated.pickedUpAt?.toIso8601String(),
        });
      } catch (_) {}
    }
    return updated;
  }

  Future<bool> verifyAndCompleteTask(String taskId, String otp) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return false;

    final task = _tasks[index];
    if (task.requiredOtp.trim() != otp.trim()) {
      return false;
    }

    final now = DateTime.now();
    final updated = task.copyWith(
      status: DeliveryTaskStatus.delivered,
      deliveredAt: now,
    );
    _tasks[index] = updated;

    // Credit earnings
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

    final fs = firestore;
    if (FirebaseService.isInitialized && fs != null) {
      try {
        await fs.collection('delivery_tasks').doc(taskId).update({
          'status': DeliveryTaskStatus.delivered.name,
          'deliveredAt': now.toIso8601String(),
        });
      } catch (_) {}
    }
    return true;
  }

  Future<double> getWalletBalance() async => _walletBalance;

  Future<int> getTripsCompletedCount() async => _tripsCompletedCount;

  Future<List<DeliveryWalletRecord>> getTransactions() async {
    return List.unmodifiable(_transactions);
  }

  Future<bool> requestBankPayout(double amount, String upiOrBank) async {
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

