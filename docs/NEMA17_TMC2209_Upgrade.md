# NEMA 17 + TMC2209 Motor Upgrade Design

**Status:** Design Phase
**Date:** 2025-12-31
**Configuration:** 48 modules (4 rows × 12 modules), 8 driver boards, RJ45 daisy chain

---

## 1. System Overview

### 1.1 Hardware Configuration
- **Display Layout:** 4 rows × 12 modules = 48 total modules
- **Driver Boards:** 8 boards @ 6 modules each (2 boards per row)
- **Interconnect:** RJ45 daisy chain with CAT5e/6 cable
- **Motor:** NEMA 17 (17HS19-2004S1) - 200 steps/rev, 2.0A rated
- **Driver:** TMC2209 with 1/16 microstepping = 3200 steps/rev effective
- **Current:** 1.0A RMS per motor (50% of rated)
- **Power:** One PSU per row (4× 12V 15A supplies)

### 1.2 Physical Layout
```
Row 1: [Board 1: M0-M5 ] ←RJ45→ [Board 2: M6-M11 ]  ← PSU 1 (12V 15A)
Row 2: [Board 3: M12-M17] ←RJ45→ [Board 4: M18-M23]  ← PSU 2 (12V 15A)
Row 3: [Board 5: M24-M29] ←RJ45→ [Board 6: M30-M35]  ← PSU 3 (12V 15A)
Row 4: [Board 7: M36-M41] ←RJ45→ [Board 8: M42-M47]  ← PSU 4 (12V 15A)
           ↑                        ↑
       ESP32 via SPI            RJ45 OUT
```

### 1.3 Data Flow Architecture
```
ESP32 Controller (Chainlink Base or custom)
  ↓
  ├─ SPI Bus: MOSI, MISO, CLK, Latch (4 wires)
  ├─ UART Bus: TX/RX for TMC2209 configuration (2 wires)
  └─ Power: 5V logic power
  ↓
[Board 1] ═RJ45═> [Board 2] ═RJ45═> ... ═RJ45═> [Board 8]
    ↓                ↓                              ↓
 6× TMC2209       6× TMC2209                    6× TMC2209
    ↓                ↓                              ↓
 6× NEMA 17       6× NEMA 17                    6× NEMA 17
    ↓                ↓                              ↓
 6× Hall Sensor   6× Hall Sensor                6× Hall Sensor
```

---

## 2. Power Distribution

### 2.1 Per-Row Power Requirements
**Each row has:**
- 2 boards × 6 modules = 12 modules
- 12 motors × 1.0A @ 12V = **12A @ 12V = 144W per row**

### 2.2 Recommended Power Architecture

**Four Independent PSUs (one per row):**
- 4× 12V 15A (180W) switched power supplies
- Each PSU powers one row (2 boards, 12 modules)
- Provides 25% power headroom (15A available, 12A used)

**Benefits:**
- **Fault isolation:** If one PSU fails, only that row is affected
- **Heat distribution:** Four smaller PSUs vs one giant hot PSU
- **Easier wiring:** Short power runs from PSU to row
- **Lower cost:** 4× small PSUs cheaper than 1× 60A PSU
- **Redundancy:** Can keep 3 rows operational during maintenance

**Wire Gauge:**
- **14 AWG recommended** for 12A @ 12V (rated to 15A, minimal voltage drop)
- Keep power cable runs under 10 feet to minimize voltage drop
- Use XT30 or barrel jack connectors (rated 15A+)

### 2.3 Total System Power Budget
- 48 motors × 1.0A @ 12V = 576W (all running)
- 48 motors × 0.5A @ 12V = 288W (all idle with hold current)
- Logic + sensors = ~10W
- **Total maximum: ~590W**

---

## 3. Hardware Specifications

### 3.1 Motor Comparison

