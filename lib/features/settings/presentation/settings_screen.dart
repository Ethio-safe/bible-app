import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../app/router.dart';
import '../../../core/backup/backup_service.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../../automation/presentation/providers/automation_providers.dart';
import '../../bible/presentation/providers/bible_providers.dart';
import '../../bible/presentation/widgets/translation_chip.dart';
import '../../profile/presentation/providers/profile_providers.dart';
import '../../reader_settings/domain/reader_style.dart';
import '../../reader_settings/presentation/reader_settings_sheet.dart';
import '../../reader_settings/presentation/reader_style_provider.dart';
import 'providers/notification_settings_provider.dart';

/// Grouped settings list in the style of the reference design: bold section
/// headers, plain rows with a muted value line, and blue toggles.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 40),
        children: const [
          _Section('Account', [_AccountRows()]),
          _Section('General', [_GeneralRows()]),
          _Section('Bible reading', [_ReadingRows()]),
          _Section('Wallpaper', [_WallpaperRows()]),
          _Section('Verse of the Day', [_NotificationRows()]),
          _Section('More', [_DataRows(), _AboutRows()]),
        ],
      ),
    );
  }
}

// ── Sections ────────────────────────────────────────────────────────────────

class _AccountRows extends ConsumerWidget {
  const _AccountRows();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(displayNameProvider);
    final account = ref.watch(authStateProvider);
    final notifier = ref.read(authStateProvider.notifier);

    return Column(
      children: [
        _Row(
          title: 'Edit Profile',
          value: name.isEmpty ? 'Add your name' : name,
          onTap: () => context.push(AppRoutes.editProfile),
        ),
        _Row(
          title: 'Google account',
          value: account == null
              ? 'Sign in to save your data to a Google account'
              : 'Signed in as ${account.email}',
          onTap: account == null ? notifier.signIn : notifier.signOut,
        ),
      ],
    );
  }
}

class _GeneralRows extends ConsumerWidget {
  const _GeneralRows();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translations = ref.watch(translationsProvider);
    final current = ref.watch(currentTranslationKeyProvider);
    final theme = ref.watch(readerStyleNotifierProvider.select((s) => s.theme));
    final currentName =
        translations.valueOrNull
            ?.where((t) => t.key == current)
            .map((t) => '${t.name} (${t.abbreviation})')
            .firstOrNull ??
        '…';

    return Column(
      children: [
        _Row(
          title: 'Bible version',
          value: currentName,
          onTap: () => showTranslationPicker(context),
        ),
        _Row(
          title: 'Appearance',
          value: theme.label,
          onTap: () => _pick<ReaderTheme>(
            context,
            title: 'Appearance',
            values: ReaderTheme.values,
            label: (t) => t.label,
            current: theme,
            onSelected: (t) =>
                ref.read(readerStyleNotifierProvider.notifier).setTheme(t),
          ),
        ),
      ],
    );
  }
}

class _ReadingRows extends ConsumerWidget {
  const _ReadingRows();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final style = ref.watch(readerStyleNotifierProvider);
    return _Row(
      title: 'Font',
      value:
          '${style.font.label} · ${style.fontSize.round()} pt · '
          '${style.lineHeight.toStringAsFixed(1)} spacing',
      onTap: () => showReaderSettingsSheet(context),
    );
  }
}

class _WallpaperRows extends ConsumerStatefulWidget {
  const _WallpaperRows();

  @override
  ConsumerState<_WallpaperRows> createState() => _WallpaperRowsState();
}

class _WallpaperRowsState extends ConsumerState<_WallpaperRows>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Coming back from the system wallpaper picker → re-check status.
    if (state == AppLifecycleState.resumed) {
      ref.read(liveWallpaperActiveProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(automationSettingsNotifierProvider);
    final active = ref.watch(liveWallpaperActiveProvider).valueOrNull ?? false;
    final setup = ref.watch(liveWallpaperSetupProvider);

    ref.listen(liveWallpaperSetupProvider, (prev, next) {
      final messenger = ScaffoldMessenger.of(context);
      next.whenOrNull(
        data: (n) {
          if (n == null) return;
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                'Ready: $n verse wallpapers. Lock your phone to see the next '
                'one.',
              ),
            ),
          );
        },
        error: (e, _) => messenger.showSnackBar(
          SnackBar(content: Text('Could not prepare wallpapers: $e')),
        ),
      );
    });

    final String liveStatus;
    if (kIsWeb || !Platform.isAndroid) {
      liveStatus = 'Android only';
    } else if (settings.liveMode) {
      liveStatus = 'On · new verse every time you lock the screen';
    } else {
      liveStatus = 'Off';
    }

    return Column(
      children: [
        _Row(
          title: 'Wallpaper gallery',
          value: 'Pick a photo and verse, set it as wallpaper',
          onTap: () => context.push(AppRoutes.wallpaper),
        ),
        _ToggleRow(
          title: 'Change on every lock',
          value: liveStatus,
          enabled: !kIsWeb && Platform.isAndroid && !setup.isLoading,
          on: !kIsWeb && Platform.isAndroid && settings.liveMode,
          trailing: setup.isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : null,
          onChanged: (v) async {
            final notifier = ref.read(liveWallpaperSetupProvider.notifier);
            if (v) {
              await notifier.prepare(View.of(context).physicalSize);
            } else {
              await notifier.disable();
            }
          },
        ),
        if (!kIsWeb && Platform.isAndroid && settings.liveMode)
          _Row(
            title: 'Also use as home-screen live wallpaper',
            value: active
                ? 'Active'
                : 'Select "Verse Bible" in the system wallpaper picker',
            onTap: active
                ? null
                : () => ref.read(liveWallpaperServiceProvider).openChooser(),
          ),
        _Row(
          title: 'Automatic rotation',
          value: settings.enabled
              ? 'On · ${settings.interval.label.toLowerCase()}'
              : 'Off',
          onTap: () => context.push(AppRoutes.automation),
        ),
      ],
    );
  }
}

