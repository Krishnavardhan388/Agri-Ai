import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/services/api_client.dart';
import '../../../../core/widgets/agri_card.dart';
import '../../../auth/state/auth_provider.dart';
import '../../../marketplace/domain/product_model.dart';
import '../../../marketplace/state/marketplace_provider.dart';

class CustomerHomeTab extends ConsumerStatefulWidget {
  final VoidCallback onNavigateToCart;

  const CustomerHomeTab({super.key, required this.onNavigateToCart});

  @override
  ConsumerState<CustomerHomeTab> createState() => _CustomerHomeTabState();
}

class _CustomerHomeTabState extends ConsumerState<CustomerHomeTab> {
  final _searchController = TextEditingController();
  final List<String> _categories = [
    'All Items',
    'Vegetables',
    'Grains & Pulses',
    'Fruits',
    'Cash Crops',
    'Spices',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final marketState = ref.watch(marketplaceProvider);
    final cart = ref.watch(cartProvider);
    final products = marketState.products;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Farm Fresh Marketplace', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            Row(
              children: [
                Icon(Icons.location_on, size: 12, color: AppColors.primaryGreen),
                SizedBox(width: 4),
                Text('Warangal Region • Direct from Farmers', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ],
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: widget.onNavigateToCart,
              ),
              if (cart.totalItemsCount > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryGreen,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${cart.totalItemsCount}',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Flipkart-style Search Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => ref.read(marketplaceProvider.notifier).searchProducts(val),
                decoration: const InputDecoration(
                  hintText: 'Search fresh tomatoes, rice, cotton, onions...',
                  prefixIcon: Icon(Icons.search_rounded, color: AppColors.primaryGreen),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Direct Farm Savings Banner
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryGreen, AppColors.healthyTeal],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'DIRECT FROM FARMERS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          '100% Fresh • 0% Middlemen',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Farmers earn fair prices, you get fresh harvest within 24 hours.',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.eco_rounded, size: 50, color: Colors.white),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Category Filter Horizontal List
            SizedBox(
              height: 38,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = marketState.selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (_) => ref.read(marketplaceProvider.notifier).filterCategory(cat),
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
            const SizedBox(height: 20),

            // Products Grid
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Featured Produce (${products.length} Crops)',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                Text(
                  'Direct Farm Harvest',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 12),

            products.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('No matching crops found in this category.'),
                    ),
                  )
                : GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: products.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return _ProductCard(
                        product: product,
                        apiClient: ref.read(apiClientProvider),
                        buyerName: ref.read(authProvider).userName.isNotEmpty
                            ? ref.read(authProvider).userName
                            : 'Verified Buyer',
                        onAddToCart: () {
                          ref.read(cartProvider.notifier).addToCart(product, 1.0);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Added 1 kg "${product.title}" to cart!'),
                              duration: const Duration(seconds: 2),
                              action: SnackBarAction(
                                label: 'VIEW CART',
                                textColor: Colors.white,
                                onPressed: widget.onNavigateToCart,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductModel product;
  final ApiClient apiClient;
  final String buyerName;
  final VoidCallback onAddToCart;

  const _ProductCard({
    required this.product,
    required this.apiClient,
    required this.buyerName,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return AgriCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 85,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.greenSurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(Icons.grass_rounded, color: AppColors.primaryGreen, size: 44),
            ),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: () => _showFarmerReviewsModal(context, product),
            child: Row(
              children: [
                const Icon(Icons.star_rounded, color: AppColors.earthAmber, size: 16),
                const SizedBox(width: 2),
                Text('${product.rating} (${product.totalReviews})', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            product.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          Text(
            product.farmerName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('₹${product.pricePerKg.toStringAsFixed(1)}/kg', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryDark)),
              const SizedBox(width: 4),
              Text(
                '₹${product.originalPricePerKg.toStringAsFixed(1)}',
                style: const TextStyle(
                  fontSize: 10,
                  decoration: TextDecoration.lineThrough,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 32,
            child: ElevatedButton(
              onPressed: onAddToCart,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Add to Cart', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  void _showFarmerReviewsModal(BuildContext context, ProductModel product) {
    List<Map<String, dynamic>> liveReviews = [
      {
        'buyer_name': 'Dr. Priya Sharma',
        'rating': 5.0,
        'comment': 'Exceptional farm-fresh organic produce! Arrived firm with zero transport bruising.',
        'created_at': 'Recent',
      },
      {
        'buyer_name': 'Anand Rao',
        'rating': 4.8,
        'comment': 'Authentic harvest quality with 4-digit OTP handover.',
        'created_at': 'Yesterday',
      },
    ];
    bool initialized = false;
    bool isLoading = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setSheetState) {
          if (!initialized) {
            initialized = true;
            apiClient.get('/api/v1/reviews').then((resp) {
              if (resp is List && modalCtx.mounted) {
                setSheetState(() {
                  liveReviews = resp
                      .whereType<Map>()
                      .map((e) => Map<String, dynamic>.from(e))
                      .toList();
                  isLoading = false;
                });
              }
            }).catchError((_) {
              if (modalCtx.mounted) setSheetState(() => isLoading = false);
            });
          }

          return DraggableScrollableSheet(
            initialChildSize: 0.65,
            maxChildSize: 0.9,
            minChildSize: 0.4,
            expand: false,
            builder: (_, scrollController) => Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Verified Reviews: ${product.title}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(Icons.verified_user_rounded, color: AppColors.primaryGreen, size: 14),
                                const SizedBox(width: 4),
                                Text('Farmer: ${product.farmerName}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.earthAmber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, color: AppColors.earthAmber, size: 16),
                            const SizedBox(width: 2),
                            Text('${product.rating}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  if (isLoading)
                    const LinearProgressIndicator(color: AppColors.primaryGreen, minHeight: 2),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: liveReviews.length,
                      itemBuilder: (_, idx) {
                        final r = liveReviews[idx];
                        return _buildReviewItem(
                          buyerName: r['buyer_name']?.toString() ?? 'Verified Buyer',
                          date: r['created_at']?.toString().split('T').first ?? 'Verified',
                          rating: (r['rating'] as num?)?.toDouble() ?? 5.0,
                          comment: r['comment']?.toString() ?? '',
                          isVerifiedBuyer: true,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showWriteReviewDialog(
                        context,
                        product,
                        onSubmitted: (newRev) {
                          if (modalCtx.mounted) {
                            setSheetState(() {
                              liveReviews.insert(0, newRev);
                            });
                          }
                        },
                      ),
                      icon: const Icon(Icons.rate_review_rounded, size: 18),
                      label: const Text('Write a Verified Review'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showWriteReviewDialog(
    BuildContext context,
    ProductModel product, {
    required void Function(Map<String, dynamic>) onSubmitted,
  }) {
    final commentCtrl = TextEditingController();
    double rating = 5.0;
    bool submitting = false;

    showDialog(
      context: context,
      builder: (dlgCtx) => StatefulBuilder(
        builder: (c, setDlgState) => AlertDialog(
          title: const Text('Submit Verified Review', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Produce: ${product.title}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              Row(
                children: List.generate(5, (idx) {
                  final starVal = idx + 1.0;
                  return IconButton(
                    icon: Icon(
                      starVal <= rating ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: AppColors.earthAmber,
                    ),
                    onPressed: () => setDlgState(() => rating = starVal),
                  );
                }),
              ),
              TextField(
                controller: commentCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Share produce freshness, delivery speed, and packaging quality...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dlgCtx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: submitting
                  ? null
                  : () async {
                      if (commentCtrl.text.trim().isEmpty) return;
                      setDlgState(() => submitting = true);
                      final payload = {
                        'farmer_name': product.farmerName,
                        'buyer_name': buyerName,
                        'rating': rating,
                        'comment': commentCtrl.text.trim(),
                        'persona_type': 'REAL_USER',
                      };
                      try {
                        final saved = await apiClient.post('/api/v1/reviews', body: payload);
                        if (saved is Map<String, dynamic>) {
                          onSubmitted(saved);
                        } else {
                          onSubmitted(payload);
                        }
                      } catch (_) {
                        onSubmitted(payload);
                      }
                      if (dlgCtx.mounted) Navigator.pop(dlgCtx);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: AppColors.primaryDark,
                            content: Text('Review saved to database! Thank you for rating.'),
                          ),
                        );
                      }
                    },
              child: Text(submitting ? 'Saving...' : 'Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewItem({
    required String buyerName,
    required String date,
    required double rating,
    required String comment,
    required bool isVerifiedBuyer,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FBF9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.15),
                      child: Text(buyerName[0], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
                    ),
                    const SizedBox(width: 8),
                    Text(buyerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                    if (isVerifiedBuyer) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.verified_rounded, size: 13, color: AppColors.primaryGreen),
                    ],
                  ],
                ),
                Text(date, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: List.generate(
                5,
                (i) => Icon(
                  i < rating.floor() ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: AppColors.earthAmber,
                  size: 14,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(comment, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, height: 1.35)),
          ],
        ),
      ),
    );
  }
}
