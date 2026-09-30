import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/user_database.dart';
import '../../../bible/presentation/providers/bible_providers.dart';
import '../../../wallpaper/data/wallpaper_applier.dart';
import '../../../wallpaper/domain/entities/wallpaper_image.dart';
import '../../data/rotation_scheduler.dart';
import '../../domain/automation_settings.dart';
import '../providers/automation_providers.dart';

class AutomationScreen extends ConsumerWidget {
  const AutomationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(automationSettingsNotifierProvider);
    final n = ref.read(automationSettingsNotifierProvider.notifier);
    final refresh = ref.watch(refreshNowControllerProvider);
    final remoteOk = ref.watch(remoteConfiguredProvider);
    final status = ref.watch(rotationStatusProvider);
    final stats = ref.watch(poolStatsProvider);

    ref.listen(refreshNowControllerProvider, (prev, next) {
      final messenger = ScaffoldMessenger.of(context);
      next.whenOrNull(
        data: (r) {
          if (r == null) return;
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                !kIsWeb && Platform.isIOS
                    ? 'Saved to Photos — set it from the Photos app.'
                    : 'Wallpaper updated (${r.template.label}).',
              ),
            ),
          );
        },
        error: (e, _) => messenger.showSnackBar(
          SnackBar(content: Text('Refresh failed: $e')),
        ),
      );
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Automation')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          if (!kIsWeb && Platform.isIOS)
            const _Notice(
              icon: Icons.info_outline,
              text:
                  'iOS does not allow apps to change the wallpaper. Automatic '
                  'rotation saves a fresh image to Photos and updates the lock-'
                  'screen widget; use Shortcuts → "Set Wallpaper" to automate.',
            ),
          if (!kIsWeb && Platform.isAndroid && s.liveMode)
            const _Notice(
              icon: Icons.lock_clock_outlined,
              text:
                  '"Change on every lock" is on. Each rotation re-renders the '
                  'set of lock-screen wallpapers instead of setting a single '
                  'image, so the "Apply to" option does not apply.',
            ),
          SwitchListTile(
            title: const Text('Rotate wallpaper automatically'),
            subtitle: Text(_statusLine(status)),
            value: s.enabled,
            onChanged: n.setEnabled,
          ),
          ListTile(
            enabled: s.enabled,
            title: const Text('Interval'),
            subtitle: Text(s.interval.label),
            onTap: () => _pick<RotationInterval>(
              context,
              title: 'Rotate every',
              values: RotationInterval.values,
              label: (v) => v.label,
              current: s.interval,
              onSelected: n.setInterval,
            ),
          ),
          if (!kIsWeb && Platform.isAndroid && !s.liveMode)
            ListTile(
              enabled: s.enabled,
              title: const Text('Apply to'),
              subtitle: Text(_targetLabel(s.target)),
              onTap: () => _pick<WallpaperTarget>(
                context,
                title: 'Apply to',
                values: WallpaperTarget.values,
                label: _targetLabel,
                current: s.target,
                onSelected: n.setTarget,
              ),
            ),
          ListTile(
            enabled: s.enabled,
            title: const Text('Text layout'),
            subtitle: Text(
              s.templateName == null
                  ? 'Vary each time'
                  : WallpaperTemplate.values
                        .firstWhere((t) => t.name == s.templateName)
                        .label,
            ),
            onTap: () => _pick<String?>(
              context,
              title: 'Text layout',
              values: [null, ...WallpaperTemplate.values.map((t) => t.name)],
              label: (v) => v == null
                  ? 'Vary each time'
                  : WallpaperTemplate.values
                        .firstWhere((t) => t.name == v)
                        .label,
              current: s.templateName,
              onSelected: n.setTemplate,
            ),
          ),
          const _Header('Fresh images'),
          if (!remoteOk)
            const _Notice(
              icon: Icons.key_off_outlined,
              text:
                  'No image API key compiled in. Rotation uses the built-in '
                  'gallery only. Build with --dart-define=UNSPLASH_KEY=… or '
                  'PEXELS_KEY=… to download new photos.',
            ),
          SwitchListTile(
            title: const Text('Download new photos'),
            subtitle: const Text('From Unsplash / Pexels, with attribution'),
            value: s.remoteEnabled && remoteOk,
            onChanged: remoteOk ? n.setRemoteEnabled : null,
          ),
          SwitchListTile(
            title: const Text('Wi-Fi only'),
            value: s.wifiOnly,
            onChanged: remoteOk && s.remoteEnabled ? n.setWifiOnly : null,
          ),
          ListTile(
            enabled: remoteOk && s.remoteEnabled,
            title: const Text('Photo style'),
            subtitle: Text(s.category.label),
            onTap: () => _pick<ImageCategory>(
              context,
              title: 'Photo style',
              values: ImageCategory.values,
              label: (v) => v.label,
              current: s.category,
              onSelected: n.setCategory,
            ),
          ),
          ListTile(
            title: const Text('Keep at most'),
            subtitle: Text(
              '${s.poolSize} images'
              '${stats.valueOrNull == null ? '' : ' · now ${stats.value!.count} '
                        '(${_mb(stats.value!.bytes)})'}',
            ),
            onTap: () => _pick<int>(
              context,
              title: 'Keep at most',
              values: AutomationSettings.poolSizeOptions,
              label: (v) => '$v images',
              current: s.poolSize,
              onSelected: n.setPoolSize,
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: FilledButton.icon(
              onPressed: refresh.isLoading
                  ? null
                  : () => ref
                        .read(refreshNowControllerProvider.notifier)
                        .run(View.of(context).physicalSize),
              icon: refresh.isLoading
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
              label: Text(refresh.isLoading ? 'Working…' : 'Refresh now'),
            ),
          ),
          if (status.lastError != null)
            _Notice(
              icon: Icons.error_outline,
              text: 'Last background run failed: ${status.lastError}',
            ),
          const _Header('History'),
          const _HistoryList(),
        ],
      ),
    );
  }

  static String _statusLine(({DateTime? lastRun, String? lastError}) st) {
    if (st.lastRun == null) return 'Never run yet';
    return 'Last run ${DateFormat.yMMMd().add_jm().format(st.lastRun!)}';
  }

  static String _targetLabel(WallpaperTarget t) => switch (t) {
    WallpaperTarget.lock => 'Lock screen',
    WallpaperTarget.home => 'Home screen',
    WallpaperTarget.both => 'Lock & home screen',
  };

  static String _mb(int bytes) =>
      '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';

  static Future<void> _pick<T>(
    BuildContext context, {
    required String title,
    required List<T> values,
    required String Function(T) label,
    required T current,
    required Future<void> Function(T) onSelected,
  }) async {
    final chosen = await showModalBottomSheet<_Choice<T>>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(title, style: Theme.of(ctx).textTheme.titleMedium),
            ),
            for (final v in values)
              RadioListTile<T>(
                title: Text(label(v)),
                value: v,
                // ignore: deprecated_member_use
                groupValue: current,
                // ignore: deprecated_member_use
                onChanged: (_) => Navigator.pop(ctx, _Choice(v)),
              ),
          ],
        ),
      ),
    );
    if (chosen != null) await onSelected(chosen.value);
  }
}

