import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/services/api_client.dart';
import '../data/auth_repository.dart';
import '../domain/user_model.dart';
import '../domain/user_role.dart';

export '../../../core/providers/core_providers.dart' show localStorageProvider;

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final localStorage = ref.watch(localStorageProvider);
  final apiClient = ref.watch(apiClientProvider);
  return FirebaseAuthRepository(
    localStorage: localStorage,
    apiClient: apiClient,
  );
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
  final bool smsDispatchedReal;
  final String? smsStatusMessage;
  final String? sandboxOtpPreview;
  final BackendHealthStatus? backendHealth;

  const AuthState({
    this.isAuthenticated = false,
    this.user,
    this.selectedRole = UserRole.farmer,
    this.isLoading = false,
    this.errorMessage,
    this.verificationId,
    this.pendingPhone,
    this.isOtpSent = false,
    this.smsDispatchedReal = false,
    this.smsStatusMessage,
    this.sandboxOtpPreview,
    this.backendHealth,
  });

  String get userName => user?.name ?? '';
  String get userPhone => user?.phone ?? '';

  AuthState copyWith({
    bool? isAuthenticated,
    UserModel? user,
    UserRole? selectedRole,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    String? verificationId,
    String? pendingPhone,
    bool? isOtpSent,
    bool? smsDispatchedReal,
    String? smsStatusMessage,
    String? sandboxOtpPreview,
    bool clearSandboxOtp = false,
    BackendHealthStatus? backendHealth,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      selectedRole: selectedRole ?? this.selectedRole,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      verificationId: verificationId ?? this.verificationId,
      pendingPhone: pendingPhone ?? this.pendingPhone,
      isOtpSent: isOtpSent ?? this.isOtpSent,
      smsDispatchedReal: smsDispatchedReal ?? this.smsDispatchedReal,
      smsStatusMessage: smsStatusMessage ?? this.smsStatusMessage,
      sandboxOtpPreview: clearSandboxOtp ? null : (sandboxOtpPreview ?? this.sandboxOtpPreview),
      backendHealth: backendHealth ?? this.backendHealth,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState()) {
    checkAuthStatus();
    refreshBackendHealth();
  }

  Future<void> refreshBackendHealth() async {
    final health = await _repository.checkBackendHealth();
    state = state.copyWith(backendHealth: health);
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
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      isOtpSent: false,
      clearSandboxOtp: true,
    );

    String? errorResult;
    final dispatchResult = await _repository.sendOtp(
      phoneNumber: phone,
      onCodeSent: (_) {},
      onError: (err) {
        errorResult = err;
      },
    );

    if (errorResult != null || dispatchResult.verificationId.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: errorResult ?? dispatchResult.message,
      );
      return false;
    }

    state = state.copyWith(
      isLoading: false,
      verificationId: dispatchResult.verificationId,
      pendingPhone: dispatchResult.phone,
      isOtpSent: true,
      smsDispatchedReal: dispatchResult.smsSent,
      smsStatusMessage: dispatchResult.message,
      sandboxOtpPreview: dispatchResult.sandboxOtpPreview,
    );
    return true;
  }

  Future<bool> verifyOtp(String smsCode, {String? name, String? location}) async {
    if (state.verificationId == null) {
      state = state.copyWith(errorMessage: 'Please request an OTP first.');
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);
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
        clearSandboxOtp: true,
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
    if (phone.trim().length < 10) {
      state = state.copyWith(errorMessage: 'Enter a valid 10-digit mobile number');
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repository.loginWithPin(
        phoneNumber: phone.trim(),
        pin: password.trim(),
        role: state.selectedRole,
      );
      state = state.copyWith(
        isAuthenticated: true,
        user: user,
        isLoading: false,
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

  Future<bool> register({
    required String name,
    required String phone,
    required String location,
    required UserRole role,
    String pin = '123456',
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final newUser = await _repository.registerUser(
        name: name.trim(),
        phoneNumber: phone.trim(),
        location: location.trim(),
        role: role,
        pin: pin.trim(),
      );

      state = state.copyWith(
        isAuthenticated: true,
        user: newUser,
        selectedRole: role,
        isLoading: false,
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

  Future<void> logout() async {
    await _repository.signOut();
    state = const AuthState();
    refreshBackendHealth();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});
