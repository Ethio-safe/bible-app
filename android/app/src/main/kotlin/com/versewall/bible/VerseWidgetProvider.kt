package com.versewall.bible

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.graphics.BitmapFactory
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetPlugin
import java.io.File

/** Home-screen widget showing the verse published by HomeWidgetService (Dart). */
class VerseWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        val data = HomeWidgetPlugin.getData(context)
        val reference = data.getString("widget_reference", "Verse of the Day")
        val text = data.getString("widget_text", "Open Verse Bible to load today's verse.")
        val imagePath = data.getString("widget_image", null)

        for (id in ids) {
            val views = RemoteViews(context.packageName, R.layout.verse_widget)
            views.setTextViewText(R.id.widget_text, text)
            views.setTextViewText(R.id.widget_reference, reference)
            if (!imagePath.isNullOrEmpty() && File(imagePath).exists()) {
                // Down-sample: RemoteViews bitmaps must stay small.
                val opts = BitmapFactory.Options().apply { inSampleSize = 4 }
                BitmapFactory.decodeFile(imagePath, opts)?.let {
                    views.setImageViewBitmap(R.id.widget_bg, it)
                }
            }
            views.setOnClickPendingIntent(
                R.id.widget_root,
                HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
            )
            manager.updateAppWidget(id, views)
        }
    }
}
