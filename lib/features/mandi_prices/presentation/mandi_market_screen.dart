import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/agri_card.dart';
import '../../smart_farming/state/smart_farming_provider.dart';
import '../domain/mandi_crop_model.dart';

class MandiMarketScreen extends ConsumerStatefulWidget {
  const MandiMarketScreen({super.key});

  @override
  ConsumerState<MandiMarketScreen> createState() => _MandiMarketScreenState();
}

class _MandiMarketScreenState extends ConsumerState<MandiMarketScreen> {
  final _searchController = TextEditingController();
  final List<String> _categories = ['All', 'Cash Crops', 'Cereals', 'Spices', 'Vegetables'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showComparisonSheet(BuildContext context, String cropName) async {
    await ref.read(smartFarmingProvider.notifier).compareCrop(cropName);
    if (!context.mounted) return;

    final comparisonItems = ref.read(smartFarmingProvider).comparisonItems;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Mandi Price Comparison', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    Text('Best markets for $cropName', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.greenSurface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Live APMC Rates', style: TextStyle(color: AppColors.primaryDark, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 18),

            ...comparisonItems.map((item) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: item.isHighestPrice ? AppColors.greenSurface : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: item.isHighestPrice ? AppColors.primaryGreen : AppColors.border,
                    width: item.isHighestPrice ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(item.mandiName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            if (item.isHighestPrice) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGreen,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'HIGHEST PROFIT',
                                  style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(item.district, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                    Text(
                      '₹${item.modalPricePerQuintal.toInt()} / Qtl',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: item.isHighestPrice ? AppColors.primaryDark : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(smartFarmingProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Daily Mandi Rates', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            Text('Agmarknet Verified Agricultural Prices', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.read(smartFarmingProvider.notifier).refreshLocationAndWeather();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Updated mandi prices with live GPS location')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mandi GPS Location Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: AppColors.primaryGreen, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nearest Market: ${state.location.district} APMC Yard',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        Text(
                          'GPS: ${state.location.formattedAddress}',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => ref.read(smartFarmingProvider.notifier).togglePriceUnit(),
                    child: Text(
                      state.showPerKg ? 'Per kg' : 'Per Quintal',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => ref.read(smartFarmingProvider.notifier).searchCrops(val),
                decoration: const InputDecoration(
                  hintText: 'Search Cotton, Paddy, Mirchi, Maize...',
                  prefixIcon: Icon(Icons.search_rounded, color: AppColors.primaryGreen),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Category Chips
            SizedBox(
              height: 38,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = state.selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (_) => ref.read(smartFarmingProvider.notifier).selectCategory(cat),
                      backgroundColor: Colors.white,
                      selectedColor: AppColors.greenSurface,
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                      side: BorderSide(
                        color: isSelected ? AppColors.primaryGreen : AppColors.border,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 18),

            // Mandi Crops List
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Commodity Rates (${state.mandiCrops.length} Crops)',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                Text(
                  'Updated Today, 06:00 AM',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 10),

            ...state.mandiCrops.map((crop) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: _MandiRateCard(
                  item: crop,
                  showPerKg: state.showPerKg,
                  onCompare: () => _showComparisonSheet(context, crop.cropName),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _MandiRateCard extends StatelessWidget {
  final MandiCropItem item;
  final bool showPerKg;
  final VoidCallback onCompare;

  const _MandiRateCard({
    required this.item,
    required this.showPerKg,
    required this.onCompare,
  });

  @override
  Widget build(BuildContext context) {
    final displayPrice = showPerKg ? item.formattedPerKg : item.formattedModalPrice;
    final rangeText = showPerKg
        ? 'Range: ₹${(item.minPrice / 100).toStringAsFixed(1)} - ₹${(item.maxPrice / 100).toStringAsFixed(1)}'
        : 'Range: ₹${item.minPrice.toInt()} - ₹${item.maxPrice.toInt()}';

    return AgriCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.greenSurface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.grass_rounded, color: AppColors.primaryGreen, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.cropName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text('${item.variety} • ${item.category}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    displayPrice,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryDark),
                  ),
                  Row(
                    children: [
                      Icon(
                        item.isPriceUp ? Icons.arrow_drop_up_rounded : Icons.arrow_drop_down_rounded,
                        color: item.isPriceUp ? AppColors.primaryGreen : AppColors.alertRed,
                        size: 20,
                      ),
                      Text(
                        '${item.isPriceUp ? '+' : '-'}₹${item.priceChange.toInt()}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: item.isPriceUp ? AppColors.primaryGreen : AppColors.alertRed,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 18),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.storefront_outlined, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text('${item.marketName} (${item.distanceKm} km)', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
              Text(rangeText, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            height: 36,
            child: OutlinedButton.icon(
              onPressed: onCompare,
              icon: const Icon(Icons.compare_arrows_rounded, size: 16),
              label: const Text('Compare Across Nearby Mandis', style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}
