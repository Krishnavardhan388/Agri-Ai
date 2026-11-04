import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/agri_card.dart';

class AdminVerificationTab extends StatelessWidget {
  const AdminVerificationTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Farmer & Delivery Partner Verification Queue',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Review submitted agricultural land records, organic certifications, and driver licenses.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.filter_list_rounded, size: 18),
                label: const Text('Filter (4 Pending)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Verification Table Card
          AgriCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildVerificationRow(
                  name: 'Ramesh Kumar',
                  role: 'Farmer (Kisan)',
                  location: 'Warangal, Telangana',
                  docType: 'Organic Farming Certificate (NPOP)',
                  status: 'Pending Review',
                  statusColor: const Color(0xFFFFA000),
                ),
                const Divider(height: 24),
                _buildVerificationRow(
                  name: 'Suresh Patel',
                  role: 'Delivery Partner',
                  location: 'Hanamkonda, Telangana',
                  docType: 'Driving License & Bike RC (TS-03-EB-4421)',
                  status: 'Verified & Active',
                  statusColor: const Color(0xFF2E7D32),
                ),
                const Divider(height: 24),
                _buildVerificationRow(
                  name: 'Venkat Rao',
                  role: 'Farmer (Kisan)',
                  location: 'Karimnagar, Telangana',
                  docType: 'Pattadar Passbook Land Record',
                  status: 'Pending Review',
                  statusColor: const Color(0xFFFFA000),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationRow({
    required String name,
    required String role,
    required String location,
    required String docType,
    required String status,
    required Color statusColor,
  }) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.greenSurface,
          child: Icon(
            role.contains('Farmer') ? Icons.agriculture_rounded : Icons.two_wheeler_rounded,
            color: AppColors.primaryGreen,
            size: 22,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Text(
                '$role • $location',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 3,
          child: Row(
            children: [
              const Icon(Icons.description_outlined, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  docType,
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
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
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 11.5,
            ),
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Review', style: TextStyle(fontSize: 12)),
        ),
      ],
    );
  }
}
