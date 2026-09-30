# Flutter / plugins
-keep class io.flutter.** { *; }
-keep class com.versewall.bible.** { *; }
# flutter_local_notifications (Gson reflection)
-keep class com.dexterous.** { *; }
-keepattributes *Annotation*
-keepclassmembers class * { @com.google.gson.annotations.SerializedName <fields>; }
# workmanager
-keep class be.tramckrijte.workmanager.** { *; }
-keep class androidx.work.** { *; }
# home_widget
-keep class es.antonborri.home_widget.** { *; }
# Play Core (deferred components) is not used
-dontwarn com.google.android.play.core.**
