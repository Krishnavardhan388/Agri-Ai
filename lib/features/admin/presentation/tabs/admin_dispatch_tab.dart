import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/agri_card.dart';
import '../../domain/admin_dispatch_trip.dart';
import '../../state/dispatch_provider.dart';

class AdminDispatchTab extends ConsumerStatefulWidget {
  const AdminDispatchTab({super.key});

  @override
  ConsumerState<AdminDispatchTab> createState() => _AdminDispatchTabState();
}

class _AdminDispatchTabState extends ConsumerState<AdminDispatchTab> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showReassignDialog(BuildContext context, AdminDispatchTrip trip) {
    String selectedDriver = 'Suresh Patel';
    String selectedPhone = '+91 98765 22114';
    String selectedVehicle = 'Hero Splendor (TS-03-EB-4421)';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.swap_horiz_rounded, color: AppColors.primaryGreen),
              const SizedBox(width: 8),
              Text('Reassign Driver: ${trip.tripId}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          content: SizedBox(
            width: 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Current Driver: ${trip.driverName}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                Text('Order: ${trip.orderId} • ${trip.produceSummary}', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                const Text('Select Available Fleet Driver:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: selectedDriver,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Suresh Patel',
                      child: Text('Suresh Patel (Hero Splendor • Active nearby)'),
                    ),
                    DropdownMenuItem(
                      value: 'Rajesh Goud',
                      child: Text('Rajesh Goud (Piaggio Ape Cargo • Warangal Yard)'),
                    ),
                    DropdownMenuItem(
                      value: 'Anand Kumar',
                      child: Text('Anand Kumar (Bajaj Pulsar • Kazipet)'),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() {
                        selectedDriver = val;
                        if (val == 'Suresh Patel') {
                          selectedPhone = '+91 98765 22114';
                          selectedVehicle = 'Hero Splendor (TS-03-EB-4421)';
                        } else if (val == 'Rajesh Goud') {
                          selectedPhone = '+91 98765 44332';
                          selectedVehicle = 'Piaggio Ape Cargo (TS-03-TR-9102)';
                        } else {
                          selectedPhone = '+91 98765 66554';
                          selectedVehicle = 'Bajaj Pulsar 150 (TS-03-FA-1102)';
                        }
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                Navigator.of(ctx).pop();
                final success = await ref.read(dispatchProvider.notifier).reassignDriver(
                      tripId: trip.tripId,
                      newDriverName: selectedDriver,
                      newDriverPhone: selectedPhone,
                      newDriverVehicle: selectedVehicle,
                    );
                if (mounted && success) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('✅ Trip ${trip.tripId} reassigned to $selectedDriver!'),
                      backgroundColor: AppColors.primaryGreen,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, foregroundColor: Colors.white),
              child: const Text('Confirm Reassignment'),
            ),
          ],
        ),
      ),
    );
  }

  void _showOverrideOtpDialog(BuildContext context, AdminDispatchTrip trip) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.verified_user_rounded, color: Color(0xFFE65100)),
            SizedBox(width: 8),
            Text('Admin Doorstep OTP Override', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Trip: ${trip.tripId} • Order: ${trip.orderId}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
              const SizedBox(height: 4),
              Text('Customer: ${trip.customerName} (${trip.customerAddress})', style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFFB74D)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Expected Delivery Handover OTP:', style: TextStyle(fontSize: 11.5, color: Color(0xFFE65100))),
                    const SizedBox(height: 2),
                    Text(trip.deliveryOtp, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFFBF360C), letterSpacing: 2)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Use this action only when customer confirms receipt verbally but cannot read/receive the 4-digit SMS OTP (e.g. phone offline or dead battery).',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.of(ctx).pop();
              final success = await ref.read(dispatchProvider.notifier).overrideVerifyOtp(trip.tripId);
              if (mounted && success) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('✅ Handover completed for ${trip.tripId} via Admin Override!'),
                    backgroundColor: AppColors.primaryGreen,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white),
            child: const Text('Force Verify & Complete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dispatchState = ref.watch(dispatchProvider);
    final trips = dispatchState.trips;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),
          const SizedBox(height: 18),

          // Search and Filters Bar
          _buildFiltersBar(dispatchState),
          const SizedBox(height: 20),

          // Trips List
          if (dispatchState.isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
          else if (trips.isEmpty)
            _buildEmptyState()
          else
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: trips.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final trip = trips[index];
                return _buildTripCard(trip);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Color(0xFFE8F5E9),
            child: Icon(Icons.local_shipping_rounded, color: AppColors.primaryGreen, size: 28),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Live Farm-to-Doorstep Dispatch & Logistics Control',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Monitor active pickup trips, reassign delayed orders, and override 4-digit handover OTP verification when required.',
                  style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersBar(DispatchState state) {
    return AgriCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by trip ID, order ID, driver name, farmer, or customer...',
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(dispatchProvider.notifier).setSearchQuery('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              filled: true,
              fillColor: const Color(0xFFF9FBF9),
            ),
            onChanged: (val) => ref.read(dispatchProvider.notifier).setSearchQuery(val),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text('Status:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
              _buildFilterChip(
                label: 'All Trips',
                isSelected: state.selectedStatus == null,
                onTap: () => ref.read(dispatchProvider.notifier).setStatusFilter(null),
              ),
              _buildFilterChip(
                label: '🟢 In Transit (${state.activeInTransitCount})',
                isSelected: state.selectedStatus == DispatchStatus.inTransit,
                onTap: () => ref.read(dispatchProvider.notifier).setStatusFilter(DispatchStatus.inTransit),
              ),
              _buildFilterChip(
                label: '🟡 Pending Driver',
                isSelected: state.selectedStatus == DispatchStatus.pendingAssignment,
                onTap: () => ref.read(dispatchProvider.notifier).setStatusFilter(DispatchStatus.pendingAssignment),
              ),
              _buildFilterChip(
                label: '🔴 Disputed / Delayed (${state.disputedCount})',
                isSelected: state.selectedStatus == DispatchStatus.disputed,
                onTap: () => ref.read(dispatchProvider.notifier).setStatusFilter(DispatchStatus.disputed),
              ),
              _buildFilterChip(
                label: '✅ Delivered',
                isSelected: state.selectedStatus == DispatchStatus.delivered,
                onTap: () => ref.read(dispatchProvider.notifier).setStatusFilter(DispatchStatus.delivered),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreen : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.primaryGreen : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildTripCard(AdminDispatchTrip t) {
    return AgriCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: t.status.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(t.status.icon, color: t.status.color, size: 26),
          ),
          const SizedBox(width: 14),

          // Trip & Driver Details
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 2,
                  children: [
                    Text(t.tripId, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECEFF1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(t.orderId, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Driver: ${t.driverName}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
                if (t.driverVehicle.isNotEmpty)
                  Text(
                    t.driverVehicle,
                    style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Route: Farm -> Customer
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.storefront_rounded, size: 14, color: AppColors.primaryGreen),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text('From: ${t.farmerName} (${t.farmerLocation})', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, size: 14, color: Color(0xFFD32F2F)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text('To: ${t.customerName} • ${t.customerAddress}', style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${t.produceSummary} • ₹${t.totalAmount.toStringAsFixed(0)} • ${t.distanceKm} km',
                  style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Status & OTP Badge
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: t.status.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: t.status.color, width: 1),
                ),
                child: Text(
                  t.status.displayName,
                  style: TextStyle(color: t.status.color, fontWeight: FontWeight.bold, fontSize: 11.5),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.key_rounded, size: 12, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    t.isOtpOverridden ? 'OTP: Override Verified ✅' : 'OTP: ${t.deliveryOtp}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: t.isOtpOverridden ? AppColors.primaryGreen : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 14),

          // Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.swap_horiz_rounded, size: 20),
                tooltip: 'Reassign Fleet Driver',
                onPressed: () => _showReassignDialog(context, t),
              ),
              if (t.status != DispatchStatus.delivered)
                IconButton(
                  icon: const Icon(Icons.verified_user_rounded, size: 20, color: Color(0xFFE65100)),
                  tooltip: 'Admin OTP Override',
                  onPressed: () => _showOverrideOtpDialog(context, t),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(Icons.search_off_rounded, size: 48, color: AppColors.textMuted),
          const SizedBox(height: 12),
          const Text('No Dispatch Trips Found', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          const Text('Try adjusting your search criteria or removing active status filters.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _searchController.clear();
              ref.read(dispatchProvider.notifier).setSearchQuery('');
              ref.read(dispatchProvider.notifier).setStatusFilter(null);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, foregroundColor: Colors.white),
            child: const Text('Reset All Filters'),
          ),
        ],
      ),
    );
  }
}
