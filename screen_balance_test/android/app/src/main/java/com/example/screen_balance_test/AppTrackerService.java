package com.example.screen_balance_test;

import android.accessibilityservice.AccessibilityService;
import android.accessibilityservice.AccessibilityServiceInfo;
import android.content.Intent;
import android.util.Log;
import android.view.accessibility.AccessibilityEvent;

public class AppTrackerService extends AccessibilityService {

    private static final String TAG = "AppTrackerService";
    public static final String ACTION_APP_CHANGED = "com.example.screen_balance_test.APP_CHANGED";
    public static final String EXTRA_PACKAGE_NAME = "package_name";

    @Override
    protected void onServiceConnected() {
        super.onServiceConnected();
        AccessibilityServiceInfo info = new AccessibilityServiceInfo();
        info.eventTypes = AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED;
        info.feedbackType = AccessibilityServiceInfo.FEEDBACK_GENERIC;
        info.flags = AccessibilityServiceInfo.DEFAULT;
        this.setServiceInfo(info);
        Log.d(TAG, "ScreenBalance Accessibility Service Connected");
    }

    @Override
    public void onAccessibilityEvent(AccessibilityEvent event) {
        if (event.getEventType() == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            if (event.getPackageName() != null) {
                String packageName = event.getPackageName().toString();
                Log.d(TAG, "Opened app: " + packageName);
                
                Intent intent = new Intent(ACTION_APP_CHANGED);
                intent.setPackage(getPackageName());
                intent.putExtra(EXTRA_PACKAGE_NAME, packageName);
                sendBroadcast(intent);
            }
        }
    }

    @Override
    public void onInterrupt() {
        Log.e(TAG, "Service interrupted");
    }
}
