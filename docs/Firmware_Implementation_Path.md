# NEMA 17 + TMC2209 Firmware Implementation Path

**Document Purpose:** Step-by-step guide to implement and test firmware for NEMA 17 motors with TMC2209 drivers

**Target:** Get from "motor not spinning" to "full closed-loop split-flap control"

**Estimated Time:** 4-8 hours over 1-2 days

---

## 📋 **Prerequisites**

Before starting firmware work, you need:

### **Hardware**
- [ ] NEMA 17 motor (17HS19-2004S1 or similar)
- [ ] TMC2209 driver board (e.g., BTT TMC2209 V1.2, or custom PCB)
- [ ] ESP32 development board (any variant)
- [ ] 12-24V power supply for motor
- [ ] USB cable for ESP32 programming
- [ ] Breadboard and jumper wires (for prototyping)
- [ ] Hall sensor (for Phase 3)
- [ ] Optional: Logic analyzer or oscilloscope (for debugging)

### **Software**
- [ ] PlatformIO installed
- [ ] This repository cloned
- [ ] USB drivers for ESP32
- [ ] Serial monitor (built into PlatformIO)

### **Knowledge**
- [ ] Basic terminal/command line usage
- [ ] How to upload firmware to ESP32
- [ ] How to read serial output

---

## 🎯 **Implementation Overview**

We'll implement in 4 phases, each building on the previous:

```
Phase 1: Basic Motor Test (1-2 hours)
  └─> Motor spins via STEP/DIR

Phase 2: TMC2209 Configuration (1-2 hours)
  └─> Smooth motion with microstepping

Phase 3: Hall Sensor & Homing (2-3 hours)
  └─> Closed-loop position control

Phase 4: Scale to Multiple Modules (1-2 hours)
  └─> Full system integration
```

**Each phase has:**
- Clear objectives
- Code to implement
- Tests to verify
- Troubleshooting tips

---

## 📍 **Phase 1: Basic Motor Test**

**Goal:** Make ONE motor spin using STEP/DIR signals from ESP32

**Time:** 1-2 hours

**Success Criteria:** Motor rotates continuously when ESP32 sends STEP pulses

---

### **1.1 Hardware Setup**

**Wiring Diagram:**
```
ESP32          TMC2209         NEMA 17         Power Supply
-----          -------         -------         ------------
GPIO 25 -----> STEP
GPIO 26 -----> DIR
GPIO 27 -----> EN (Enable)
GND ----------> GND ----------> GND ------------> GND
                VM+ ----------> (not connected)-> +12V (motor power)
                A1/A2 ---------> Coil A
                B1/B2 ---------> Coil B
```

**Pin Assignments (default, you can change):**
- STEP: GPIO 25
- DIR: GPIO 26
- EN (Enable): GPIO 27 (optional, can tie low if not used)

**Power:**
- ESP32: 5V via USB
- TMC2209 VM+: 12-24V (motor power, separate from ESP32!)
- TMC2209 VDD: 3.3V or 5V (logic power, from ESP32 or separate)

**CRITICAL:** Motor power (VM+) and ESP32 power must share COMMON GROUND!

---

### **1.2 TMC2209 Standalone Mode Setup**

For Phase 1, use **standalone mode** (no UART needed):

**DIP Switches / Jumpers on TMC2209:**
- MS1: High (or leave open)
- MS2: High (or leave open)
- This sets 1/16 microstepping in standalone mode

**Current Limiting (VERY IMPORTANT!):**
TMC2209 has a tiny potentiometer (Vref) to set current:
1. Measure Vref with multimeter (between pot center and GND)
2. Target Vref for 1.0A motor: ~0.9V
3. Formula: Vref = I_rms × 2.5 × R_sense
   - For 1.0A: Vref ≈ 0.9V (with 0.11Ω sense resistor)
4. Adjust pot GENTLY (1/8 turn at a time)

**Without proper current limiting, motor will overheat or driver will shut down!**

---

### **1.3 Code: Simple STEP Test**

Create test file: `firmware/test/motor_step_test.cpp`

