import 'user_role.dart';

class UserModel {
  final String uid;
  final String name;
  final String phone;
  final String? email;
  final UserRole role;
  final String location;
  final DateTime createdAt;
  final bool isVerified;

  const UserModel({
    required this.uid,
    required this.name,
    required this.phone,
    this.email,
    required this.role,
    required this.location,
    required this.createdAt,
    this.isVerified = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'phone': phone,
      'email': email,
      'role': role.name,
      'location': location,
      'createdAt': createdAt.toIso8601String(),
      'isVerified': isVerified,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    UserRole parsedRole = UserRole.farmer;
    try {
      parsedRole = UserRole.values.byName(map['role'] ?? 'farmer');
    } catch (_) {
      parsedRole = UserRole.farmer;
    }

    return UserModel(
      uid: id,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'],
      role: parsedRole,
      location: map['location'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      isVerified: map['isVerified'] ?? true,
    );
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? phone,
    String? email,
    UserRole? role,
    String? location,
    DateTime? createdAt,
    bool? isVerified,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      role: role ?? this.role,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}
