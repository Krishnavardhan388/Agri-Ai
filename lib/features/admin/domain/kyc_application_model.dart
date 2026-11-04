import 'package:flutter/material.dart';
import '../../auth/domain/user_role.dart';

enum KycStatus {
  pending,
  approved,
  rejected;

  String get displayName {
    switch (this) {
      case KycStatus.pending:
        return 'Pending Review';
      case KycStatus.approved:
        return 'Verified & Active';
      case KycStatus.rejected:
        return 'Rejected';
    }
  }

  Color get color {
    switch (this) {
      case KycStatus.pending:
        return const Color(0xFFFFA000); // Amber
      case KycStatus.approved:
        return const Color(0xFF2E7D32); // Green
      case KycStatus.rejected:
        return const Color(0xFFD32F2F); // Red
    }
  }

  IconData get icon {
    switch (this) {
      case KycStatus.pending:
        return Icons.pending_actions_rounded;
      case KycStatus.approved:
        return Icons.verified_rounded;
      case KycStatus.rejected:
        return Icons.cancel_rounded;
    }
  }
}

class KycApplication {
  final String id;
  final String userId;
  final String applicantName;
  final String phone;
  final UserRole role;
  final String location;
  final String documentType;
  final String documentNumber;
  final String? documentDetails;
  final KycStatus status;
  final String? rejectionReason;
  final DateTime appliedAt;
  final DateTime? reviewedAt;
  final String? reviewedBy;

  const KycApplication({
    required this.id,
    required this.userId,
    required this.applicantName,
    required this.phone,
    required this.role,
    required this.location,
    required this.documentType,
    required this.documentNumber,
    this.documentDetails,
    required this.status,
    this.rejectionReason,
    required this.appliedAt,
    this.reviewedAt,
    this.reviewedBy,
  });

  KycApplication copyWith({
    String? id,
    String? userId,
    String? applicantName,
    String? phone,
    UserRole? role,
    String? location,
    String? documentType,
    String? documentNumber,
    String? documentDetails,
    KycStatus? status,
    String? rejectionReason,
    DateTime? appliedAt,
    DateTime? reviewedAt,
    String? reviewedBy,
  }) {
    return KycApplication(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      applicantName: applicantName ?? this.applicantName,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      location: location ?? this.location,
      documentType: documentType ?? this.documentType,
      documentNumber: documentNumber ?? this.documentNumber,
      documentDetails: documentDetails ?? this.documentDetails,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      appliedAt: appliedAt ?? this.appliedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
    );
  }
}
