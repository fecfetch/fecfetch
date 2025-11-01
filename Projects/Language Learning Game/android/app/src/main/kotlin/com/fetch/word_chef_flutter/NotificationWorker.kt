package com.fetch.word_chef_flutter

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import androidx.core.app.NotificationCompat
import android.util.Log
import org.json.JSONObject
import androidx.work.Worker
import androidx.work.WorkerParameters
import android.app.ActivityManager
import android.app.ActivityManager.RunningAppProcessInfo

class NotificationWorker(appContext: Context, params: WorkerParameters) : Worker(appContext, params) {

    private val CHANNEL_ID = "wordchef_reminders"
    private val CHANNEL_NAME = "WordChef Reminders"

    private fun isAppInForeground(): Boolean {
        val activityManager = applicationContext.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val appProcesses = activityManager.runningAppProcesses ?: return false
        val packageName = applicationContext.packageName
        return appProcesses.any { appProcess ->
            appProcess.importance == RunningAppProcessInfo.IMPORTANCE_FOREGROUND && appProcess.processName == packageName
        }
    }

    override fun doWork(): Result {
        try {
            val TAG = "NotificationWorker"
            if (isAppInForeground()) {
                Log.d(TAG, "App is in foreground, skipping notifications.")
                return Result.success()
            }

            // Non-test path: read prefs and determine whether to post notifications
            val prefs = applicationContext.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)

            val languageCode = when {
                prefs.contains("flutter.background_language_code") -> prefs.getString("flutter.background_language_code", "en")
                prefs.contains("background_language_code") -> prefs.getString("background_language_code", "en")
                else -> "en"
            } ?: "en"

            val nm = applicationContext.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                val channel = NotificationChannel(CHANNEL_ID, CHANNEL_NAME, NotificationManager.IMPORTANCE_DEFAULT)
                nm.createNotificationChannel(channel)
            }

            val intent = Intent(applicationContext, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_NEW_TASK
            }

