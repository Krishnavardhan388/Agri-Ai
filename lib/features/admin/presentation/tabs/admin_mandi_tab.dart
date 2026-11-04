import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/agri_card.dart';
import '../../domain/admin_mandi_update.dart';
import '../../state/mandi_controller_provider.dart';

class AdminMandiTab extends ConsumerStatefulWidget {
  const AdminMandiTab({super.key});

  @override
  ConsumerState<AdminMandiTab> createState() => _AdminMandiTabState();
}

class _AdminMandiTabState extends ConsumerState<AdminMandiTab> {
  void _showEditRateDialog(BuildContext context, AdminMandiCropRate rate) {
    final priceController = TextEditingController(
      text: rate.modalPricePerQuintal.toInt().toString(),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.edit_note_rounded, color: AppColors.primaryGreen),
            const SizedBox(width: 8),
            Text('Update APMC Floor Rate: ${rate.cropName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${rate.marketName} (${rate.district} District)', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              const Text('Modal Benchmark Price (₹ / Quintal):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixText: '₹ ',
                  suffixText: '/ Qtl',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Current equivalent per kg: ₹${rate.pricePerKg.toStringAsFixed(1)} / kg',
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final newPrice = double.tryParse(priceController.text);
              if (newPrice != null && newPrice > 0) {
                final messenger = ScaffoldMessenger.of(context);
                Navigator.of(ctx).pop();
                final success = await ref.read(mandiControllerProvider.notifier).updateRate(rate.id, newPrice);
                if (mounted && success) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('✅ ${rate.cropName} updated to ₹${newPrice.toInt()}/Qtl!'),
                      backgroundColor: AppColors.primaryGreen,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, foregroundColor: Colors.white),
            child: const Text('Save & Apply Rate'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mandiState = ref.watch(mandiControllerProvider);
    final rates = mandiState.rates;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),
          const SizedBox(height: 20),

          // Regional Disease Outbreak Alert Banner
          _buildOutbreakAlertBanner(),
          const SizedBox(height: 20),

          // Mandi Benchmarks Card
          AgriCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'APMC Daily Floor Price Benchmarks (₹ / Quintal)',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Official market benchmarks broadcast to local farmers and used for marketplace price moderation.',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.greenSurface,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('Agmarknet Live', style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold, fontSize: 11)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                if (mandiState.isLoading)
                  const Center(child: Padding(padding: EdgeInsets.all(30), child: CircularProgressIndicator()))
                else
                  ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: rates.length,
                    separatorBuilder: (_, _) => const Divider(height: 24),
                    itemBuilder: (context, index) {
                      final rate = rates[index];
                      return _buildMandiRow(rate);
                    },
                  ),
              ],
            ),
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
            child: Icon(Icons.insights_rounded, color: AppColors.primaryGreen, size: 28),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Regional Mandi Rates & AI Disease Outbreak Alerts',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Broadcast official daily APMC floor prices across Telangana mandis and dispatch real-time crop disease advisories.',
                  style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutbreakAlertBanner() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFB74D)),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Color(0xFFE65100), size: 32),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Regional Pest Outbreak Active: Cotton Pink Bollworm',
                  style: TextStyle(
                    color: Color(0xFFE65100),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'AI Crop Doctor detected 42 confirmed cases across Warangal district in the past 48 hours. Broadcast alert active for 680 registered cotton farmers.',
                  style: TextStyle(
                    color: Color(0xFFBF360C),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMandiRow(AdminMandiCropRate rate) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: rate.isRising ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            rate.isRising ? Icons.trending_up_rounded : Icons.trending_down_rounded,
            color: rate.isRising ? const Color(0xFF2E7D32) : const Color(0xFFD32F2F),
            size: 24,
          ),
        ),
        const SizedBox(width: 14),

        // Crop & Market
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                rate.cropName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '${rate.marketName} • ${rate.district}',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),

        // Benchmark Modal & Range
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6,
                runSpacing: 4,
                children: [
                  Text(
                    '₹${rate.modalPricePerQuintal.toInt()} / Qtl',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: rate.isRising ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${rate.isRising ? '+' : ''}${rate.trendPercentage}% ${rate.isRising ? '↗' : '↘'}',
                      style: TextStyle(
                        color: rate.isRising ? const Color(0xFF2E7D32) : const Color(0xFFD32F2F),
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '₹${rate.pricePerKg.toStringAsFixed(1)}/kg (Range: ₹${rate.minPricePerQuintal.toInt()} - ₹${rate.maxPricePerQuintal.toInt()})',
                style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),

        // Actions
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            OutlinedButton.icon(
              onPressed: () => _showEditRateDialog(context, rate),
              icon: const Icon(Icons.edit_rounded, size: 14),
              label: const Text('Edit Rate'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                textStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () async {
                final success = await ref.read(mandiControllerProvider.notifier).broadcastRate(rate.id);
                if (mounted && success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('📢 ${rate.cropName} rate broadcast to farmers in ${rate.district}!'),
                      backgroundColor: AppColors.primaryGreen,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.campaign_rounded, size: 14),
              label: const Text('Broadcast'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                textStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
