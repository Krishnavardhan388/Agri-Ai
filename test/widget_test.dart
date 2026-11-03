import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agri_ai/app.dart';
import 'package:agri_ai/core/constants/app_strings.dart';

void main() {
  testWidgets('AGRI AI App boots and displays Splash Screen branding', (WidgetTester tester) async {
    // Build our app wrapped with ProviderScope.
    await tester.pumpWidget(
      const ProviderScope(
        child: AgriApp(),
      ),
    );

    // Verify initial splash screen branding is shown.
    expect(find.text(AppStrings.appName), findsOneWidget);
    expect(find.text(AppStrings.appTagline), findsOneWidget);

    // Fast-forward past the splash timer (2.4s) into the Onboarding screen.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Verify Onboarding screen has loaded.
    expect(find.text(AppStrings.onbTitle1), findsOneWidget);
  });
}
