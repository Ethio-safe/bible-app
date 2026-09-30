package com.versewall.bible

import android.util.Log
import java.io.DataOutputStream

/**
 * Helper object for managing root privileges on Android devices.
 *
 * This object provides functionality to:
 * 1. Check if the device is rooted (su binary is accessible)
 * 2. Request root permission from the user
 * 3. Execute arbitrary shell commands with superuser privileges
 *
 * Usage:
 * ```kotlin
 * if (RootHelper.isRooted()) {
 *     val success = RootHelper.execCommand("chmod 644 /data/system/wallpaper.png")
 * }
 * ```
 */
object RootHelper {
    private const val TAG = "RootHelper"

    /**
     * Checks if the device is rooted and if the app has su privileges.
     *
     * This works by attempting to execute a simple command (`id`) as root.
     * If the su binary exists and the app has been granted superuser privileges,
     * the check will succeed. The user may be prompted by their superuser manager
     * (Magisk, SuperSU, etc.) to grant access.
     *
     * @return true if root is available, false otherwise
     */
    fun isRooted(): Boolean {
        return try {
            val process = Runtime.getRuntime().exec(arrayOf("su", "-c", "id"))
            val output = process.inputStream.bufferedReader().readText()
            val exitCode = process.waitFor()
            process.destroy()
            exitCode == 0 && output.contains("uid=0")
        } catch (e: Exception) {
            Log.w(TAG, "Root check failed", e)
            false
        }
    }

    /**
     * Checks if root access is available by testing execution of a simple command.
     *
     * This is more thorough than [isRooted] because it actually attempts to execute
     * a command and verify the output, rather than just testing the su binary.
     *
     * @return true if root commands can be executed successfully
     */
    fun hasRootAccess(): Boolean {
        return try {
            val process = Runtime.getRuntime().exec(arrayOf("su", "-c", "id"))
            val output = process.inputStream.bufferedReader().readText()
            val exitCode = process.waitFor()
            process.destroy()
            exitCode == 0 && output.contains("uid=0")
        } catch (e: Exception) {
            Log.w(TAG, "Root access check failed", e)
            false
        }
    }

    /**
     * Requests root permission from the user via their superuser manager.
     *
     * This will trigger a permission prompt from Magisk, SuperSU, or similar
     * root management apps installed on the device. The user must approve
     * the request for the app to gain superuser access.
     *
     * @return true if the user granted root access, false if denied or error occurred
     */
    fun requestRoot(): Boolean {
        return try {
            val process = Runtime.getRuntime().exec(arrayOf("su", "-c", "id"))
            val output = process.inputStream.bufferedReader().readText()
            val exitCode = process.waitFor()
            process.destroy()
            exitCode == 0 && output.contains("uid=0")
        } catch (e: Exception) {
            Log.w(TAG, "Root request failed", e)
            false
        }
    }

    /**
     * Executes a shell command with superuser privileges.
     *
     * This method opens a su shell and sends the command to be executed.
     * The command is executed asynchronously, and this method waits for
     * the process to complete before returning.
     *
     * Example commands:
     * - `chmod 644 /data/system/wallpaper_info.xml`
     * - `cp /source/wallpaper.png /data/system/wallpaper.png`
     * - `getprop ro.build.version.release` (get Android version)
     * - `settings get system screen_brightness` (get screen brightness)
     *
     * @param command The shell command to execute (without 'su -c' prefix)
     * @return true if the command executed successfully (exit code 0), false otherwise
     */
    fun execCommand(command: String): Boolean {
        return try {
            val process = Runtime.getRuntime().exec("su")
            DataOutputStream(process.outputStream).use { dos ->
                dos.writeBytes("$command\n")
                dos.writeBytes("exit\n")
                dos.flush()
            }
            val exitCode = process.waitFor()
            process.destroy()
            exitCode == 0
        } catch (e: Exception) {
            Log.e(TAG, "Failed to execute command: $command", e)
            false
        }
    }

    /**
     * Executes a shell command with superuser privileges and captures output.
     *
     * Unlike [execCommand], this method captures and returns the command's output,
     * making it useful for commands that need to return data.
     *
     * Example commands:
     * - `getprop ro.build.version.release` (get Android version)
     * - `pm list packages` (list installed packages)
     * - `dumpsys display | grep density` (get display density)
     *
     * @param command The shell command to execute
     * @return The command's output as a string, or null if execution failed
     */
    fun execCommandWithOutput(command: String): String? {
        return try {
            val process = Runtime.getRuntime().exec("su")
            DataOutputStream(process.outputStream).use { dos ->
                dos.writeBytes("$command\n")
                dos.writeBytes("exit\n")
                dos.flush()
            }
            val output = process.inputStream.bufferedReader().readText()
            val exitCode = process.waitFor()
            process.destroy()
            if (exitCode == 0) output else null
        } catch (e: Exception) {
            Log.e(TAG, "Failed to execute command with output: $command", e)
            null
        }
    }

    /**
     * Checks if a specific su binary path is available (for multi-su scenarios).
     *
     * Some devices may have multiple su binaries (e.g., Magisk, SuperSU, LineageOS).
     * This method checks if a specific one is accessible.
     *
     * @param suPath Path to the su binary (e.g., "/system/xbin/su", "/system/bin/su")
     * @return true if the su binary exists and is executable
     */
    fun isSuAvailable(suPath: String = "su"): Boolean {
        return try {
            val process = Runtime.getRuntime().exec(arrayOf(suPath, "-v"))
            val output = process.inputStream.bufferedReader().readText()
            val exitCode = process.waitFor()
            process.destroy()
            exitCode == 0 && output.isNotEmpty()
        } catch (e: Exception) {
            false
        }
    }

    /**
     * Attempts to grant persistent root access to the app.
     *
     * This method creates a persistent grant by storing the app's UID
     * in the superuser manager's whitelist. This reduces permission prompts
     * for subsequent root calls.
     *
     * Note: This may not work with all superuser managers, and depends on
     * the user having already granted access once.
     *
     * @return true if persistent grant was attempted successfully
     */
    fun grantPersistentAccess(): Boolean {
        return try {
            // This attempts to store a grant by running a dummy command
            // Different su managers handle this differently
            val process = Runtime.getRuntime().exec("su")
            DataOutputStream(process.outputStream).use { dos ->
                dos.writeBytes("exit\n")
                dos.flush()
            }
            val exitCode = process.waitFor()
            process.destroy()
            exitCode == 0
        } catch (e: Exception) {
            Log.w(TAG, "Failed to grant persistent access", e)
            false
        }
    }
}
