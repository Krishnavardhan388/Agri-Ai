import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/agri_card.dart';
import '../../domain/admin_marketplace_item.dart';
import '../../state/marketplace_moderation_provider.dart';

class AdminMarketplaceTab extends ConsumerStatefulWidget {
  const AdminMarketplaceTab({super.key});

  @override
  ConsumerState<AdminMarketplaceTab> createState() => _AdminMarketplaceTabState();
}

class _AdminMarketplaceTabState extends ConsumerState<AdminMarketplaceTab> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFlagAnomalyDialog(BuildContext context, AdminProductItem item) {
    final noteController = TextEditingController(
      text: 'Farmer asking price (₹${item.pricePerKg.toStringAsFixed(0)}/kg) exceeds the APMC Mandi benchmark (₹${item.mandiBenchmarkPerKg.toStringAsFixed(0)}/kg) by ${item.priceDeviationPercent.toStringAsFixed(1)}%. Please adjust to ensure fair buyer pricing.',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Color(0xFFD32F2F)),
            const SizedBox(width: 8),
            Text('Price Anomaly Warning: ${item.title}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Farmer: ${item.farmerName} (${item.farmerLocation})', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFFCDD2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text('Farmer Price', style: TextStyle(fontSize: 11, color: Color(0xFFC62828))),
                        Text('₹${item.pricePerKg.toStringAsFixed(0)} / kg', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFB71C1C))),
                      ],
                    ),
                    const Text('vs', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFC62828))),
                    Column(
                      children: [
                        const Text('APMC Mandi Rate', style: TextStyle(fontSize: 11, color: Color(0xFFC62828))),
                        Text('₹${item.mandiBenchmarkPerKg.toStringAsFixed(0)} / kg', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFB71C1C))),
                      ],
                    ),
                    Column(
                      children: [
                        const Text('Deviation', style: TextStyle(fontSize: 11, color: Color(0xFFC62828))),
                        Text('+${item.priceDeviationPercent.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFFD32F2F))),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Text('Advisory Note (will notify farmer):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
              const SizedBox(height: 6),
              TextField(
                controller: noteController,
                maxLines: 3,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.all(12),
                ),
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
              final success = await ref.read(marketplaceModerationProvider.notifier).flagPriceWarning(
                    item.id,
                    noteController.text,
                  );
              if (mounted && success) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('⚠️ Anomaly warning dispatched to ${item.farmerName}!'),
                    backgroundColor: const Color(0xFFD32F2F),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
            ),
            child: const Text('Send Price Warning'),
          ),
        ],
      ),
    );
  }

  void _showEditStockDialog(BuildContext context, AdminProductItem item) {
    final stockController = TextEditingController(text: item.stockKg.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Update Available Stock: ${item.title}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Farmer: ${item.farmerName}', style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              const Text('Available Stock (kg):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              TextField(
                controller: stockController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  suffixText: 'kg',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final newStock = double.tryParse(stockController.text) ?? item.stockKg;
              final messenger = ScaffoldMessenger.of(context);
              Navigator.of(ctx).pop();
              final success = await ref.read(marketplaceModerationProvider.notifier).updateStock(item.id, newStock);
              if (mounted && success) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('✅ Stock updated to $newStock kg!'),
                    backgroundColor: AppColors.primaryGreen,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, foregroundColor: Colors.white),
            child: const Text('Save Stock'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final modState = ref.watch(marketplaceModerationProvider);
    final products = modState.products;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),
          const SizedBox(height: 18),

          // Anomaly Banner (if any)
          if (modState.anomalyCount > 0) ...[
            _buildAnomalyAlertBanner(modState.anomalyCount),
            const SizedBox(height: 18),
          ],

          // Search and Filters
          _buildFiltersBar(modState),
          const SizedBox(height: 20),

          // Product List
          if (modState.isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
          else if (products.isEmpty)
            _buildEmptyState()
          else
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: products.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final product = products[index];
                return _buildProductCard(product);
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
            child: Icon(Icons.storefront_rounded, color: AppColors.primaryGreen, size: 28),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Marketplace Produce Moderation & Quality Assurance',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Monitor live farmer listings, evaluate fair pricing against APMC Mandi rates, and verify organic authenticity.',
                  style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnomalyAlertBanner(int count) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFB74D)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Color(0xFFE65100), size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count Produce Listing Detected with Severe Price Anomaly (>45% above APMC Mandi Floor Rate)',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(0xFFE65100)),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Farmer asking prices exceeding local market rates can deter customer adoption. Review flagged listings below.',
                  style: TextStyle(fontSize: 12, color: Color(0xFFBF360C)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersBar(MarketplaceModerationState state) {
    return AgriCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by crop name, farmer, category, or district...',
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(marketplaceModerationProvider.notifier).setSearchQuery('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              filled: true,
              fillColor: const Color(0xFFF9FBF9),
            ),
            onChanged: (val) => ref.read(marketplaceModerationProvider.notifier).setSearchQuery(val),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text('Filter:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
              _buildFilterChip(
                label: 'All Items',
                isSelected: state.selectedStatus == null && !state.onlyOrganic,
                onTap: () {
                  ref.read(marketplaceModerationProvider.notifier).setStatusFilter(null);
                  if (state.onlyOrganic) {
                    ref.read(marketplaceModerationProvider.notifier).toggleOrganicFilter();
                  }
                },
              ),
              _buildFilterChip(
                label: '🟢 Active & Approved',
                isSelected: state.selectedStatus == ProductModerationStatus.active,
                onTap: () => ref.read(marketplaceModerationProvider.notifier).setStatusFilter(ProductModerationStatus.active),
              ),
              _buildFilterChip(
                label: '⚠️ Price Anomaly (${state.anomalyCount})',
                isSelected: state.selectedStatus == ProductModerationStatus.priceAlert,
                onTap: () => ref.read(marketplaceModerationProvider.notifier).setStatusFilter(ProductModerationStatus.priceAlert),
              ),
              _buildFilterChip(
                label: '⏸️ Unlisted / Paused',
                isSelected: state.selectedStatus == ProductModerationStatus.unlisted,
                onTap: () => ref.read(marketplaceModerationProvider.notifier).setStatusFilter(ProductModerationStatus.unlisted),
              ),
              _buildFilterChip(
                label: '🌿 100% Organic Only',
                isSelected: state.onlyOrganic,
                onTap: () => ref.read(marketplaceModerationProvider.notifier).toggleOrganicFilter(),
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

  Widget _buildProductCard(AdminProductItem p) {
    Color deviationColor;
    if (p.priceDeviationPercent > 45) {
      deviationColor = const Color(0xFFD32F2F);
    } else if (p.priceDeviationPercent > 15) {
      deviationColor = const Color(0xFF2E7D32);
    } else {
      deviationColor = const Color(0xFF1565C0);
    }

    return AgriCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: p.status.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.eco_rounded, color: p.status.color, size: 26),
          ),
          const SizedBox(width: 14),

          // Crop & Farmer Details
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        p.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (p.isOrganic) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFFA5D6A7)),
                        ),
                        child: const Text('ORGANIC', style: TextStyle(color: Color(0xFF2E7D32), fontSize: 9.5, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${p.category} • Farmer: ${p.farmerName}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  p.farmerLocation,
                  style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Price vs Mandi Benchmark
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
                    Text('₹${p.pricePerKg.toStringAsFixed(0)} / kg', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: deviationColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${p.priceDeviationPercent >= 0 ? '+' : ''}${p.priceDeviationPercent.toStringAsFixed(0)}% vs Mandi',
                        style: TextStyle(color: deviationColor, fontWeight: FontWeight.bold, fontSize: 10.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Mandi Floor: ₹${p.mandiBenchmarkPerKg.toStringAsFixed(0)}/kg • Stock: ${p.stockKg.toStringAsFixed(0)} kg',
                  style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Moderation Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: p.status.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: p.status.color, width: 1),
            ),
            child: Text(
              p.status.displayName,
              style: TextStyle(color: p.status.color, fontWeight: FontWeight.bold, fontSize: 11.5),
            ),
          ),
          const SizedBox(width: 14),

          // Action Buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_note_rounded, size: 20),
                tooltip: 'Edit Stock',
                onPressed: () => _showEditStockDialog(context, p),
              ),
              IconButton(
                icon: Icon(p.isOrganic ? Icons.verified_rounded : Icons.eco_outlined, size: 20, color: p.isOrganic ? AppColors.primaryGreen : AppColors.textMuted),
                tooltip: 'Toggle Organic Verification Tag',
                onPressed: () => ref.read(marketplaceModerationProvider.notifier).toggleOrganic(p.id),
              ),
              if (p.hasHighDeviation || p.status == ProductModerationStatus.priceAlert)
                IconButton(
                  icon: const Icon(Icons.warning_amber_rounded, size: 20, color: Color(0xFFD32F2F)),
                  tooltip: 'Flag Price Warning',
                  onPressed: () => _showFlagAnomalyDialog(context, p),
                ),
              if (p.status == ProductModerationStatus.active)
                IconButton(
                  icon: const Icon(Icons.pause_circle_outline_rounded, size: 20, color: AppColors.textSecondary),
                  tooltip: 'Pause / Unlist',
                  onPressed: () => ref.read(marketplaceModerationProvider.notifier).unlistListing(p.id),
                )
              else
                IconButton(
                  icon: const Icon(Icons.play_circle_outline_rounded, size: 20, color: AppColors.primaryGreen),
                  tooltip: 'Approve & Activate',
                  onPressed: () => ref.read(marketplaceModerationProvider.notifier).approveListing(p.id),
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
          const Text('No Produce Listings Found', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          const Text('Try adjusting your search criteria or removing active filters.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _searchController.clear();
              ref.read(marketplaceModerationProvider.notifier).setSearchQuery('');
              ref.read(marketplaceModerationProvider.notifier).setStatusFilter(null);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, foregroundColor: Colors.white),
            child: const Text('Reset All Filters'),
          ),
        ],
      ),
    );
  }
}
