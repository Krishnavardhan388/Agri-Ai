import '../../../core/services/api_client.dart';
import '../../auth/domain/user_role.dart';
import '../domain/kyc_application_model.dart';

class AdminKycRepository {
  final ApiClient _apiClient;

  AdminKycRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final List<KycApplication> _applications = [
    KycApplication(
      id: 'KYC-FARM-101',
      userId: 'farmer-ramesh',
      applicantName: 'Ramesh Kumar',
      phone: '+91 98765 12345',
      role: UserRole.farmer,
      location: 'Geesugonda, Warangal (Telangana)',
      documentType: 'NPOP Organic Farming Certificate',
      documentNumber: 'TS-ORG-2026-8812',
      documentDetails: 'Certified 4.5 Acres organic paddy & red chilli farm under Telangana State Organic Certification Authority (TSOCA). Valid until Dec 2027.',
      status: KycStatus.pending,
      appliedAt: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    KycApplication(
      id: 'KYC-DRV-201',
      userId: 'driver-suresh',
      applicantName: 'Suresh Patel',
      phone: '+91 98765 22114',
      role: UserRole.deliveryPartner,
      location: 'Subedari, Hanamkonda (Telangana)',
      documentType: 'Commercial DL & Two-Wheeler RC',
      documentNumber: 'TS-03-EB-4421',
      documentDetails: 'Hero Splendor Plus (100cc) with carrier box, valid commercial driving license (DL-03202100492), active comprehensive insurance.',
      status: KycStatus.approved,
      appliedAt: DateTime.now().subtract(const Duration(days: 2)),
      reviewedAt: DateTime.now().subtract(const Duration(days: 1)),
      reviewedBy: 'Admin Officer (HQ)',
    ),
    KycApplication(
      id: 'KYC-FARM-102',
      userId: 'farmer-venkat',
      applicantName: 'Venkat Rao',
      phone: '+91 98765 33221',
      role: UserRole.farmer,
      location: 'Manakondur, Karimnagar (Telangana)',
      documentType: 'Pattadar Passbook Land Record',
      documentNumber: 'TS-LND-KM-4901',
      documentDetails: 'Dharani Portal Title Deed: Survey No. 412/A, 6.2 Acres irrigated land under Lower Manair Dam canal network. Cultivating Sona Masoori.',
      status: KycStatus.pending,
      appliedAt: DateTime.now().subtract(const Duration(hours: 9)),
    ),
    KycApplication(
      id: 'KYC-DRV-202',
      userId: 'driver-rajesh',
      applicantName: 'Rajesh Goud',
      phone: '+91 98765 44332',
      role: UserRole.deliveryPartner,
      location: 'Kazipet, Warangal (Telangana)',
      documentType: 'Auto-Trolley Goods Vehicle RC',
      documentNumber: 'TS-03-TR-9102',
      documentDetails: 'Piaggio Ape 3-Wheeler Cargo Trolley (500 kg payload capacity) for farm-to-mandi bulky produce transport. DL Class: LMV-Goods.',
      status: KycStatus.pending,
      appliedAt: DateTime.now().subtract(const Duration(hours: 18)),
    ),
    KycApplication(
      id: 'KYC-FARM-103',
      userId: 'farmer-lakshmi',
      applicantName: 'Lakshmi Devi',
      phone: '+91 98765 55443',
      role: UserRole.farmer,
      location: 'Madhira, Khammam (Telangana)',
      documentType: 'Telangana Horticulture Certificate',
      documentNumber: 'TS-HORT-KM-1104',
      documentDetails: 'Department of Horticulture Registration for 3 Acres natural drip-irrigated tomato and bell pepper crop cultivation.',
      status: KycStatus.approved,
      appliedAt: DateTime.now().subtract(const Duration(days: 3)),
      reviewedAt: DateTime.now().subtract(const Duration(days: 2)),
      reviewedBy: 'Admin Officer (HQ)',
    ),
    KycApplication(
      id: 'KYC-DRV-203',
      userId: 'driver-anand',
      applicantName: 'Anand Kumar',
      phone: '+91 98765 66554',
      role: UserRole.deliveryPartner,
      location: 'Warangal Rural (Telangana)',
      documentType: 'Two-Wheeler Driving License',
      documentNumber: 'DL-TS03-2018-0021',
      documentDetails: 'Bajaj Pulsar 150. Transport DL validity expired on 12-Dec-2023.',
      status: KycStatus.rejected,
      rejectionReason: 'Driving license expired in Dec 2023. Please upload renewed RTA smart card license to resume verification.',
      appliedAt: DateTime.now().subtract(const Duration(days: 4)),
      reviewedAt: DateTime.now().subtract(const Duration(days: 3)),
      reviewedBy: 'Admin Officer (HQ)',
    ),
  ];

  KycApplication _fromApi(Map<String, dynamic> map) {
    KycStatus parsedStatus = KycStatus.pending;
    try {
      parsedStatus = KycStatus.values.byName(map['status']?.toString() ?? 'pending');
    } catch (_) {}

    UserRole parsedRole = UserRole.farmer;
    try {
      parsedRole = UserRole.values.byName(map['role']?.toString() ?? 'farmer');
    } catch (_) {}

    return KycApplication(
      id: map['id']?.toString() ?? '',
      userId: map['user_id']?.toString() ?? '',
      applicantName: map['applicant_name']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      role: parsedRole,
      location: map['location']?.toString() ?? '',
      documentType: map['document_type']?.toString() ?? '',
      documentNumber: map['document_number']?.toString() ?? '',
      documentDetails: map['document_details']?.toString() ?? '',
      status: parsedStatus,
      rejectionReason: map['rejection_reason']?.toString(),
      appliedAt: DateTime.tryParse(map['applied_at']?.toString() ?? '') ?? DateTime.now(),
      reviewedAt: DateTime.tryParse(map['reviewed_at']?.toString() ?? ''),
      reviewedBy: map['reviewed_by']?.toString(),
    );
  }

  Future<List<KycApplication>> getApplications({
    KycStatus? status,
    UserRole? role,
    String? searchQuery,
  }) async {
    List<KycApplication> source = _applications;
    try {
      final resp = await _apiClient.get('/api/v1/admin/kyc');
      if (resp is List && resp.isNotEmpty) {
        source = resp.whereType<Map>().map((e) => _fromApi(Map<String, dynamic>.from(e))).toList();
      }
    } catch (_) {}

    return source.where((app) {
      if (status != null && app.status != status) {
        return false;
      }
      if (role != null && app.role != role) {
        return false;
      }
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final query = searchQuery.trim().toLowerCase();
        final matchesName = app.applicantName.toLowerCase().contains(query);
        final matchesPhone = app.phone.contains(query);
        final matchesDoc = app.documentNumber.toLowerCase().contains(query);
        final matchesType = app.documentType.toLowerCase().contains(query);
        final matchesLocation = app.location.toLowerCase().contains(query);
        if (!matchesName && !matchesPhone && !matchesDoc && !matchesType && !matchesLocation) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  Future<bool> approveApplication(String id, {String reviewedBy = 'Admin Officer (HQ)'}) async {
    try {
      await _apiClient.post(
        '/api/v1/admin/kyc/$id/approve',
        body: {'reviewed_by': reviewedBy},
      );
      return true;
    } catch (_) {}

    final index = _applications.indexWhere((app) => app.id == id);
    if (index != -1) {
      _applications[index] = _applications[index].copyWith(
        status: KycStatus.approved,
        rejectionReason: null,
        reviewedAt: DateTime.now(),
        reviewedBy: reviewedBy,
      );
      return true;
    }
    return false;
  }

  Future<bool> rejectApplication(
    String id, {
    required String reason,
    String reviewedBy = 'Admin Officer (HQ)',
  }) async {
    try {
      await _apiClient.post(
        '/api/v1/admin/kyc/$id/reject',
        body: {'reason': reason, 'reviewed_by': reviewedBy},
      );
      return true;
    } catch (_) {}

    final index = _applications.indexWhere((app) => app.id == id);
    if (index != -1) {
      _applications[index] = _applications[index].copyWith(
        status: KycStatus.rejected,
        rejectionReason: reason,
        reviewedAt: DateTime.now(),
        reviewedBy: reviewedBy,
      );
      return true;
    }
    return false;
  }

  int getPendingCount() {
    return _applications.where((a) => a.status == KycStatus.pending).length;
  }
}
