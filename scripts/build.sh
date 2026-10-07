#!/usr/bin/env bash
#
# build.sh — Clean build for Shark Power V2 iOS Application
#

set -euo pipefail

echo "=================================================="
echo "⚡ SHARK POWER V2 — BUILD SCRIPT"
echo "=================================================="

# Detect Xcode
if ! command -v xcodebuild >/dev/null 2>&1; then
    echo "❌ Error: xcodebuild is not installed or not in PATH."
    echo "This script must be executed in macOS with Xcode installed."
    exit 1
fi

CONFIGURATION="${1:-Release}"
SCHEME="SharkPowerV2"
PROJECT="SharkPowerV2.xcodeproj"
DESTINATION="generic/platform=iOS"

echo "📦 Project:       $PROJECT"
echo "🎯 Scheme:        $SCHEME"
echo "⚙️  Configuration: $CONFIGURATION"
echo "📱 Destination:   $DESTINATION"

echo "🧹 Cleaning previous build artifacts..."
xcodebuild clean \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -quiet

echo "🔨 Building $SCHEME ($CONFIGURATION)..."
xcodebuild build \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -destination "$DESTINATION" \
    CODE_SIGNING_ALLOWED=NO

echo "✅ Build completed successfully."