| Parameter | 28BYJ-48 (Old) | NEMA 17 17HS19-2004S1 (New) |
|-----------|----------------|------------------------------|
| Native steps/rev | 2048 (with 1:64 gearbox) | 200 (1.8° step angle) |
| Effective steps/rev | 2048 | 3200 (with 1/16 µstep) |
| Rated current | ~240mA @ 5V | 2000mA @ 12-24V |
| Operating current | 240mA @ 5V | 1000mA @ 12V (50% rated) |
| Holding torque | ~30 g·cm | ~4000 g·cm @ 1.0A |
| Driver | ULN2003A (4-phase direct) | TMC2209 (STEP/DIR + UART) |
| Holding torque at rest | 0 (unpowered) | Yes (powered, adjustable) |
| Noise level | Medium | Low (StealthChop enabled) |
| Cost per motor | ~$3 | ~$15 |
| Cost per driver | ~$1 (ULN2003A) | ~$4 (TMC2209 module) |

**Key Advantage:** 13× more torque for heavy flaps, smoother motion, quieter operation

### 3.2 TMC2209 Driver Configuration

**Features to Enable:**
- **Microstepping:** 1/16 (3200 steps/rev)
- **StealthChop:** Silent operation at low speeds
- **SpreadCycle:** High-torque mode at higher speeds
- **CoolStep:** Automatic current reduction when load is light
- **StallGuard:** Stall detection (optional: sensorless homing backup)

**UART Configuration Parameters:**
```cpp
// Current limiting
#define TMC_RUN_CURRENT_MA   1000  // 1.0A RMS running
#define TMC_HOLD_CURRENT_MA   500  // 0.5A RMS holding (idle)

// Microstepping
#define TMC_MICROSTEPS         16  // 1/16 microstepping

// Features
#define TMC_STEALTHCHOP_ENABLED  true   // Quiet mode
#define TMC_COOLSTEP_ENABLED     true   // Power saving
#define TMC_STALLGUARD_THRESHOLD 10     // Stall detection sensitivity
```

---

## 4. Driver Board Design

### 4.1 Per-Board Components (6 modules each)

**Shift Registers:**
- **2× 74HC595** (output) - Generates STEP/DIR for 6 motors (12 bits total)
- **1× 74HC165** (input) - Reads hall sensors for 6 modules (6 bits total)

**Motor Drivers:**
- **6× TMC2209** stepper drivers
- STEP/DIR inputs from shift registers
- UART bus shared across all 6 drivers (unique addressing)
- Motor output: 4-pin connectors (A+, A-, B+, B-)

**Connectors:**
- **1× RJ45 input** - SPI + UART + power from previous board (or ESP32)
- **1× RJ45 output** - SPI + UART + power to next board
- **1× XT30 or barrel jack** - 12V motor power input (per row)
- **6× 4-pin motor connectors** - NEMA 17 outputs
- **6× 3-pin sensor connectors** - Hall sensors (VCC, GND, OUT)

**Power:**
- **12V input** for motor drivers (XT30 or barrel jack)
- **5V logic** from ESP32 via RJ45 or onboard 12V→5V buck converter
- **Bulk capacitors:** 100µF electrolytic + 0.1µF ceramic per TMC2209

### 4.2 RJ45 Pinout (Daisy Chain)
```
Pin 1: +12V Motor Power (or +5V logic, TBD)
Pin 2: +12V Motor Power (or +5V logic, TBD)
Pin 3: GND
Pin 4: SPI MOSI (data out from ESP32)
Pin 5: SPI MISO (sensor data in to ESP32)
Pin 6: SPI CLK (clock)
Pin 7: SPI Latch (shift register latch)
Pin 8: UART (bidirectional TX/RX shared)
```

**Note:** May use only 5V logic via RJ45, with separate 12V motor power per row via XT30/barrel jack.

### 4.3 TMC2209 UART Addressing

**Challenge:** 48 TMC2209 drivers on shared UART bus need unique addresses.

**Solution:** Board-level + driver-level addressing
```
Driver Address = (Board_ID × 6) + Local_Driver_ID

Board 0, Drivers 0-5: Address 0, 1, 2, 3, 4, 5
Board 1, Drivers 0-5: Address 6, 7, 8, 9, 10, 11
Board 2, Drivers 0-5: Address 12, 13, 14, 15, 16, 17
...
Board 7, Drivers 0-5: Address 42, 43, 44, 45, 46, 47
```

