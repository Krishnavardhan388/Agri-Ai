import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/agri_card.dart';
import '../../../auth/domain/user_role.dart';
import '../../domain/kyc_application_model.dart';
import '../../state/kyc_provider.dart';

class AdminVerificationTab extends ConsumerStatefulWidget {
  const AdminVerificationTab({super.key});

  @override
  ConsumerState<AdminVerificationTab> createState() => _AdminVerificationTabState();
}

class _AdminVerificationTabState extends ConsumerState<AdminVerificationTab> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showInspectDialog(BuildContext context, KycApplication app) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: app.role == UserRole.farmer ? AppColors.greenSurface : const Color(0xFFFFF3E0),
              child: Icon(
                app.role == UserRole.farmer ? Icons.agriculture_rounded : Icons.two_wheeler_rounded,
                color: app.role == UserRole.farmer ? AppColors.primaryGreen : const Color(0xFFE65100),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(app.applicantName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                  Text(app.id, style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                ],
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 540,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildInspectRow('Role Profile', app.role.displayName),
                _buildInspectRow('Phone Number', app.phone),
                _buildInspectRow('Location / District', app.location),
                const Divider(height: 20),
                _buildInspectRow('Document Type', app.documentType),
                _buildInspectRow('Document Number', app.documentNumber),
                if (app.documentDetails != null) ...[
                  const SizedBox(height: 8),
                  const Text('Verification Details & Land/Vehicle Specs:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      app.documentDetails!,
                      style: const TextStyle(fontSize: 12.5, color: AppColors.textPrimary, height: 1.4),
                    ),
                  ),
                ],
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Current Status:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: app.status.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: app.status.color, width: 1),
                      ),
                      child: Text(
                        app.status.displayName,
                        style: TextStyle(color: app.status.color, fontWeight: FontWeight.bold, fontSize: 11.5),
                      ),
                    ),
                  ],
                ),
                if (app.rejectionReason != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Rejection Note: ${app.rejectionReason}',
                    style: const TextStyle(fontSize: 12, color: Color(0xFFD32F2F), fontWeight: FontWeight.w600),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
          if (app.status != KycStatus.rejected)
            OutlinedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _showRejectDialog(context, app);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFD32F2F),
                side: const BorderSide(color: Color(0xFFD32F2F)),
              ),
              child: const Text('Reject Application'),
            ),
          if (app.status != KycStatus.approved)
            ElevatedButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                final success = await ref.read(kycProvider.notifier).approve(app.id);
                if (context.mounted && success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✅ ${app.applicantName} (${app.id}) verified successfully!'),
                      backgroundColor: AppColors.primaryGreen,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
              ),
              child: const Text('Approve & Activate'),
            ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, KycApplication app) {
    final reasonController = TextEditingController(
      text: 'Document photo is unclear or certificate validity has expired. Please re-upload.',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Reject Application (${app.id})', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Applicant: ${app.applicantName} (${app.role.displayName})', style: const TextStyle(fontSize: 13)),
              const SizedBox(height: 14),
              const Text('Reason for Rejection (sent to applicant):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final success = await ref.read(kycProvider.notifier).reject(app.id, reasonController.text);
              if (context.mounted && success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Application ${app.id} marked as Rejected.'),
                    backgroundColor: const Color(0xFFD32F2F),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm Rejection'),
          ),
        ],
      ),
    );
  }

  Widget _buildInspectRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final kycState = ref.watch(kycProvider);
    final apps = kycState.applications;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          _buildHeader(),
          const SizedBox(height: 18),

          // Search and Filters
          _buildFiltersBar(kycState),
          const SizedBox(height: 20),

          // Applications Feed
          if (kycState.isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
          else if (apps.isEmpty)
            _buildEmptyState()
          else
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: apps.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final app = apps[index];
                return _buildApplicationCard(app);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Color(0xFFE8F5E9),
            child: Icon(Icons.verified_user_rounded, color: AppColors.primaryGreen, size: 28),
          ),
          SizedBox(width: 16),
          Expanded(
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
                SizedBox(height: 2),
                Text(
                  'Review government Dharani land passbooks, organic certificates, DL and commercial vehicle registrations.',
                  style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersBar(KycState state) {
    return AgriCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search TextField
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by applicant name, phone, district, or document number...',
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(kycProvider.notifier).setSearchQuery('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              filled: true,
              fillColor: const Color(0xFFF9FBF9),
            ),
            onChanged: (val) => ref.read(kycProvider.notifier).setSearchQuery(val),
          ),
          const SizedBox(height: 14),

          // Filters Row
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text('Role:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
              _buildFilterChip(
                label: 'All Roles',
                isSelected: state.selectedRole == null,
                onTap: () => ref.read(kycProvider.notifier).setRoleFilter(null),
              ),
              _buildFilterChip(
                label: '🌾 Farmers',
                isSelected: state.selectedRole == UserRole.farmer,
                onTap: () => ref.read(kycProvider.notifier).setRoleFilter(UserRole.farmer),
              ),
              _buildFilterChip(
                label: '🚚 Delivery Partners',
                isSelected: state.selectedRole == UserRole.deliveryPartner,
                onTap: () => ref.read(kycProvider.notifier).setRoleFilter(UserRole.deliveryPartner),
              ),
              const SizedBox(width: 8),
              const Text('Status:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
              _buildFilterChip(
                label: 'All',
                isSelected: state.selectedStatus == null,
                onTap: () => ref.read(kycProvider.notifier).setStatusFilter(null),
              ),
              _buildFilterChip(
                label: '🟡 Pending (${state.pendingCount})',
                isSelected: state.selectedStatus == KycStatus.pending,
                onTap: () => ref.read(kycProvider.notifier).setStatusFilter(KycStatus.pending),
              ),
              _buildFilterChip(
                label: '🟢 Approved',
                isSelected: state.selectedStatus == KycStatus.approved,
                onTap: () => ref.read(kycProvider.notifier).setStatusFilter(KycStatus.approved),
              ),
              _buildFilterChip(
                label: '🔴 Rejected',
                isSelected: state.selectedStatus == KycStatus.rejected,
                onTap: () => ref.read(kycProvider.notifier).setStatusFilter(KycStatus.rejected),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreen : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.primaryGreen : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildApplicationCard(KycApplication app) {
    final isFarmer = app.role == UserRole.farmer;

    return AgriCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: isFarmer ? AppColors.greenSurface : const Color(0xFFFFF3E0),
            child: Icon(
              isFarmer ? Icons.agriculture_rounded : Icons.two_wheeler_rounded,
              color: isFarmer ? AppColors.primaryGreen : const Color(0xFFE65100),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),

          // Applicant Details
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        app.applicantName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECEFF1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        app.id,
                        style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${app.role.displayName} • ${app.phone}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  app.location,
                  style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Document Info
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.description_outlined, size: 16, color: AppColors.primaryGreen),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        app.documentType,
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'ID: ${app.documentNumber}',
                  style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary, fontFamily: 'monospace'),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: app.status.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: app.status.color, width: 1),
            ),
            child: Text(
              app.status.displayName,
              style: TextStyle(
                color: app.status.color,
                fontWeight: FontWeight.bold,
                fontSize: 11.5,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Action Buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlinedButton.icon(
                onPressed: () => _showInspectDialog(context, app),
                icon: const Icon(Icons.visibility_rounded, size: 14),
                label: const Text('Inspect'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  textStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                ),
              ),
              if (app.status == KycStatus.pending) ...[
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    final success = await ref.read(kycProvider.notifier).approve(app.id);
                    if (mounted && success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('✅ ${app.applicantName} approved!'),
                          backgroundColor: AppColors.primaryGreen,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    textStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                  ),
                  child: const Text('Approve'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(Icons.search_off_rounded, size: 48, color: AppColors.textMuted),
          const SizedBox(height: 12),
          const Text('No Applications Match Criteria', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          const Text('Try adjusting your search query, status filters, or role selection.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _searchController.clear();
              ref.read(kycProvider.notifier).setSearchQuery('');
              ref.read(kycProvider.notifier).setStatusFilter(null);
              ref.read(kycProvider.notifier).setRoleFilter(null);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset All Filters'),
          ),
        ],
      ),
    );
  }
}
