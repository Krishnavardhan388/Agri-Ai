import 'package:flutter_test/flutter_test.dart';
import 'package:agri_ai/features/orders_delivery/domain/delivery_task_model.dart';
import 'package:agri_ai/features/orders_delivery/data/delivery_repository.dart';
import 'package:agri_ai/features/orders_delivery/data/map_navigation_service.dart';
import 'package:agri_ai/features/orders_delivery/state/delivery_provider.dart';

void main() {
  group('Delivery Partner Module Tests', () {
    late DeliveryRepository repository;

    setUp(() {
      repository = DeliveryRepository();
    });

    test('DeliveryTask model toMap and fromMap serialization', () {
      final task = DeliveryTask(
        id: 'TASK-TEST-1',
        orderId: 'AGRI-TEST-100',
        farmName: 'Test Organic Farm',
        farmAddress: 'Warangal Highway',
        farmLat: 17.9689,
        farmLng: 79.5941,
        farmPhone: '+91 99999 11111',
        customerName: 'Kavitha Devi',
        customerAddress: 'Kishanpura, Hanamkonda',
        customerLat: 18.0072,
        customerLng: 79.5583,
        customerPhone: '+91 88888 22222',
        cropSummary: '10 kg Tomatoes',
        totalWeightKg: 10.0,
        distanceKm: 5.2,
        tripPayout: 80.0,
        requiredOtp: '5678',
        status: DeliveryTaskStatus.available,
        createdAt: DateTime(2026, 5, 1, 10, 0),
      );

      final map = task.toMap();
      expect(map['id'], 'TASK-TEST-1');
      expect(map['tripPayout'], 80.0);
      expect(map['requiredOtp'], '5678');
      expect(map['status'], 'available');

      final deserialized = DeliveryTask.fromMap(map);
      expect(deserialized.id, 'TASK-TEST-1');
      expect(deserialized.customerName, 'Kavitha Devi');
      expect(deserialized.tripPayout, 80.0);
      expect(deserialized.status, DeliveryTaskStatus.available);
    });

    test('DeliveryRepository initial state and task acceptance', () async {
      final tasks = await repository.getTasks();
      expect(tasks.isNotEmpty, true);

      // Check available task
      final availableTask = tasks.firstWhere(
        (t) => t.status == DeliveryTaskStatus.available,
      );
      expect(availableTask.id, isNotEmpty);

      // Accept task
      final accepted = await repository.acceptTask(availableTask.id);
      expect(accepted, isNotNull);
      expect(accepted!.status, DeliveryTaskStatus.accepted);

      // Mark picked up
      final pickedUp = await repository.markTaskPickedUp(availableTask.id);
      expect(pickedUp, isNotNull);
      expect(pickedUp!.status, DeliveryTaskStatus.pickedUp);
      expect(pickedUp.pickedUpAt, isNotNull);
    });

    test('OTP Verification and Wallet Payout flow', () async {
      final initialBalance = await repository.getWalletBalance();
      final initialTrips = await repository.getTripsCompletedCount();

      // TASK-101 has OTP '4821' and payout ₹95
      // 1. Invalid OTP should fail
      final failResult = await repository.verifyAndCompleteTask('TASK-101', '0000');
      expect(failResult, false);

      final balanceAfterFail = await repository.getWalletBalance();
      expect(balanceAfterFail, initialBalance);

      // 2. Valid OTP should succeed, credit ₹95 and record transaction
      final successResult = await repository.verifyAndCompleteTask('TASK-101', '4821');
      expect(successResult, true);

      final balanceAfterSuccess = await repository.getWalletBalance();
      expect(balanceAfterSuccess, initialBalance + 95.0);

      final tripsAfterSuccess = await repository.getTripsCompletedCount();
      expect(tripsAfterSuccess, initialTrips + 1);

      final txns = await repository.getTransactions();
      expect(txns.first.amount, 95.0);
      expect(txns.first.isCredit, true);
    });

    test('Bank payout withdrawal flow', () async {
      final currentBalance = await repository.getWalletBalance();

      // Withdraw invalid amount (negative or exceeding balance)
      final invalidWithdraw = await repository.requestBankPayout(currentBalance + 500, 'test@upi');
      expect(invalidWithdraw, false);

      // Withdraw valid amount
      final validWithdraw = await repository.requestBankPayout(200.0, 'driver.kisan@okhdfcbank');
      expect(validWithdraw, true);

      final balanceAfterWithdraw = await repository.getWalletBalance();
      expect(balanceAfterWithdraw, currentBalance - 200.0);

      final txns = await repository.getTransactions();
      expect(txns.first.amount, 200.0);
      expect(txns.first.isCredit, false);
      expect(txns.first.status, 'Processing');
    });

    test('DeliveryNotifier state and online toggle', () async {
      final notifier = DeliveryNotifier(
        repository: repository,
        navService: const MapNavigationService(),
      );

      await notifier.loadData();
      expect(notifier.state.isOnline, true);
      expect(notifier.state.tasks.isNotEmpty, true);

      // Toggle offline
      notifier.toggleOnline(false);
      expect(notifier.state.isOnline, false);

      // Toggle online
      notifier.toggleOnline(true);
      expect(notifier.state.isOnline, true);
    });
  });
}