**Implementation Options:**
1. **Hardware addressing:** Use MS1/MS2 pins (4 addresses) + board select lines
2. **Software addressing:** Write UART address via TMC2209 SLAVECONF register at boot
3. **Hybrid:** Hardwire board ID, software set driver ID

### 4.4 BOM Estimate (per board)

| Component | Quantity | Unit Price | Total |
|-----------|----------|------------|-------|
| PCB (100mm × 80mm, 2-layer, 2oz copper) | 1 | $5.00 | $5.00 |
| TMC2209 modules | 6 | $4.00 | $24.00 |
| 74HC595 shift registers | 2 | $0.30 | $0.60 |
| 74HC165 shift register | 1 | $0.30 | $0.30 |
| RJ45 jacks (vertical) | 2 | $0.50 | $1.00 |
| 4-pin motor connectors (screw terminal) | 6 | $0.50 | $3.00 |
| 3-pin sensor connectors (JST-XH) | 6 | $0.30 | $1.80 |
| Bulk capacitors (100µF electrolytic) | 6 | $0.15 | $0.90 |
| Ceramic capacitors (0.1µF) | 12 | $0.05 | $0.60 |
| Resistors (pull-ups, etc.) | 20 | $0.02 | $0.40 |
| XT30 or barrel jack (12V power input) | 1 | $1.00 | $1.00 |
| **Total per board** | | | **~$38.60** |

**For 8 boards:** ~$309

---

## 5. Firmware Architecture Changes

### 5.1 Current Firmware (28BYJ-48)

**Motor Control:**
```cpp
// 4-bit phase patterns (direct coil control)
#define MOT_PHASE_A 0b00001000
#define MOT_PHASE_B 0b00000100
#define MOT_PHASE_C 0b00000010
#define MOT_PHASE_D 0b00000001

const uint8_t step_pattern[] = {
    MOT_PHASE_A | MOT_PHASE_B,  // Energize coils A+B
    MOT_PHASE_B | MOT_PHASE_C,  // Energize coils B+C
    MOT_PHASE_C | MOT_PHASE_D,  // Energize coils C+D
    MOT_PHASE_D | MOT_PHASE_A,  // Energize coils D+A
};

// Stepping: cycle through phase patterns
current_phase = (current_phase + 1) % 4;
SetMotor(step_pattern[current_phase]);
```

**Steps per revolution:**
```cpp
#define STEPS_PER_REVOLUTION 2048  // 28BYJ-48 with 1:64 gearbox
```

**Buffer sizes (6 modules):**
```cpp
#define NUM_MODULES 6
#define MOTOR_BUFFER_LENGTH 3  // 6 modules × 4 bits ÷ 8 = 3 bytes
#define SENSOR_BUFFER_LENGTH 1 // 6 modules × 1 bit ÷ 8 = 1 byte
```

### 5.2 New Firmware (NEMA 17 + TMC2209)

**Motor Control:**
```cpp
// 2-bit STEP/DIR control
#define MOT_STEP 0b00000010  // Bit 1: STEP pulse
#define MOT_DIR  0b00000001  // Bit 0: Direction

// Stepping: pulse STEP pin, set DIR based on direction
void TakeStep(bool direction) {
    SetMotorStepDir(true, direction);   // STEP high
    delayMicroseconds(2);                // Min pulse width (TMC2209: 100ns)
    SetMotorStepDir(false, direction);  // STEP low
    current_step += direction ? 1 : -1;
}

inline void SetMotorStepDir(bool step, bool dir) {
    uint8_t bits = (step ? MOT_STEP : 0) | (dir ? MOT_DIR : 0);
    motor_out &= ~(0b11 << motor_bitshift);  // Clear 2 bits
    motor_out |= (bits << motor_bitshift);   // Set new value
}
```

**Steps per revolution:**
```cpp
#define STEPS_PER_REVOLUTION 3200  // NEMA 17: 200 × 16 microsteps
```

**Buffer sizes (48 modules):**
```cpp
#define NUM_MODULES 48
#define MOTOR_BUFFER_LENGTH 12  // 48 modules × 2 bits ÷ 8 = 12 bytes
#define SENSOR_BUFFER_LENGTH 6  // 48 modules × 1 bit ÷ 8 = 6 bytes
```

