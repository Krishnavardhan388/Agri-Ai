import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/agri_card.dart';
import '../../../marketplace/domain/order_model.dart';
import '../../../marketplace/state/marketplace_provider.dart';

class CustomerOrdersTab extends ConsumerWidget {
  const CustomerOrdersTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersState = ref.watch(ordersProvider);
    final orders = ordersState.customerOrders;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Harvest Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.read(ordersProvider.notifier).refreshAllOrders(),
          ),
        ],
      ),
      body: orders.isEmpty
          ? const Center(
              child: Text(
                'No orders placed yet.\nYour orders will show live delivery tracking here.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                final itemsSummary = order.items.map((i) => '${i.productTitle} (${i.quantityKg.toInt()} kg)').join(', ');

                final isStep1Done = true;
                final isStep2Done = order.status == OrderStatus.accepted ||
                    order.status == OrderStatus.packed ||
                    order.status == OrderStatus.inTransit ||
                    order.status == OrderStatus.delivered;
                final isStep3Done = order.status == OrderStatus.packed ||
                    order.status == OrderStatus.inTransit ||
                    order.status == OrderStatus.delivered;
                final isStep4Done = order.status == OrderStatus.inTransit ||
                    order.status == OrderStatus.delivered;
                final isStep5Done = order.status == OrderStatus.delivered;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: AgriCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Order #${order.id}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textSecondary),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.greenSurface,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                order.status.displayName,
                                style: const TextStyle(color: AppColors.primaryDark, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(itemsSummary, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        Text('From ${order.farmerName}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        const SizedBox(height: 14),

                        // Handover OTP Container
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Handover Delivery OTP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                  Text('Share with delivery driver upon arrival', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                ],
                              ),
                              Text(
                                order.deliveryOtp,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Order Tracking Stepper
                        _TrackingStep(
                          title: 'Order Confirmed',
                          subtitle: 'Payment verified via ${order.paymentMethod}',
                          isCompleted: isStep1Done,
                          isLast: false,
                        ),
                        _TrackingStep(
                          title: 'Farmer Accepted',
                          subtitle: 'Harvest scheduled from field',
                          isCompleted: isStep2Done,
                          isLast: false,
                        ),
                        _TrackingStep(
                          title: 'Fresh Harvest Packed',
                          subtitle: 'Packed in breathable crates for transit',
                          isCompleted: isStep3Done,
                          isLast: false,
                        ),
                        _TrackingStep(
                          title: 'Out for Doorstep Delivery',
                          subtitle: 'Delivery partner assigned & en route',
                          isCompleted: isStep4Done,
                          isCurrent: order.status == OrderStatus.inTransit,
                          isLast: false,
                        ),
                        _TrackingStep(
                          title: 'Delivery Confirmed via OTP',
                          subtitle: 'Produce inspected & handed over',
                          isCompleted: isStep5Done,
                          isLast: true,
                        ),
                        const Divider(height: 24),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Paid: ₹${order.totalAmount.toInt()}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryDark),
                            ),
                            OutlinedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Calling farmer support desk...')),
                                );
                              },
                              icon: const Icon(Icons.call_outlined, size: 16),
                              label: const Text('Contact Farmer', style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _TrackingStep extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isCompleted;
  final bool isCurrent;
  final bool isLast;

  const _TrackingStep({
    required this.title,
    required this.subtitle,
    this.isCompleted = false,
    this.isCurrent = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? AppColors.primaryGreen
                    : isCurrent
                        ? AppColors.earthAmber
                        : AppColors.border,
              ),
              child: Center(
                child: Icon(
                  isCompleted ? Icons.check : Icons.circle,
                  size: 10,
                  color: Colors.white,
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 28,
                color: isCompleted ? AppColors.primaryGreen : AppColors.border,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: isCompleted || isCurrent ? AppColors.textPrimary : AppColors.textMuted,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              if (!isLast) const SizedBox(height: 10),
            ],
          ),
        ),
      ],
    );
  }
}
