package com.fetch.word_chef_flutter

import android.os.Bundle
import android.Manifest
import android.content.pm.PackageManager
import androidx.core.content.ContextCompat
import androidx.core.app.ActivityCompat
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import java.util.concurrent.TimeUnit

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Enable edge-to-edge display
        WindowCompat.setDecorFitsSystemWindows(window, false)

        // Schedule native periodic notification worker (runs even if Flutter background isolate has issues)
        try {
            // Schedule periodic work every 15 minutes (minimum interval enforced by WorkManager on some OS versions)
            val workRequest = PeriodicWorkRequestBuilder<NotificationWorker>(15, TimeUnit.MINUTES)
                .build()
            WorkManager.getInstance(applicationContext)
                .enqueueUniquePeriodicWork("native_notification_worker", ExistingPeriodicWorkPolicy.KEEP, workRequest)
        } catch (e: Exception) {
            e.printStackTrace()
        }

        // Request runtime notification permission on Android 13+
        try {
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.TIRAMISU) {
                val permission = Manifest.permission.POST_NOTIFICATIONS
                if (ContextCompat.checkSelfPermission(this, permission) != PackageManager.PERMISSION_GRANTED) {
                    ActivityCompat.requestPermissions(this, arrayOf(permission), 1001)
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }

        // Enqueue a one-time worker immediately for quick testing of notifications
        try {
            val immediate = androidx.work.OneTimeWorkRequestBuilder<NotificationWorker>()
                .setInputData(androidx.work.Data.Builder().putBoolean("test", true).build())
                .build()
            WorkManager.getInstance(applicationContext).enqueue(immediate)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}