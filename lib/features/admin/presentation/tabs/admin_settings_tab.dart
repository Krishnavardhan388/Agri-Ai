import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/agri_card.dart';

class AdminSettingsTab extends StatelessWidget {
  const AdminSettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'System Configurations & API Services',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Configure cloud integrations, active models, payment keys, and platform commission rates.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          AgriCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildConfigRow(
                  title: 'Google Gemini Vision AI',
                  subtitle: 'Gemini 1.5 Flash & Pro multimodal model for plant pathology',
                  status: 'Connected 🟢',
                  statusColor: AppColors.primaryGreen,
                ),
                const Divider(height: 24),
                _buildConfigRow(
                  title: 'Cloud Firestore & Storage',
                  subtitle: 'Real-time document synchronization & crop photo storage',
                  status: 'Active 🟢',
                  statusColor: AppColors.primaryGreen,
                ),
                const Divider(height: 24),
                _buildConfigRow(
                  title: 'Razorpay Payment Gateway',
                  subtitle: 'Online checkout with UPI, NetBanking, Cards & Instant Settlement',
                  status: 'Sandbox Mode 🟡',
                  statusColor: const Color(0xFFFFA000),
                ),
                const Divider(height: 24),
                _buildConfigRow(
                  title: 'Multilingual Voice (TTS & STT)',
                  subtitle: 'Bhashini & Indian regional voice models (Telugu, Hindi, English)',
                  status: 'Ready 🟢',
                  statusColor: AppColors.primaryGreen,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigRow({
    required String title,
    required String subtitle,
    required String status,
    required Color statusColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: statusColor, width: 1),
          ),
          child: Text(
            status,
            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
      ],
    );
  }
}
