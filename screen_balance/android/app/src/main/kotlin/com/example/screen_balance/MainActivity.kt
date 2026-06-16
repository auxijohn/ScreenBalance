package com.example.screen_balance

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

import android.content.ComponentName
import android.provider.Settings
import android.text.TextUtils
import android.view.accessibility.AccessibilityManager
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val EVENT_CHANNEL = "com.screenbalance.tracker/events"
    private val COMMAND_CHANNEL = "com.screenbalance.tracker/commands"
    private var eventSink: EventChannel.EventSink? = null

    private val receiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            when (intent.action) {
                "com.example.screen_balance.APP_CHANGED" -> {
                    val packageName = intent.getStringExtra("package_name") ?: return
                    val eventType = intent.getStringExtra("event_type") ?: "APP_OPEN"
                    
                    when (eventType) {
                        "SCROLL" -> {
                            eventSink?.success("SCROLL:$packageName")
                        }
                        "TEXT_CHANGE" -> {
                            val added = intent.getIntExtra("added_count", 0)
                            val deleted = intent.getIntExtra("deleted_count", 0)
                            eventSink?.success("TEXT_CHANGE:$packageName:$added:$deleted")
                        }
                        "CONTENT_CHANGE" -> {
                            eventSink?.success("CONTENT_CHANGE:$packageName")
                        }
                        else -> {
                            eventSink?.success(packageName)
                        }
                    }
                }
                Intent.ACTION_SCREEN_OFF -> {
                    eventSink?.success("DEVICE_LOCK")
                }
                Intent.ACTION_USER_PRESENT -> {
                    eventSink?.success("DEVICE_UNLOCK")
                }
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Commands MethodChannel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, COMMAND_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isAccessibilityServiceEnabled" -> {
                    result.success(isAccessibilityServiceEnabled(context))
                }
                "openAccessibilitySettings" -> {
                    val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
                    intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    context.startActivity(intent)
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

        // Events EventChannel
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                    val filter = IntentFilter().apply {
                        addAction("com.example.screen_balance.APP_CHANGED")
                        addAction(Intent.ACTION_SCREEN_OFF)
                        addAction(Intent.ACTION_USER_PRESENT)
                    }
                    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.TIRAMISU) {
                        registerReceiver(receiver, filter, Context.RECEIVER_EXPORTED)
                    } else {
                        registerReceiver(receiver, filter)
                    }
                }

                override fun onCancel(arguments: Any?) {
                    unregisterReceiver(receiver)
                    eventSink = null
                }
            }
        )
    }

    private fun isAccessibilityServiceEnabled(context: Context): Boolean {
        val service = context.packageName + "/" + AppTrackerService::class.java.name
        val enabled = Settings.Secure.getInt(
            context.contentResolver,
            Settings.Secure.ACCESSIBILITY_ENABLED, 0
        )
        if (enabled == 1) {
            val settingValue = Settings.Secure.getString(
                context.contentResolver,
                Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
            )
            if (settingValue != null) {
                val splitter = TextUtils.SimpleStringSplitter(':')
                splitter.setString(settingValue)
                while (splitter.hasNext()) {
                    val accessibilityService = splitter.next()
                    if (accessibilityService.equals(service, ignoreCase = true)) {
                        return true
                    }
                }
            }
        }
        return false
    }
}