class _Choice<T> {
  const _Choice(this.value);
  final T value;
}

class _Header extends StatelessWidget {
  const _Header(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
    child: Text(
      text,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: Theme.of(context).colorScheme.primary,
      ),
    ),
  );
}

class _Notice extends StatelessWidget {
  const _Notice({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
    color: Theme.of(context).colorScheme.surfaceContainerHighest,
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    ),
  );
}

class _HistoryList extends ConsumerWidget {
  const _HistoryList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(wallpaperHistoryProvider);
    final books = ref.watch(booksProvider).valueOrNull;
    return history.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: LinearProgressIndicator(),
      ),
      error: (e, _) => ListTile(title: Text('$e')),
      data: (rows) {
        if (rows.isEmpty) {
          return const ListTile(
            title: Text('No rotations yet'),
            subtitle: Text('Tap "Refresh now" to try it.'),
          );
        }
        return Column(
          children: [for (final r in rows) _HistoryTile(row: r, books: books)],
        );
      },
    );
  }
}

class _HistoryTile extends ConsumerWidget {
  const _HistoryTile({required this.row, required this.books});
  final WallpaperHistoryRow row;
  final List? books;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookName =
        books
            ?.where((b) => b.id == row.bookId)
            .map((b) => b.name as String)
            .firstOrNull ??
        'Book ${row.bookId}';
    final when = DateFormat.MMMd().add_jm().format(row.appliedAt);
    return ListTile(
      leading: Icon(
        row.success ? Icons.check_circle_outline : Icons.error_outline,
        color: row.success
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.error,
      ),
      title: Text('$bookName ${row.chapter}:${row.verse}'),
      subtitle: Text(
        '$when · ${row.trigger} · ${row.template}'
        '${row.error == null ? '' : '\n${row.error}'}',
      ),
      isThreeLine: row.error != null,
      dense: true,
    );
  }
}

/// Keeps [RotationTasks.prefScreenW/H] fresh; mount once near the app root.
class ScreenSizeRecorder extends StatefulWidget {
  const ScreenSizeRecorder({super.key, required this.child});
  final Widget child;
  @override
  State<ScreenSizeRecorder> createState() => _ScreenSizeRecorderState();
}

class _ScreenSizeRecorderState extends State<ScreenSizeRecorder> {
  bool _done = false;
  @override
  Widget build(BuildContext context) {
    if (!_done) {
      _done = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) rememberScreenSize(context);
      });
    }
    return widget.child;
  }
}