```cpp
/*
  Phase 1: Basic STEP/DIR Motor Test

  This code sends STEP pulses to make the motor rotate.
  No TMC2209 UART, no hall sensor, just basic motion.
*/

#include <Arduino.h>

// Pin definitions (change if needed)
#define STEP_PIN 25
#define DIR_PIN  26
#define EN_PIN   27

// Timing parameters
#define STEP_DELAY_US 1000  // 1000µs = 1ms between steps (1000 steps/sec)

void setup() {
  Serial.begin(115200);
  Serial.println("Phase 1: Basic Motor Test");

  // Configure pins
  pinMode(STEP_PIN, OUTPUT);
  pinMode(DIR_PIN, OUTPUT);
  pinMode(EN_PIN, OUTPUT);

  // Enable driver (LOW = enabled for most TMC2209 boards)
  digitalWrite(EN_PIN, LOW);

  // Set direction (HIGH = CW, LOW = CCW)
  digitalWrite(DIR_PIN, HIGH);

  delay(1000);  // Wait for driver to power up
  Serial.println("Starting motor rotation...");
}

void loop() {
  // Take one step
  digitalWrite(STEP_PIN, HIGH);
  delayMicroseconds(5);  // Minimum pulse width
  digitalWrite(STEP_PIN, LOW);
  delayMicroseconds(STEP_DELAY_US);

  // Optional: Print every 200 steps
  static int step_count = 0;
  step_count++;
  if (step_count % 200 == 0) {
    Serial.print("Steps: ");
    Serial.println(step_count);
  }
}
```

---

### **1.4 Upload and Test**

**Upload Code:**
```bash
cd /Users/paulhawk/Dropbox/projects/splitflap/splitflap
# Create test environment if needed
pio run -t upload
```

**Expected Behavior:**
1. Motor should start rotating immediately after upload
2. Serial monitor shows step count every 200 steps
3. Motor should rotate smoothly (may be slow)

**Troubleshooting:**

| Problem | Likely Cause | Solution |
|---------|--------------|----------|
| Motor doesn't move | EN pin wrong polarity | Try `digitalWrite(EN_PIN, HIGH)` |
| Motor stutters | Current too low | Increase Vref on TMC2209 |
| Motor overheats | Current too high | Decrease Vref |
| Motor vibrates in place | Wiring wrong | Check A/B coil connections |
| Nothing happens | No power | Check VM+ has 12V |
| Driver thermal shutdown | Overheating | Add heatsink, reduce current |

---

### **1.5 Experiments**

Once motor is spinning, try:

**Change speed:**
```cpp
#define STEP_DELAY_US 500   // Faster: 2000 steps/sec
#define STEP_DELAY_US 2000  // Slower: 500 steps/sec
```

**Change direction:**
```cpp
digitalWrite(DIR_PIN, LOW);  // Reverse direction
```

**Count rotations:**
```cpp
// 200 steps/rev × 16 microsteps = 3200 steps per rotation
if (step_count % 3200 == 0) {
  Serial.println("Completed 1 rotation!");
}
```

---

### **1.6 Phase 1 Success Criteria**

- [x] Motor rotates continuously
- [x] Can change speed by adjusting STEP_DELAY_US
- [x] Can reverse direction
- [x] Motor doesn't overheat (stays warm, not hot)
- [x] No strange noises (grinding, squealing)

**Once all checked, proceed to Phase 2!**

---

## 📍 **Phase 2: TMC2209 Configuration via UART**

**Goal:** Configure TMC2209 via UART for optimal performance

**Time:** 1-2 hours

**Success Criteria:**
- Motor runs smoother (StealthChop at low speed)
- Current control via firmware (no pot adjustment)
- Can read driver status

---

### **2.1 Hardware Setup**

**Add UART connection:**
```
ESP32          TMC2209
-----          -------
GPIO 16 -----> TX (TMC2209 RX)
GPIO 17 -----> RX (TMC2209 TX)
```

**Note:** Some TMC2209 boards have a single PDN_UART pin that's bidirectional. Check your specific board!

---

### **2.2 Add TMCStepper Library**

**Option A: Use TMCStepper Library (Recommended)**

Add to `platformio.ini`:
```ini
[env:test_nema17]
platform = espressif32
board = esp32dev
framework = arduino
lib_deps =
    teemuatlut/TMCStepper @ ^0.7.3
build_flags =
    -DMOTOR_TYPE=MOTOR_NEMA17_TMC
```

**Option B: Write Custom UART Code**
(More advanced, skip for now)

---

### **2.3 Code: TMC2209 with UART**

Create: `firmware/test/motor_tmc_uart_test.cpp`