            val pendingFlags = if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.S) {
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            } else {
                PendingIntent.FLAG_UPDATE_CURRENT
            }

            val pendingIntent = PendingIntent.getActivity(applicationContext, 0, intent, pendingFlags)

            // Helper to read both flutter-prefixed keys and raw keys
            fun getBoolPref(name: String, defaultVal: Boolean = false): Boolean {
                val prefName = "flutter.$name"
                return when {
                    prefs.contains(prefName) -> prefs.getBoolean(prefName, defaultVal)
                    prefs.contains(name) -> prefs.getBoolean(name, defaultVal)
                    else -> defaultVal
                }
            }

            // Helper to mark notified state
            fun wasNotified(type: String): Boolean {
                val key = "flutter.notified_$type"
                return prefs.getBoolean(key, false)
            }

            fun markNotified(type: String, value: Boolean) {
                prefs.edit().putBoolean("flutter.notified_$type", value).apply()
            }

            // Check flags set by Dart background service (support both pref naming conventions)
            val notifyTranslation = getBoolPref("notify_translation", false)
            val notifyLetter = getBoolPref("notify_letter", false)

            // Log current preferences for debugging / diagnosis
            Log.d(TAG, "Prefs: notify_translation=$notifyTranslation, notify_letter=$notifyLetter")

            // Read timers under flutter.feature_timers (the shared pref key is prefixed)
            val timersJson = when {
                prefs.contains("flutter.feature_timers") -> prefs.getString("flutter.feature_timers", null)
                prefs.contains("feature_timers") -> prefs.getString("feature_timers", null)
                else -> null
            }
            Log.d(TAG, "feature_timers: $timersJson")

            // Additional diagnostic: dump all SharedPreferences entries so we can see exact key names/types
            try {
                val all = prefs.all
                Log.d(TAG, "SharedPreferences dump: keys=${all.keys}")
                for (entry in all.entries) {
                    Log.d(TAG, "Pref entry: ${entry.key} => ${entry.value}")
                }
            } catch (e: Exception) {
                Log.d(TAG, "Failed to dump SharedPreferences: $e")
            }

            var posted = false

            // First, honor explicit notify_* flags set by Dart (if present)
            if (notifyTranslation) {
                val (tTitle, tBody) = getLocalizedStrings(languageCode, "translation")
                val notif = NotificationCompat.Builder(applicationContext, CHANNEL_ID)
                    .setContentTitle(tTitle)
                    .setContentText(tBody)
                    .setSmallIcon(R.mipmap.launcher_icon)
                    .setContentIntent(pendingIntent)
                    .setAutoCancel(true)
                    .build()
                nm.notify(2001, notif)
                try { prefs.edit().putBoolean("notify_translation", false).apply() } catch (_: Exception) {}
                try { prefs.edit().putBoolean("flutter.notify_translation", false).apply() } catch (_: Exception) {}
                markNotified("translation", true)
                posted = true
            }

            if (notifyLetter) {
                val (lTitle, lBody) = getLocalizedStrings(languageCode, "letter")
                val notif = NotificationCompat.Builder(applicationContext, CHANNEL_ID)
                    .setContentTitle(lTitle)
                    .setContentText(lBody)
                    .setSmallIcon(R.mipmap.launcher_icon)
                    .setContentIntent(pendingIntent)
                    .setAutoCancel(true)
                    .build()
                nm.notify(2002, notif)
                try { prefs.edit().putBoolean("notify_letter", false).apply() } catch (_: Exception) {}
                try { prefs.edit().putBoolean("flutter.notify_letter", false).apply() } catch (_: Exception) {}
                markNotified("letter", true)
                posted = true
            }


            // If nothing was explicitly flagged, try computing from feature_timers JSON
            if (!posted && timersJson != null) {
                try {
                    val root = JSONObject(timersJson)

                    fun checkTimer(timerKey: String, notifId: Int, type: String) {
                        if (!root.has(timerKey)) return
                        val t = root.optJSONObject(timerKey) ?: return
                        val current = t.optInt("currentCount", -1)
                        val max = t.optInt("maxCount", -1)
                        val alreadyNotified = wasNotified(type)

                        Log.d(TAG, "checkTimer $timerKey: current=$current max=$max alreadyNotified=$alreadyNotified")

                        if (current == max && !alreadyNotified) {
                            // Post notification for this type
                            val (title, body) = getLocalizedStrings(languageCode, type)
                            val n = NotificationCompat.Builder(applicationContext, CHANNEL_ID)
                                .setContentTitle(title)
                                .setContentText(body)
                                .setSmallIcon(R.mipmap.launcher_icon)
                                .setContentIntent(pendingIntent)
                                .setAutoCancel(true)
                                .build()
                            nm.notify(notifId, n)
                            markNotified(type, true)
                            posted = true
                        } else if (current < max && alreadyNotified) {
                            // Reset notified flag so next time it can notify again
                            markNotified(type, false)
                        }
                    }

                    checkTimer("translationTimer", 2001, "translation")
                    checkTimer("letterTimer", 2002, "letter")
                } catch (je: Exception) {
                    Log.d(TAG, "Failed to parse feature_timers JSON: $je")
                }
            }

            return Result.success()
        } catch (t: Throwable) {
            t.printStackTrace()
            return Result.failure()
        }
    }

    private fun getLocalizedStrings(lang: String, type: String): Pair<String, String> {
        return when (type) {
            "letter" -> when (lang) {
                "de" -> Pair("Buchstabenhinweise voll", "Deine Buchstabenhinweise sind voll. Komm zurück und spiele!")
                "fr" -> Pair("Indices de lettres pleins", "Vos indices de lettres sont pleins. Revenez jouer !")
                "es" -> Pair("Pistas de letras llenas", "Tus pistas de letras están llenas. ¡Vuelve a jugar!")
                "tr" -> Pair("Harf İpuçları Dolu", "Harf ipuçlarınız doldu. Geri gel ve oyna!")
                "hi" -> Pair("पत्र संकेत भरे हुए हैं", "आपके पत्र संकेत भरे हुए हैं। वापस आकर खेलें!")
                "zh" -> Pair("字母提示已满", "您的字母提示已满。回来玩吧！")
                else -> Pair("Letter Hints Full", "Your letter hints are full. Come back and play!")
            }
            else -> when (lang) {
                "de" -> Pair("Übersetzungshinweise voll", "Deine Übersetzungshinweise sind voll. Komm zurück und spiele!")
                "fr" -> Pair("Indices de traduction pleins", "Vos indices de traduction sont pleins. Revenez jouer !")
                "es" -> Pair("Pistas de traducción llenas", "Tus pistas de traducción están llenas. ¡Vuelve a jugar!")
                "tr" -> Pair("Çeviri İpuçları Dolu", "Çeviri ipuçlarınız doldu. Geri gel ve oyna!")
                "hi" -> Pair("अनुवाद संकेत भरे हुए हैं", "आपके अनुवाद संकेत भरे हुए हैं। वापस आकर खेलें!")
                "zh" -> Pair("翻译提示已满", "您的翻译提示已满。回来玩吧！")
                else -> Pair("Translation Hints Full", "Your translation hints are full. Come back and play!")
            }
        }
    }
}