### 5.3 Motor Abstraction Layer (NEW)

**Goal:** Support both old and new motors with compile-time selection.

**New files to create:**
- `firmware/src/motor_driver.h` - Abstract base class
- `firmware/src/motor_28byj48.h` - Legacy 4-phase implementation
- `firmware/src/motor_nema17_tmc.h` - New STEP/DIR implementation
- `firmware/src/tmc2209_uart.h` - TMC2209 UART driver

**Architecture:**
```cpp
// motor_driver.h - Abstract interface
class MotorDriver {
public:
    virtual void Init() = 0;
    virtual void TakeStep(bool direction) = 0;
    virtual void Stop() = 0;
    virtual uint16_t GetStepsPerRevolution() = 0;
};

// motor_28byj48.h - Legacy implementation
class Motor28BYJ48 : public MotorDriver {
private:
    uint8_t current_phase = 0;
    static const uint8_t step_pattern[4];
public:
    void Init() override { /* ... */ }
    void TakeStep(bool direction) override {
        current_phase = (current_phase + (direction ? 1 : -1)) & 0x03;
        SetMotor(step_pattern[current_phase]);
    }
    uint16_t GetStepsPerRevolution() override { return 2048; }
};

// motor_nema17_tmc.h - New implementation
class MotorNEMA17TMC : public MotorDriver {
public:
    void Init() override { /* Configure TMC2209 via UART */ }
    void TakeStep(bool direction) override {
        SetMotorStepDir(true, direction);
        delayMicroseconds(2);
        SetMotorStepDir(false, direction);
    }
    uint16_t GetStepsPerRevolution() override { return 3200; }
};
```

**Compile-time selection in platformio.ini:**
```ini
[env:nema17_48modules]
build_flags =
    -DMOTOR_TYPE=MOTOR_NEMA17_TMC
    -DNUM_MODULES=48
    -DTMC2209_ENABLED=true
```

### 5.4 TMC2209 Initialization (NEW)

**File:** `firmware/src/tmc2209_uart.h`

**Initialization sequence:**
```cpp
void InitTMC2209Drivers() {
    // Initialize UART (9600 baud for TMC2209)
    Serial2.begin(9600, SERIAL_8N1, TMC_RX_PIN, TMC_TX_PIN);

    for (uint8_t addr = 0; addr < NUM_MODULES; addr++) {
        // Configure each driver via UART
        TMC2209_WriteRegister(addr, REG_GCONF,
            GCONF_PDN_DISABLE |       // Use UART, not legacy mode
            GCONF_MSTEP_REG_SELECT |  // Microstep via register
            GCONF_MULTISTEP_FILT      // Pulse filtering
        );

        TMC2209_WriteRegister(addr, REG_CHOPCONF,
            (4 << 24) |  // MRES = 4 (1/16 microstepping)
            (2 << 15) |  // TBL = 2 (comparator blank time)
            (1 << 17)    // CHM = 1 (SpreadCycle)
        );

        TMC2209_WriteRegister(addr, REG_IHOLD_IRUN,
            (16 << 8) |  // IRUN = 16 (~1.0A RMS)
            (8 << 0) |   // IHOLD = 8 (~0.5A RMS)
            (10 << 16)   // IHOLDDELAY = 10 (hold delay)
        );

        TMC2209_WriteRegister(addr, REG_TPOWERDOWN, 128);  // 2s idle timeout

        delay(10);  // Allow driver to initialize
    }
}
```

**UART Protocol:**
- TMC2209 uses proprietary UART protocol (8N1, 9600-500k baud)
- Registers are 32-bit, accessed via read/write commands
- CRC8 checksum for data integrity
- Can use TMCStepper library for Arduino

---

## 6. Motion Control Updates

### 6.1 Steps Per Revolution Change

**Impact:**
```cpp
// Old
#define STEPS_PER_REVOLUTION 2048
// Steps per flap: 2048 ÷ 52 = 39.4 steps

// New
#define STEPS_PER_REVOLUTION 3200
// Steps per flap: 3200 ÷ 52 = 61.5 steps
```