```cpp
/*
  Phase 2: TMC2209 UART Configuration

  Configure TMC2209 via UART for optimal settings:
  - 1/16 microstepping
  - 1.0A RMS current
  - StealthChop for quiet operation
*/

#include <Arduino.h>
#include <TMCStepper.h>

// Pin definitions
#define STEP_PIN    25
#define DIR_PIN     26
#define EN_PIN      27
#define SERIAL_PORT Serial2  // Use Serial2 for TMC2209 UART
#define DRIVER_ADDRESS 0b00  // TMC2209 address (set by MS1/MS2 pins)
#define R_SENSE 0.11f        // Sense resistor value (check your board!)

// Create TMC2209 driver object
TMC2209Stepper driver(&SERIAL_PORT, R_SENSE, DRIVER_ADDRESS);

void setup() {
  Serial.begin(115200);
  Serial.println("Phase 2: TMC2209 UART Configuration");

  // Setup UART for TMC2209 (16/17 are default Serial2 pins on ESP32)
  SERIAL_PORT.begin(115200, SERIAL_8N1, 16, 17);

  // Setup step/dir pins
  pinMode(STEP_PIN, OUTPUT);
  pinMode(DIR_PIN, OUTPUT);
  pinMode(EN_PIN, OUTPUT);

  digitalWrite(EN_PIN, LOW);  // Enable driver
  digitalWrite(DIR_PIN, HIGH);

  delay(100);

  // Configure TMC2209 via UART
  driver.begin();
  driver.toff(5);                 // Enable driver
  driver.rms_current(1000);       // Set current to 1000mA (1.0A RMS)
  driver.microsteps(16);          // 1/16 microstepping
  driver.pwm_autoscale(true);     // Automatic current scaling
  driver.en_spreadCycle(false);   // Use StealthChop (quiet mode)

  Serial.println("TMC2209 configured!");

  // Read back settings to verify
  Serial.print("RMS Current: ");
  Serial.println(driver.rms_current());
  Serial.print("Microsteps: ");
  Serial.println(driver.microsteps());

  delay(1000);
  Serial.println("Starting motor...");
}

void loop() {
  // Same stepping code as Phase 1
  digitalWrite(STEP_PIN, HIGH);
  delayMicroseconds(5);
  digitalWrite(STEP_PIN, LOW);
  delayMicroseconds(800);  // Faster now: 1250 steps/sec

  // Every 3200 steps (1 rotation), print status
  static int step_count = 0;
  step_count++;

  if (step_count % 3200 == 0) {
    Serial.print("Rotation ");
    Serial.print(step_count / 3200);
    Serial.print(" - Status: ");

    // Read driver status
    uint32_t drv_status = driver.DRV_STATUS();
    if (drv_status & 0x80000000) {
      Serial.println("STALL DETECTED!");
    } else if (drv_status & 0x01000000) {
      Serial.println("Overtemp warning!");
    } else {
      Serial.println("OK");
    }
  }
}
```

---

### **2.4 Upload and Test**

**Upload:**
```bash
pio run -e test_nema17 -t upload
pio device monitor
```

**Expected Output:**
```
Phase 2: TMC2209 UART Configuration
TMC2209 configured!
RMS Current: 1000
Microsteps: 16
Starting motor...
Rotation 1 - Status: OK
Rotation 2 - Status: OK
...
```

**Motor should:**
- Run MUCH quieter than Phase 1 (StealthChop!)
- Feel smoother
- Stay cooler (proper current limiting)

---

### **2.5 Tune Parameters**

**Adjust Current:**
```cpp
driver.rms_current(800);   // Lower current (0.8A) - cooler, less torque
driver.rms_current(1400);  // Higher current (1.4A) - more torque, hotter
```

**Change Microstepping:**
```cpp
driver.microsteps(8);    // 1/8: Faster but less smooth
driver.microsteps(32);   // 1/32: Smoother but slower max speed
```

**Switch to SpreadCycle (high-speed mode):**
```cpp
driver.en_spreadCycle(true);  // Better for high speeds, louder
```

---

### **2.6 Phase 2 Success Criteria**

- [x] Motor runs quieter than Phase 1 (StealthChop working)
- [x] Can set current via firmware (no pot twiddling)
- [x] Can read driver status (no errors)
- [x] Serial monitor shows successful UART communication
- [x] Motor temperature reasonable (~40-50°C under load)

**Once all checked, proceed to Phase 3!**

---

## 📍 **Phase 3: Hall Sensor & Closed-Loop Control**

**Goal:** Add hall sensor for position feedback and automatic homing

**Time:** 2-3 hours

**Success Criteria:**
- Motor finds home position automatically
- Can command "go to flap 10" and motor goes there
- Position stays accurate over time

---

### **3.1 Hardware Setup**

**Add hall sensor:**
```
Hall Sensor    ESP32
-----------    -----
VCC ---------> 3.3V
GND ---------> GND
OUT ---------> GPIO 34 (input only pin)
```

