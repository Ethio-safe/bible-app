# Lock Screen Verses with Root Access - Implementation Guide

## Overview
This enhancement transforms the Bible app to display 10 random verses on the lock screen dynamically on every lock/unlock event, utilizing root access when available.

## What's Been Added

### 1. **New Feature: Lock Screen Verses** (`lib/features/lockscreen_verses/`)

#### Domain
- `RandomVerse` entity: stores verse book, chapter, verse number, text, and reference

#### Data Layer
- `RandomVersesLocalSource`: caches verses in SharedPreferences
- `RandomVersesRepository`: fetches/manages random verses from Bible database
- `RootAccessService`: handles root access requests and commands
- `LockScreenService`: listens to lock/unlock events

#### Presentation
- `LockscreenVersesScreen`: UI to view and manage 10 random verses
- `RootAccessScreen`: display root status and request root access
- `lockscreen_verses_providers.dart`: Riverpod providers for state management

### 2. **Android Native Enhancement** (`MainActivity.kt`)

Added three MethodChannels:
- **`com.versewall.bible/wallpaper`**: Set wallpapers on lock/home screens
- **`com.versewall.bible/lockscreen`**: Listen to device lock/unlock events
- **`com.versewall.bible/root`**: Request and execute root commands

Added `LockScreenReceiver` BroadcastReceiver that listens to:
- `ACTION_SCREEN_ON`: Screen turned on
- `ACTION_SCREEN_OFF`: Screen turned off (ready to rotate verse)
- `ACTION_USER_PRESENT`: Device unlocked

### 3. **Android Permissions** (AndroidManifest.xml)

```xml
<uses-permission android:name="android.permission.DISABLE_KEYGUARD"/>
<uses-permission android:name="android.permission.WRITE_SECURE_SETTINGS"/>
<uses-permission android:name="android.permission.WAKE_LOCK"/>
```

## How It Works

### Without Root
1. User opens the app and can view 10 random verses
2. Can manually apply verses to lock screen wallpaper
3. Updates require user action

### With Root Access
1. User grants root access via Magisk/SuperSU
2. App listens to device lock/unlock events
3. On every lock, a new random verse is automatically displayed
4. Changes happen instantly without user interaction
5. Verses are cached for fast rotation

## Integration Steps

### 1. Generate Freezed Models
```bash
cd /Users/melion/Documents/bible
flutter pub run build_runner build --delete-conflicting-outputs
```

This generates:
- `random_verse.freezed.dart`
- `random_verse.g.dart` (JSON serialization)

### 2. Update Main Navigation
Add to your router configuration in `main.dart` or navigation provider:

```dart
GoRoute(
  path: '/lockscreen-verses',
  builder: (context, state) => const LockscreenVersesScreen(),
),
GoRoute(
  path: '/root-access',
  builder: (context, state) => const RootAccessScreen(),
),
```

### 3. Add to Settings Menu
In `settings_screen.dart`, add a new ListTile:

```dart
ListTile(
  leading: const Icon(Icons.lock),
  title: const Text('Lock Screen Verses'),
  subtitle: const Text('Dynamic verses on lock/unlock'),
  onTap: () => context.push('/lockscreen-verses'),
),
ListTile(
  leading: const Icon(Icons.security),
  title: const Text('Root Access'),
  onTap: () => context.push('/root-access'),
),
```

### 4. Remove Unnecessary Wallpaper Features (Optional)
If you want to remove unused wallpaper screens:
- Comment out `wallpaper_screen.dart` from main navigation
- Keep `wallpaper_applier.dart` and `wallpaper_composer.dart` (used by lock screen verses)

### 5. Build & Deploy

```bash
# Build APK
flutter build apk --release

# Install
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

## Features

✅ **Fetch 10 Random Verses**: Pulls from Bible database
✅ **Cache Locally**: Stored in SharedPreferences  
✅ **Display on Lock Screen**: Applied as wallpaper
✅ **Root Access Detection**: Checks if device is rooted
✅ **Request Root**: Prompts user via su binary
✅ **Lock/Unlock Listener**: Broadcast receiver triggers on screen events
✅ **Dynamic Rotation**: Changes verse on every lock (with root)

## Root Access Flow

```
User clicks "Request Root Access"
    ↓
RootAccessService.requestRoot()
    ↓
Runtime.getRuntime().exec("su") - prompts Magisk/SuperSU dialog
    ↓
User grants access (or denies)
    ↓
isRooted() = true (on grant)
    ↓
LockScreenReceiver activates
    ↓
On screen-off: rotates to next verse
On unlock: displays current verse
```

## Troubleshooting

### Device Not Rooted?
- Install Magisk from https://topjohnwu.github.io/Magisk/
- Verses will still work manually via UI, but won't auto-rotate

### Verses Not Showing?
- Ensure Bible data is loaded (required by RandomVersesRepository)
- Check Logcat: `flutter logs | grep "LockScreen"`

### Root Permission Denied?
- Make sure to grant when prompted
- Some devices have restricted root access
- Try Superuser/SuperSU alternative

## Next Steps (Optional Enhancements)

1. **Create Live Wallpaper Service**: For independent rotation without app running
2. **Add Verse Customization**: Filter by Bible version, book, or length
3. **Create Magisk Module**: Auto-apply on boot
4. **Add Analytics**: Track verse views and user engagement
5. **Verse Scheduling**: Different verses at different times of day

## File Structure

```
lib/features/lockscreen_verses/
├── domain/
│   └── entities/
│       └── random_verse.dart          # Verse model
├── data/
│   ├── datasources/
│   │   └── random_verses_local_source.dart
│   ├── random_verses_repository.dart
│   ├── root_access_service.dart       # Root commands
│   └── lockscreen_service.dart        # Lock listener
└── presentation/
    ├── providers/
    │   └── lockscreen_verses_providers.dart
    └── screens/
        ├── lockscreen_verses_screen.dart
        └── root_access_screen.dart
```

## Important Notes

⚠️ **Root Required for Full Features**: Without root, verses won't rotate automatically on lock/unlock
⚠️ **Device Warranty**: Rooting may void warranty
⚠️ **Knox Security**: Samsung Knox may be tripped; use carefully
⚠️ **Battery Impact**: Lock listener consumes minimal battery (BroadcastReceiver)

## Testing

Test the flow:
1. Tap "Lock Screen Verses" in settings
2. View 10 random verses
3. Tap "Refresh Verses" to get new ones
4. Tap "Apply to Lock Screen" to set current verse
5. Go to Root Access screen
6. Tap "Request Root Access"
7. Grant when prompted
8. Lock device - verse should rotate
9. Unlock device - observe new verse on wallpaper

---

**Removed**: Screen saver wallpaper cycling
**Added**: Dynamic lock screen verses on every lock/unlock with root access
