#!/bin/bash

# Visual helper to trigger the Dopamine Loop by opening Chrome, Settings, Maps, and ScreenBalance.
ADB="/Users/Auxi/Library/Android/sdk/platform-tools/adb"

echo "📱 Launching Chrome..."
$ADB shell monkey -p com.android.chrome -c android.intent.category.LAUNCHER 1
sleep 2

echo "📱 Launching Settings..."
$ADB shell monkey -p com.android.settings -c android.intent.category.LAUNCHER 1
sleep 2

echo "📱 Launching Maps..."
$ADB shell monkey -p com.google.android.apps.maps -c android.intent.category.LAUNCHER 1
sleep 2

echo "📱 Bringing ScreenBalance back to the front..."
$ADB shell monkey -p com.example.screen_balance -c android.intent.category.LAUNCHER 1

echo "🚨 [Dopamine Loop triggered visually on emulator!]"
