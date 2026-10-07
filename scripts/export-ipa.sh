#!/usr/bin/env bash
#
# export-ipa.sh — Export .xcarchive to .ipa (signed or sideloadable/unsigned) and validate
#

set -euo pipefail

echo "=================================================="
echo "⚡ SHARK POWER V2 — IPA EXPORT SCRIPT"
echo "=================================================="

ARCHIVE_PATH="build/SharkPowerV2.xcarchive"
EXPORT_OPTIONS="ExportOptions.plist"
EXPORT_DIR="build/ipa"
APP_PATH="$ARCHIVE_PATH/Products/Applications/SharkPowerV2.app"

if [[ ! -d "$ARCHIVE_PATH" ]]; then
    echo "❌ Error: Archive not found at $ARCHIVE_PATH. Run ./scripts/archive.sh first."
    exit 1
fi

mkdir -p "$EXPORT_DIR"

EXPORT_SUCCESS=false

# Try official xcodebuild exportArchive if ExportOptions.plist exists and signing is configured
if [[ -f "$EXPORT_OPTIONS" && "${HAS_SIGNING:-false}" == "true" ]]; then
    echo "📦 Exporting signed archive with $EXPORT_OPTIONS..."
    if xcodebuild -exportArchive \
        -archivePath "$ARCHIVE_PATH" \
        -exportPath "$EXPORT_DIR" \
        -exportOptionsPlist "$EXPORT_OPTIONS" -quiet; then
        EXPORT_SUCCESS=true
        echo "✅ Official signed export completed."
    else
        echo "⚠️ xcodebuild -exportArchive failed, falling back to direct Payload packaging."
    fi
fi

# Fallback: package direct Payload/ application bundle into standard IPA
if [[ "$EXPORT_SUCCESS" == "false" ]]; then
    if [[ ! -d "$APP_PATH" ]]; then
        echo "❌ Error: Application bundle not found at $APP_PATH."
        exit 1
    fi
    echo "📦 Packaging IPA directly from archive application bundle..."
    PAYLOAD_DIR="$EXPORT_DIR/Payload"
    rm -rf "$PAYLOAD_DIR"
    mkdir -p "$PAYLOAD_DIR"
    cp -R "$APP_PATH" "$PAYLOAD_DIR/"
    
    IPA_NAME="${IPA_FILENAME:-SharkPowerV2.ipa}"
    (cd "$EXPORT_DIR" && zip -qr "$IPA_NAME" Payload)
    rm -rf "$PAYLOAD_DIR"
    echo "✅ Direct IPA packaging completed: $EXPORT_DIR/$IPA_NAME"
fi

# Search for the exported .ipa
IPA_PATH=$(find "$EXPORT_DIR" -name "*.ipa" | head -n 1)

if [[ -z "$IPA_PATH" || ! -f "$IPA_PATH" ]]; then
    echo "❌ Error: No .ipa file found in $EXPORT_DIR."
    exit 1
fi

echo "🔍 Validating IPA integrity..."
if [[ ! -s "$IPA_PATH" ]]; then
    echo "❌ Error: IPA is empty."
    exit 1
fi

if ! unzip -tq "$IPA_PATH" >/dev/null 2>&1; then
    echo "❌ Error: IPA is not a valid zip archive."
    exit 1
fi

if ! unzip -l "$IPA_PATH" | grep -q "Payload/.*\.app"; then
    echo "❌ Error: IPA does not contain valid Payload/.app package."
    exit 1
fi

echo "✅ IPA validation passed successfully: $IPA_PATH"
