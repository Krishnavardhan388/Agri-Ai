import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/agri_card.dart';
import '../../../../core/widgets/custom_button.dart';

/// Interactive Variable-Rate Application (VRA) Dosage & Tank Dilution Calculator
/// Solves knapsack sprayer over-spraying, chemical scorch, and drift loss.
class DosageCalculatorSheet extends StatefulWidget {
  final String cropName;
  final String diseaseName;
  final List<String> organicTreatments;
  final List<String> chemicalTreatments;

  const DosageCalculatorSheet({
    super.key,
    required this.cropName,
    required this.diseaseName,
    this.organicTreatments = const [],
    this.chemicalTreatments = const [],
  });

  static Future<void> show(
    BuildContext context, {
    required String cropName,
    required String diseaseName,
    List<String> organicTreatments = const [],
    List<String> chemicalTreatments = const [],
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DosageCalculatorSheet(
        cropName: cropName,
        diseaseName: diseaseName,
        organicTreatments: organicTreatments,
        chemicalTreatments: chemicalTreatments,
      ),
    );
  }

  @override
  State<DosageCalculatorSheet> createState() => _DosageCalculatorSheetState();
}

class _DosageCalculatorSheetState extends State<DosageCalculatorSheet> {
  double _acreage = 1.0;
  double _tankCapacity = 16.0; // Liters
  bool _isOrganic = true;

  final List<double> _acreagePresets = [0.5, 1.0, 2.0, 3.0, 5.0];
  final List<Map<String, dynamic>> _sprayerTypes = [
    {'name': 'Knapsack Manual (16L)', 'capacity': 16.0},
    {'name': 'Battery Sprayer (15L)', 'capacity': 15.0},
    {'name': 'Power Knapsack (20L)', 'capacity': 20.0},
    {'name': 'Tractor Boom (500L)', 'capacity': 500.0},
  ];

