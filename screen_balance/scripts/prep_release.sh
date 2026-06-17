#!/bin/bash
# Prepare for Release Build
# Run this BEFORE building release in Android Studio or Xcode

set -e

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Navigate to the project root (one level up from scripts/)
cd "$SCRIPT_DIR/.."

echo "🔧 Preparing for release build..."

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get


echo ""
echo "✅ Ready for release build!"
echo ""
echo "Next steps:"
echo "  • Android: Build APK/AAB in Android Studio or run 'flutter build apk --release'"
echo "  • iOS: Open Xcode, select 'Any iOS Device', then Product → Archive"
