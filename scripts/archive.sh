#!/usr/bin/env bash
#
# archive.sh — Build Release and create .xcarchive for Shark Power V2
#

set -euo pipefail

echo "=================================================="
echo "⚡ SHARK POWER V2 — ARCHIVE SCRIPT"
echo "=================================================="

if ! command -v xcodebuild >/dev/null 2>&1; then
    echo "❌ Error: xcodebuild is not installed or not in PATH."
    exit 1
fi

PROJECT="SharkPowerV2.xcodeproj"
SCHEME="SharkPowerV2"
CONFIGURATION="Release"
ARCHIVE_PATH="build/SharkPowerV2.xcarchive"

mkdir -p build

echo "🧹 Cleaning project..."
xcodebuild clean \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -quiet

echo "📦 Archiving $SCHEME into $ARCHIVE_PATH..."
xcodebuild archive \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -destination "generic/platform=iOS" \
    -archivePath "$ARCHIVE_PATH" \
    CODE_SIGNING_ALLOWED=NO

if [[ -d "$ARCHIVE_PATH" ]]; then
    echo "✅ Archive successfully created at $ARCHIVE_PATH"
else
    echo "❌ Failed to create archive."
    exit 1
fi
