import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../admin/presentation/admin_main_screen.dart';
import '../../dashboards/customer/customer_main_screen.dart';
import '../../dashboards/delivery/delivery_main_screen.dart';
import '../../dashboards/farmer/farmer_main_screen.dart';
import '../domain/user_role.dart';
import '../state/auth_provider.dart';
import 'otp_verification_sheet.dart';
import 'register_screen.dart';
import 'role_selection_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final UserRole initialRole;

  const LoginScreen({super.key, this.initialRole = UserRole.farmer});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController(text: '9876543210');
  final _passwordController = TextEditingController(text: '123456');
  final _formKey = GlobalKey<FormState>();
  bool _useOtpLogin = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _navigateToDashboard(UserRole role) {
    Widget destination;
    switch (role) {
      case UserRole.farmer:
        destination = const FarmerMainScreen();
        break;
      case UserRole.customer:
        destination = const CustomerMainScreen();
        break;
      case UserRole.deliveryPartner:
        destination = const DeliveryMainScreen();
        break;
      case UserRole.admin:
        destination = const AdminMainScreen();
        break;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => destination),
      (route) => false,
    );
  }

  Future<void> _handlePrimaryAction() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final phone = _phoneController.text.trim();

    if (_useOtpLogin) {
      // Send OTP flow
      final sent = await ref.read(authProvider.notifier).sendOtp(phone);
      if (sent && mounted) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (ctx) => OtpVerificationSheet(
            phoneNumber: phone,
            onVerificationSuccess: () {
              final currentRole = ref.read(authProvider).selectedRole;
              _navigateToDashboard(currentRole);
            },
          ),
        );
      }
    } else {
      // Password / PIN quick login flow
      final success = await ref.read(authProvider.notifier).quickLogin(
            phone: phone,
            password: _passwordController.text,
          );

      if (success && mounted) {
        final currentRole = ref.read(authProvider).selectedRole;
        _navigateToDashboard(currentRole);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final activeRole = authState.selectedRole;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Sign In'),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
              );
            },
            icon: const Icon(Icons.swap_horiz_rounded, size: 18),
            label: Text(
              activeRole.shortName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Active Role Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.greenSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.greenAccent),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(activeRole.icon, size: 18, color: AppColors.primaryGreen),
                      const SizedBox(width: 8),
                      Text(
                        'Role: ${activeRole.displayName}',
                        style: const TextStyle(
                          color: AppColors.primaryDark,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                const Text(
                  AppStrings.welcomeBack,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  AppStrings.loginSubtitle,
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),

                // Login Mode Switcher Tabs
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _useOtpLogin = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _useOtpLogin ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: _useOtpLogin
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.05),
                                        blurRadius: 4,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                'Mobile OTP (Recommended)',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: _useOtpLogin ? FontWeight.bold : FontWeight.w500,
                                  color: _useOtpLogin ? AppColors.primaryGreen : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _useOtpLogin = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: !_useOtpLogin ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: !_useOtpLogin
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.05),
                                        blurRadius: 4,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                'PIN / Password',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: !_useOtpLogin ? FontWeight.bold : FontWeight.w500,
                                  color: !_useOtpLogin ? AppColors.primaryGreen : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Error Banner
                if (authState.errorMessage != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.alertRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.alertRed),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded,
                            color: AppColors.alertRed, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            authState.errorMessage!,
                            style: const TextStyle(
                              color: AppColors.alertRed,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                CustomTextField(
                  controller: _phoneController,
                  label: 'Registered Mobile Number',
                  hint: '10-digit mobile number',
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_android_rounded,
                  validator: (value) {
                    if (value == null || value.trim().length < 10) {
                      return 'Enter a valid 10-digit mobile number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                if (!_useOtpLogin) ...[
                  CustomTextField(
                    controller: _passwordController,
                    label: 'Security PIN / Password',
                    hint: 'Enter your 4 or 6 digit PIN',
                    obscureText: true,
                    prefixIcon: Icons.lock_outline_rounded,
                    validator: (value) {
                      if (value == null || value.length < 4) {
                        return 'Please enter at least 4 digits';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: CustomButton(
                    text: _useOtpLogin ? 'Send Verification OTP' : 'Sign In',
                    isLoading: authState.isLoading,
                    icon: _useOtpLogin ? Icons.sms_outlined : Icons.login_rounded,
                    onPressed: _handlePrimaryAction,
                  ),
                ),

                const SizedBox(height: 24),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Register Now',
                          style: TextStyle(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
