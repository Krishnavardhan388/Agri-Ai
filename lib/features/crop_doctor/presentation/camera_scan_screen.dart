import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/state/auth_provider.dart';
import '../state/crop_doctor_provider.dart';
import 'diagnosis_result_screen.dart';

class CameraScanScreen extends ConsumerStatefulWidget {
  const CameraScanScreen({super.key});

  @override
  ConsumerState<CameraScanScreen> createState() => _CameraScanScreenState();
}

class _CameraScanScreenState extends ConsumerState<CameraScanScreen> {
  Future<void> _capture(ImageSource source) async {
    final auth = ref.read(authProvider);
    final uid = auth.user?.uid ?? 'guest-farmer';

    final result = await ref.read(cropDoctorProvider.notifier).pickAndAnalyze(
          source: source,
          userId: uid,
        );

    if (result != null && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => DiagnosisResultScreen(result: result),
        ),
      );
    }
  }

  void _showApiKeyDialog() {
    final geminiService = ref.read(geminiServiceProvider);
    final controller = TextEditingController(text: geminiService.getApiKey() ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Gemini API Key'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your free Gemini API key from Google AI Studio (aistudio.google.com) for live cloud leaf vision:',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'AIzaSy...',
                labelText: 'API Key',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await geminiService.saveApiKey(controller.text);
              if (mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Gemini API key saved!')),
                );
              }
            },
            child: const Text('Save Key'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cropDoctorProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Crop Leaf Scanner',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.key_rounded, color: Colors.white70),
            tooltip: 'Configure Gemini API Key',
            onPressed: _showApiKeyDialog,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Viewfinder Background
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Camera Target Frame
                  Container(
                    width: double.infinity,
                    height: 340,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.primaryGreen, width: 2),
                    ),
                    child: Stack(
                      children: [
                        // Center Scanning Target
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.eco_rounded,
                                size: 64,
                                color: Colors.white.withValues(alpha: 0.25),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Align leaf inside the frame',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Corner Guide Accents
                        const Positioned(
                          top: 12,
                          left: 12,
                          child: Icon(Icons.crop_free_rounded, color: AppColors.primaryGreen, size: 28),
                        ),
                        const Positioned(
                          bottom: 12,
                          right: 12,
                          child: Icon(Icons.crop_free_rounded, color: AppColors.primaryGreen, size: 28),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Farmer Tip Banner
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.wb_sunny_outlined, color: AppColors.earthAmber, size: 18),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Hold phone 10-15 cm away under bright daylight',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Loading Overlay
          if (state.isAnalyzing)
            Container(
              color: Colors.black.withValues(alpha: 0.75),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: AppColors.primaryGreen),
                      SizedBox(height: 18),
                      Text(
                        'AI Doctor Analyzing Leaf...',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Detecting crop variety, pathogen symptoms & deficiency scores with Gemini Vision',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Bottom Shutter Controls
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Gallery Picker Button
                IconButton(
                  icon: const Icon(Icons.photo_library_rounded, color: Colors.white, size: 30),
                  onPressed: state.isAnalyzing ? null : () => _capture(ImageSource.gallery),
                ),

                // Primary Shutter Button
                GestureDetector(
                  onTap: state.isAnalyzing ? null : () => _capture(ImageSource.camera),
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      color: AppColors.primaryGreen,
                    ),
                    child: const Center(
                      child: Icon(Icons.camera_alt_rounded, color: Colors.white, size: 36),
                    ),
                  ),
                ),

                // Flash / Info Toggle
                IconButton(
                  icon: const Icon(Icons.flash_auto_rounded, color: Colors.white70, size: 28),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Flash automatic')),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
