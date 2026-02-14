#!/bin/bash
# Upload motor/sensor test to ESP32
#
# This script compiles and uploads the test program to your TTGO T-Display ESP32

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT_DIR="$( cd "$SCRIPT_DIR/.." && pwd )"

echo "=== Motor/Sensor Test Upload Script ==="
echo ""
echo "This will upload a test program that:"
echo "  - Spins both motors 50 revolutions"
echo "  - Logs each sensor hit"
echo "  - Verifies breadboard wiring"
echo ""

# Check if platformio is available
if ! command -v pio &> /dev/null; then
    echo "Error: PlatformIO CLI not found"
    echo "Install with: pip install platformio"
    exit 1
fi

# Create temporary test environment in platformio.ini
echo "Creating temporary test environment..."

# Backup original platformio.ini if not already backed up
if [ ! -f "$ROOT_DIR/platformio.ini.backup" ]; then
    cp "$ROOT_DIR/platformio.ini" "$ROOT_DIR/platformio.ini.backup"
    echo "  ✓ Backed up platformio.ini"
fi

# Append test environment to platformio.ini
cat >> "$ROOT_DIR/platformio.ini" << 'EOF'

; === TEMPORARY TEST ENVIRONMENT ===
; This environment is for motor/sensor testing
; Remove this section after testing

[env:motor_sensor_test]
platform = espressif32
board = esp32dev
framework = arduino
board_build.partitions = default.csv
board_build.flash_mode = dio
monitor_speed = 115200
monitor_filters = direct
upload_speed = 921600
build_flags =
    -DCORE_DEBUG_LEVEL=3
build_src_filter =
    +<test_motor_sensors.cpp>
    -<*>
lib_deps = SPI

EOF

echo "  ✓ Added test environment to platformio.ini"

# Change to project root
cd "$ROOT_DIR"

# Compile
echo ""
echo "Compiling test program..."
pio run -e motor_sensor_test

# Upload
echo ""
echo "Uploading to ESP32..."
echo "Make sure your ESP32 is connected via USB!"
pio run -e motor_sensor_test -t upload

# Monitor
echo ""
echo "Starting serial monitor..."
echo "Press Ctrl+C to exit"
echo ""
pio device monitor -e motor_sensor_test

# Cleanup on exit
cleanup() {
    echo ""
    echo "Restoring original platformio.ini..."
    if [ -f "$ROOT_DIR/platformio.ini.backup" ]; then
        mv "$ROOT_DIR/platformio.ini.backup" "$ROOT_DIR/platformio.ini"
        echo "  ✓ Restored"
    fi
}
trap cleanup EXIT
