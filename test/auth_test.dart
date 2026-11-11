import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agri_ai/core/services/api_client.dart';
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

    final mockHttpClient = MockClient((request) async {
      final path = request.url.path;

      if (path.endsWith('/api/v1/health')) {
        return http.Response(
          jsonEncode({
            'status': 'ONLINE',
            'mongodb_connected': true,
            'sms_gateway_active': true,
            'database': 'MongoDB Atlas Connected',
            'sms_gateway': 'Fast2SMS Active',
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }

      if (path.endsWith('/api/v1/auth/send-otp')) {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(
          jsonEncode({
            'verification_id': 'OTP-${body['phone']}',
            'phone': '+91${body['phone']}',
            'sms_sent': true,
            'provider': 'Fast2SMS (q)',
            'expires_in_seconds': 300,
            'message': 'Verification SMS dispatched to +91${body['phone']}',
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }

      if (path.endsWith('/api/v1/auth/verify-otp')) {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        if (body['sms_code'] != '492817') {
          return http.Response(
            jsonEncode({'detail': 'Incorrect 6-digit OTP code.'}),
            400,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response(
          jsonEncode({
            'access_token': 'signed_token_abc',
            'token_type': 'bearer',
            'user': {
              'uid': 'user-farmer-1',
              'name': body['name'] ?? 'Ramesh Kumar',
              'phone': '+919876543210',
              'role': body['role'] ?? 'farmer',
              'location': body['location'] ?? 'Warangal',
              'is_verified': true,
              'created_at': DateTime.now().toIso8601String(),
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }

      if (path.endsWith('/api/v1/auth/login-pin')) {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        if (body['pin'] != '654321') {
          return http.Response(
            jsonEncode({'detail': 'Invalid security PIN.'}),
            401,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response(
          jsonEncode({
            'access_token': 'signed_token_pin',
            'token_type': 'bearer',
            'user': {
              'uid': 'user-farmer-1',
              'name': 'Ramesh Kumar',
              'phone': '+919876543210',
              'role': body['role'] ?? 'farmer',
              'location': 'Warangal',
              'is_verified': true,
              'created_at': DateTime.now().toIso8601String(),
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }

      if (path.endsWith('/api/v1/auth/register')) {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(
          jsonEncode({
            'access_token': 'signed_token_reg',
            'token_type': 'bearer',
            'user': {
              'uid': 'user-new-99',
              'name': body['name'],
              'phone': '+91${body['phone']}',
              'role': body['role'],
              'location': body['location'],
              'is_verified': true,
              'created_at': DateTime.now().toIso8601String(),
            },
          }),
          201,
          headers: {'content-type': 'application/json'},
        );
      }

      return http.Response(jsonEncode({'detail': 'Not found'}), 404);
    });

    final apiClient = ApiClient(client: mockHttpClient, localStorage: localStorage);
    repository = FirebaseAuthRepository(localStorage: localStorage, apiClient: apiClient);
  });

  test('Send OTP calls Fast2SMS backend and returns verification session', () async {
    String? codeSentId;
    final result = await repository.sendOtp(
      phoneNumber: '9876543210',
      onCodeSent: (id) => codeSentId = id,
      onError: (err) => fail(err),
    );

    expect(codeSentId, isNotNull);
    expect(codeSentId, contains('9876543210'));
    expect(result.smsSent, true);
    expect(result.provider, contains('Fast2SMS'));
  });

  test('Verify OTP validates code against backend and saves real token session', () async {
    final user = await repository.verifyOtp(
      verificationId: 'OTP-9876543210',
      smsCode: '492817',
      role: UserRole.farmer,
      name: 'Ramesh Kumar',
      location: 'Warangal',
    );

    expect(user.phone, '+919876543210');
    expect(user.role, UserRole.farmer);
    expect(user.name, 'Ramesh Kumar');
    expect(localStorage.isLoggedIn, true);
    expect(localStorage.authToken, 'signed_token_abc');
    expect(localStorage.savedRole, UserRole.farmer);
  });

  test('PIN login rejects wrong PIN and succeeds on valid MongoDB PIN', () async {
    expect(
      () => repository.loginWithPin(phoneNumber: '9876543210', pin: '000000', role: UserRole.farmer),
      throwsException,
    );

    final user = await repository.loginWithPin(
      phoneNumber: '9876543210',
      pin: '654321',
      role: UserRole.farmer,
    );
    expect(user.name, 'Ramesh Kumar');
    expect(localStorage.authToken, 'signed_token_pin');
  });

  test('AuthNotifier integrates real-time OTP, registration, and backend health check', () async {
    final notifier = AuthNotifier(repository);
    notifier.setRole(UserRole.customer);

    await notifier.refreshBackendHealth();
    expect(notifier.state.backendHealth?.mongoConnected, true);
    expect(notifier.state.backendHealth?.smsGatewayActive, true);

    final sent = await notifier.sendOtp('9876543210');
    expect(sent, true);
    expect(notifier.state.isOtpSent, true);
    expect(notifier.state.smsDispatchedReal, true);

    final wrongVerify = await notifier.verifyOtp('111111');
    expect(wrongVerify, false);
    expect(notifier.state.errorMessage, contains('Incorrect'));

    final verified = await notifier.verifyOtp('492817');
    expect(verified, true);
    expect(notifier.state.isAuthenticated, true);
    expect(notifier.state.user?.role, UserRole.customer);

    await notifier.logout();
    expect(notifier.state.isAuthenticated, false);

    final registered = await notifier.register(
      name: 'Startup Founder',
      phone: '9988776655',
      location: 'Hyderabad',
      role: UserRole.farmer,
      pin: '4321',
    );
    expect(registered, true);
    expect(notifier.state.user?.name, 'Startup Founder');
  });
}