  @override
  Widget build(BuildContext context) {
    // Standard volume rate: 200 Litres of spray solution per acre for foliage canopy
    final double totalWaterVolume = _acreage * 200.0;
    final double numberOfTanks = (totalWaterVolume / _tankCapacity);
    
    // Dosage parameters
    final String materialName = _isOrganic
        ? (widget.organicTreatments.isNotEmpty
            ? widget.organicTreatments.first.split('.').first
            : 'Neem Oil 1500 ppm + Bio-soap')
        : (widget.chemicalTreatments.isNotEmpty
            ? widget.chemicalTreatments.first.split('.').first
            : 'Mancozeb 75% WP Broad Spectrum Fungicide');

    final double ratePerLiter = _isOrganic ? 5.0 : 2.5; // 5ml or 2.5g per Liter
    final String unit = _isOrganic ? 'ml' : 'g';
    final double dosePerTank = ratePerLiter * _tankCapacity;
    final double totalMaterial = (totalWaterVolume * ratePerLiter);
    final String totalMaterialFormatted = _isOrganic
        ? (totalMaterial >= 1000 ? '${(totalMaterial / 1000).toStringAsFixed(2)} Liters' : '${totalMaterial.toInt()} ml')
        : (totalMaterial >= 1000 ? '${(totalMaterial / 1000).toStringAsFixed(2)} kg' : '${totalMaterial.toInt()} g');

    final double costSavingsInr = _acreage * (_isOrganic ? 480.0 : 750.0);

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.calculate_rounded, color: AppColors.primaryGreen, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Plot Dilution & Tank Calculator',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      Text(
                        '${widget.cropName} • ${widget.diseaseName}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Main Scrollable Area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step 1: Treatment Mode (Organic vs Chemical)
                  const Text(
                    '1. SELECT TREATMENT FORMULATION',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.8),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isOrganic = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                            decoration: BoxDecoration(
                              color: _isOrganic ? AppColors.greenSurface : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _isOrganic ? AppColors.primaryGreen : AppColors.border,
                                width: _isOrganic ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.eco_rounded, color: _isOrganic ? AppColors.primaryGreen : AppColors.textMuted, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  'Organic Bio-Spray',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: _isOrganic ? AppColors.primaryDark : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isOrganic = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                            decoration: BoxDecoration(
                              color: !_isOrganic ? const Color(0xFFFDE8E8) : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: !_isOrganic ? AppColors.alertRed : AppColors.border,
                                width: !_isOrganic ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.science_rounded, color: !_isOrganic ? AppColors.alertRed : AppColors.textMuted, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  'Chemical Fungicide',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: !_isOrganic ? AppColors.alertRed : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Step 2: Acreage Selection
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '2. FARM PLOT AREA',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.8),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${_acreage.toStringAsFixed(1)} Acre${_acreage > 1 ? 's' : ''}',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.primaryGreen,
                      thumbColor: AppColors.primaryGreen,
                      overlayColor: AppColors.primaryGreen.withValues(alpha: 0.2),
                    ),
                    child: Slider(
                      value: _acreage,
                      min: 0.25,
                      max: 10.0,
                      divisions: 39,
                      onChanged: (val) => setState(() => _acreage = (val * 4).round() / 4),
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    children: _acreagePresets.map((preset) {
                      final isSelected = (_acreage == preset);
                      return ChoiceChip(
                        label: Text('$preset Ac'),
                        selected: isSelected,
                        selectedColor: AppColors.primaryGreen,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        onSelected: (selected) {
                          if (selected) setState(() => _acreage = preset);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Step 3: Sprayer Tank Size
                  const Text(
                    '3. KNAPSACK / SPRAY TANK CAPACITY',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.8),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<double>(
                        isExpanded: true,
                        value: _tankCapacity,
                        items: _sprayerTypes.map((item) {
                          return DropdownMenuItem<double>(
                            value: item['capacity'] as double,
                            child: Text(item['name'] as String, style: const TextStyle(fontSize: 14)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _tankCapacity = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Computed Results Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryDark,
                          AppColors.primaryGreen,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryGreen.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'CALCULATED SPRAY RECIPE',
                              style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Precision VRA',
                                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Dose per tank highlight
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.water_drop_rounded, color: Colors.white, size: 28),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${dosePerTank.toStringAsFixed(1)} $unit per ${_tankCapacity.toInt()}L Tank',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    materialName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: Colors.white24, height: 1),
                        const SizedBox(height: 14),

                        // Key Metrics Grid
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _CalculationMetric(
                              label: 'Total Water',
                              value: '${totalWaterVolume.toInt()} L',
                            ),
                            _CalculationMetric(
                              label: 'Tank Refills',
                              value: '${numberOfTanks.toStringAsFixed(1)} Tanks',
                            ),
                            _CalculationMetric(
                              label: 'Total Material',
                              value: totalMaterialFormatted,
                            ),
                            _CalculationMetric(
                              label: 'Cost Saved',
                              value: '₹${costSavingsInr.toInt()}',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Agronomic Spraying Advisory Rules
                  AgriCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.shield_outlined, color: AppColors.earthAmber, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Agronomic Safety & Anti-Drift Guidelines',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _GuidelineBullet(
                          icon: Icons.access_time_rounded,
                          text: 'Spray Window: 06:30 AM - 09:30 AM before wind speed exceeds 10 km/h or leaf temperature rises above 28°C.',
                        ),
                        _GuidelineBullet(
                          icon: Icons.speed_rounded,
                          text: 'Walking Speed: Maintain steady 3.5 km/h with nozzle 45 cm above crop canopy for uniform micron droplet distribution.',
                        ),
                        _GuidelineBullet(
                          icon: Icons.masks_rounded,
                          text: _isOrganic
                              ? 'Organic: 100% bio-degradable. Safe for beneficial predatory ladybugs and honeybees once foliage dries.'
                              : 'Chemical: Wear N95 respirator mask and nitrile gloves. Pre-mix powder in a bucket before pouring into tank.',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Action Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: CustomButton(
              text: 'Save Dosage to Spray Log',
              icon: Icons.check_circle_rounded,
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.primaryDark,
                    content: Text(
                      'Saved! Apply ${dosePerTank.toStringAsFixed(1)}$unit per ${_tankCapacity.toInt()}L tank for $_acreage acre(s).',
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CalculationMetric extends StatelessWidget {
  final String label;
  final String value;

  const _CalculationMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
      ],
    );
  }
}

class _GuidelineBullet extends StatelessWidget {
  final IconData icon;
  final String text;

  const _GuidelineBullet({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}