**Higher resolution = better position accuracy!**

### 6.2 Acceleration Profile Regeneration

**Current parameters** (in `firmware/src/generate_acceleration.py`):
```python
MIN_PERIOD_MICROS = 1600   # Fastest: 625 steps/sec
MAX_PERIOD_MICROS = 10000  # Slowest: 100 steps/sec
ACCEL_TIME_MICROS = 200000 # Ramp time: 200ms
```

**Proposed new parameters** (needs testing!):
```python
MIN_PERIOD_MICROS = 800    # Faster: 1250 steps/sec
MAX_PERIOD_MICROS = 6000   # Starting: 167 steps/sec
ACCEL_TIME_MICROS = 150000 # Shorter ramp: 150ms
```

**Rationale:**
- NEMA 17 has no gearbox → faster acceleration possible
- TMC2209 microstepping → smoother motion at higher speeds
- Higher torque → can handle faster ramps without stalling

**Must test and tune based on:**
- Actual flap weight and inertia
- Mechanical friction in module
- Desired noise level
- Position accuracy requirements

### 6.3 Home Calibration Parameter Updates

**Old:**
```cpp
#define _ROUGH_STEPS_PER_FLAP (2048 / 52)  // ~39 steps
#define HOME_ERROR_MARGIN_STEPS (_ROUGH_STEPS_PER_FLAP / 4)  // ~10 steps
#define UNEXPECTED_HOME_START_BUFFER_STEPS (_ROUGH_STEPS_PER_FLAP * 5)  // ~195 steps
```

**New:**
```cpp
#define _ROUGH_STEPS_PER_FLAP (3200 / 52)  // ~61 steps
#define HOME_ERROR_MARGIN_STEPS (_ROUGH_STEPS_PER_FLAP / 4)  // ~15 steps
#define UNEXPECTED_HOME_START_BUFFER_STEPS (_ROUGH_STEPS_PER_FLAP * 5)  // ~307 steps
```

**Higher resolution = tighter accuracy!**

---

## 7. Implementation Plan

### Phase 1: Firmware Infrastructure (Week 1)
- [ ] Create motor abstraction layer (`motor_driver.h`, base classes)
- [ ] Refactor existing code into `Motor28BYJ48` class
- [ ] Implement `MotorNEMA17TMC` class with STEP/DIR logic
- [ ] Add compile-time motor type selection
- [ ] Update buffer sizes for 48 modules
- [ ] Test compilation for both motor types

### Phase 2: TMC2209 UART Driver (Week 2)
- [ ] Create `tmc2209_uart.h` with register definitions
- [ ] Implement UART read/write functions (or integrate TMCStepper library)
- [ ] Implement initialization sequence
- [ ] Add diagnostic register reading (DRV_STATUS, TSTEP, SG_RESULT)
- [ ] Test UART communication with single TMC2209

### Phase 3: Prototype Hardware (Week 2-3)
- [ ] Design single-module test board (1 TMC2209, 1 motor, 1 sensor)
- [ ] Order PCBs and parts
- [ ] Assemble prototype board
- [ ] Test STEP/DIR control with oscilloscope
- [ ] Verify UART configuration
- [ ] Tune current limiting (measure with current probe)

### Phase 4: Full Driver Board (Week 3-4)
- [ ] Design full 6-module driver board with shift registers
- [ ] Add RJ45 daisy chain connectors
- [ ] Route 12V motor power, 5V logic
- [ ] Order PCBs (8× boards)
- [ ] Order all components (BOM ~$309 total)
- [ ] Assemble boards (or use JLCPCB SMD assembly)

### Phase 5: Integration & Testing (Week 4-5)
- [ ] Test single board (6 modules)
- [ ] Test RJ45 daisy chain (2 boards, 12 modules)
- [ ] Test full system (8 boards, 48 modules)
- [ ] Regenerate and tune acceleration profile
- [ ] Tune home calibration windows
- [ ] Measure power consumption per row
- [ ] Stress test: 24-hour continuous operation
- [ ] Thermal testing (driver temps, motor temps)

