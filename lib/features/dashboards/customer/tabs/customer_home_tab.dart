import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/agri_card.dart';

class CustomerHomeTab extends StatefulWidget {
  final VoidCallback onNavigateToCart;

  const CustomerHomeTab({super.key, required this.onNavigateToCart});

  @override
  State<CustomerHomeTab> createState() => _CustomerHomeTabState();
}

class _CustomerHomeTabState extends State<CustomerHomeTab> {
  int _selectedCategoryIndex = 0;
  final List<String> _categories = [
    'All Items',
    'Vegetables',
    'Grains & Rice',
    'Fruits',
    'Spices & Herbs'
  ];

  @override
  Widget build(BuildContext context) {
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
                Text('Delivering to: Hanamkonda (2.4 km)', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: widget.onNavigateToCart,
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
              child: const TextField(
                decoration: InputDecoration(
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

            // Promotional Banner
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
                          'Farmers earn fair prices, you get farm-fresh harvest within 24 hours.',
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
                  final isSelected = _selectedCategoryIndex == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(_categories[index]),
                      selected: isSelected,
                      onSelected: (val) {
                        setState(() => _selectedCategoryIndex = index);
                      },
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
            const Text(
              'Featured Farm Produce',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.72,
              children: [
                _ProductCard(
                  title: 'Farm Fresh Tomatoes',
                  farmer: 'Ramesh Farm, Warangal',
                  price: '₹35 / kg',
                  marketPrice: '₹48 / kg',
                  icon: Icons.grass_rounded,
                  rating: '4.8 (82)',
                  onAddToCart: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Added 1 kg Tomatoes to cart!')),
                    );
                  },
                ),
                _ProductCard(
                  title: 'Sona Masoori Rice',
                  farmer: 'Krishna Valley Farms',
                  price: '₹55 / kg',
                  marketPrice: '₹68 / kg',
                  icon: Icons.grain_rounded,
                  rating: '4.9 (140)',
                  onAddToCart: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Added 5 kg Rice to cart!')),
                    );
                  },
                ),
                _ProductCard(
                  title: 'Organic Red Onions',
                  farmer: 'Govind Rao, Hanamkonda',
                  price: '₹28 / kg',
                  marketPrice: '₹38 / kg',
                  icon: Icons.eco_rounded,
                  rating: '4.7 (55)',
                  onAddToCart: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Added 2 kg Onions to cart!')),
                    );
                  },
                ),
                _ProductCard(
                  title: 'Green Chilli (Mirchi)',
                  farmer: 'Balaji Farms',
                  price: '₹45 / kg',
                  marketPrice: '₹60 / kg',
                  icon: Icons.spa_rounded,
                  rating: '4.9 (94)',
                  onAddToCart: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Added Green Chilli to cart!')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final String title;
  final String farmer;
  final String price;
  final String marketPrice;
  final IconData icon;
  final String rating;
  final VoidCallback onAddToCart;

  const _ProductCard({
    required this.title,
    required this.farmer,
    required this.price,
    required this.marketPrice,
    required this.icon,
    required this.rating,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return AgriCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Crop Thumbnail Placeholder
          Container(
            height: 85,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.greenSurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(icon, color: AppColors.primaryGreen, size: 44),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.star_rounded, color: AppColors.earthAmber, size: 16),
              const SizedBox(width: 2),
              Text(rating, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          Text(
            farmer,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryDark)),
              const SizedBox(width: 4),
              Text(
                marketPrice,
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
}

