import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/local_storage_service.dart';
import '../data/auth_repository.dart';
import '../domain/user_model.dart';
import '../domain/user_role.dart';

final localStorageProvider = Provider<LocalStorageService>((ref) {
  throw UnimplementedError('localStorageProvider must be initialized in main.dart');
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final localStorage = ref.watch(localStorageProvider);
  return FirebaseAuthRepository(localStorage: localStorage);
});

class AuthState {
  final bool isAuthenticated;
  final UserModel? user;
  final UserRole selectedRole;
  final bool isLoading;
  final String? errorMessage;
  final String? verificationId;
  final String? pendingPhone;
  final bool isOtpSent;

  const AuthState({
    this.isAuthenticated = false,
    this.user,
    this.selectedRole = UserRole.farmer,
    this.isLoading = false,
    this.errorMessage,
    this.verificationId,
    this.pendingPhone,
    this.isOtpSent = false,
  });

  String get userName => user?.name ?? '';
  String get userPhone => user?.phone ?? '';

  AuthState copyWith({
    bool? isAuthenticated,
    UserModel? user,
    UserRole? selectedRole,
    bool? isLoading,
    String? errorMessage,
    String? verificationId,
    String? pendingPhone,
    bool? isOtpSent,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      selectedRole: selectedRole ?? this.selectedRole,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      verificationId: verificationId ?? this.verificationId,
      pendingPhone: pendingPhone ?? this.pendingPhone,
      isOtpSent: isOtpSent ?? this.isOtpSent,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState()) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    final savedUser = await _repository.getCurrentUser();
    if (savedUser != null) {
      state = state.copyWith(
        isAuthenticated: true,
        user: savedUser,
        selectedRole: savedUser.role,
      );
    }
  }

  void setRole(UserRole role) {
    state = state.copyWith(selectedRole: role);
  }

  Future<bool> sendOtp(String phone) async {
    state = state.copyWith(isLoading: true, errorMessage: null, isOtpSent: false);

    bool success = false;
    await _repository.sendOtp(
      phoneNumber: phone,
      onCodeSent: (id) {
        state = state.copyWith(
          isLoading: false,
          verificationId: id,
          pendingPhone: phone,
          isOtpSent: true,
        );
        success = true;
      },
      onError: (err) {
        state = state.copyWith(isLoading: false, errorMessage: err);
        success = false;
      },
    );

    return success;
  }

  Future<bool> verifyOtp(String smsCode, {String? name, String? location}) async {
    if (state.verificationId == null) {
      state = state.copyWith(errorMessage: 'Please request an OTP first.');
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await _repository.verifyOtp(
        verificationId: state.verificationId!,
        smsCode: smsCode,
        role: state.selectedRole,
        name: name,
        location: location,
      );

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: user,
        isOtpSent: false,
        verificationId: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> quickLogin({required String phone, required String password}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    await Future.delayed(const Duration(milliseconds: 500));

    if (phone.trim().length < 10) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Enter a valid 10-digit mobile number',
      );
      return false;
    }

    final dummyUser = UserModel(
      uid: 'uid-${phone.trim()}',
      name: state.selectedRole == UserRole.farmer
          ? 'Ramesh Kumar (Farmer)'
          : state.selectedRole == UserRole.customer
              ? 'Priya Sharma (Buyer)'
              : 'Suresh Patel (Delivery)',
      phone: phone.trim(),
      role: state.selectedRole,
      location: 'Warangal, Telangana',
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      isAuthenticated: true,
      user: dummyUser,
      isLoading: false,
    );
    return true;
  }

  Future<bool> register({
    required String name,
    required String phone,
    required String location,
    required UserRole role,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    await Future.delayed(const Duration(milliseconds: 500));

    final newUser = UserModel(
      uid: 'uid-${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      phone: phone.trim(),
      role: role,
      location: location.trim(),
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      isAuthenticated: true,
      user: newUser,
      selectedRole: role,
      isLoading: false,
    );
    return true;
  }

  Future<void> logout() async {
    await _repository.signOut();
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});
