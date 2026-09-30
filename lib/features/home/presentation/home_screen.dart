import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_theme.dart';
import '../../bible/presentation/providers/bible_providers.dart';
import '../../bible/presentation/providers/reading_position_provider.dart';
import '../../bible/presentation/widgets/translation_chip.dart';
import '../../profile/presentation/providers/profile_providers.dart';
import '../../votd/presentation/providers/votd_providers.dart';
import '../../wallpaper/presentation/providers/wallpaper_providers.dart';

/// "Today" tab: greeting, Verse of the Day hero, continue reading, shortcuts.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(displayNameProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Container(
                  height: 3,
                  width: 44,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          const TranslationChip(),
          IconButton(
            tooltip: 'Notifications',
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push(AppRoutes.notifications),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text(
            name.isEmpty
                ? greetingFor(DateTime.now())
                : '${greetingFor(DateTime.now())}, $name',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          const _VerseOfTheDayHero(),
          const SizedBox(height: 16),
          const _ContinueReadingCard(),
          const SizedBox(height: 28),
          Text(
            'More for you',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          _ShortcutCard(
            icon: Icons.wallpaper_outlined,
            title: 'Verse wallpapers',
            subtitle: 'Turn any verse into a lock-screen wallpaper',
            onTap: () => context.push(AppRoutes.wallpaper),
          ),
          const SizedBox(height: 12),
          _ShortcutCard(
            icon: Icons.autorenew,
            title: 'Automatic wallpaper',
            subtitle: 'A new verse every time you lock your phone',
            onTap: () => context.push(AppRoutes.automation),
          ),
          const SizedBox(height: 12),
          _ShortcutCard(
            icon: Icons.search,
            title: 'Search the Bible',
            subtitle: 'Find any word, phrase or reference',
            onTap: () => context.push(AppRoutes.search),
          ),
        ],
      ),
    );
  }
}

// ── Widgets ─────────────────────────────────────────────────────────────────

/// Full-bleed photo card with the verse in serif, like the reference design.
class _VerseOfTheDayHero extends ConsumerWidget {
  const _VerseOfTheDayHero();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final votd = ref.watch(verseOfTheDayProvider);
    final images = ref.watch(wallpaperImagesProvider).valueOrNull;
    final theme = Theme.of(context);

    // Stable image for the day so the card doesn't change on every rebuild.
    String? bgPath;
    if (images != null && images.isNotEmpty) {
      final day = DateTime.now().difference(DateTime(2024)).inDays;
      bgPath = images[day % images.length].path;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        constraints: const BoxConstraints(minHeight: 300),
        color: theme.colorScheme.surfaceContainer,
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            if (bgPath != null)
              Positioned.fill(
                child: Image.file(
                  File(bgPath),
                  fit: BoxFit.cover,
                  cacheWidth: 900,
                  gaplessPlayback: true,
                ),
              ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.35),
                      Colors.black.withValues(alpha: 0.15),
                      Colors.black.withValues(alpha: 0.55),
                    ],
                  ),
                ),
              ),
            ),
            votd.when(
              loading: () => const SizedBox(
                height: 300,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(20),
                child: Text('Verse of the day unavailable: $e'),
              ),
              data: (v) => InkWell(
                onTap: () => context.push(
                  AppRoutes.reader(
                    v.book.id,
                    v.pool.chapter,
                    verse: v.pool.verse,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Verse of the Day',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${v.reference} ${v.translationAbbreviation}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        v.text,
                        style: ReaderTypography.quote(
                          context,
                          size: v.text.length > 160 ? 19 : 23,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _HeroAction(
                            icon: Icons.menu_book_outlined,
                            label: 'Read',
                            onTap: () => context.push(
                              AppRoutes.reader(
                                v.book.id,
                                v.pool.chapter,
                                verse: v.pool.verse,
                              ),
                            ),
                          ),
                          _HeroAction(
                            icon: Icons.wallpaper_outlined,
                            label: 'Wallpaper',
                            onTap: () {
                              final list = images;
                              if (list == null || list.isEmpty) return;
                              ref
                                  .read(previewControllerProvider.notifier)
                                  .start(
                                    imageId: list.first.id,
                                    source: const VotdQuoteSource(),
                                  );
                              context.push(AppRoutes.wallpaperPreview);
                            },
                          ),
                          _HeroAction(
                            icon: Icons.ios_share,
                            label: 'Share',
                            onTap: () => SharePlus.instance.share(
                              ShareParams(
                                text: v.shareText,
                                subject: v.reference,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroAction extends StatelessWidget {
  const _HeroAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContinueReadingCard extends ConsumerWidget {
  const _ContinueReadingCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final last = ref.watch(lastReadChapterProvider);
    final books = ref.watch(booksProvider).valueOrNull;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final String title;
    final String subtitle;
    final VoidCallback onTap;
    if (last != null && books != null) {
      final book = books.where((b) => b.id == last.bookId).firstOrNull;
      title = '${book?.name ?? 'Bible'} ${last.chapter}';
      subtitle = 'Continue reading';
      onTap = () => context.push(AppRoutes.reader(last.bookId, last.chapter));
    } else {
      title = 'Start reading';
      subtitle = 'Pick a book to begin';
      onTap = () => context.go(AppRoutes.read);
    }

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.play_arrow_rounded, color: scheme.onSurface),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subtitle,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShortcutCard extends StatelessWidget {
  const _ShortcutCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 30, color: scheme.onSurface),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
