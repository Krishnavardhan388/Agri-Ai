import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/agri_card.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../orders_delivery/domain/delivery_task_model.dart';
import '../../../orders_delivery/state/delivery_provider.dart';

class DeliveryTasksTab extends ConsumerWidget {
  const DeliveryTasksTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deliveryState = ref.watch(deliveryProvider);
    final notifier = ref.read(deliveryProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Delivery Partner Tasks'),
        actions: [
          // Online / Offline Toggle Pill
          GestureDetector(
            onTap: () {
              notifier.toggleOnline(!deliveryState.isOnline);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    deliveryState.isOnline
                        ? 'Status set to Offline. You won\'t receive new orders.'
                        : 'Status set to Online! Ready for farm pickup tasks.',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(right: 14),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: deliveryState.isOnline
                    ? AppColors.greenSurface
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: deliveryState.isOnline
                      ? AppColors.primaryGreen
                      : AppColors.textMuted,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.circle,
                    size: 8,
                    color: deliveryState.isOnline
                        ? AppColors.primaryGreen
                        : AppColors.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    deliveryState.isOnline ? 'Online • Ready' : 'Offline',
                    style: TextStyle(
                      color: deliveryState.isOnline
                          ? AppColors.primaryDark
                          : AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => notifier.loadData(),
        color: AppColors.primaryGreen,
        child: deliveryState.isOnline
            ? _buildOnlineBody(context, ref, deliveryState, notifier)
            : _buildOfflineBody(context, notifier),
      ),
    );
  }

  Widget _buildOfflineBody(BuildContext context, DeliveryNotifier notifier) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.two_wheeler_outlined,
                size: 64,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'You are Currently Offline',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Toggle your status to Online to receive harvest pickup assignments from nearby farms.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Go Online & Start Earning',
              icon: Icons.power_settings_new_rounded,
              onPressed: () => notifier.toggleOnline(true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnlineBody(
    BuildContext context,
    WidgetRef ref,
    DeliveryState state,
    DeliveryNotifier notifier,
  ) {
    final activeTasks = state.activeTasks;
    final availableTasks = state.availableTasks;
    final completedTasks = state.completedTasks;

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Quick Online Status Banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.greenSurface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.radar_rounded, color: AppColors.primaryGreen, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'GPS Active • Warangal Region (${availableTasks.length} farm pickups ready)',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Section 1: Active Trips
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Active Trip Assignment',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: activeTasks.isNotEmpty
                    ? AppColors.primaryGreen
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${activeTasks.length} Active',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: activeTasks.isNotEmpty ? Colors.white : AppColors.textMuted,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (activeTasks.isEmpty)
          AgriCard(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              child: Column(
                children: [
                  const Icon(Icons.check_circle_outline_rounded,
                      size: 40, color: AppColors.primaryGreen),
                  const SizedBox(height: 10),
                  const Text(
                    'No active trip in progress',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Review the available orders below and accept a pickup to begin.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
          )
        else
          ...activeTasks.map((task) => _buildActiveTaskCard(context, task, notifier)),

        const SizedBox(height: 24),

        // Section 2: Available Farm Pickups
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Available Farm Orders',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '${availableTasks.length} nearby',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (availableTasks.isEmpty)
          AgriCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'No more pending pickups in this cluster.',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ),
            ),
          )
        else
          ...availableTasks.map((task) => _buildAvailableTaskCard(context, task, notifier)),

        if (completedTasks.isNotEmpty) ...[
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recently Delivered Today',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                '${completedTasks.length} completed',
                style: const TextStyle(fontSize: 12, color: AppColors.primaryDark),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...completedTasks.map((task) => _buildCompletedTaskCard(task)),
        ],
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildActiveTaskCard(
    BuildContext context,
    DeliveryTask task,
    DeliveryNotifier notifier,
  ) {
    final isInTransit = task.status == DeliveryTaskStatus.pickedUp;

    return AgriCard(
      border: Border.all(
        color: isInTransit ? AppColors.primaryLight : AppColors.primaryGreen,
        width: 1.8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isInTransit ? Colors.blue.shade700 : AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isInTransit ? 'IN TRANSIT TO CUSTOMER' : 'PICKUP PENDING',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                'Trip Payout: ₹${task.tripPayout.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Crop info pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.eco_rounded, size: 16, color: AppColors.primaryGreen),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${task.cropSummary} • ${task.totalWeightKg} kg • ${task.distanceKm} km',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Farm Pickup Row
          _LocationRow(
            icon: Icons.storefront_rounded,
            iconColor: AppColors.primaryGreen,
            label: 'PICKUP FROM FARM',
            name: task.farmName,
            address: task.farmAddress,
            phone: task.farmPhone,
            onCall: () => notifier.launchPhone(task.farmPhone),
            onRoute: () => notifier.launchNavigation(
              lat: task.farmLat,
              lng: task.farmLng,
              label: task.farmName,
            ),
          ),

          const Padding(
            padding: EdgeInsets.only(left: 17),
            child: SizedBox(
              height: 18,
              child: VerticalDivider(color: AppColors.border, thickness: 2),
            ),
          ),

          // Customer Drop Row
          _LocationRow(
            icon: Icons.person_pin_circle_rounded,
            iconColor: AppColors.alertRed,
            label: 'DELIVER TO CUSTOMER',
            name: task.customerName,
            address: task.customerAddress,
            phone: task.customerPhone,
            onCall: () => notifier.launchPhone(task.customerPhone),
            onRoute: () => notifier.launchNavigation(
              lat: task.customerLat,
              lng: task.customerLng,
              label: task.customerName,
            ),
          ),

          const Divider(height: 24),

          // Stage Progression Action Button
          if (!isInTransit) ...[
            CustomButton(
              text: 'Mark Harvest Picked Up from Farm',
              icon: Icons.check_box_rounded,
              onPressed: () async {
                final success = await notifier.markPickedUp(task.id);
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Harvest picked up! Navigate to customer drop location.'),
                      backgroundColor: AppColors.primaryGreen,
                    ),
                  );
                }
              },
            ),
          ] else ...[
            CustomButton(
              text: 'Enter Customer Handover OTP',
              icon: Icons.verified_rounded,
              onPressed: () => _showOtpDialog(context, task, notifier),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvailableTaskCard(
    BuildContext context,
    DeliveryTask task,
    DeliveryNotifier notifier,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: AgriCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'NEW ORDER',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  'Earn ₹${task.tripPayout.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '${task.farmName} → ${task.customerAddress}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              '${task.cropSummary} • ${task.totalWeightKg} kg • ${task.distanceKm} km trip',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => notifier.launchNavigation(
                      lat: task.farmLat,
                      lng: task.farmLng,
                      label: task.farmName,
                    ),
                    icon: const Icon(Icons.map_outlined, size: 16),
                    label: const Text('View Route', style: TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final success = await notifier.acceptTrip(task.id);
                      if (success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Accepted order for ${task.farmName}!'),
                            backgroundColor: AppColors.primaryGreen,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.check_rounded, size: 16),
                    label: const Text('Accept Trip', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedTaskCard(DeliveryTask task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: AppColors.primaryGreen, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delivered to ${task.customerName}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Text(
                  '${task.cropSummary} • Order ${task.orderId}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
          Text(
            '+₹${task.tripPayout.toStringAsFixed(0)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _showOtpDialog(
    BuildContext context,
    DeliveryTask task,
    DeliveryNotifier notifier,
  ) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.shield_outlined, color: AppColors.primaryGreen),
            const SizedBox(width: 8),
            const Text('Handover OTP', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ask customer (${task.customerName}) for the 4-digit verification code to confirm handover:',
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              maxLength: 4,
              textAlign: TextAlign.center,
              autofocus: true,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: 12,
                color: AppColors.primaryDark,
              ),
              decoration: InputDecoration(
                hintText: '••••',
                counterText: '',
                fillColor: AppColors.greenSurface,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primaryGreen),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Customer\'s app shows OTP: ${task.requiredOtp}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final code = controller.text.trim();
              if (code.length < 4) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter all 4 digits')),
                );
                return;
              }

              Navigator.pop(ctx);
              final success = await notifier.verifyOtpAndDeliver(task.id, code);
              if (context.mounted) {
                if (success) {
                  showDialog(
                    context: context,
                    builder: (alertCtx) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              size: 56, color: AppColors.primaryGreen),
                          const SizedBox(height: 14),
                          const Text(
                            'Delivery Confirmed!',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '₹${task.tripPayout.toStringAsFixed(0)} has been credited to your AGRI Partner wallet.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      actions: [
                        CustomButton(
                          text: 'Great, Continue',
                          onPressed: () => Navigator.pop(alertCtx),
                        ),
                      ],
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Incorrect OTP! Please check code with customer.'),
                      backgroundColor: AppColors.alertRed,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('Verify & Complete'),
          ),
        ],
      ),
    );
  }
}

class _LocationRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String name;
  final String address;
  final String phone;
  final VoidCallback onCall;
  final VoidCallback onRoute;

  const _LocationRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.name,
    required this.address,
    required this.phone,
    required this.onCall,
    required this.onRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 28),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: iconColor,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text(address, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.phone_rounded, color: AppColors.primaryGreen, size: 20),
              tooltip: 'Call $name',
              onPressed: onCall,
            ),
            IconButton(
              icon: const Icon(Icons.directions_rounded, color: AppColors.primaryDark, size: 20),
              tooltip: 'GPS Route',
              onPressed: onRoute,
            ),
          ],
        ),
      ],
    );
  }
}
