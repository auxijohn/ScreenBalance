#!/bin/bash
# Flash Release APK to Device
# This script installs the release APK to a connected device.
# If multiple devices are connected, it prompts for a selection.

set -e

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Navigate to the project root
cd "$SCRIPT_DIR/.."

# 1. Select Device
DEVICES=$(adb devices | grep -v "List" | grep "device$" | cut -f1)
COUNT=$(echo "$DEVICES" | grep -v "^$" | wc -l | xargs)

if [ "$COUNT" -eq 0 ]; then
    echo "❌ No devices or emulators found. Connect a device via USB first."
    exit 1
fi

if [ "$COUNT" -eq 1 ]; then
    SERIAL=$DEVICES
    echo "📲 Using single device: $SERIAL"
else
    echo "📱 Multiple devices detected:"
    i=1
    declare -a SERIALS
    while read -r line; do
        SERIALS[$i]=$line
        echo "  $i) $line"
        ((i++))
    done <<< "$DEVICES"
    
    echo -n "Select a device (1-$COUNT): "
    read -r choice
    
    if [[ "$choice" -ge 1 && "$choice" -le "$COUNT" ]]; then
        SERIAL=${SERIALS[$choice]}
    else
        echo "❌ Invalid selection."
        exit 1
    fi
fi

# 2. Detect Device ABI
ABI=$(adb -s "$SERIAL" shell getprop ro.product.cpu.abi | tr -d '\r')
echo "🧬 Device ABI detected: $ABI"

# 3. Find Matching APK
APK_DIR="build/app/outputs/flutter-apk"
FAT_APK="$APK_DIR/app-release.apk"
MATCHING_APK="$APK_DIR/app-$ABI-release.apk"

if [ -f "$MATCHING_APK" ]; then
    echo "🎯 Found matching optimized APK: $(basename "$MATCHING_APK")"
    APK_PATH="$MATCHING_APK"
elif [ -f "$FAT_APK" ]; then
    echo "📦 Using fat APK (fallback): $(basename "$FAT_APK")"
    APK_PATH="$FAT_APK"
else
    # Fallback: list all split apks and let user choose if auto-match fails
    echo "⚠️  No direct match for $ABI found. Available APKs in $APK_DIR:"
    SPLIT_APKS=$(ls $APK_DIR/app-*-release.apk 2>/dev/null || true)
    
    if [ -n "$SPLIT_APKS" ]; then
        select opt in $SPLIT_APKS; do
            if [ -n "$opt" ]; then
                APK_PATH="$opt"
                break
            fi
        done
    else
        echo "❌ No APKs found in $APK_DIR. Run ./scripts/build_release.sh apk first."
        exit 1
    fi
fi

# 4. Install
echo "🚀 Installing to $SERIAL..."
adb -s "$SERIAL" install -r "$APK_PATH"

echo ""
echo "✅ Installation complete!"
