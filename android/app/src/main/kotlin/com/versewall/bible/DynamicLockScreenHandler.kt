package com.versewall.bible

import android.app.WallpaperManager
import android.content.Context
import android.os.Build
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream
import androidx.work.Constraints
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.NetworkType
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import java.util.concurrent.TimeUnit

/**
 * Handles dynamic lock screen wallpaper operations.
 *
 * This class keeps the method-channel logic separate from MainActivity so the
 * Android integration stays manageable as more root / scheduling features are added.
 */
class DynamicLockScreenHandler(
    private val context: Context,
) {
    companion object {
        const val CHANNEL = "com.versewall.bible/dynamic_lock"
        private const val UNIQUE_WORK_NAME = "dynamic_lock_wallpaper"
    }

    fun handle(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "checkRootAccess" -> result.success(RootHelper.hasRootAccess())
            "requestRootAccess" -> result.success(RootHelper.requestRoot())
            "setLockScreenWallpaper" -> handleSetLockScreenWallpaper(call, result)
            "startAutoChange" -> handleStartAutoChange(call, result)
            "stopAutoChange" -> handleStopAutoChange(result)
            "isAutoChangeRunning" -> handleIsAutoChangeRunning(result)
            else -> result.notImplemented()
        }
    }

    private fun handleSetLockScreenWallpaper(call: MethodCall, result: MethodChannel.Result) {
        val imagePath = call.argument<String>("imagePath")
        val target = call.argument<String>("target") ?: "lock"
        if (imagePath.isNullOrBlank()) {
            result.error("INVALID_ARGUMENT", "imagePath is required", null)
            return
        }

        val file = File(imagePath)
        if (!file.exists()) {
            result.error("FILE_NOT_FOUND", "Image file not found: $imagePath", null)
            return
        }

        val flags = when (target) {
            "lock" -> WallpaperManager.FLAG_LOCK
            "home" -> WallpaperManager.FLAG_SYSTEM
            "both" -> WallpaperManager.FLAG_LOCK or WallpaperManager.FLAG_SYSTEM
            else -> {
                result.error("INVALID_TARGET", "Unknown wallpaper target: $target", null)
                return
            }
        }

        try {
            val manager = WallpaperManager.getInstance(context)
            FileInputStream(file).use { input ->
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                    manager.setStream(input, null, true, flags)
                } else {
                    manager.setStream(input)
                }
            }
            result.success(true)
        } catch (e: SecurityException) {
            result.error("PERMISSION_DENIED", e.message, null)
        } catch (e: Exception) {
            result.error("SET_WALLPAPER_FAILED", e.message, null)
        }
    }

    private fun handleStartAutoChange(call: MethodCall, result: MethodChannel.Result) {
        val intervalMinutes = call.argument<Int>("intervalMinutes") ?: 15
        val requiresNetwork = call.argument<Boolean>("requiresNetwork") ?: false
        val requiresCharging = call.argument<Boolean>("requiresCharging") ?: false
        val requiresBatteryNotLow = call.argument<Boolean>("requiresBatteryNotLow") ?: false

        val constraintsBuilder = Constraints.Builder()
        if (requiresNetwork) constraintsBuilder.setRequiredNetworkType(NetworkType.CONNECTED)
        constraintsBuilder.setRequiresCharging(requiresCharging)
        constraintsBuilder.setRequiresBatteryNotLow(requiresBatteryNotLow)

        val workRequest = PeriodicWorkRequestBuilder<WallpaperWorker>(
            intervalMinutes.toLong(),
            TimeUnit.MINUTES,
        )
            .setConstraints(constraintsBuilder.build())
            .build()

        WorkManager.getInstance(context).enqueueUniquePeriodicWork(
            UNIQUE_WORK_NAME,
            ExistingPeriodicWorkPolicy.REPLACE,
            workRequest,
        )

        result.success(true)
    }

    private fun handleStopAutoChange(result: MethodChannel.Result) {
        WorkManager.getInstance(context).cancelUniqueWork(UNIQUE_WORK_NAME)
        result.success(true)
    }

    private fun handleIsAutoChangeRunning(result: MethodChannel.Result) {
        try {
            val infos = WorkManager.getInstance(context)
                .getWorkInfosForUniqueWork(UNIQUE_WORK_NAME)
                .get()
            result.success(infos.any { !it.state.isFinished })
        } catch (e: Exception) {
            result.error("WORKMANAGER_QUERY_FAILED", e.message, null)
        }
    }
}