**Magnet placement:**
- Attach small magnet to spool/pulley
- Position so hall sensor triggers once per revolution
- Test with LED: sensor output goes LOW when magnet passes

---

### **3.2 Code: Homing and Position Control**

This integrates with existing `splitflap_module.h` code.

**Modify:** `firmware/src/config.h`

Add:
```cpp
// Motor type selection
#define MOTOR_28BYJ48      1
#define MOTOR_NEMA17_TMC   2

#ifndef MOTOR_TYPE
  #define MOTOR_TYPE MOTOR_NEMA17_TMC
#endif

// NEMA 17 specific settings
#if MOTOR_TYPE == MOTOR_NEMA17_TMC
  #define STEPS_PER_REVOLUTION 3200  // 200 × 16 microsteps
  #define MOTOR_BITS_PER_MODULE 2    // STEP + DIR
#else
  #define STEPS_PER_REVOLUTION 2048  // 28BYJ-48 default
  #define MOTOR_BITS_PER_MODULE 4    // 4-phase
#endif
```

---

### **3.3 Implement Motor Abstraction**

**Create:** `firmware/src/motor_nema17_tmc.h`

```cpp
#ifndef MOTOR_NEMA17_TMC_H
#define MOTOR_NEMA17_TMC_H

#include "motor_config.h"

#if MOTOR_TYPE == MOTOR_NEMA17_TMC

struct MotorNEMA17TMCState {
    bool last_step_state;
    MotorNEMA17TMCState() : last_step_state(false) {}
};

inline void Motor_Init(uint8_t module_id) {
    // TMC2209 UART init happens globally, nothing per-module
}

inline void Motor_Step(
    MotorNEMA17TMCState& state,
    uint8_t& motor_out,
    uint8_t motor_bitshift,
    bool direction
) {
    // Set direction
    motor_out &= ~(0b11 << motor_bitshift);
    if (direction) {
        motor_out |= (MOT_DIR << motor_bitshift);
    }
    // Set STEP high
    motor_out |= (MOT_STEP << motor_bitshift);
    state.last_step_state = true;
}

inline void Motor_ClearStep(
    MotorNEMA17TMCState& state,
    uint8_t& motor_out,
    uint8_t motor_bitshift
) {
    if (state.last_step_state) {
        motor_out &= ~(MOT_STEP << motor_bitshift);
        state.last_step_state = false;
    }
}

inline void Motor_Stop(
    MotorNEMA17TMCState& state,
    uint8_t& motor_out,
    uint8_t motor_bitshift
) {
    motor_out &= ~(MOT_STEP << motor_bitshift);
    state.last_step_state = false;
}

#endif // MOTOR_TYPE == MOTOR_NEMA17_TMC
#endif // MOTOR_NEMA17_TMC_H
```

---

### **3.4 Update Main Code**

**Modify:** `firmware/src/splitflap_module.h`

```cpp
// Add at top
#include "motor_config.h"

#if MOTOR_TYPE == MOTOR_28BYJ48
  #include "motor_28byj48.h"
  using MotorState = Motor28BYJ48State;
#elif MOTOR_TYPE == MOTOR_NEMA17_TMC
  #include "motor_nema17_tmc.h"
  using MotorState = MotorNEMA17TMCState;
#endif

// In Update() function, replace motor stepping code:
if (current_accel_step > 0 && delta_steps > 0) {
    Motor_Step(motor_state, motor_out, motor_bitshift, true);

    current_step++;
    if (current_step >= STEPS_PER_REVOLUTION) {
        current_step = 0;
    }
    delta_steps--;

    CheckSensor();

    #if MOTOR_TYPE == MOTOR_NEMA17_TMC
        Motor_ClearStep(motor_state, motor_out, motor_bitshift);
    #endif
} else {
    Motor_Stop(motor_state, motor_out, motor_bitshift);
}
```

---

### **3.5 Test Homing**

**Upload and monitor:**
```bash
pio run -e chainlink -t upload
pio device monitor
```

**Expected behavior:**
1. Motor rotates on startup (looking for home)
2. When magnet passes sensor, motor stops
3. Reports "Home found" via serial
4. Can now send position commands

**Test commands (via serial):**
```
#=A     // Go to letter 'A'
#=5     // Go to number '5'
#=Z     // Go to letter 'Z'
```

---

### **3.6 Phase 3 Success Criteria**

- [x] Motor finds home position on startup
- [x] Can command specific flap positions
- [x] Motor stops at correct position
- [x] Position stays accurate (no drift)
- [x] Home sensor triggers reliably
- [x] No missed steps or position errors

