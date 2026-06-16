package com.example.screen_balance;

import android.accessibilityservice.AccessibilityService;
import android.accessibilityservice.AccessibilityServiceInfo;
import android.content.Intent;
import android.util.Log;
import android.view.accessibility.AccessibilityEvent;

public class AppTrackerService extends AccessibilityService {

    private static final String TAG = "AppTrackerService";
    public static final String ACTION_APP_CHANGED = "com.example.screen_balance.APP_CHANGED";
    public static final String EXTRA_PACKAGE_NAME = "package_name";
    public static final String EXTRA_EVENT_TYPE = "event_type";
    public static final String EXTRA_ADDED_COUNT = "added_count";
    public static final String EXTRA_DELETED_COUNT = "deleted_count";

    @Override
    protected void onServiceConnected() {
        super.onServiceConnected();
        AccessibilityServiceInfo info = new AccessibilityServiceInfo();
        info.eventTypes = AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED
                        | AccessibilityEvent.TYPE_VIEW_SCROLLED
                        | AccessibilityEvent.TYPE_VIEW_TEXT_CHANGED
                        | AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED;
        info.feedbackType = AccessibilityServiceInfo.FEEDBACK_GENERIC;
        info.flags = AccessibilityServiceInfo.DEFAULT;
        info.notificationTimeout = 100;
        this.setServiceInfo(info);
        Log.d(TAG, "ScreenBalance Accessibility Service Connected");
    }

    @Override
    public void onAccessibilityEvent(AccessibilityEvent event) {
        if (event.getPackageName() == null) return;
        String packageName = event.getPackageName().toString();

        Intent intent = new Intent(ACTION_APP_CHANGED);
        intent.setPackage(getPackageName());
        intent.putExtra(EXTRA_PACKAGE_NAME, packageName);

        int eventType = event.getEventType();
        if (eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            Log.d(TAG, "Opened app: " + packageName);
            intent.putExtra(EXTRA_EVENT_TYPE, "APP_OPEN");
            sendBroadcast(intent);
        } else if (eventType == AccessibilityEvent.TYPE_VIEW_SCROLLED) {
            intent.putExtra(EXTRA_EVENT_TYPE, "SCROLL");
            sendBroadcast(intent);
        } else if (eventType == AccessibilityEvent.TYPE_VIEW_TEXT_CHANGED) {
            intent.putExtra(EXTRA_EVENT_TYPE, "TEXT_CHANGE");
            intent.putExtra(EXTRA_ADDED_COUNT, event.getAddedCount());
            intent.putExtra(EXTRA_DELETED_COUNT, event.getRemovedCount());
            sendBroadcast(intent);
        } else if (eventType == AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED) {
            intent.putExtra(EXTRA_EVENT_TYPE, "CONTENT_CHANGE");
            sendBroadcast(intent);
        }
    }

    @Override
    public void onInterrupt() {
        Log.e(TAG, "Service interrupted");
    }
}
