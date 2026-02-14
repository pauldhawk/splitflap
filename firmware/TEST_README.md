# Motor & Sensor Test

This test verifies your breadboard wiring by spinning both motors 50 times and logging each hall sensor activation.

## Quick Start (Automated)

```bash
cd /Users/paulhawk/Dropbox/projects/splitflap/splitflap/firmware
./upload_test.sh
```

The script will:
1. Backup your `platformio.ini`
2. Add a temporary test environment
3. Compile the test program
4. Upload to your ESP32
5. Open the serial monitor
6. Restore your original `platformio.ini` when you exit (Ctrl+C)

## Manual Upload (Alternative)

If the automated script doesn't work, follow these steps:

### Step 1: Add test environment to platformio.ini

Add this to the end of `/Users/paulhawk/Dropbox/projects/splitflap/splitflap/platformio.ini`:

```ini
[env:motor_sensor_test]
platform = espressif32
board = esp32dev
framework = arduino
monitor_speed = 115200
monitor_filters = direct
upload_speed = 921600
build_src_filter =
    +<test_motor_sensors.cpp>
    -<*>
lib_deps = SPI
```

### Step 2: Upload

```bash
cd /Users/paulhawk/Dropbox/projects/splitflap/splitflap
pio run -e motor_sensor_test -t upload
```

### Step 3: Monitor serial output

```bash
pio device monitor -e motor_sensor_test
```

Press `Ctrl+]` to exit the monitor.

### Step 4: Clean up

Remove the `[env:motor_sensor_test]` section from `platformio.ini` when done.

## Expected Output

You should see output like this:

```
=== Motor & Sensor Test ===
Breadboard Wiring Verification
===============================

SPI initialized:
  MOSI: GPIO25
  MISO: GPIO26
  SCK:  GPIO27
  CS:   GPIO32

Initial sensor state:
  Sensor A: inactive
  Sensor B: inactive

Starting test: 50 revolutions per motor...

[  1234] Motor A: Sensor HIT #1 (step 1024)
Motor A:  1/50 revolutions (1 sensor hits)
[  2456] Motor B: Sensor HIT #1 (step 1024)
Motor B:  1/50 revolutions (1 sensor hits)
...
[120000] Motor A: Sensor HIT #50 (step 160000)
Motor A: 50/50 revolutions (50 sensor hits)
[121000] Motor B: Sensor HIT #50 (step 160000)
Motor B: 50/50 revolutions (50 sensor hits)

===============================
=== TEST COMPLETE ===
===============================

Motor A:
  Total steps:       160000
  Total revolutions: 50
  Sensor hits:       50
  Expected hits:     ~50 (1 per revolution)
  Status:            ✓ PASS

Motor B:
  Total steps:       160000
  Total revolutions: 50
  Sensor hits:       50
  Expected hits:     ~50 (1 per revolution)
  Status:            ✓ PASS
```

## Adjusting Speed

If the motors are too fast or too slow, edit `test_motor_sensors.cpp` and change:

```cpp
#define STEP_DELAY_US 500   // Increase = slower, Decrease = faster
```

Valid range: 200-2000 microseconds

- **500µs** = ~400 steps/sec = moderate speed (default)
- **1000µs** = ~200 steps/sec = slower, smoother
- **200µs** = ~1000 steps/sec = faster (may skip steps if too fast)

Recompile after changing: `pio run -e motor_sensor_test -t upload`

## Troubleshooting

### No sensor hits

**Possible causes:**
- Hall sensors not powered (check 3.3V rail)
- Sensor signal wires not connected to 74HC165 D0/D1
- Magnets not positioned near sensors (2-5mm distance)
- Sensors inverted (check datasheet for pinout)

**Diagnostics:**
- Add `Serial.printf("Sensor raw: 0x%02X\n", sensors);` in `readSensors()` to see raw values
- Expected: `0x00` when inactive, `0x01` or `0x02` when active

### Motors don't move

**Possible causes:**
- TMC2209 not powered (check 24V on VMOT)
- ~EN pin not connected to GND (drivers disabled)
- STEP signal not reaching driver
- Motor coils not connected properly

**Diagnostics:**
- Check for blinking LED on TMC2209 breakout (indicates STEP pulses)
- Measure voltage on STEP pin with multimeter (should toggle 0V-5V)
- Verify DIR_FIXED connection (should be +5V or GND)

### Wrong direction

**Solution:**
- Change `DIR_FIXED` connection from +5V to GND (or vice versa)

### SPI errors / loopback warnings

**Note:** This test doesn't use the loopback verification (QB→D6, QC→D7). Those are only needed for the full firmware. The test directly controls STEP signals via QA and QE.

### Too many sensor hits

**Possible causes:**
- Electrical noise on sensor lines
- Magnet passing sensor multiple times (misalignment)
- Sensor bounce (rare with hall effect sensors)

**Diagnostics:**
- Add `delay(10)` in `readSensors()` to debounce
- Check for loose connections on sensor wires

## Next Steps

Once this test passes:

1. **Proceed to full firmware**: Follow `docs/Firmware_Implementation_Path.md`
2. **Calibrate motor current**: Adjust TMC2209 Vref if motors are too hot or skipping steps
3. **Test with flaps**: Attach split-flap modules and verify mechanical operation

## Test Source

The test code is in `test_motor_sensors.cpp`. It's a standalone Arduino sketch that:

- Uses SPI to control 74HC595 (output) and 74HC165 (input)
- Generates STEP pulses on QA (Motor A) and QE (Motor B)
- Reads hall sensors from D0 and D1
- Logs sensor activations with timestamps
- Reports pass/fail based on expected sensor hits (45-55 hits for 50 revolutions)

## Hardware Configuration

From your breadboard checklist:

- **Motors**: NEMA 17 with TMC2209 drivers
- **Microstepping**: 1/16 (3200 steps/revolution)
- **Direction**: Both motors rotate same direction (DIR_FIXED = +5V)
- **Sensors**: Hall effect (active-low with 1kΩ pull-ups)
- **Power**: 24V for motors, 5V for drivers, 3.3V for logic

## Safety Reminders

- **Never disconnect motors while powered** (can damage TMC2209)
- **Check electrolytic capacitor polarity** before powering on
- **Verify Vref setting** (0.9V for 1.0A motors)
- **Monitor temperature** during test (drivers should stay < 80°C)

---

**Questions or issues?** Check the breadboard wiring checklist or `docs/Firmware_Implementation_Path.md` for debugging guidance.
