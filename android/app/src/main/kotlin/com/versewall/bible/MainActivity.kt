package com.versewall.bible

import android.app.WallpaperManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.util.Log
import androidx.work.Constraints
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.NetworkType
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.DataOutputStream
import java.io.File
import java.io.FileInputStream
import java.util.concurrent.TimeUnit

class MainActivity : FlutterActivity() {
	private val wallpaperChannel = "com.versewall.bible/wallpaper"
	private val rootChannel = "com.versewall.bible/root"
	private val lockscreenChannel = "com.versewall.bible/lockscreen"
	private val dynamicLockChannel = "com.versewall.bible/dynamic_lock"
	private lateinit var dynamicLockHandler: DynamicLockScreenHandler
	private lateinit var lockReceiver: LockScreenReceiver
	private var lockReceiverRegistered = false

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)
		dynamicLockHandler = DynamicLockScreenHandler(this)

		// Wallpaper & Lock screen channel
		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, wallpaperChannel)
			.setMethodCallHandler { call, result ->
				when (call.method) {
					"setWallpaper" -> handleSetWallpaper(call, result)
					"liveWallpaperDir" -> result.success(getLiveWallpaperDir().absolutePath)
					"isLiveWallpaperActive" -> result.success(false)
					"openLiveWallpaperChooser" -> result.success(false)
					"refreshLiveWallpaper" -> result.success(null)
					"startLockRotation" -> result.success(true)
					"stopLockRotation" -> result.success(true)
					"isLockRotationRunning" -> result.success(false)
					else -> result.notImplemented()
				}
			}

		// Lock screen listener channel
		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, lockscreenChannel)
			.setMethodCallHandler { call, result ->
				when (call.method) {
					"startLockScreenListener" -> handleStartLockScreenListener(result)
					"stopLockScreenListener" -> handleStopLockScreenListener(result)
					else -> result.notImplemented()
				}
			}

		// Root channel
		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, rootChannel)
			.setMethodCallHandler { call, result ->
				when (call.method) {
					"requestRoot" -> handleRequestRoot(result)
					"isRooted" -> result.success(RootHelper.isRooted())
					"execSuCommand" -> handleExecSuCommand(call, result)
					else -> result.notImplemented()
				}
			}

		// Dynamic lock screen channel (new)
		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, dynamicLockChannel)
			.setMethodCallHandler { call, result ->
				dynamicLockHandler.handle(call, result)
			}
	}

	private fun handleSetWallpaper(call: MethodCall, result: MethodChannel.Result) {
		val bytes = call.argument<ByteArray>("bytes")
		val target = call.argument<String>("target")
		if (bytes == null || bytes.isEmpty() || target == null) {
			result.error("INVALID_ARGUMENT", "Wallpaper bytes and target are required", null)
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
			val wallpaperManager = WallpaperManager.getInstance(this)
			bytes.inputStream().use { stream ->
				wallpaperManager.setStream(stream, null, true, flags)
			}
			result.success(null)
		} catch (error: SecurityException) {
			result.error("PERMISSION_DENIED", error.message, null)
		} catch (error: Exception) {
			result.error("SET_WALLPAPER_FAILED", error.message, null)
		}
	}

	private fun getLiveWallpaperDir(): File {
		val dir = File(filesDir, "live_wallpapers")
		if (!dir.exists()) {
			dir.mkdirs()
		}
		return dir
	}

	private fun handleStartLockScreenListener(result: MethodChannel.Result) {
		try {
			if (!lockReceiverRegistered) {
				lockReceiver = LockScreenReceiver(this)
				val filter = IntentFilter().apply {
					addAction(Intent.ACTION_SCREEN_ON)
					addAction(Intent.ACTION_SCREEN_OFF)
					addAction(Intent.ACTION_USER_PRESENT)
				}
				if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
					registerReceiver(lockReceiver, filter, Context.RECEIVER_EXPORTED)
				} else {
					@Suppress("UnspecifiedRegisterReceiverFlag")
					registerReceiver(lockReceiver, filter)
				}
				lockReceiverRegistered = true
			}
			result.success("Lock screen listener started")
		} catch (e: Exception) {
			result.error("FAILED", e.message, null)
		}
	}

	private fun handleStopLockScreenListener(result: MethodChannel.Result) {
		try {
			if (lockReceiverRegistered && ::lockReceiver.isInitialized) {
				unregisterReceiver(lockReceiver)
				lockReceiverRegistered = false
			}
			result.success("Lock screen listener stopped")
		} catch (e: Exception) {
			result.error("FAILED", e.message, null)
		}
	}

	private fun handleRequestRoot(result: MethodChannel.Result) {
		try {
			result.success(RootHelper.requestRoot())
		} catch (e: Exception) {
			result.success(false)
		}
	}

	private fun handleExecSuCommand(call: MethodCall, result: MethodChannel.Result) {
		val command = call.argument<String>("command")
		if (command == null) {
			result.error("MISSING_ARG", "command required", null)
			return
		}
		try {
			val process = Runtime.getRuntime().exec("su")
			DataOutputStream(process.outputStream).apply {
				writeBytes(command + "\n")
				writeBytes("exit\n")
				flush()
				close()
			}
			val exitCode = process.waitFor()
			result.success(exitCode == 0)
		} catch (e: Exception) {
			result.error("SU_FAILED", e.message, null)
		}
	}

	private fun isRooted(): Boolean {
		return try {
			RootHelper.hasRootAccess()
		} catch (e: Exception) {
			false
		}
	}

	private inner class LockScreenReceiver(private val context: Context) : BroadcastReceiver() {
		override fun onReceive(context: Context?, intent: Intent?) {
			when (intent?.action) {
				Intent.ACTION_SCREEN_OFF -> {
					Log.d("LockScreen", "Screen turned off - ready to show verse")
					// Notify Flutter to rotate wallpaper
					notifyLockscreenEvent("screen_off")
				}
				Intent.ACTION_USER_PRESENT -> {
					Log.d("LockScreen", "Device unlocked")
					notifyLockscreenEvent("unlocked")
				}
				Intent.ACTION_SCREEN_ON -> {
					Log.d("LockScreen", "Screen turned on")
					notifyLockscreenEvent("screen_on")
				}
			}
		}

		private fun notifyLockscreenEvent(event: String) {
			// This will be handled by sending a method call to Flutter
			Log.d("LockScreen", "Event: $event")
		}
	}
}
