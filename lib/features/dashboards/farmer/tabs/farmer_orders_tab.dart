import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/agri_card.dart';
import '../../../marketplace/domain/order_model.dart';
import '../../../marketplace/state/marketplace_provider.dart';

class FarmerOrdersTab extends ConsumerWidget {
  const FarmerOrdersTab({super.key});

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return AppColors.earthAmber;
      case OrderStatus.accepted:
        return AppColors.primaryLight;
      case OrderStatus.packed:
        return AppColors.primaryGreen;
      case OrderStatus.inTransit:
        return AppColors.healthyTeal;
      case OrderStatus.delivered:
        return AppColors.primaryDark;
      case OrderStatus.cancelled:
        return AppColors.alertRed;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersState = ref.watch(ordersProvider);
    final orders = ordersState.farmerOrders;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Farm Orders Received'),
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
                'No orders received yet.\nNew customer orders will show here in real time.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                final statusColor = _getStatusColor(order.status);
                final isActionable = order.status == OrderStatus.pending || order.status == OrderStatus.accepted;

                final itemsSummary = order.items.map((i) => '${i.productTitle} (${i.quantityKg.toInt()} kg)').join(', ');

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
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
                                color: statusColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                order.status.displayName,
                                style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          itemsSummary,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.person_outline_rounded, size: 15, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(order.customerName, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            const SizedBox(width: 8),
                            const Icon(Icons.phone_outlined, size: 13, color: AppColors.textSecondary),
                            const SizedBox(width: 2),
                            Text(order.customerPhone, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 15, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                order.deliveryAddress,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Paid: ${order.paymentMethod}', style: const TextStyle(fontSize: 11, color: AppColors.primaryGreen, fontWeight: FontWeight.w600)),
                                Text('₹${order.totalAmount.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryDark)),
                              ],
                            ),
                            if (isActionable)
                              ElevatedButton(
                                onPressed: () {
                                  ref.read(ordersProvider.notifier).updateStatus(order.id, OrderStatus.packed);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Order #${order.id} marked as Packed for delivery handover!')),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                ),
                                child: const Text('Pack Harvest', style: TextStyle(fontSize: 12)),
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
