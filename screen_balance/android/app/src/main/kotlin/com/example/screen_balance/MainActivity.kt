package com.example.screen_balance

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
            if (intent.action == "com.example.screen_balance.APP_CHANGED") {
                val packageName = intent.getStringExtra("package_name")
                if (packageName != null) {
                    eventSink?.success(packageName)
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
                    val filter = IntentFilter("com.example.screen_balance.APP_CHANGED")
                    registerReceiver(receiver, filter)
                }

                override fun onCancel(arguments: Any?) {
                    unregisterReceiver(receiver)
                    eventSink = null
                }
            }
        )
    }
}
