#!/bin/zsh
set -euo pipefail

DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
export DEVELOPER_DIR

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DERIVED_DATA_PATH="/tmp/TapLogDerived"
APP_PATH="$DERIVED_DATA_PATH/Build/Products/Debug-iphonesimulator/TapLog.app"
OUTPUT_DIR="$ROOT_DIR/AppStoreScreenshots"

IPHONE_DEVICE_ID="264B953D-4708-4CE2-8F73-8010D429B684"
IPAD_DEVICE_ID="E1276396-0AEE-458E-ADE5-0162D7EE50AD"
BUNDLE_ID="com.zec.TapLog"

mkdir -p "$OUTPUT_DIR"

xcrun simctl boot "$IPHONE_DEVICE_ID" || true
xcrun simctl boot "$IPAD_DEVICE_ID" || true
xcrun simctl bootstatus "$IPHONE_DEVICE_ID" -b
xcrun simctl bootstatus "$IPAD_DEVICE_ID" -b
xcrun simctl ui "$IPHONE_DEVICE_ID" appearance light
xcrun simctl ui "$IPAD_DEVICE_ID" appearance light

xcrun simctl install "$IPHONE_DEVICE_ID" "$APP_PATH"
xcrun simctl install "$IPAD_DEVICE_ID" "$APP_PATH"

capture_shot() {
    local device_id="$1"
    local mode="$2"
    local raw_file="$3"
    local final_file="$4"
    local height="$5"
    local width="$6"

    xcrun simctl terminate "$device_id" "$BUNDLE_ID" || true
    xcrun simctl launch "$device_id" "$BUNDLE_ID" --app-store-screenshot "$mode"
    sleep 2
    xcrun simctl io "$device_id" screenshot --type=png "$raw_file"
    sips -z "$height" "$width" "$raw_file" --out "$final_file" >/dev/null
}

capture_shot \
    "$IPHONE_DEVICE_ID" \
    "today" \
    "$OUTPUT_DIR/iphone_today_raw.png" \
    "$OUTPUT_DIR/iphone_today.png" \
    "2778" \
    "1284"

capture_shot \
    "$IPHONE_DEVICE_ID" \
    "history" \
    "$OUTPUT_DIR/iphone_history_raw.png" \
    "$OUTPUT_DIR/iphone_history.png" \
    "2778" \
    "1284"

capture_shot \
    "$IPAD_DEVICE_ID" \
    "today" \
    "$OUTPUT_DIR/ipad_today_raw.png" \
    "$OUTPUT_DIR/ipad_today.png" \
    "2732" \
    "2048"

capture_shot \
    "$IPAD_DEVICE_ID" \
    "history" \
    "$OUTPUT_DIR/ipad_history_raw.png" \
    "$OUTPUT_DIR/ipad_history.png" \
    "2732" \
    "2048"

echo "Generated screenshots in $OUTPUT_DIR"
