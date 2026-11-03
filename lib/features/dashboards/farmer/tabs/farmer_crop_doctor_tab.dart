import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/agri_card.dart';
import '../../../../core/widgets/custom_button.dart';

class FarmerCropDoctorTab extends StatelessWidget {
  const FarmerCropDoctorTab({super.key});

  @override
  Widget build(BuildContext context) {
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
                    '1. Take a clear, well-lit photo of an affected plant leaf.\n'
                    '2. Our Gemini Vision AI detects the crop, disease, or deficiency in seconds.\n'
                    '3. Receive step-by-step organic and chemical treatment instructions.',
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
                          text: 'Take Photo',
                          icon: Icons.camera_alt_rounded,
                          backgroundColor: Colors.white,
                          textColor: AppColors.primaryGreen,
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Camera scanner will be fully connected in Phase 3 with Gemini AI'),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: CustomButton(
                          text: 'Gallery',
                          icon: Icons.photo_library_rounded,
                          backgroundColor: Colors.white.withValues(alpha: 0.25),
                          textColor: Colors.white,
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Gallery photo upload will be connected in Phase 3'),
                              ),
                            );
                          },
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
                  'Recent Diagnosis History',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.greenSurface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    '3 Reports',
                    style: TextStyle(
                      color: AppColors.primaryDark,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Mock Scan 1 (Tomato Early Blight)
            _DiagnosisHistoryCard(
              crop: 'Tomato',
              disease: 'Early Blight (Alternaria solani)',
              healthScore: 68,
              severity: 'Moderate',
              severityColor: AppColors.earthAmber,
              date: 'Today, 10:30 AM',
              treatment: 'Spray Mancozeb (2g/L) or neem oil extract.',
            ),
            const SizedBox(height: 12),

            // Mock Scan 2 (Rice Brown Spot)
            _DiagnosisHistoryCard(
              crop: 'Paddy / Rice',
              disease: 'Brown Spot Fungus',
              healthScore: 52,
              severity: 'High Severity',
              severityColor: AppColors.alertRed,
              date: 'Yesterday, 04:15 PM',
              treatment: 'Apply Tricyclazole 75% WP. Ensure adequate potassium in soil.',
            ),
            const SizedBox(height: 12),

            // Mock Scan 3 (Healthy Cotton)
            _DiagnosisHistoryCard(
              crop: 'Cotton',
              disease: 'Healthy Leaf • No Disease Detected',
              healthScore: 96,
              severity: 'Healthy',
              severityColor: AppColors.primaryGreen,
              date: '28 Oct 2026',
              treatment: 'Continue standard irrigation and balanced NPK fertilizer.',
            ),
          ],
        ),
      ),
    );
  }
}

class _DiagnosisHistoryCard extends StatelessWidget {
  final String crop;
  final String disease;
  final int healthScore;
  final String severity;
  final Color severityColor;
  final String date;
  final String treatment;

  const _DiagnosisHistoryCard({
    required this.crop,
    required this.disease,
    required this.healthScore,
    required this.severity,
    required this.severityColor,
    required this.date,
    required this.treatment,
  });

  @override
  Widget build(BuildContext context) {
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
                      color: severityColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.eco_rounded, color: severityColor, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(crop, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(date, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: severityColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  severity,
                  style: TextStyle(
                    color: severityColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            disease,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Text('Health Score: ', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              Text(
                '$healthScore / 100',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: severityColor),
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
                  'Recommended: $treatment',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
