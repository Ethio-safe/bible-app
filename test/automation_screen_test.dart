import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bible/core/database/database_providers.dart';
import 'package:bible/core/database/user_database.dart';
import 'package:bible/core/storage/preferences_provider.dart';
import 'package:bible/features/automation/domain/automation_settings.dart';
import 'package:bible/features/automation/presentation/screens/automation_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('AutomationScreen renders and toggles settings', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final db = UserDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          userDatabaseProvider.overrideWithValue(db),
        ],
        child: const MaterialApp(home: AutomationScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Rotate wallpaper automatically'), findsOneWidget);
    expect(find.text('Refresh now'), findsOneWidget);
    expect(find.text('No rotations yet'), findsOneWidget);
    // Without compiled-in keys the notice must be visible.
    expect(find.textContaining('No image API key'), findsOneWidget);

    // Toggle the master switch → persisted to prefs.
    await tester.tap(find.byType(SwitchListTile).first);
    await tester.pumpAndSettle();
    expect(AutomationSettings.read(prefs).enabled, isTrue);

    // Interval picker opens and selects.
    await tester.tap(find.text('Interval'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(RotationInterval.daily.label).last);
    await tester.pumpAndSettle();
    expect(AutomationSettings.read(prefs).interval, RotationInterval.daily);

    // Basic accessibility: tappable rows meet the minimum size guideline.
    final handle = tester.ensureSemantics();
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    handle.dispose();
  });
}
