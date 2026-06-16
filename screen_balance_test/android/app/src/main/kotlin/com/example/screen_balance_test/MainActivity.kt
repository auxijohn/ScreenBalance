package com.example.screen_balance_test

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

class MainActivity: FlutterActivity() {
    private val EVENT_CHANNEL = "com.screenbalance.tracker/events"
    private var eventSink: EventChannel.EventSink? = null

    private val receiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            when (intent.action) {
                "com.example.screen_balance_test.APP_CHANGED" -> {
                    val packageName = intent.getStringExtra("package_name")
                    if (packageName != null) {
                        eventSink?.success(packageName)
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

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                    val filter = IntentFilter().apply {
                        addAction("com.example.screen_balance_test.APP_CHANGED")
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
                    try {
                        unregisterReceiver(receiver)
                    } catch (e: Exception) {}
                    eventSink = null
                }
            }
        )
    }
}
