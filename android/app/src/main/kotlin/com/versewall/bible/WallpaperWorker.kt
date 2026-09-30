package com.versewall.bible

import android.app.WallpaperManager
import android.content.Context
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import java.io.File
import java.io.FileInputStream

/**
 * Background worker that reapplies the newest rendered wallpaper.
 *
 * The worker looks for PNG files in the app's live wallpaper directory and applies
 * the most recently modified image to the lock screen. This keeps the wallpaper
 * rotation moving even if the app is not currently in memory.
 */
class WallpaperWorker(
    appContext: Context,
    workerParams: WorkerParameters,
) : CoroutineWorker(appContext, workerParams) {
    override suspend fun doWork(): Result {
        return try {
            val dir = File(applicationContext.filesDir, "live_wallpapers")
            val latest = dir.listFiles { file ->
                file.isFile && file.extension.equals("png", ignoreCase = true)
            }?.maxByOrNull { it.lastModified() }

            if (latest == null) return Result.success()

            val wallpaperManager = WallpaperManager.getInstance(applicationContext)
            FileInputStream(latest).use { input ->
                if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.N) {
                    wallpaperManager.setStream(input, null, true, WallpaperManager.FLAG_LOCK)
                } else {
                    wallpaperManager.setStream(input)
                }
            }

            Result.success()
        } catch (e: SecurityException) {
            Result.retry()
        } catch (e: Exception) {
            Result.retry()
        }
    }
}
