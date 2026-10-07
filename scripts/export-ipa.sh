#!/usr/bin/env bash
#
# export-ipa.sh — Export .xcarchive to .ipa using ExportOptions.plist and validate
#

set -euo pipefail

echo "=================================================="
echo "⚡ SHARK POWER V2 — IPA EXPORT SCRIPT"
echo "=================================================="

ARCHIVE_PATH="build/SharkPowerV2.xcarchive"
EXPORT_OPTIONS="ExportOptions.plist"
EXPORT_DIR="build/ipa"

if [[ ! -d "$ARCHIVE_PATH" ]]; then
    echo "❌ Error: Archive not found at $ARCHIVE_PATH. Run ./scripts/archive.sh first."
    exit 1
fi

if [[ ! -f "$EXPORT_OPTIONS" ]]; then
    echo "❌ Error: ExportOptions.plist not found at $EXPORT_OPTIONS."
    exit 1
fi

mkdir -p "$EXPORT_DIR"

echo "📦 Exporting archive with $EXPORT_OPTIONS to $EXPORT_DIR..."
xcodebuild -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportPath "$EXPORT_DIR" \
    -exportOptionsPlist "$EXPORT_OPTIONS"

# Search for the exported .ipa
IPA_PATH=$(find "$EXPORT_DIR" -name "*.ipa" | head -n 1)

if [[ -z "$IPA_PATH" || ! -f "$IPA_PATH" ]]; then
    echo "❌ Error: IPA file was not generated in $EXPORT_DIR."
    echo "Note: If code signing was not configured, an exportable signed IPA cannot be produced."
    exit 1
fi

echo "🔍 Validating IPA integrity..."
if [[ ! -s "$IPA_PATH" ]]; then
    echo "❌ Error: IPA is empty."
    exit 1
fi

# Check if IPA is a valid zip archive containing Payload/*.app
if ! unzip -tq "$IPA_PATH" >/dev/null 2>&1; then
    echo "❌ Error: IPA is not a valid zip archive."
    exit 1
fi

if ! unzip -l "$IPA_PATH" | grep -q "Payload/.*\.app"; then
    echo "❌ Error: IPA does not contain valid Payload/.app package."
    exit 1
fi

echo "✅ IPA validation passed successfully: $IPA_PATH"
