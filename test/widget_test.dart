import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agri_ai/app.dart';
import 'package:agri_ai/core/constants/app_strings.dart';
import 'package:agri_ai/core/services/local_storage_service.dart';
import 'package:agri_ai/features/auth/state/auth_provider.dart';
import 'package:agri_ai/features/crop_doctor/state/crop_doctor_provider.dart';

void main() {
  testWidgets('AGRI AI App boots and displays Splash Screen branding', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final localStorage = LocalStorageService(prefs);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          localStorageProvider.overrideWithValue(localStorage),
        ],
        child: const AgriApp(),
      ),
    );

    // Verify initial splash screen branding is shown.
    expect(find.text(AppStrings.appName), findsOneWidget);
    expect(find.text(AppStrings.appTagline), findsOneWidget);

    // Fast-forward past the splash timer into the Onboarding screen.
    await tester.pump(const Duration(milliseconds: 2500));
    await tester.pumpAndSettle();

    // Verify Onboarding screen has loaded.
    expect(find.text(AppStrings.onbTitle1), findsOneWidget);
  });
}
