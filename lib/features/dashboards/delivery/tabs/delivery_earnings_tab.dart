import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/agri_card.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../orders_delivery/domain/delivery_task_model.dart';
import '../../../orders_delivery/state/delivery_provider.dart';

class DeliveryEarningsTab extends ConsumerWidget {
  const DeliveryEarningsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(deliveryProvider);
    final notifier = ref.read(deliveryProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Partner Earnings & Wallet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Wallet',
            onPressed: () => notifier.loadData(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => notifier.loadData(),
        color: AppColors.primaryGreen,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Total Payout Balance Banner
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryDark, AppColors.primaryGreen],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGreen.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text('Available Wallet Balance',
                        style: TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 6),
                    Text(
                      '₹${state.walletBalance.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _BannerStat(
                          label: 'Today\'s Earnings',
                          value: '₹${state.todayEarnings.toStringAsFixed(0)}',
                        ),
                        Container(width: 1, height: 26, color: Colors.white24),
                        _BannerStat(
                          label: 'Trips Completed',
                          value: '${state.tripsCompletedToday} Trips',
                        ),
                        Container(width: 1, height: 26, color: Colors.white24),
                        const _BannerStat(
                          label: 'Weekly Rating',
                          value: '★ 4.9',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Quick Payout Action Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _showPayoutSheet(context, state, notifier),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primaryDark,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.account_balance_rounded, size: 18),
                        label: const Text(
                          'Withdraw to Bank / UPI',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Transaction History Ledger
              AgriCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Transactions',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Text(
                          '${state.transactions.length} entries',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (state.transactions.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Text(
                            'No wallet transactions recorded yet.',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          ),
                        ),
                      )
                    else
                      ...state.transactions.map((txn) => _buildTransactionItem(txn)),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Weekly Payout Summary Table
              AgriCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Weekly Summary',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 12),
                    _EarningRow(
                      day: 'Today',
                      amount: '₹${state.todayEarnings.toStringAsFixed(0)}',
                      trips: '${state.tripsCompletedToday} Trips',
                    ),
                    const Divider(height: 16),
                    const _EarningRow(
                      day: 'Yesterday',
                      amount: '₹1,840',
                      trips: '18 Trips',
                    ),
                    const Divider(height: 16),
                    const _EarningRow(
                      day: 'Saturday',
                      amount: '₹1,420',
                      trips: '14 Trips',
                    ),
                    const Divider(height: 16),
                    const _EarningRow(
                      day: 'Friday',
                      amount: '₹950',
                      trips: '9 Trips',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionItem(DeliveryWalletRecord txn) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border, width: 0.8)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: txn.isCredit ? AppColors.greenSurface : Colors.orange.shade50,
            child: Icon(
              txn.isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
              size: 18,
              color: txn.isCredit ? AppColors.primaryGreen : Colors.orange.shade800,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  txn.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Text(
                  '${txn.status} • ${_formatTime(txn.timestamp)}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
          Text(
            '${txn.isCredit ? '+' : '-'}₹${txn.amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: txn.isCredit ? AppColors.primaryDark : AppColors.alertRed,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final min = dt.minute.toString().padLeft(2, '0');
    return '$hour:$min $period';
  }

  void _showPayoutSheet(
    BuildContext context,
    DeliveryState state,
    DeliveryNotifier notifier,
  ) {
    final amountController = TextEditingController(
      text: state.walletBalance > 500 ? '500' : state.walletBalance.toStringAsFixed(0),
    );
    final upiController = TextEditingController(text: 'driver.kisan@okhdfcbank');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Withdraw Wallet Balance',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Available: ₹${state.walletBalance.toStringAsFixed(2)}',
              style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Enter Withdrawal Amount (₹)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 6),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                prefixText: '₹ ',
                hintText: '500',
              ),
            ),
            const SizedBox(height: 14),
            const Text('Transfer to UPI ID / Bank VPA', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 6),
            TextField(
              controller: upiController,
              decoration: const InputDecoration(
                hintText: 'e.g. mobile@upi',
                prefixIcon: Icon(Icons.payment_rounded, color: AppColors.primaryGreen),
              ),
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Confirm Withdrawal',
              icon: Icons.check_circle_outline_rounded,
              onPressed: () async {
                final amt = double.tryParse(amountController.text.trim()) ?? 0;
                final upi = upiController.text.trim();

                if (amt <= 0 || amt > state.walletBalance) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid amount within your wallet balance')),
                  );
                  return;
                }

                Navigator.pop(ctx);
                final success = await notifier.requestBankPayout(amt, upi);
                if (context.mounted) {
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('₹${amt.toStringAsFixed(0)} transfer initiated to $upi!'),
                        backgroundColor: AppColors.primaryGreen,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to process withdrawal')),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BannerStat extends StatelessWidget {
  final String label;
  final String value;

  const _BannerStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }
}

class _EarningRow extends StatelessWidget {
  final String day;
  final String amount;
  final String trips;

  const _EarningRow({
    required this.day,
    required this.amount,
    required this.trips,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(day, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            Text(trips, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          ],
        ),
        Text(
          amount,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: AppColors.primaryDark,
          ),
        ),
      ],
    );
  }
}
