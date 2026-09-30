/// Static catalogue of the translations bundled in `assets/bible/`.
///
/// Bump [bundledDbVersion] whenever the asset databases are rebuilt so that
/// [AssetDbInstaller] re-copies them over any previously installed copy.
class BundledBibles {
  BundledBibles._();

  /// Increment when `tools/build_bible_db.py` output changes.
  static const int bundledDbVersion = 3;

  static const String assetDir = 'assets/bible';

  /// Translation keys → asset file names. Keys are also used as DB file names.
  static const Map<String, String> files = {
    'kjv': 'kjv.db',
    'web': 'web.db',
    'asv': 'asv.db',
    'eot_am': 'eot_am.db',
    'eot_en': 'eot_en.db',
  };

  static const String defaultTranslation = 'kjv';

  static String assetPath(String key) => '$assetDir/${files[key]!}';
}
