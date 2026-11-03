import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agri_ai/core/services/local_storage_service.dart';
import 'package:agri_ai/features/auth/data/auth_repository.dart';
import 'package:agri_ai/features/auth/domain/user_role.dart';
import 'package:agri_ai/features/auth/state/auth_provider.dart';

void main() {
  late LocalStorageService localStorage;
  late FirebaseAuthRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    localStorage = await LocalStorageService.init();
    repository = FirebaseAuthRepository(localStorage: localStorage);
  });

  test('Send OTP triggers onCodeSent callback', () async {
    String? codeSentId;
    await repository.sendOtp(
      phoneNumber: '9876543210',
      onCodeSent: (id) => codeSentId = id,
      onError: (err) => fail(err),
    );

    expect(codeSentId, isNotNull);
    expect(codeSentId, contains('9876543210'));
  });

  test('Verify OTP creates a verified user profile and saves session', () async {
    final user = await repository.verifyOtp(
      verificationId: 'mock-verification-id-9876543210',
      smsCode: '123456',
      role: UserRole.farmer,
      name: 'Ramesh Kumar',
      location: 'Warangal',
    );

    expect(user.phone, '9876543210');
    expect(user.role, UserRole.farmer);
    expect(user.name, 'Ramesh Kumar');
    expect(localStorage.isLoggedIn, true);
    expect(localStorage.savedRole, UserRole.farmer);
  });

  test('AuthNotifier integrates OTP flow and role selection', () async {
    final notifier = AuthNotifier(repository);
    notifier.setRole(UserRole.customer);

    expect(notifier.state.selectedRole, UserRole.customer);

    final sent = await notifier.sendOtp('9876543210');
    expect(sent, true);
    expect(notifier.state.isOtpSent, true);

    final verified = await notifier.verifyOtp('123456');
    expect(verified, true);
    expect(notifier.state.isAuthenticated, true);
    expect(notifier.state.user?.role, UserRole.customer);
  });
}

