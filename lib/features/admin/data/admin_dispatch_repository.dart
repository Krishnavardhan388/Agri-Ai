import '../domain/admin_dispatch_trip.dart';

class AdminDispatchRepository {
  final List<AdminDispatchTrip> _trips = [
    AdminDispatchTrip(
      tripId: 'TRIP-4019',
      orderId: 'AGRI-1092',
      driverId: 'driver-suresh',
      driverName: 'Suresh Patel',
      driverPhone: '+91 98765 22114',
      driverVehicle: 'Hero Splendor (TS-03-EB-4421)',
      farmerName: 'Ramesh Farm',
      farmerLocation: 'Geesugonda, Warangal',
      customerName: 'Priya Sharma',
      customerAddress: 'Flat 402, Green Meadows, Hanamkonda',
      produceSummary: '5 kg Fresh Organic Tomatoes',
      totalAmount: 190.0,
      deliveryOtp: '4821',
      distanceKm: 8.5,
      status: DispatchStatus.inTransit,
      createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
    ),
    AdminDispatchTrip(
      tripId: 'TRIP-4018',
      orderId: 'AGRI-1088',
      driverId: 'driver-rajesh',
      driverName: 'Rajesh Goud',
      driverPhone: '+91 98765 44332',
      driverVehicle: 'Piaggio Ape Cargo (TS-03-TR-9102)',
      farmerName: 'Ramesh Farm',
      farmerLocation: 'Geesugonda, Warangal',
      customerName: 'Anand Rao',
      customerAddress: 'Subedari, Kazipet (6 km)',
      produceSummary: '50 kg Sona Masoori Raw Rice',
      totalAmount: 2510.0,
      deliveryOtp: '7192',
      distanceKm: 14.2,
      status: DispatchStatus.delivered,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      deliveredAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    AdminDispatchTrip(
      tripId: 'TRIP-4020',
      orderId: 'AGRI-1095',
      driverId: 'driver-anand',
      driverName: 'Anand Kumar',
      driverPhone: '+91 98765 66554',
      driverVehicle: 'Bajaj Pulsar 150 (TS-03-FA-1102)',
      farmerName: 'Sri Krishna Farm',
      farmerLocation: 'Karimnagar Bypass Road',
      customerName: 'Dr. K. Rao',
      customerAddress: 'Plot 18, Kakatiya University Colony, Hanamkonda',
      produceSummary: '10 kg Green Capsicum & 4 kg Tomatoes',
      totalAmount: 620.0,
      deliveryOtp: '8842',
      distanceKm: 6.8,
      status: DispatchStatus.disputed,
      createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 20)),
    ),
    AdminDispatchTrip(
      tripId: 'TRIP-4021',
      orderId: 'AGRI-1099',
      driverId: '',
      driverName: 'Awaiting Driver Allocation',
      driverPhone: '',
      driverVehicle: '',
      farmerName: 'Rayalaseema Natural Farms',
      farmerLocation: 'Madhira Road, Khammam',
      customerName: 'Sneha Reddy',
      customerAddress: 'Balasamudram, Hanamkonda',
      produceSummary: '2 kg Organic Guntur Teja Red Chilli',
      totalAmount: 360.0,
      deliveryOtp: '5521',
      distanceKm: 4.2,
      status: DispatchStatus.pendingAssignment,
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
  ];

  Future<List<AdminDispatchTrip>> getTrips({
    DispatchStatus? status,
    String? searchQuery,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));

    return _trips.where((t) {
      if (status != null && t.status != status) {
        return false;
      }
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final query = searchQuery.trim().toLowerCase();
        final matchesTrip = t.tripId.toLowerCase().contains(query);
        final matchesOrder = t.orderId.toLowerCase().contains(query);
        final matchesDriver = t.driverName.toLowerCase().contains(query);
        final matchesCustomer = t.customerName.toLowerCase().contains(query);
        final matchesFarmer = t.farmerName.toLowerCase().contains(query);
        if (!matchesTrip && !matchesOrder && !matchesDriver && !matchesCustomer && !matchesFarmer) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  Future<bool> reassignDriver(
    String tripId, {
    required String newDriverName,
    required String newDriverPhone,
    required String newDriverVehicle,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _trips.indexWhere((t) => t.tripId == tripId);
    if (index != -1) {
      _trips[index] = _trips[index].copyWith(
        driverName: newDriverName,
        driverPhone: newDriverPhone,
        driverVehicle: newDriverVehicle,
        status: DispatchStatus.inTransit,
      );
      return true;
    }
    return false;
  }

  Future<bool> overrideVerifyOtp(String tripId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _trips.indexWhere((t) => t.tripId == tripId);
    if (index != -1) {
      _trips[index] = _trips[index].copyWith(
        status: DispatchStatus.delivered,
        isOtpOverridden: true,
        deliveredAt: DateTime.now(),
      );
      return true;
    }
    return false;
  }

  int getActiveCount() {
    return _trips.where((t) => t.status == DispatchStatus.inTransit || t.status == DispatchStatus.pickedUp).length;
  }

  int getDisputedCount() {
    return _trips.where((t) => t.status == DispatchStatus.disputed).length;
  }
}
