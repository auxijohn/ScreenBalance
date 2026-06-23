#!/bin/bash
# Release Build Script for ScreenBalance
# This script prepares the release build by automatically incrementing version numbers.

set -e  # Exit on error

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Navigate to the project root (one level up from scripts/)
cd "$SCRIPT_DIR/.."

# Step 0: Handle version incrementing
echo "📝 Checking version in pubspec.yaml..."
CURRENT_VERSION=$(grep 'version: ' pubspec.yaml | sed 's/version: //')
# Extract major.minor.patch+build
V_BASE=$(echo $CURRENT_VERSION | cut -d'+' -f1)
V_BUILD=$(echo $CURRENT_VERSION | cut -d'+' -f2)

# Extract major, minor, patch
MAJOR=$(echo $V_BASE | cut -d'.' -f1)
MINOR=$(echo $V_BASE | cut -d'.' -f2)
PATCH=$(echo $V_BASE | cut -d'.' -f3)

# Increment minor and build
NEW_MINOR=$((MINOR + 1))
NEW_BUILD=$((V_BUILD + 1))
NEW_V_BASE="$MAJOR.$NEW_MINOR.0"
NEW_VERSION="$NEW_V_BASE+$NEW_BUILD"

echo "Current version: $CURRENT_VERSION (Version Name: $V_BASE, Build Number: $V_BUILD)"
echo "Proposed version: $NEW_VERSION (Version Name: $NEW_V_BASE, Build Number: $NEW_BUILD)"
read -p "Apply new version & build number ($NEW_VERSION)? (y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "✅ Updating pubspec.yaml..."
    # Use different sed syntax for macOS compatibility
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s/version: $CURRENT_VERSION/version: $NEW_VERSION/" pubspec.yaml
    else
        sed -i "s/version: $CURRENT_VERSION/version: $NEW_VERSION/" pubspec.yaml
    fi

    echo "🍎 Updating iOS version details..."
    PBXPROJ="ios/Runner.xcodeproj/project.pbxproj"
    if [[ -f "$PBXPROJ" ]]; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s/MARKETING_VERSION = [0-9.]*;/MARKETING_VERSION = $NEW_V_BASE;/g" "$PBXPROJ"
            sed -i '' "s/CURRENT_PROJECT_VERSION = [0-9]*;/CURRENT_PROJECT_VERSION = $NEW_BUILD;/g" "$PBXPROJ"
        else
            sed -i "s/MARKETING_VERSION = [0-9.]*;/MARKETING_VERSION = $NEW_V_BASE;/g" "$PBXPROJ"
            sed -i "s/CURRENT_PROJECT_VERSION = [0-9]*;/CURRENT_PROJECT_VERSION = $NEW_BUILD;/g" "$PBXPROJ"
        fi
        echo "✅ iOS project file updated (MARKETING_VERSION=$NEW_V_BASE, CURRENT_PROJECT_VERSION=$NEW_BUILD)."
    else
        echo "⚠️  iOS project file not found at $PBXPROJ"
    fi
else
    echo "⏩ Skipping version increment."
fi

echo "🔧 Preparing release build..."

# Step 1: Get dependencies
echo "📦 Getting dependencies..."
flutter pub get


# Step 3: Build based on argument
case "$1" in
  "apk")
    echo "🤖 Building Android APK (Optimized)..."
    flutter build apk --release --split-debug-info=./debug_info --obfuscate --split-per-abi
    echo "✅ APKs built in: build/app/outputs/flutter-apk/"
    ;;
  "appbundle")
    echo "🤖 Building Android App Bundle (Optimized)..."
    flutter build appbundle --release --split-debug-info=./debug_info --obfuscate
    echo "✅ AAB built: build/app/outputs/bundle/release/app-release.aab"
    ;;
  "ios")
    echo "🍎 Building iOS..."
    flutter build ios --release
    echo "✅ iOS build complete. Open Xcode to archive."
    ;;
  "ipa")
    echo "🍎 Building iOS IPA..."
    flutter build ipa --release
    echo "✅ IPA built: build/ios/ipa/"
    ;;
  *)
    echo "📱 Building all platforms..."
    flutter build apk --release --split-debug-info=./debug_info --obfuscate --split-per-abi
    flutter build appbundle --release --split-debug-info=./debug_info --obfuscate
    echo "✅ Android builds complete!"
    echo ""
    echo "For iOS, run: ./scripts/build_release.sh ios"
    ;;
esac

echo ""
echo "🎉 Release build complete!"
