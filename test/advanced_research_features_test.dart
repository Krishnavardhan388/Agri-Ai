import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agri_ai/features/crop_doctor/presentation/widgets/dosage_calculator_sheet.dart';
import 'package:agri_ai/features/community/presentation/kisan_charcha_screen.dart';

void main() {
  group('Advanced Research Features Tests', () {
    testWidgets('DosageCalculatorSheet renders and computes tank dilution properly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DosageCalculatorSheet(
              cropName: 'Tomato',
              diseaseName: 'Early Blight',
              organicTreatments: ['Neem Oil 1500 ppm @ 5ml/L water', 'Trichoderma viride'],
              chemicalTreatments: ['Mancozeb 75% WP @ 2.5g/L water'],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify title & crop info
      expect(find.text('Plot Dilution & Tank Calculator'), findsOneWidget);
      expect(find.text('Tomato • Early Blight'), findsOneWidget);

      // Verify Treatment buttons
      expect(find.text('Organic Bio-Spray'), findsOneWidget);
      expect(find.text('Chemical Fungicide'), findsOneWidget);

      // Verify default 1.0 Acre and 16L tank
      expect(find.text('1.0 Acre'), findsOneWidget);
      expect(find.text('200 L'), findsOneWidget); // 1.0 * 200L = 200L
      expect(find.text('12.5 Tanks'), findsOneWidget); // 200 / 16 = 12.5

      // Switch to Chemical Fungicide
      await tester.tap(find.text('Chemical Fungicide'));
      await tester.pumpAndSettle();

      // Verify Mancozeb active ingredient displayed
      expect(find.textContaining('Mancozeb'), findsOneWidget);

      // Tap 2.0 Ac preset
      await tester.tap(find.text('2.0 Ac'));
      await tester.pumpAndSettle();

      // 2.0 Acres -> 400 L water, 25.0 Tanks
      expect(find.text('400 L'), findsOneWidget);
      expect(find.text('25.0 Tanks'), findsOneWidget);

      // Verify Save button
      expect(find.text('Save Dosage to Spray Log'), findsOneWidget);
    });

    testWidgets('KisanCharchaScreen displays posts, filters, and supports upvoting', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: KisanCharchaScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify header and filter chips
      expect(find.text('🌾 Kisan Charcha Forum'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'All'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Cotton'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Chilli'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Paddy'), findsOneWidget);

      // Verify initial seed posts
      expect(find.textContaining('Pink Bollworm'), findsOneWidget);
      expect(find.textContaining('Thrips'), findsOneWidget);
      expect(find.text('AI Agronomist Verified'), findsWidgets);

      // Upvote testing
      final upvoteButton = find.text('35 Helpful');
      expect(upvoteButton, findsOneWidget);
      await tester.tap(upvoteButton);
      await tester.pumpAndSettle();
      expect(find.text('36 Helpful'), findsOneWidget);

      // Filter by Chilli
      await tester.tap(find.widgetWithText(ChoiceChip, 'Chilli'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Thrips'), findsOneWidget);
      expect(find.textContaining('Pink Bollworm'), findsNothing);

      // Open Ask Question Dialog
      await tester.tap(find.text('Ask Question'));
      await tester.pumpAndSettle();
      expect(find.text('Ask Kisan Charcha'), findsOneWidget);
    });
  });
}