class _NotificationRows extends ConsumerWidget {
  const _NotificationRows();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(notificationSettingsNotifierProvider);
    final notifier = ref.read(notificationSettingsNotifierProvider.notifier);
    final timeLabel = MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(settings.time, alwaysUse24HourFormat: false);

    return Column(
      children: [
        _ToggleRow(
          title: 'Daily reminder',
          value: settings.enabled ? 'At $timeLabel' : 'Off',
          on: settings.enabled,
          onChanged: (v) async {
            final ok = await notifier.setEnabled(v);
            if (!ok && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Notifications are blocked. Enable them in system settings.',
                  ),
                ),
              );
            }
          },
        ),
        if (settings.enabled)
          _Row(
            title: 'Reminder time',
            value: timeLabel,
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: settings.time,
              );
              if (picked != null) await notifier.setTime(picked);
            },
          ),
      ],
    );
  }
}

class _DataRows extends ConsumerWidget {
  const _DataRows();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backup = ref.read(backupServiceProvider);
    void toast(String msg) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }

    return Column(
      children: [
        _Row(
          title: 'Export backup',
          value: 'Highlights, bookmarks and notes',
          onTap: () async {
            try {
              final s = await backup.exportAndShare();
              toast('Exported ${s.total} items');
            } catch (e) {
              toast('Export failed: $e');
            }
          },
        ),
        _Row(
          title: 'Import backup',
          onTap: () async {
            try {
              final n = await backup.pickAndImport();
              if (n != null) toast('Imported $n items');
            } on FormatException catch (e) {
              toast(e.message);
            } catch (e) {
              toast('Import failed: $e');
            }
          },
        ),
      ],
    );
  }
}

class _AboutRows extends StatelessWidget {
  const _AboutRows();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Row(
          title: 'Bible text sources & licenses',
          onTap: () => context.push(AppRoutes.licenses),
        ),
        _Row(
          title: 'Open-source licenses',
          onTap: () =>
              showLicensePage(context: context, applicationName: 'Verse Bible'),
        ),
        FutureBuilder<PackageInfo>(
          future: PackageInfo.fromPlatform(),
          builder: (context, snap) => _Row(
            title: 'Version',
            value: snap.hasData
                ? '${snap.data!.version} (${snap.data!.buildNumber})'
                : '…',
            showChevron: false,
            onTap: snap.hasData
                ? () =>
                      Clipboard.setData(ClipboardData(text: snap.data!.version))
                : null,
          ),
        ),
      ],
    );
  }
}

// ── Building blocks ─────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section(this.title, this.children);
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 6),
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        ...children,
        const Padding(padding: EdgeInsets.only(top: 16), child: Divider()),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.title,
    this.value,
    this.onTap,
    this.showChevron = false,
  });
  final String title;
  final String? value;
  final VoidCallback? onTap;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (value != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      value!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (showChevron)
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
          ],
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.title,
    required this.on,
    required this.onChanged,
    this.value,
    this.enabled = true,
    this.trailing,
  });
  final String title;
  final String? value;
  final bool on;
  final bool enabled;
  final Widget? trailing;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: enabled ? () => onChanged(!on) : null,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (value != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      value!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            trailing ??
                Switch(value: on, onChanged: enabled ? onChanged : null),
          ],
        ),
      ),
    );
  }
}

Future<void> _pick<T>(
  BuildContext context, {
  required String title,
  required List<T> values,
  required String Function(T) label,
  String Function(T)? subtitle,
  required T current,
  required void Function(T) onSelected,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: Theme.of(
                  ctx,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          for (final v in values)
            ListTile(
              title: Text(label(v)),
              subtitle: subtitle == null ? null : Text(subtitle(v)),
              trailing: v == current
                  ? Icon(
                      Icons.check,
                      color: Theme.of(ctx).colorScheme.onSurface,
                    )
                  : null,
              onTap: () {
                onSelected(v);
                Navigator.pop(ctx);
              },
            ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}