### Phase 6: Documentation & Release (Week 5-6)
- [ ] Update CLAUDE.md with new motor configuration
- [ ] Create assembly instructions for driver boards
- [ ] Document TMC2209 tuning parameters
- [ ] Create troubleshooting guide
- [ ] Release firmware with dual motor support
- [ ] Publish PCB design files (KiCad or EasyEDA)

---

## 8. Testing Strategy

### 8.1 Unit Tests (Software)
- Motor abstraction layer (mock hardware, verify interface)
- TMC2209 UART register read/write (loopback test)
- Shift register buffer manipulation (verify STEP/DIR bits)
- Acceleration profile generation (verify smooth ramp)

### 8.2 Hardware Tests (Single Module)

**Test Bench:**
- 1 driver board (prototype)
- 1 NEMA 17 motor
- 1 hall sensor
- 12V PSU + current probe
- Logic analyzer on SPI bus
- Oscilloscope on STEP/DIR lines

**Test Cases:**
1. **UART Configuration:** Write/read TMC2209 registers, verify values
2. **STEP Pulse Output:** Verify pulse width, frequency, timing
3. **DIR Signal:** Verify direction control (CW/CCW rotation)
4. **Current Limiting:** Measure motor current, verify 1.0A ±10%
5. **Microstepping:** Verify smooth motion with 1/16 microstepping
6. **Home Calibration:** Verify sensor detection, position reset
7. **Acceleration Profile:** Verify smooth ramp up/down
8. **Position Accuracy:** Move to each flap, verify ±1 step accuracy
9. **Thermal:** Run continuous for 1 hour, measure driver/motor temp

### 8.3 Integration Tests (Multi-Module)

**6-Module Board Test:**
- All 6 motors running simultaneously
- Independent control of each module
- SPI shift register timing verification
- Power consumption measurement (6× 1A = 6A @ 12V)

**12-Module Daisy Chain Test:**
- 2 boards connected via RJ45
- Signal integrity check (SPI, UART, sensors)
- Verify addressing (modules 0-11)
- Power distribution (12A @ 12V per row)

**48-Module Full System Test:**
- All 8 boards operational
- Display all characters sequentially
- Stress test: Random character changes for 24 hours
- Total power consumption (48× 1A = 50A @ 12V = 600W)
- Thermal management (ambient temp in enclosure)

---

## 9. Risk Mitigation

### 9.1 Technical Risks

| Risk | Impact | Mitigation |
|------|--------|------------|
| UART addressing fails with 48 drivers | High | Start with 6 drivers, verify before scaling |
| Signal integrity issues in long daisy chain | Medium | Test with 2-3 boards first, add buffers if needed |
| EMI from stepper motors | Medium | Add ferrite beads, shielded cables, proper grounding |
| Thermal issues (48 motors = 600W heat) | High | Thermal testing, adequate cooling/ventilation |
| Insufficient torque for heavy flaps | Low | NEMA 17 has 13× more torque than 28BYJ-48 |
| Position accuracy issues at higher speeds | Medium | Start with conservative acceleration, tune carefully |

### 9.2 Mechanical Risks

| Risk | Impact | Mitigation |
|------|--------|------------|
| Motor mounting doesn't fit NEMA 17 | High | Verify mechanical interface early, design adapter if needed |
| Faster acceleration causes flap bounce | Medium | Tune acceleration profile conservatively |
| Vibration from direct-drive motor | Medium | Add damping, tune StealthChop parameters |

### 9.3 Budget Risks

| Item | Estimated | Actual | Buffer |
|------|-----------|--------|--------|
| 48× NEMA 17 motors | $720 | TBD | 10% |
| 48× TMC2209 drivers | $192 | TBD | 10% |
| 8× driver boards (PCB + parts) | $309 | TBD | 20% |
| 4× PSUs (12V 15A) | $120 | TBD | 10% |
| Wire, connectors, misc | $100 | TBD | 50% |
| **Total** | **$1,441** | | ~15% |

**Cost vs old system:** ~4× more expensive, but significantly better performance

---

