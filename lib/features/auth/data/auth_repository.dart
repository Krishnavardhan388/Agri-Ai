import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/services/local_storage_service.dart';
import '../domain/user_model.dart';
import '../domain/user_role.dart';

class OtpDispatchResult {
  final String verificationId;
  final String phone;
  final bool smsSent;
  final String provider;
  final String message;
  final String? sandboxOtpPreview;

  const OtpDispatchResult({
    required this.verificationId,
    required this.phone,
    required this.smsSent,
    required this.provider,
    required this.message,
    this.sandboxOtpPreview,
  });
}

abstract class AuthRepository {
  Future<OtpDispatchResult> sendOtp({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(String error) onError,
  });

  Future<UserModel> verifyOtp({
    required String verificationId,
    required String smsCode,
    required UserRole role,
    String? name,
    String? location,
  });

  Future<UserModel> loginWithPin({
    required String phoneNumber,
    required String pin,
    required UserRole role,
  });

  Future<UserModel> registerUser({
    required String name,
    required String phoneNumber,
    required String location,
    required UserRole role,
    required String pin,
  });

  Future<BackendHealthStatus> checkBackendHealth();

  Future<void> signOut();

  Future<UserModel?> getCurrentUser();
}

class FirebaseAuthRepository implements AuthRepository {
  final ApiClient _apiClient;
  final LocalStorageService localStorage;
  FirebaseAuth? _firebaseAuth;

  FirebaseAuthRepository({
    FirebaseAuth? firebaseAuth,
    ApiClient? apiClient,
    required this.localStorage,
  }) : _apiClient = apiClient ?? ApiClient(localStorage: localStorage) {
    if (firebaseAuth != null) _firebaseAuth = firebaseAuth;
  }

  FirebaseAuth? get firebaseAuth {
    if (_firebaseAuth != null) return _firebaseAuth;
    if (FirebaseService.isInitialized) {
      _firebaseAuth = FirebaseAuth.instance;
      return _firebaseAuth;
    }
    return null;
  }

  UserModel _userFromJson(Map<String, dynamic> map) {
    UserRole role = UserRole.farmer;
    final roleStr = map['role']?.toString() ?? 'farmer';
    try {
      role = UserRole.values.byName(roleStr);
    } catch (_) {}

    return UserModel(
      uid: map['uid']?.toString() ?? '',
      name: map['name']?.toString() ?? 'AGRI AI User',
      phone: map['phone']?.toString() ?? '',
      role: role,
      location: map['location']?.toString() ?? 'Warangal, Telangana',
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  @override
  Future<BackendHealthStatus> checkBackendHealth() {
    return _apiClient.checkHealth();
  }

  @override
  Future<OtpDispatchResult> sendOtp({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(String error) onError,
  }) async {
    try {
      final data = await _apiClient.post(
        '/api/v1/auth/send-otp',
        body: {'phone': phoneNumber.trim()},
      );

      if (data is! Map<String, dynamic>) {
        throw ApiException('Unexpected response from OTP service.');
      }

      final result = OtpDispatchResult(
        verificationId: data['verification_id']?.toString() ?? '',
        phone: data['phone']?.toString() ?? phoneNumber,
        smsSent: data['sms_sent'] == true,
        provider: data['provider']?.toString() ?? 'Fast2SMS',
        message: data['message']?.toString() ?? 'OTP created.',
        sandboxOtpPreview: data['sandbox_otp_preview']?.toString(),
      );

      if (result.verificationId.isEmpty) {
        throw ApiException('Backend did not return a verification session ID.');
      }

      onCodeSent(result.verificationId);
      return result;
    } catch (e) {
      final errMsg = e.toString().replaceAll('Exception: ', '');
      onError(errMsg);
      return OtpDispatchResult(
        verificationId: '',
        phone: phoneNumber,
        smsSent: false,
        provider: 'Error',
        message: errMsg,
      );
    }
  }

  @override
  Future<UserModel> verifyOtp({
    required String verificationId,
    required String smsCode,
    required UserRole role,
    String? name,
    String? location,
  }) async {
    final data = await _apiClient.post(
      '/api/v1/auth/verify-otp',
      body: {
        'verification_id': verificationId,
        'sms_code': smsCode.trim(),
        'role': role.name,
        if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
        if (location != null && location.trim().isNotEmpty) 'location': location.trim(),
      },
    );

    if (data is! Map<String, dynamic> || data['user'] == null) {
      throw ApiException('Invalid authentication response from server.');
    }

    final user = _userFromJson(Map<String, dynamic>.from(data['user'] as Map));
    final token = data['access_token']?.toString();
    await localStorage.saveUserSession(user, token: token);
    return user;
  }

  @override
  Future<UserModel> loginWithPin({
    required String phoneNumber,
    required String pin,
    required UserRole role,
  }) async {
    final data = await _apiClient.post(
      '/api/v1/auth/login-pin',
      body: {
        'phone': phoneNumber.trim(),
        'pin': pin.trim(),
        'role': role.name,
      },
    );

    if (data is! Map<String, dynamic> || data['user'] == null) {
      throw ApiException('Invalid login response from server.');
    }

    final user = _userFromJson(Map<String, dynamic>.from(data['user'] as Map));
    final token = data['access_token']?.toString();
    await localStorage.saveUserSession(user, token: token);
    return user;
  }

  @override
  Future<UserModel> registerUser({
    required String name,
    required String phoneNumber,
    required String location,
    required UserRole role,
    required String pin,
  }) async {
    final data = await _apiClient.post(
      '/api/v1/auth/register',
      body: {
        'name': name.trim(),
        'phone': phoneNumber.trim(),
        'location': location.trim(),
        'role': role.name,
        'pin': pin.trim(),
      },
    );

    if (data is! Map<String, dynamic> || data['user'] == null) {
      throw ApiException('Invalid registration response from server.');
    }

    final user = _userFromJson(Map<String, dynamic>.from(data['user'] as Map));
    final token = data['access_token']?.toString();
    await localStorage.saveUserSession(user, token: token);
    return user;
  }

  @override
  Future<void> signOut() async {
    final auth = firebaseAuth;
    if (FirebaseService.isInitialized && auth != null) {
      await auth.signOut();
    }
    await localStorage.clearUserSession();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final token = localStorage.authToken;
    if (token != null && token.isNotEmpty) {
      try {
        final data = await _apiClient.get('/api/v1/auth/me');
        if (data is Map<String, dynamic>) {
          final user = _userFromJson(data);
          await localStorage.saveUserSession(user, token: token);
          return user;
        }
      } catch (_) {}
    }
    return localStorage.getSavedUser();
  }
}
