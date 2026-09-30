# Implementation Checklist ✓

## Code Generation (MUST RUN FIRST)
- [ ] `flutter pub run build_runner build --delete-conflicting-outputs`
  - Generates `random_verse.freezed.dart` and `random_verse.g.dart`

## Main App Integration

### 1. Update Router Configuration
- [ ] Add lockscreen routes to GoRouter in `main.dart` or `app_router.dart`
  - See: `integration_example.dart`

### 2. Add to Settings Navigation
- [ ] Update `features/settings/presentation/settings_screen.dart`
  - Add: Lock Screen Verses → `context.push('/lockscreen-verses')`
  - Add: Root Access → `context.push('/root-access')`

### 3. Update Dependencies (if needed)
- [ ] Check `pubspec.yaml` has all required packages:
  - flutter_riverpod ✓ (already present)
  - shared_preferences ✓ (already present)
  - freezed_annotation ✓ (already present)
  - json_annotation ✓ (already present)

### 4. Android Configuration
- [ ] AndroidManifest.xml updated with:
  - ✓ Lock screen permissions
  - ✓ Live wallpaper service declaration
  - ✓ Lock screen rotation service
- [ ] MainActivity.kt updated with:
  - ✓ Root access channel
  - ✓ Lock screen listener
  - ✓ LockScreenReceiver

## Testing

### Local Testing (No Root)
- [ ] Navigate to Lock Screen Verses screen
- [ ] Tap "Refresh Verses" → 10 verses should load
- [ ] Tap "Apply to Lock Screen" → wallpaper should update
- [ ] Lock/unlock device → wallpaper doesn't change (expected without root)

### Root Testing (Device must be rooted with Magisk)
- [ ] Navigate to Root Access screen
- [ ] Tap "Request Root Access" → dialog appears
- [ ] Grant when prompted by Magisk
- [ ] Root Status should show "Device is rooted"
- [ ] Lock device → verse rotates automatically
- [ ] Unlock device → new verse appears
- [ ] Repeat: verses should change each lock cycle

## Build & Deploy

```bash
# Generate models
flutter pub run build_runner build --delete-conflicting-outputs

# Build release APK
flutter build apk --release

# Install
adb install -r build/app/outputs/flutter-apk/app-release.apk

# View logs
flutter logs | grep -E "(LockScreen|Root|verse)"
```

## What Was REMOVED
- ~~Screen saver wallpaper cycling~~ (not found; kept wallpaper features)
- ~~Unnecessary wallpaper rotation~~ (Kept functional for lock screen use)

## What Was ADDED
✅ `lockscreen_verses/` feature (10 random verses)
✅ `RootAccessService` (root detection & commands)
✅ `LockScreenService` (lock/unlock listener)
✅ `LockscreenVersesScreen` (UI for verses)
✅ `RootAccessScreen` (UI for root status)
✅ Android `MainActivity.kt` enhancements
✅ Android manifest permissions
✅ Broadcast receiver for lock events

## Common Issues & Fixes

| Issue | Fix |
|-------|-----|
| `Build failed: random_verse.freezed.dart not found` | Run: `flutter pub run build_runner build --delete-conflicting-outputs` |
| `RootAccessService not found` | Check import: `import '../data/root_access_service.dart';` |
| `Navigation not working` | Add routes to GoRouter config |
| `Verses not loading` | Ensure Bible DB is populated; check: `flutter logs` |
| `Root access denied` | Device may not be rooted; install Magisk first |
| `Verse not rotating on lock` | Root access not granted; check Root Access screen |

## Deployment Notes

🔴 **Critical**: Device must be rooted (Magisk) for auto-rotation
🟡 **Warning**: Rooting voids warranty on most devices
🟢 **Feature**: Manual verse application works without root
🟢 **Performance**: Lock listener has minimal battery impact

## Next Steps After Implementation

1. Test on emulator (rooted): `emulator -avd Pixel_6_Root -writable-system`
2. Test on physical device with Magisk
3. Deploy to Play Store (or F-Droid for FOSS)
4. Gather user feedback on verse rotation feature
5. Consider Magisk module for boot-time setup

---

**Last Updated**: 2026-09-28
**Status**: Ready for implementation
