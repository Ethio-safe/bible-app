import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../shared/widgets/async_value_widget.dart';
import '../../../reader_settings/presentation/reader_settings_sheet.dart';
import '../../domain/entities/chapter.dart';
import '../providers/bible_providers.dart';
import '../providers/chapter_index_provider.dart';
import '../providers/reading_position_provider.dart';
import '../providers/verse_selection_provider.dart';
import '../widgets/chapter_navigator_sheet.dart';
import '../widgets/chapter_text.dart';
import '../widgets/translation_chip.dart';
import '../widgets/verse_action_bar.dart';

/// Continuous reader: horizontal [PageView] across every chapter of the Bible,
/// each page a scrollable chapter with its own collapsing app bar.
class ReaderScreen extends ConsumerStatefulWidget {
  const ReaderScreen({
    super.key,
    required this.bookId,
    required this.chapter,
    this.initialVerse,
  });

  final int bookId;
  final int chapter;
  final int? initialVerse;

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  PageController? _controller;
  ChapterId? _current;
  int? _pendingVerse;
  String? _edition;
  bool _needsRemember = true;

  @override
  void initState() {
    super.initState();
    _current = ChapterId(bookId: widget.bookId, chapter: widget.chapter);
    _pendingVerse = widget.initialVerse;
  }

