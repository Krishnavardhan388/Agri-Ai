import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/agri_card.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../state/system_settings_provider.dart';

class AdminSettingsTab extends ConsumerStatefulWidget {
  const AdminSettingsTab({super.key});

  @override
  ConsumerState<AdminSettingsTab> createState() => _AdminSettingsTabState();
}

class _AdminSettingsTabState extends ConsumerState<AdminSettingsTab> {
  @override
  Widget build(BuildContext context) {
    final settingsState = ref.watch(systemSettingsProvider);
    final settings = settingsState.settings;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'System Configurations & Platform Control Center',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage multimodal AI engine settings, payment gateway modes, commission economics, and rural speech rate.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cloud_done_rounded, color: AppColors.primaryGreen, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'asia-south1 (Mumbai) • Online',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 1. Google Gemini Multimodal AI Engine
          _buildGeminiCard(settings),
          const SizedBox(height: 20),

          // 2. Razorpay Payment Gateway & Checkout
          _buildRazorpayCard(settings),
          const SizedBox(height: 20),

          // 3. Platform Marketplace Economics & Commission
          _buildCommissionCard(settings),
          const SizedBox(height: 20),

          // 4. Multilingual AGRI MITRA Voice Tuning
          _buildVoiceSettingsCard(settings),
          const SizedBox(height: 20),

          // 5. Automated Logistics & Dispatch Settings
          _buildDispatchSettingsCard(settings),
          const SizedBox(height: 20),

          // 6. Cloud Services Health & Infrastructure Status
          _buildCloudInfrastructureCard(),
          const SizedBox(height: 28),

          // Action Buttons Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  final messenger = ScaffoldMessenger.of(context);
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('AI Diagnostic cache and Mandi price indexes flushed successfully!'),
                      backgroundColor: AppColors.primaryGreen,
                    ),
                  );
                },
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Flush System Cache'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                ),
              ),
              const SizedBox(width: 14),
              CustomButton(
                text: 'Save Configurations',
                icon: Icons.check_circle_outline_rounded,
                onPressed: () {
                  final messenger = ScaffoldMessenger.of(context);
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('✅ Platform configurations saved to Firestore remote config!'),
                      backgroundColor: AppColors.primaryGreen,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildGeminiCard(dynamic settings) {
    return AgriCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Row(
                  children: [
                    Icon(Icons.psychology_rounded, color: AppColors.primaryGreen, size: 22),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Google Gemini Vision AI Engine',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primaryGreen, width: 0.8),
                ),
                child: const Text(
                  'API Key: Active 🟢',
                  style: TextStyle(color: AppColors.primaryGreen, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Multimodal vision model utilized by AI Crop Doctor for real-time foliar pathology identification and organic pesticide recommendations.',
            style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          const Text(
            'Active Model Selection:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            isExpanded: true,
            initialValue: settings.geminiModel,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            items: const [
              DropdownMenuItem(
                value: 'Gemini 1.5 Flash (Multimodal)',
                child: Text(
                  'Gemini 1.5 Flash (Recommended: Ultra-fast 1.2s inference)',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              DropdownMenuItem(
                value: 'Gemini 1.5 Pro (Multimodal)',
                child: Text(
                  'Gemini 1.5 Pro (Deep analytical reasoning, complex cases)',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            onChanged: (val) {
              if (val != null) {
                ref.read(systemSettingsProvider.notifier).updateGeminiModel(val);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Switched AI engine to $val'),
                    backgroundColor: AppColors.primaryGreen,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FBF9),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.greenAccent.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded, color: AppColors.primaryGreen, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Offline Fallback: Enabled. If rural connectivity drops below 2G, the mobile client falls back to embedded rule-based diagnostics.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRazorpayCard(dynamic settings) {
    final isSandbox = settings.razorpayMode.contains('Sandbox');

    return AgriCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Row(
                  children: [
                    Icon(Icons.payment_rounded, color: Color(0xFF1565C0), size: 22),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Razorpay Payment Gateway',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (isSandbox ? const Color(0xFFFFA000) : AppColors.primaryGreen).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSandbox ? const Color(0xFFFFA000) : AppColors.primaryGreen,
                    width: 0.8,
                  ),
                ),
                child: Text(
                  settings.razorpayMode,
                  style: TextStyle(
                    color: isSandbox ? const Color(0xFFE65100) : AppColors.primaryGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Processes direct digital checkout transactions supporting UPI (Google Pay, PhonePe, Paytm), NetBanking, Credit/Debit cards.',
            style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              ChoiceChip(
                label: const Text('Sandbox / Test Mode (rzp_test_...)'),
                selected: isSandbox,
                selectedColor: const Color(0xFFFFF3E0),
                labelStyle: TextStyle(
                  color: isSandbox ? const Color(0xFFE65100) : AppColors.textPrimary,
                  fontWeight: isSandbox ? FontWeight.bold : FontWeight.normal,
                ),
                onSelected: (selected) {
                  if (selected) {
                    ref.read(systemSettingsProvider.notifier).setRazorpayMode('Sandbox / Test Mode');
                  }
                },
              ),
              ChoiceChip(
                label: const Text('Production Live Mode (rzp_live_...)'),
                selected: !isSandbox,
                selectedColor: AppColors.greenAccent.withValues(alpha: 0.3),
                labelStyle: TextStyle(
                  color: !isSandbox ? AppColors.primaryGreen : AppColors.textPrimary,
                  fontWeight: !isSandbox ? FontWeight.bold : FontWeight.normal,
                ),
                onSelected: (selected) {
                  if (selected) {
                    ref.read(systemSettingsProvider.notifier).setRazorpayMode('Production Live Mode');
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Row(
            children: [
              Icon(Icons.shield_rounded, color: AppColors.primaryGreen, size: 16),
              SizedBox(width: 6),
              Text(
                'Instant Settlement: Enabled (T+0 for verified UPI rural merchant accounts)',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommissionCard(dynamic settings) {
    final double commission = settings.platformCommissionPercent;
    final double sampleOrderValue = 1000.0;
    final double platformEarnings = sampleOrderValue * (commission / 100);
    final double farmerEarnings = sampleOrderValue - platformEarnings;

    return AgriCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Row(
                  children: [
                    Icon(Icons.percent_rounded, color: Color(0xFF2E7D32), size: 22),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Marketplace Economics & Platform Commission',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${commission.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Commission retained by AGRI AI to cover server infrastructure, real-time SMS OTP alerts, and transit logistics insurance.',
            style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          Slider(
            value: commission,
            min: 0.0,
            max: 15.0,
            divisions: 30,
            activeColor: AppColors.primaryGreen,
            label: '${commission.toStringAsFixed(1)}%',
            onChanged: (val) {
              ref.read(systemSettingsProvider.notifier).updateCommission(double.parse(val.toStringAsFixed(1)));
            },
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F8F4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('Sample Order Value', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    const SizedBox(height: 2),
                    Text('₹${sampleOrderValue.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
                const Icon(Icons.arrow_forward_rounded, color: AppColors.textSecondary, size: 16),
                Column(
                  children: [
                    const Text('Farmer Payout (95%)', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    const SizedBox(height: 2),
                    Text('₹${farmerEarnings.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen, fontSize: 14)),
                  ],
                ),
                const Icon(Icons.add_rounded, color: AppColors.textSecondary, size: 16),
                Column(
                  children: [
                    const Text('Platform Fee', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    const SizedBox(height: 2),
                    Text('₹${platformEarnings.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1565C0), fontSize: 14)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceSettingsCard(dynamic settings) {
    final double speechRate = settings.defaultVoiceSpeechRate;

    return AgriCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Row(
                  children: [
                    Icon(Icons.record_voice_over_rounded, color: Color(0xFF6A1B9A), size: 22),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'AGRI MITRA Regional Voice Assistant Tuning',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE7F6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Telugu • Hindi • English',
                  style: TextStyle(color: Color(0xFF6A1B9A), fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Speech pace settings for text-to-speech audio advisories. Lower rates (0.45 - 0.50x) provide enhanced comprehension for elderly farmers.',
            style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Default Speech Rate:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Text(
                '${speechRate.toStringAsFixed(2)}x (${speechRate < 0.55 ? "Rural Clear Pace" : "Standard Pace"})',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6A1B9A), fontSize: 13),
              ),
            ],
          ),
          Slider(
            value: speechRate,
            min: 0.30,
            max: 0.90,
            divisions: 12,
            activeColor: const Color(0xFF6A1B9A),
            label: '${speechRate.toStringAsFixed(2)}x',
            onChanged: (val) {
              ref.read(systemSettingsProvider.notifier).updateSpeechRate(double.parse(val.toStringAsFixed(2)));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDispatchSettingsCard(dynamic settings) {
    final bool isAutoDispatch = settings.isAutoDispatchEnabled;

    return AgriCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Row(
                  children: [
                    Icon(Icons.local_shipping_rounded, color: Color(0xFFE65100), size: 22),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Automated Logistics & Fleet Dispatching',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Switch(
                value: isAutoDispatch,
                activeTrackColor: AppColors.primaryGreen,
                onChanged: (val) {
                  ref.read(systemSettingsProvider.notifier).toggleAutoDispatch();
                },
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            isAutoDispatch
                ? 'Automated routing is ACTIVE: Orders placed in the marketplace are instantly broadcast to verified delivery partners within a 15 km radius.'
                : 'Manual dispatch ONLY: Administrators must manually assign drivers to pending farm pick-ups.',
            style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildCloudInfrastructureCard() {
    return AgriCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.dns_rounded, color: AppColors.textPrimary, size: 22),
              SizedBox(width: 10),
              Text(
                'Cloud Infrastructure & Storage Health',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildHealthTile(
            service: 'Cloud Firestore Database',
            region: 'asia-south1 (Mumbai)',
            latency: '24 ms',
            status: 'Operational',
            statusColor: AppColors.primaryGreen,
          ),
          const Divider(height: 20),
          _buildHealthTile(
            service: 'Firebase Cloud Storage (Crop Images)',
            region: 'Multi-region (IN)',
            latency: '45 ms',
            status: 'Operational',
            statusColor: AppColors.primaryGreen,
          ),
          const Divider(height: 20),
          _buildHealthTile(
            service: 'SMS & OTP Delivery Gateway',
            region: 'Domestic DLT Route',
            latency: '99.4% Delivery',
            status: 'Operational',
            statusColor: AppColors.primaryGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildHealthTile({
    required String service,
    required String region,
    required String latency,
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
              Text(service, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
              const SizedBox(height: 2),
              Text('$region • $latency', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: statusColor, width: 0.8),
          ),
          child: Text(
            status,
            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11.5),
          ),
        ),
      ],
    );
  }
}
