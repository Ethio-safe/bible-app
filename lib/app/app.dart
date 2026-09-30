import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/bible/presentation/providers/bible_providers.dart';
import '../features/reader_settings/domain/reader_style.dart';
import '../features/reader_settings/presentation/reader_style_provider.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class _AppMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const _AppMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      locale.languageCode == 'en' || locale.languageCode == 'am';

  @override
  Future<MaterialLocalizations> load(Locale locale) async =>
      const DefaultMaterialLocalizations();

  @override
  bool shouldReload(_AppMaterialLocalizationsDelegate old) => false;
}

class _AppCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const _AppCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      locale.languageCode == 'en' || locale.languageCode == 'am';

  @override
  Future<CupertinoLocalizations> load(Locale locale) async =>
      const DefaultCupertinoLocalizations();

  @override
  bool shouldReload(_AppCupertinoLocalizationsDelegate old) => false;
}

class VerseBibleApp extends ConsumerWidget {
  const VerseBibleApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readerTheme = ref.watch(
      readerStyleNotifierProvider.select((s) => s.theme),
    );
    final translation = ref.watch(currentTranslationProvider).valueOrNull;
    final locale = Locale(translation?.language == 'am' ? 'am' : 'en');
    final router = ref.watch(appRouterProvider);

    final themeMode = switch (readerTheme) {
      ReaderTheme.system => ThemeMode.system,
      ReaderTheme.light || ReaderTheme.sepia => ThemeMode.light,
      ReaderTheme.dark => ThemeMode.dark,
    };

    return MaterialApp.router(
      title: 'Verse Bible',
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: const [Locale('en'), Locale('am')],
      localizationsDelegates: const [
        _AppMaterialLocalizationsDelegate(),
        _AppCupertinoLocalizationsDelegate(),
        DefaultWidgetsLocalizations.delegate,
      ],
      theme: readerTheme == ReaderTheme.sepia
          ? AppTheme.sepia()
          : AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