## 10. Future Enhancements

### 10.1 Sensorless Homing (StallGuard)
- TMC2209 can detect physical endstop via StallGuard
- Could eliminate hall sensors (save $0.50 × 48 = $24)
- Requires extensive tuning per module
- Keep sensors for now, add sensorless as optional feature

### 10.2 Dynamic Current Adjustment
- TMC2209 CoolStep reduces current automatically when load is light
- Could implement per-module current tuning via web UI
- Adjust based on flap weight (heavy cardstock vs thin plastic)

### 10.3 Real-Time Diagnostics
- Monitor driver status via UART (temp, stall events, load)
- Display diagnostics on web dashboard
- Alert if driver overheating or motor stalling
- Log errors for troubleshooting

### 10.4 Per-Module Configuration Storage
- Store motor parameters in EEPROM per module
- Current limit, acceleration profile, StallGuard threshold
- Allows fine-tuning individual modules with different flap weights

---

## 11. References

### Datasheets
- [TMC2209 Datasheet (PDF)](https://www.trinamic.com/fileadmin/assets/Products/ICs_Documents/TMC2209_Datasheet_V103.pdf)
- [NEMA 17 17HS19-2004S1 (STEPPERONLINE)](https://www.omc-stepperonline.com/nema-17-bipolar-0-4a-40ncm-56-7oz-in-42x42x48mm-4-wires-w-1m-cable-connector-17hs19-2004s1)
- [74HC595 Shift Register (TI)](https://www.ti.com/lit/ds/symlink/sn74hc595.pdf)
- [74HC165 Shift Register (TI)](https://www.ti.com/lit/ds/symlink/cd74hc165.pdf)

### Libraries
- [TMCStepper (Arduino)](https://github.com/teemuatlut/TMCStepper) - Full-featured TMC2209 library
- [FastAccelStepper](https://github.com/gin66/FastAccelStepper) - Alternative acceleration lib

### Firmware Files (To Modify)
- `/firmware/src/splitflap_module.h` - Main motor control logic
- `/firmware/src/config.h` - Configuration
- `/firmware/src/acceleration.h` - Auto-generated acceleration table
- `/firmware/src/generate_acceleration.py` - Acceleration generator script
- `/firmware/esp32/core/splitflap_task.cpp` - Main task loop
- `/platformio.ini` - Build configuration

### Related Documentation
- `/docs/MotorControlLogic.md` - Current motor control explanation (28BYJ-48)
- `/docs/Assembly.md` - Assembly guide (will need update)
- `/CLAUDE.md` - Development guide
- `/electronics/chainlinkDriver/` - Current Chainlink Driver PCB (reference)

---

## Appendix: Quick Reference

### Key Parameter Changes

| Parameter | Old (28BYJ-48) | New (NEMA 17 + TMC2209) |
|-----------|----------------|--------------------------|
| Steps/revolution | 2048 | 3200 |
| Steps/flap | ~39 | ~61 |
| Motor control | 4-bit phase | 2-bit STEP/DIR |
| Motor current | 240mA @ 5V | 1000mA @ 12V |
| Holding torque | 0 (unpowered) | Yes (~0.5A idle) |
| Buffer size (48 modules) | 24 bytes motor + 6 bytes sensor | 12 bytes motor + 6 bytes sensor |
| Pin count | 4 (SPI only) | 6 (SPI + UART) |
| Power per row (12 modules) | ~1.5A @ 5V = 7.5W | ~12A @ 12V = 144W |

### Configuration Summary

```cpp
// platformio.ini
[env:nema17_48modules]
build_flags =
    -DMOTOR_TYPE=MOTOR_NEMA17_TMC
    -DNUM_MODULES=48
    -DSTEPS_PER_REVOLUTION=3200
    -DTMC2209_ENABLED=true
    -DTMC_RUN_CURRENT_MA=1000
    -DTMC_HOLD_CURRENT_MA=500
    -DTMC_MICROSTEPS=16
```

---

## Document Status

- **2025-12-31:** Initial design document created
- **Next:** Hardware prototyping and firmware implementation
- **Target:** Full system operational within 6 weeks