  @override
  void didUpdateWidget(covariant ReaderScreen old) {
    super.didUpdateWidget(old);
    // Navigated to a new chapter via the navigator/My Stuff while open.
    if (old.bookId != widget.bookId ||
        old.chapter != widget.chapter ||
        old.initialVerse != widget.initialVerse) {
      final target = ChapterId(bookId: widget.bookId, chapter: widget.chapter);
      _pendingVerse = widget.initialVerse;
      final index = ref.read(chapterIndexProvider).valueOrNull;
      if (index != null &&
          index.contains(target) &&
          _controller != null &&
          _controller!.hasClients) {
        _controller!.jumpToPage(index.indexOf(target));
      }
      _current = target;
      _needsRemember = true;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _onPageChanged(ChapterIndex index, int page) {
    final id = index.at(page);
    if (id == _current) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || id == _current) return;
      // Clear selection on the page we're leaving.
      if (_current != null) {
        ref.read(verseSelectionProvider(_current!).notifier).clear();
      }
      setState(() => _current = id);
      ref.read(lastReadChapterProvider.notifier).set(id);
      // Keep the URL in sync without a rebuild-triggering push.
      context.replace(AppRoutes.reader(id.bookId, id.chapter));
    });
  }

  /// Smoothly pages to the chapter [delta] steps away from the current one.
  void _goRelative(ChapterIndex index, int delta) {
    if (_controller == null || !_controller!.hasClients) return;
    final target =
        (_controller!.page ?? _controller!.initialPage).round() + delta;
    if (target < 0 || target >= index.length) return;
    _controller!.animateToPage(
      target,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final edition = ref.watch(currentTranslationKeyProvider);
    if (_edition != null && _edition != edition) {
      final old = _controller;
      _controller = null;
      WidgetsBinding.instance.addPostFrameCallback((_) => old?.dispose());
      _current = ref.read(lastReadChapterProvider);
      _pendingVerse = null;
      _needsRemember = true;
    }
    _edition = edition;
    final indexAsync = ref.watch(chapterIndexProvider);

    if (indexAsync.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: AsyncValueWidget(
        value: indexAsync,
        onRetry: () => ref.invalidate(chapterIndexProvider),
        data: (index) {
          final valid = index.validOrFirst(_current);
          if (valid == null)
            return const ErrorView(
              message: 'No readable books in this edition.',
            );
          if (valid != _current) {
            _current = valid;
            _pendingVerse = null;
            _needsRemember = true;
          }
          if (_needsRemember) {
            _needsRemember = false;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted ||
                  ref.read(currentTranslationKeyProvider) != edition ||
                  _current != valid)
                return;
              ref.read(lastReadChapterProvider.notifier).set(valid);
              if (widget.bookId != valid.bookId ||
                  widget.chapter != valid.chapter ||
                  (widget.initialVerse != null && _pendingVerse == null)) {
                context.replace(AppRoutes.reader(valid.bookId, valid.chapter));
              }
            });
          }
          _controller ??= PageController(initialPage: index.indexOf(_current!));
          return Stack(
            children: [
              PageView.builder(
                key: ValueKey(edition),
                controller: _controller,
                itemCount: index.length,
                onPageChanged: (p) => _onPageChanged(index, p),
                itemBuilder: (context, i) {
                  final id = index.at(i);
                  final verse = id == _current ? _pendingVerse : null;
                  return _ChapterPage(
                    key: ValueKey((edition, id)),
                    id: id,
                    index: index,
                    initialVerse: verse,
                    onVerseConsumed: () => _pendingVerse = null,
                  );
                },
              ),
              if (_current != null) ...[
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _ChapterNavBar(
                    id: _current!,
                    title: index.titleOf(_current!),
                    canGoPrev: index.indexOf(_current!) > 0,
                    canGoNext: index.indexOf(_current!) < index.length - 1,
                    onPrev: () => _goRelative(index, -1),
                    onNext: () => _goRelative(index, 1),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _ActionBarHost(id: _current!),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

/// Bottom pill that shows the current chapter with prev/next navigation and
/// opens the chapter selector on tap. Slides away while verses are selected.
class _ChapterNavBar extends ConsumerWidget {
  const _ChapterNavBar({
    required this.id,
    required this.title,
    required this.canGoPrev,
    required this.canGoNext,
    required this.onPrev,
    required this.onNext,
  });

  final ChapterId id;
  final String title;
  final bool canGoPrev;
  final bool canGoNext;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPassage =
        ref.watch(chapterProvider(id)).valueOrNull?.isPassage ?? false;
    final selecting =
        !isPassage && ref.watch(verseSelectionProvider(id)).isNotEmpty;
    final scheme = Theme.of(context).colorScheme;

    return AnimatedSlide(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      offset: selecting ? const Offset(0, 1.4) : Offset.zero,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: selecting ? 0 : 1,
        child: IgnorePointer(
          ignoring: selecting,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Material(
                elevation: 3,
                color: scheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(28),
                clipBehavior: Clip.antiAlias,
                child: SizedBox(
                  height: 52,
                  child: Row(
                    children: [
                      _NavArrow(
                        icon: Icons.chevron_left,
                        enabled: canGoPrev,
                        onTap: onPrev,
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () =>
                              showChapterNavigatorSheet(context, current: id),
                          child: Center(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 220),
                              transitionBuilder: (child, anim) =>
                                  FadeTransition(
                                    opacity: anim,
                                    child: SlideTransition(
                                      position: Tween(
                                        begin: const Offset(0, 0.25),
                                        end: Offset.zero,
                                      ).animate(anim),
                                      child: child,
                                    ),
                                  ),
                              child: Text(
                                title,
                                key: ValueKey(title),
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ),
                      ),
                      _NavArrow(
                        icon: Icons.chevron_right,
                        enabled: canGoNext,
                        onTap: onNext,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavArrow extends StatelessWidget {
  const _NavArrow({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 56,
      height: 52,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: Icon(
          icon,
          color: enabled
              ? scheme.onSurface
              : scheme.onSurfaceVariant.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}

/// Renders the action bar once the chapter for [id] is loaded.
class _ActionBarHost extends ConsumerWidget {
  const _ActionBarHost({required this.id});
  final ChapterId id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chapter = ref.watch(chapterProvider(id)).valueOrNull;
    if (chapter == null) return const SizedBox.shrink();
    return VerseActionBar(chapter: chapter);
  }
}

class _ChapterPage extends ConsumerStatefulWidget {
  const _ChapterPage({
    super.key,
    required this.id,
    required this.index,
    required this.initialVerse,
    required this.onVerseConsumed,
  });

  final ChapterId id;
  final ChapterIndex index;
  final int? initialVerse;
  final VoidCallback onVerseConsumed;

  @override
  ConsumerState<_ChapterPage> createState() => _ChapterPageState();
}

class _ChapterPageState extends ConsumerState<_ChapterPage> {
  final _scroll = ScrollController();
  final _textKey = GlobalKey<ChapterTextState>();
  Timer? _saveDebounce;
  bool _restored = false;
  late final String _edition;

  @override
  void initState() {
    super.initState();
    _edition = ref.read(currentTranslationKeyProvider);
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted ||
          !_scroll.hasClients ||
          ref.read(currentTranslationKeyProvider) != _edition)
        return;
      ref
          .read(scrollPositionSaverProvider.notifier)
          .save(widget.id, _scroll.offset);
    });
  }

  /// Runs once after the chapter text has laid out.
  Future<void> _restoreOrJump() async {
    if (_restored) return;
    _restored = true;

    if (widget.initialVerse != null) {
      widget.onVerseConsumed();
      _jumpToVerse(widget.initialVerse!);
      return;
    }
    final saved = await ref
        .read(scrollPositionSaverProvider.notifier)
        .restore(widget.id);
    if (!mounted || saved <= 0 || !_scroll.hasClients) return;
    _scroll.jumpTo(saved.clamp(0, _scroll.position.maxScrollExtent));
  }

  void _jumpToVerse(int verse) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients) return;
      final offset = _textKey.currentState?.verseOffset(verse);
      if (offset == null) return;
      // Leave breathing room under the (collapsed) app bar.
      final target = (offset - 24).clamp(0.0, _scroll.position.maxScrollExtent);
      _scroll.animateTo(
        target,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
      ref.read(verseSelectionProvider(widget.id).notifier).select({verse});
    });
  }

  @override
  Widget build(BuildContext context) {
    final chapterAsync = ref.watch(chapterProvider(widget.id));
    final title = widget.index.titleOf(widget.id);

    return CustomScrollView(
      controller: _scroll,
      slivers: [
        SliverAppBar(
          floating: true,
          snap: true,
          title: _TitleButton(
            title: title,
            onTap: () => showChapterNavigatorSheet(context, current: widget.id),
          ),
          actions: [
            const TranslationChip(),
            IconButton(
              tooltip: 'Reader settings',
              icon: const Icon(Icons.text_fields),
              onPressed: () => showReaderSettingsSheet(context),
            ),
            const SizedBox(width: 4),
          ],
        ),
        chapterAsync.when(
          loading: () => const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => SliverFillRemaining(
            child: ErrorView(
              message: '$e',
              onRetry: () => ref.invalidate(chapterProvider(widget.id)),
            ),
          ),
          data: (chapter) {
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => _restoreOrJump(),
            );
            return SliverPadding(
              padding: const EdgeInsets.fromLTRB(28, 8, 20, 160),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 42),
                    Text(
                      widget.index.bookOf(widget.id).name,
                      textAlign: TextAlign.center,
                      style: ReaderTypography.bookName(context),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${widget.id.chapter}',
                      textAlign: TextAlign.center,
                      style: ReaderTypography.chapterNumber(context),
                    ),
                    const SizedBox(height: 26),
                    Text(
                      widget.index.headingOf(widget.id),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 36),
                    ChapterText(key: _textKey, chapter: chapter),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _TitleButton extends StatelessWidget {
  const _TitleButton({required this.title, required this.onTap});
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
      icon: const Icon(Icons.expand_more, size: 20),
      iconAlignment: IconAlignment.end,
      label: Text(title, style: Theme.of(context).appBarTheme.titleTextStyle),
    );
  }
}
