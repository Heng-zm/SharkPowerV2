#!/usr/bin/env bash
#
# ci-check.sh — Pre-flight sanity and repository integrity check
#

set -euo pipefail

echo "=================================================="
echo "⚡ SHARK POWER V2 — PRE-FLIGHT REPOSITORY CHECK"
echo "=================================================="

# Check project structure
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_DIR"

REQUIRED_FILES=(
    "SharkPowerV2/App/SharkPowerApp.swift"
    "SharkPowerV2/App/AppRouter.swift"
    "SharkPowerV2/Core/Bluetooth/BLEScanner.swift"
    "SharkPowerV2/Core/Bluetooth/BLEConnection.swift"
    "SharkPowerV2/Core/Bluetooth/BLECommandQueue.swift"
    "SharkPowerV2/Core/Device/SharkPowerProtocol.swift"
    "SharkPowerV2/Features/Preview/LEDPreviewView.swift"
    "SharkPowerV2/Features/Preview/LEDCanvasRenderer.swift"
    "SharkPowerV2/Features/Preview/ForwardAnimation.swift"
    "SharkPowerV2/Features/Preview/ReverseAnimation.swift"
    "SharkPowerV2/Features/Preview/TrailingAnimation.swift"
    "SharkPowerV2/Features/Preview/ChasingAnimation.swift"
    "SharkPowerV2/Features/Home/HomeView.swift"
    "SharkPowerV2/Features/Devices/DevicesView.swift"
    "SharkPowerV2/Features/Presets/PresetsView.swift"
    "SharkPowerV2/Features/Settings/SettingsView.swift"
    "SharkPowerV2/Resources/Info.plist"
    "ExportOptions.plist"
)

echo "🔍 Verifying required architecture files..."
MISSING=0
for FILE in "${REQUIRED_FILES[@]}"; do
    if [[ ! -f "$FILE" ]]; then
        echo "❌ Missing file: $FILE"
        MISSING=$((MISSING + 1))
    fi
done

if [[ $MISSING -gt 0 ]]; then
    echo "❌ Integrity check failed: $MISSING files missing."
    exit 1
fi

echo "✅ All core files present."

# Check for accidental hardcoded secrets or private keys
echo "🔒 Checking for committed secrets or private keys..."
if grep -rn "BEGIN [P]RIVATE KEY" . --exclude-dir=".git" --exclude-dir="build" --exclude-dir="scripts" || \
   grep -rn "BEGIN [R]SA PRIVATE KEY" . --exclude-dir=".git" --exclude-dir="build" --exclude-dir="scripts"; then
    echo "❌ SECURITY ALERT: Private key found in repository!"
    exit 1
fi

echo "✅ No private keys or secrets found."
echo "🎉 Pre-flight checks passed successfully."