**Once all checked, proceed to Phase 4!**

---

## 📍 **Phase 4: Scale to Multiple Modules**

**Goal:** Control multiple motors simultaneously

**Time:** 1-2 hours

**Success Criteria:**
- 6+ modules working together
- Independent position control
- Synchronized motion

---

### **4.1 Update Configuration**

**Modify:** `platformio.ini`

```ini
[env:chainlink_nema17]
extends = esp32base
build_flags =
    ${esp32base.build_flags}
    -DCHAINLINK
    -DNUM_MODULES=6
    -DMOTOR_TYPE=2              # MOTOR_NEMA17_TMC
    -DSPI_IO
    -DTMC2209_UART_ENABLED
```

---

### **4.2 Buffer Sizing**

**Verify in:** `firmware/src/motor_config.h`

```cpp
#define NUM_MODULES 6
#define MOTOR_BUFFER_LENGTH ((NUM_MODULES * MOTOR_BITS_PER_MODULE + 7) / 8)
// For 6 modules × 2 bits = 12 bits = 2 bytes

#define SENSOR_BUFFER_LENGTH ((NUM_MODULES + 7) / 8)
// For 6 modules × 1 bit = 6 bits = 1 byte
```

---

### **4.3 TMC2209 Addressing**

For multiple TMC2209 drivers, each needs unique address:

```cpp
void InitAllTMC2209() {
    for (uint8_t addr = 0; addr < NUM_MODULES; addr++) {
        TMC2209Stepper driver(&Serial2, R_SENSE, addr);
        driver.begin();
        driver.rms_current(1000);
        driver.microsteps(16);
        delay(10);
    }
}
```

**Set addresses via MS1/MS2 pins on each driver:**
- Driver 0: MS1=0, MS2=0 (addr 0)
- Driver 1: MS1=1, MS2=0 (addr 1)
- Driver 2: MS1=0, MS2=1 (addr 2)
- Driver 3: MS1=1, MS2=1 (addr 3)
- For >4 drivers, need external addressing logic

---

### **4.4 Test Multi-Module**

**Upload:**
```bash
pio run -e chainlink_nema17 -t upload
```

**Test commands:**
```
=HELLO     // Display "HELLO" across 5 modules
=123456    // Display numbers
```

**Expected:**
- All modules home simultaneously
- Each module moves independently
- Display updates smoothly
- No interference between modules

---

### **4.5 Phase 4 Success Criteria**

- [x] 6+ modules operational
- [x] Independent position control
- [x] Can display different characters
- [x] All modules home correctly
- [x] No crosstalk or interference
- [x] System stable over time

---

## 🎉 **Completion!**

**You now have:**
- ✅ NEMA 17 motors running
- ✅ TMC2209 configured optimally
- ✅ Closed-loop position control
- ✅ Multiple modules working
- ✅ Ready for mechanical integration!

---

## 🔧 **Common Issues & Solutions**

### **Motor Stutters or Vibrates**
- Check Vref (current setting)
- Verify wiring (A/B coils correct?)
- Reduce acceleration
- Add decoupling capacitors

### **UART Communication Fails**
- Check Serial2 pins (16/17)
- Verify baud rate (115200)
- Check common ground
- Try different driver address

### **Home Sensor Not Triggering**
- Check sensor polarity (active HIGH or LOW?)
- Verify magnet strength
- Test sensor with LED
- Check pull-up resistor

### **Position Drifts Over Time**
- Enable home re-calibration
- Check for missed steps
- Increase holding current
- Verify mechanical coupling

### **Driver Overheats**
- Reduce current
- Add heatsink
- Improve airflow
- Check for stalled motor

---

## 📚 **References**

**Documentation:**
- `docs/Firmware_Motor_Selection.md` - Architecture overview
- `docs/MotorControlLogic.md` - Current motor control algorithm
- `CLAUDE.md` - General development guide

**Code Files:**
- `firmware/src/splitflap_module.h` - Main motor control
- `firmware/src/motor_config.h` - Configuration
- `firmware/src/motor_nema17_tmc.h` - NEMA 17 implementation
- `platformio.ini` - Build configuration

**External Resources:**
- [TMC2209 Datasheet](https://www.trinamic.com/fileadmin/assets/Products/ICs_Documents/TMC2209_Datasheet_V103.pdf)
- [TMCStepper Library](https://github.com/teemuatlut/TMCStepper)
- [ESP32 Arduino Core](https://github.com/espressif/arduino-esp32)

---

**Document Version:** 1.0
**Date:** 2025-12-31
**Status:** Ready for Implementation
