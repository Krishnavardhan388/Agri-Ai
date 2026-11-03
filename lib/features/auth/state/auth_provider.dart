import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/user_role.dart';

class AuthState {
  final bool isAuthenticated;
  final UserRole selectedRole;
  final String userName;
  final String userPhone;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    this.isAuthenticated = false,
    this.selectedRole = UserRole.farmer,
    this.userName = '',
    this.userPhone = '',
    this.isLoading = false,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    UserRole? selectedRole,
    String? userName,
    String? userPhone,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      selectedRole: selectedRole ?? this.selectedRole,
      userName: userName ?? this.userName,
      userPhone: userPhone ?? this.userPhone,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  void setRole(UserRole role) {
    state = state.copyWith(selectedRole: role);
  }

  Future<bool> login({required String phone, required String password}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    // Simulate lightweight auth delay for Phase 1 (Firebase auth will be connected in Phase 2)
    await Future.delayed(const Duration(milliseconds: 600));

    if (phone.trim().length < 10) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Please enter a valid 10-digit mobile number',
      );
      return false;
    }

    state = state.copyWith(
      isAuthenticated: true,
      userPhone: phone,
      userName: state.selectedRole == UserRole.farmer
          ? 'Ramesh Kumar (Farmer)'
          : state.selectedRole == UserRole.customer
              ? 'Priya Sharma (Buyer)'
              : 'Suresh Patel (Delivery)',
      isLoading: false,
    );
    return true;
  }

  Future<bool> register({
    required String name,
    required String phone,
    required UserRole role,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    await Future.delayed(const Duration(milliseconds: 600));

    if (name.trim().isEmpty || phone.trim().length < 10) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Please fill in all details properly',
      );
      return false;
    }

    state = state.copyWith(
      isAuthenticated: true,
      selectedRole: role,
      userName: name.trim(),
      userPhone: phone.trim(),
      isLoading: false,
    );
    return true;
  }

  void logout() {
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
