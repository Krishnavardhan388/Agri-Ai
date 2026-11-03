import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/agri_card.dart';
import '../../../core/widgets/custom_button.dart';
import '../domain/crop_diagnosis_result.dart';

class DiagnosisResultScreen extends StatefulWidget {
  final CropDiagnosisResult result;

  const DiagnosisResultScreen({super.key, required this.result});

  @override
  State<DiagnosisResultScreen> createState() => _DiagnosisResultScreenState();
}

class _DiagnosisResultScreenState extends State<DiagnosisResultScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return AppColors.primaryGreen;
    if (score >= 55) return AppColors.earthAmber;
    return AppColors.alertRed;
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final scoreColor = _getScoreColor(result.healthScore);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('AI Diagnosis Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sharing diagnosis report card...')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Health Meter & Disease Headline Card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Circular Health Score Meter
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: scoreColor.withValues(alpha: 0.1),
                                border: Border.all(color: scoreColor, width: 3),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${result.healthScore}%',
                                      style: TextStyle(
                                        color: scoreColor,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Health',
                                      style: TextStyle(
                                        color: scoreColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.greenSurface,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      result.cropName.toUpperCase(),
                                      style: const TextStyle(
                                        color: AppColors.primaryDark,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    result.diseaseName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    'Pathogen: ${result.scientificName}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),

                        // Severity & Confidence Badges
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _MetricItem(
                              label: 'Severity Level',
                              value: result.severity,
                              color: scoreColor,
                            ),
                            Container(width: 1, height: 26, color: AppColors.border),
                            _MetricItem(
                              label: 'AI Confidence',
                              value: '${(result.confidence * 100).toInt()}% Accurate',
                              color: AppColors.primaryDark,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Observed Symptoms
                  if (result.symptoms.isNotEmpty) ...[
                    const Text(
                      'Detected Symptoms',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    AgriCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: result.symptoms.map((symptom) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.circle, size: 8, color: AppColors.primaryGreen),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    symptom,
                                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],

                  // Treatment Navigation Tabs
                  const Text(
                    'Recommended Action Plan',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 10),

                  Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicator: BoxDecoration(
                        color: AppColors.primaryGreen,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: AppColors.textSecondary,
                      labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      tabs: const [
                        Tab(text: '🌿 Organic'),
                        Tab(text: '🧪 Chemical'),
                        Tab(text: '🛡️ Prevention'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    height: 220,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Tab 1: Organic
                        _TreatmentList(
                          items: result.organicTreatments,
                          icon: Icons.eco_rounded,
                          accentColor: AppColors.primaryGreen,
                          emptyMessage: 'No organic spray required. Plant is in good health.',
                        ),
                        // Tab 2: Chemical
                        _TreatmentList(
                          items: result.chemicalTreatments,
                          icon: Icons.science_rounded,
                          accentColor: AppColors.alertRed,
                          emptyMessage: 'No chemical fungicides recommended.',
                        ),
                        // Tab 3: Prevention
                        _TreatmentList(
                          items: result.preventiveMeasures,
                          icon: Icons.shield_rounded,
                          accentColor: AppColors.earthAmber,
                          emptyMessage: 'Maintain regular irrigation and balanced fertilizer.',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Action Controls
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded, size: 18),
                    label: const Text('Back to Home'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: 'Ask AGRI MITRA',
                    icon: Icons.mic_rounded,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('AGRI MITRA Voice Assistant will read this diagnosis aloud in Phase 7'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _TreatmentList extends StatelessWidget {
  final List<String> items;
  final IconData icon;
  final Color accentColor;
  final String emptyMessage;

  const _TreatmentList({
    required this.items,
    required this.icon,
    required this.accentColor,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return AgriCard(
        child: Center(
          child: Text(
            emptyMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accentColor, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  items[index],
                  style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.4),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
