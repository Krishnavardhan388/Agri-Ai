import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/services/local_storage_service.dart';
import '../domain/user_model.dart';
import '../domain/user_role.dart';
import 'firestore_user_service.dart';

abstract class AuthRepository {
  Future<void> sendOtp({
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

  Future<void> signOut();

  Future<UserModel?> getCurrentUser();
}

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuth? _firebaseAuth;
  final FirestoreUserService _firestoreService;
  final LocalStorageService localStorage;

  FirebaseAuthRepository({
    FirebaseAuth? firebaseAuth,
    FirestoreUserService? firestoreService,
    required this.localStorage,
  }) : _firestoreService = firestoreService ?? FirestoreUserService() {
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

  @override
  Future<void> sendOtp({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(String error) onError,
  }) async {
    // Format to E.164 standard for India (+91)
    final formattedPhone = phoneNumber.startsWith('+')
        ? phoneNumber
        : '+91${phoneNumber.replaceAll(RegExp(r'\D'), '')}';

    final auth = firebaseAuth;
    if (FirebaseService.isInitialized && auth != null) {
      try {
        await auth.verifyPhoneNumber(
          phoneNumber: formattedPhone,
          timeout: const Duration(seconds: 60),
          verificationCompleted: (PhoneAuthCredential credential) async {
            // Auto-retrieval handled in background
          },
          verificationFailed: (FirebaseAuthException e) {
            onError(e.message ?? 'SMS Verification failed. Check your phone number.');
          },
          codeSent: (String verificationId, int? resendToken) {
            onCodeSent(verificationId);
          },
          codeAutoRetrievalTimeout: (String verificationId) {},
        );
      } catch (e) {
        onError('Firebase Auth error: $e');
      }
    } else {
      // Local development simulation
      await Future.delayed(const Duration(milliseconds: 600));
      onCodeSent('mock-verification-id-$formattedPhone');
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
    final auth = firebaseAuth;
    if (FirebaseService.isInitialized && auth != null) {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final userCredential = await auth.signInWithCredential(credential);
      final fbUser = userCredential.user;
      if (fbUser == null) {
        throw Exception('User authentication failed.');
      }

      // Check if user already exists in Firestore
      UserModel? existingUser = await _firestoreService.getUser(fbUser.uid);
      if (existingUser == null) {
        existingUser = UserModel(
          uid: fbUser.uid,
          name: name?.trim().isNotEmpty == true ? name! : 'Kisan Farmer',
          phone: fbUser.phoneNumber ?? '',
          role: role,
          location: location ?? 'Warangal, Telangana',
          createdAt: DateTime.now(),
        );
        await _firestoreService.saveUser(existingUser);
      }

      await localStorage.saveUserSession(existingUser);
      return existingUser;
    } else {
      // Local verification simulation (accepts '123456' or any 6-digit code for testing)
      await Future.delayed(const Duration(milliseconds: 500));
      if (smsCode.trim().length != 6) {
        throw Exception('Please enter a valid 6-digit OTP code.');
      }

      final mockUser = UserModel(
        uid: 'user-${DateTime.now().millisecondsSinceEpoch}',
        name: name?.trim().isNotEmpty == true
            ? name!
            : role == UserRole.farmer
                ? 'Ramesh Kumar (Farmer)'
                : role == UserRole.customer
                    ? 'Priya Sharma (Customer)'
                    : 'Suresh Patel (Delivery Partner)',
        phone: verificationId.replaceAll('mock-verification-id-', ''),
        role: role,
        location: location ?? 'Warangal, Telangana',
        createdAt: DateTime.now(),
      );

      await localStorage.saveUserSession(mockUser);
      return mockUser;
    }
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
    final auth = firebaseAuth;
    if (FirebaseService.isInitialized && auth != null) {
      final fbUser = auth.currentUser;
      if (fbUser != null) {
        final profile = await _firestoreService.getUser(fbUser.uid);
        if (profile != null) return profile;
      }
    }
    return localStorage.getSavedUser();
  }
}
