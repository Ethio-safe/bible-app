import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/notifications/notification_service.dart';
import '../features/ai/presentation/screens/ai_history_screen.dart';
import '../features/ai/presentation/screens/ai_screen.dart';
import '../features/automation/presentation/screens/automation_screen.dart';
import '../features/bible/presentation/providers/bible_providers.dart';
import '../features/bible/presentation/providers/chapter_index_provider.dart';
import '../features/bible/presentation/providers/reading_position_provider.dart';
import '../features/bible/presentation/screens/books_screen.dart';
import '../features/bible/presentation/screens/chapters_screen.dart';
import '../features/bible/presentation/screens/reader_screen.dart';
import '../features/bible/presentation/screens/search_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/profile/presentation/screens/edit_profile_screen.dart';
import '../features/profile/presentation/screens/you_screen.dart';
import '../features/settings/presentation/bible_licenses_screen.dart';
import '../features/settings/presentation/providers/notification_settings_provider.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/votd/presentation/providers/votd_providers.dart';
import '../features/votd/presentation/screens/votd_notifications_screen.dart';
import '../features/wallpaper/presentation/screens/wallpaper_preview_screen.dart';
import '../features/wallpaper/presentation/screens/wallpaper_screen.dart';
import 'home_shell.dart';

part 'router.g.dart';

/// Central route table. Paths are kept in [AppRoutes] so screens never
/// hard-code strings.
class AppRoutes {
  AppRoutes._();

  static const home = '/home';
  static const read = '/read';
  static const you = '/you';
  static const editProfile = '$you/edit';
  static const aiHistory = '/ai/history';

  // Pushed above the tab shell (no bottom bar).
  static const settings = '/settings';
  static const licenses = '$settings/licenses';
  static const wallpaper = '$settings/wallpaper';
  static const wallpaperPreview = '$wallpaper/preview';
  static const automation = '$settings/automation';
  static const notifications = '/notifications';

  static const search = '$read/search';

  static String chapters(int bookId) => '$read/book/$bookId';

  /// [verse] scrolls to and briefly selects that verse.
  static String reader(int bookId, int chapter, {int? verse}) =>
      '$read/book/$bookId/chapter/$chapter${verse == null ? '' : '?verse=$verse'}';
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  // Open on Home; a tapped verse-of-the-day notification deep-links to it.
  final service = NotificationService.instance;
  final openDaily = service.launchPayload == NotificationService.votdPayload;
  service.launchPayload = null;

  // Keep the scheduled reminder's text fresh for the next firing day.
  Future.microtask(() => ref.read(votdSchedulerProvider).sync());

  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.home,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => HomeShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.read,
                // Tapping the Bible tab jumps straight into the reader at the
                // most recently read chapter (falling back to Genesis 1).
                redirect: (context, state) async {
                  if (state.uri.path != AppRoutes.read) return null;
                  try {
                    final index = await ref.read(chapterIndexProvider.future);
                    final last = index.validOrFirst(
                      ref.read(lastReadChapterProvider),
                    );
                    return last == null
                        ? null
                        : AppRoutes.reader(last.bookId, last.chapter);
                  } catch (_) {
                    // Never block opening the Bible tab if indexing fails.
                    return null;
                  }
                },
                builder: (context, state) => const BooksScreen(),
                routes: [
                  GoRoute(
                    path: 'search',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => const SearchScreen(),
                  ),
                  GoRoute(
                    path: 'book/:bookId',
                    builder: (context, state) => ChaptersScreen(
                      bookId: int.parse(state.pathParameters['bookId']!),
                    ),
                    routes: [
                      GoRoute(
                        path: 'chapter/:chapter',
                        builder: (context, state) => ReaderScreen(
                          bookId: int.parse(state.pathParameters['bookId']!),
                          chapter: int.parse(state.pathParameters['chapter']!),
                          initialVerse: int.tryParse(
                            state.uri.queryParameters['verse'] ?? '',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/ai',
                builder: (context, state) => const AiScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.you,
                builder: (context, state) => const YouScreen(),
                routes: [
                  GoRoute(
                    path: 'edit',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => const EditProfileScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.aiHistory,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AiHistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const VotdNotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: 'licenses',
            builder: (context, state) => const BibleLicensesScreen(),
          ),
          GoRoute(
            path: 'wallpaper',
            builder: (context, state) => const WallpaperScreen(),
            routes: [
              GoRoute(
                path: 'preview',
                builder: (context, state) => const WallpaperPreviewScreen(),
              ),
            ],
          ),
          GoRoute(
            path: 'automation',
            builder: (context, state) => const AutomationScreen(),
          ),
        ],
      ),
    ],
  );

  var disposed = false;
  service.onTap = (payload) async {
    if (payload == NotificationService.votdPayload) {
      final edition = ref.read(currentTranslationKeyProvider);
      try {
        final daily = await ref.read(
          resolvePoolVerseProvider(verseForDate(DateTime.now())).future,
        );
        if (disposed || ref.read(currentTranslationKeyProvider) != edition)
          return;
        final v = daily.pool;
        router.push(AppRoutes.reader(v.bookId, v.chapter, verse: v.verse));
      } catch (_) {
        if (!disposed) router.go(AppRoutes.home);
      }
    }
  };
  if (openDaily) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!disposed) service.onTap?.call(NotificationService.votdPayload);
    });
  }
  ref.onDispose(() {
    disposed = true;
    service.onTap = null;
    router.dispose();
  });
  return router;
}
