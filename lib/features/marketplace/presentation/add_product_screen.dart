import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../auth/state/auth_provider.dart';
import '../domain/product_model.dart';
import '../state/marketplace_provider.dart';

class AddProductScreen extends ConsumerStatefulWidget {
  const AddProductScreen({super.key});

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = 'Vegetables';
  bool _isOrganic = true;
  bool _isLoading = false;

  final List<String> _categories = [
    'Vegetables',
    'Grains & Pulses',
    'Fruits',
    'Cash Crops',
    'Spices',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    final auth = ref.read(authProvider);

    final newProduct = ProductModel(
      id: 'crop-${DateTime.now().millisecondsSinceEpoch}',
      farmerId: auth.user?.uid ?? 'farmer-ramesh',
      farmerName: auth.user?.name.isNotEmpty == true ? auth.user!.name : 'Ramesh Farm, Warangal',
      farmerLocation: auth.user?.location.isNotEmpty == true ? auth.user!.location : 'Village Nallabelli (3.2 km)',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : 'Freshly harvested produce directly from our farm.',
      category: _selectedCategory,
      pricePerKg: double.tryParse(_priceController.text) ?? 40.0,
      originalPricePerKg: (double.tryParse(_priceController.text) ?? 40.0) * 1.25,
      availableStockKg: double.tryParse(_stockController.text) ?? 100.0,
      harvestDate: 'Harvested Today',
      isOrganic: _isOrganic,
    );

    await ref.read(marketplaceProvider.notifier).addFarmerProduce(newProduct);
    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully listed "${newProduct.title}" on AGRI AI Marketplace!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('List New Harvest Produce'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo Placeholder Box
              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.greenSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.greenAccent),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_photo_alternate_rounded, size: 48, color: AppColors.primaryGreen),
                    const SizedBox(height: 8),
                    const Text(
                      'Tap to Upload Produce Photo',
                      style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                    ),
                    Text(
                      'Clear photo of your crop increases sales by 40%',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              CustomTextField(
                controller: _titleController,
                label: 'Crop / Produce Title',
                hint: 'e.g. Fresh Organic Tomatoes, Sona Masoori Rice',
                prefixIcon: Icons.grass_rounded,
                validator: (v) => v == null || v.trim().isEmpty ? 'Enter produce name' : null,
              ),
              const SizedBox(height: 16),

              // Category Selector
              const Text(
                'Crop Category',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    items: _categories.map((c) {
                      return DropdownMenuItem(value: c, child: Text(c));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCategory = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _priceController,
                      label: 'Price per kg (₹)',
                      hint: 'e.g. 35',
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.currency_rupee_rounded,
                      validator: (v) => v == null || v.trim().isEmpty ? 'Enter price' : null,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: CustomTextField(
                      controller: _stockController,
                      label: 'Available Stock (kg)',
                      hint: 'e.g. 500',
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.inventory_2_outlined,
                      validator: (v) => v == null || v.trim().isEmpty ? 'Enter stock' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // AI Persona Optimization: Quick Batch Weight Presets
              Row(
                children: [
                  const Text('Quick Batch:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [10, 25, 50, 100, 250, 500].map((preset) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 6.0),
                            child: InkWell(
                              onTap: () => setState(() => _stockController.text = preset.toString()),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.greenSurface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.greenAccent.withValues(alpha: 0.5)),
                                ),
                                child: Text(
                                  '$preset kg',
                                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _descriptionController,
                label: 'Harvest Details & Variety (Optional)',
                hint: 'e.g. BPT 5204 single-origin, aged 6 months, pesticide-free',
                prefixIcon: Icons.notes_rounded,
              ),
              const SizedBox(height: 16),

              // 100% Organic Switch
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.eco_rounded, color: AppColors.primaryGreen),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('100% Organic Harvest', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Text('Grown without synthetic chemicals', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          ],
                        ),
                      ],
                    ),
                    Switch(
                      value: _isOrganic,
                      activeThumbColor: AppColors.primaryGreen,
                      onChanged: (val) => setState(() => _isOrganic = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: CustomButton(
                  text: 'List Harvest on Marketplace',
                  isLoading: _isLoading,
                  icon: Icons.check_circle_outline_rounded,
                  onPressed: _handleSave,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
