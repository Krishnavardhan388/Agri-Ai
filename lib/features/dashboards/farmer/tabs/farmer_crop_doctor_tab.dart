import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/agri_card.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../auth/state/auth_provider.dart';
import '../../../crop_doctor/domain/crop_diagnosis_result.dart';
import '../../../crop_doctor/presentation/camera_scan_screen.dart';
import '../../../crop_doctor/presentation/diagnosis_result_screen.dart';
import '../../../crop_doctor/state/crop_doctor_provider.dart';

class FarmerCropDoctorTab extends ConsumerWidget {
  const FarmerCropDoctorTab({super.key});

  Color _getSeverityColor(int score) {
    if (score >= 80) return AppColors.primaryGreen;
    if (score >= 55) return AppColors.earthAmber;
    return AppColors.alertRed;
  }

  Future<void> _scan(BuildContext context, WidgetRef ref, ImageSource source) async {
    final auth = ref.read(authProvider);
    final uid = auth.user?.uid ?? 'guest-farmer';

    final result = await ref.read(cropDoctorProvider.notifier).pickAndAnalyze(
          source: source,
          userId: uid,
        );

    if (result != null && context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DiagnosisResultScreen(result: result),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cropDoctorState = ref.watch(cropDoctorProvider);
    final history = cropDoctorState.history;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('AI Crop Doctor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('How AI Doctor Works'),
                  content: const Text(
                    '1. Take a clear photo of an affected plant leaf.\n'
                    '2. Our Gemini Vision AI identifies crop disease or deficiency.\n'
                    '3. Receive step-by-step organic remedies and chemical dosage guidelines.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Got it'),
                    ),
                  ],
                ),
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
            // Camera Scan Hub Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primaryGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Icon(Icons.center_focus_strong_rounded, size: 54, color: Colors.white),
                  const SizedBox(height: 12),
                  const Text(
                    'Instant Crop Disease Diagnosis',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Take a picture of damaged leaves or pests to identify solutions.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Scan with Camera',
                          icon: Icons.camera_alt_rounded,
                          backgroundColor: Colors.white,
                          textColor: AppColors.primaryGreen,
                          isLoading: cropDoctorState.isAnalyzing,
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const CameraScanScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: CustomButton(
                          text: 'Upload Gallery',
                          icon: Icons.photo_library_rounded,
                          backgroundColor: Colors.white.withValues(alpha: 0.25),
                          textColor: Colors.white,
                          isLoading: cropDoctorState.isAnalyzing,
                          onPressed: () => _scan(context, ref, ImageSource.gallery),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Scan History Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Diagnosis History',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.greenSurface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${history.length} Reports',
                    style: const TextStyle(
                      color: AppColors.primaryDark,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Fallback sample reports if history is currently empty
            if (history.isEmpty)
              Column(
                children: [
                  _DiagnosisCard(
                    result: CropDiagnosisResult(
                      id: 'demo-1',
                      cropName: 'Tomato',
                      diseaseName: 'Early Blight (Alternaria solani)',
                      scientificName: 'Alternaria solani',
                      healthScore: 68,
                      severity: 'Moderate',
                      confidence: 0.93,
                      symptoms: ['Concentric bullseye rings on leaves', 'Yellow halo'],
                      organicTreatments: ['Spray cold-pressed Neem Oil (5ml/L)'],
                      chemicalTreatments: ['Mancozeb 75% WP @ 2.5g/L'],
                      preventiveMeasures: ['Avoid overhead irrigation'],
                      diagnosedAt: DateTime.now().subtract(const Duration(hours: 2)),
                    ),
                    color: AppColors.earthAmber,
                  ),
                  const SizedBox(height: 12),
                  _DiagnosisCard(
                    result: CropDiagnosisResult(
                      id: 'demo-2',
                      cropName: 'Cotton',
                      diseaseName: 'Healthy Leaf • Vigorous Growth',
                      scientificName: 'Gossypium hirsutum',
                      healthScore: 96,
                      severity: 'Healthy',
                      confidence: 0.98,
                      symptoms: ['Clean foliage with no pest markings'],
                      organicTreatments: ['Panchagavya organic booster spray'],
                      chemicalTreatments: ['No chemical sprays required'],
                      preventiveMeasures: ['Regular weekly scouting'],
                      diagnosedAt: DateTime.now().subtract(const Duration(days: 2)),
                    ),
                    color: AppColors.primaryGreen,
                  ),
                ],
              )
            else
              ...history.map((result) {
                final color = _getSeverityColor(result.healthScore);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _DiagnosisCard(
                    result: result,
                    color: color,
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _DiagnosisCard extends StatelessWidget {
  final CropDiagnosisResult result;
  final Color color;

  const _DiagnosisCard({required this.result, required this.color});

  @override
  Widget build(BuildContext context) {
    return AgriCard(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DiagnosisResultScreen(result: result),
          ),
        );
      },
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
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.eco_rounded, color: color, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(result.cropName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(
                        '${result.diagnosedAt.day}/${result.diagnosedAt.month}/${result.diagnosedAt.year}',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  result.severity,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            result.diseaseName,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Text('Plant Health Score: ', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              Text(
                '${result.healthScore} / 100',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
          const Divider(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.healing_rounded, size: 16, color: AppColors.primaryGreen),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  result.organicTreatments.isNotEmpty
                      ? 'Action: ${result.organicTreatments.first}'
                      : 'Tap to view full treatment report',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textMuted),
            ],
          ),
        ],
      ),
    );
  }
}
