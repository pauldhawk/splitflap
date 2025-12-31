# Firmware Motor Selection Architecture

**Status:** Implementation Guide
**Date:** 2025-12-31
**Approach:** Compile-time motor type selection with zero runtime overhead

---

## Overview

This document describes the implementation of compile-time motor selection in the splitflap firmware. This architecture allows the same codebase to support multiple motor types (28BYJ-48 and NEMA 17 + TMC2209) through build-time configuration, with zero runtime overhead.

**Key Benefits:**
- ✅ Single codebase for all motor types
- ✅ Existing 28BYJ-48 systems continue to work
- ✅ New NEMA 17 systems fully supported
- ✅ Zero runtime overhead (unused code compiled out)
- ✅ Easy to test and compare both motors
- ✅ Future-proof (can add more motor types)

---

## Architecture Principles

### 1. Compile-Time Selection
- Motor type selected at **build time** via PlatformIO build flags
- Preprocessor directives (`#if`, `#elif`, `#else`) select code paths
- Compiler optimizes away unused code (zero bloat)
- No runtime if/else checks (no performance penalty)

### 2. Shared Core Logic
The following components are **motor-independent** and remain unchanged:
- Serial protocol (plaintext and protobuf)
- COBS encoding/decoding
- Hall sensor calibration logic
- Position tracking and error detection
- Protobuf message handling
- SPI shift register I/O
- Main update loop orchestration

### 3. Motor-Specific Code
Only the following components differ between motor types:
- Motor output bit patterns (4-bit phase vs 2-bit STEP/DIR)
- Steps per revolution (2048 vs 3200)
- Stepping logic (~20 lines of code)
- Motor initialization
- Buffer sizing calculations

**Result:** ~95% code sharing, ~5% motor-specific

---

## Implementation Strategy

### Phase 1: Isolate Motor-Specific Code (Week 1)
Identify and mark all motor-specific code with preprocessor guards:
```cpp
#if MOTOR_TYPE == MOTOR_28BYJ48
    // Existing 4-phase motor code
#else
    #error "Unknown motor type"
#endif
```

### Phase 2: Add NEMA 17 Support (Week 2)
Add parallel implementation for NEMA 17:
```cpp
#if MOTOR_TYPE == MOTOR_28BYJ48
    // Existing 4-phase motor code
#elif MOTOR_TYPE == MOTOR_NEMA17_TMC
    // New STEP/DIR motor code
#else
    #error "Unknown motor type"
#endif
```

### Phase 3: Test Both Configurations (Week 3)
- Build and test `chainlink` environment (28BYJ-48)
- Build and test `chainlink_nema17` environment (NEMA 17)
- Verify both work correctly
- Compare performance metrics

### Phase 4: Refactor if Needed (Week 4)
If preprocessor approach becomes messy, refactor to class-based abstraction.

---

## File Structure

### New Files to Create

```
firmware/src/
├── motor_config.h          ← NEW: Motor type definitions and selection
├── motor_28byj48.h         ← NEW: 28BYJ-48 specific code (refactored from splitflap_module.h)
├── motor_nema17_tmc.h      ← NEW: NEMA 17 + TMC2209 specific code
├── tmc2209_uart.h          ← NEW: TMC2209 UART driver (optional, for advanced features)
└── splitflap_module.h      ← MODIFIED: Use motor abstraction
```

### Files to Modify

```
firmware/
├── platformio.ini          ← ADD: New build environments for NEMA 17
├── src/
│   ├── config.h            ← MODIFY: Include motor_config.h
│   ├── splitflap_module.h  ← MODIFY: Use motor abstraction
│   └── acceleration.h      ← REGENERATE: For different steps/rev
└── esp32/core/
    └── splitflap_task.cpp  ← MODIFY: Initialize TMC2209 if enabled
```

---

## Detailed Implementation

### Step 1: Create `motor_config.h`

**File:** `firmware/src/motor_config.h`

```cpp
#ifndef MOTOR_CONFIG_H
#define MOTOR_CONFIG_H

#include <stdint.h>

// Motor type enumeration
#define MOTOR_28BYJ48      1
#define MOTOR_NEMA17_TMC   2

// Default to 28BYJ-48 if not specified
#ifndef MOTOR_TYPE
  #define MOTOR_TYPE MOTOR_28BYJ48
#endif

// Motor-specific constants
#if MOTOR_TYPE == MOTOR_28BYJ48

  // 28BYJ-48 Configuration
  #define STEPS_PER_REVOLUTION 2048
  #define MOTOR_BITS_PER_MODULE 4   // 4 bits for phase control
  #define MOTOR_INIT_REQUIRED false  // No special initialization

  // Phase bit definitions
  #define MOT_PHASE_A 0b00001000
  #define MOT_PHASE_B 0b00000100
  #define MOT_PHASE_C 0b00000010
  #define MOT_PHASE_D 0b00000001

#elif MOTOR_TYPE == MOTOR_NEMA17_TMC

  // NEMA 17 + TMC2209 Configuration
  #define STEPS_PER_REVOLUTION 3200  // 200 * 16 microsteps
  #define MOTOR_BITS_PER_MODULE 2    // 2 bits for STEP/DIR
  #define MOTOR_INIT_REQUIRED true   // Need to configure TMC2209

  // STEP/DIR bit definitions
  #define MOT_STEP 0b00000010  // Bit 1
  #define MOT_DIR  0b00000001  // Bit 0

  // TMC2209 configuration
  #define TMC2209_UART_ENABLED
  #define TMC_RUN_CURRENT_MA   1000
  #define TMC_HOLD_CURRENT_MA  500
  #define TMC_MICROSTEPS       16
  #define TMC_STEALTHCHOP_ENABLED

#else
  #error "Invalid MOTOR_TYPE. Must be MOTOR_28BYJ48 or MOTOR_NEMA17_TMC"
#endif

// Calculate buffer sizes based on motor type and module count
#ifndef NUM_MODULES
  #define NUM_MODULES 6  // Default
#endif

// Motor output buffer size (bits → bytes, rounded up)
#define MOTOR_BUFFER_LENGTH ((NUM_MODULES * MOTOR_BITS_PER_MODULE + 7) / 8)

// Sensor input buffer size (1 bit per module)
#define SENSOR_BUFFER_LENGTH ((NUM_MODULES + 7) / 8)

// Derived constants
#define _ROUGH_STEPS_PER_FLAP (STEPS_PER_REVOLUTION / NUM_FLAPS)

#endif // MOTOR_CONFIG_H
```

---

### Step 2: Create `motor_28byj48.h`

**File:** `firmware/src/motor_28byj48.h`

```cpp
#ifndef MOTOR_28BYJ48_H
#define MOTOR_28BYJ48_H

#include "motor_config.h"

#if MOTOR_TYPE == MOTOR_28BYJ48

// 4-phase stepping pattern for 28BYJ-48
// Energizes 2 coils at a time for smooth motion
const uint8_t step_pattern[] = {
    MOT_PHASE_A | MOT_PHASE_B,  // Phase 0: A+B
    MOT_PHASE_B | MOT_PHASE_C,  // Phase 1: B+C
    MOT_PHASE_C | MOT_PHASE_D,  // Phase 2: C+D
    MOT_PHASE_D | MOT_PHASE_A,  // Phase 3: D+A
};

// Motor-specific state (per module)
struct Motor28BYJ48State {
    uint8_t current_phase;  // Current phase (0-3)

    Motor28BYJ48State() : current_phase(0) {}
};

// Motor initialization (no-op for 28BYJ-48)
inline void Motor_Init(uint8_t module_id) {
    // 28BYJ-48 needs no special initialization
}

// Take a step in the specified direction
inline void Motor_Step(
    Motor28BYJ48State& state,
    uint8_t& motor_out,
    uint8_t motor_bitshift,
    bool direction
) {
    // Update phase
    if (direction) {
        state.current_phase = (state.current_phase + 1) % 4;
    } else {
        state.current_phase = (state.current_phase + 3) % 4;  // -1 mod 4
    }

    // Clear old motor bits
    motor_out &= ~(0b1111 << motor_bitshift);

    // Set new motor bits
    motor_out |= (step_pattern[state.current_phase] << motor_bitshift);
}

// Stop motor (de-energize coils)
inline void Motor_Stop(
    Motor28BYJ48State& state,
    uint8_t& motor_out,
    uint8_t motor_bitshift
) {
    motor_out &= ~(0b1111 << motor_bitshift);
}

#endif // MOTOR_TYPE == MOTOR_28BYJ48

#endif // MOTOR_28BYJ48_H
```

---

### Step 3: Create `motor_nema17_tmc.h`

**File:** `firmware/src/motor_nema17_tmc.h`

```cpp
#ifndef MOTOR_NEMA17_TMC_H
#define MOTOR_NEMA17_TMC_H

#include "motor_config.h"

#if MOTOR_TYPE == MOTOR_NEMA17_TMC

// Motor-specific state (per module)
struct MotorNEMA17TMCState {
    bool last_step_state;  // Track STEP pin state

    MotorNEMA17TMCState() : last_step_state(false) {}
};

// Motor initialization
// Note: TMC2209 UART configuration happens once at system startup,
// not per-module (see tmc2209_uart.h)
inline void Motor_Init(uint8_t module_id) {
    // Per-module init (if needed)
    // Global TMC2209 UART init happens in splitflap_task.cpp
}

// Take a step in the specified direction
inline void Motor_Step(
    MotorNEMA17TMCState& state,
    uint8_t& motor_out,
    uint8_t motor_bitshift,
    bool direction
) {
    // Clear old motor bits
    motor_out &= ~(0b11 << motor_bitshift);

    // Set direction bit
    if (direction) {
        motor_out |= (MOT_DIR << motor_bitshift);
    }

    // Pulse STEP pin
    // Note: Actual pulse happens in shift register update cycle
    // We just toggle the bit here, the SPI write creates the pulse
    motor_out |= (MOT_STEP << motor_bitshift);
    state.last_step_state = true;
}

// Clear STEP pulse (called after Motor_Step)
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

// Stop motor (keep DIR, clear STEP)
inline void Motor_Stop(
    MotorNEMA17TMCState& state,
    uint8_t& motor_out,
    uint8_t motor_bitshift
) {
    motor_out &= ~(MOT_STEP << motor_bitshift);
    state.last_step_state = false;
    // Note: Motor holds position due to TMC2209 hold current
}

#endif // MOTOR_TYPE == MOTOR_NEMA17_TMC

#endif // MOTOR_NEMA17_TMC_H
```

---

### Step 4: Modify `splitflap_module.h`

**File:** `firmware/src/splitflap_module.h` (key changes)

```cpp
#ifndef SPLITFLAP_MODULE_H
#define SPLITFLAP_MODULE_H

#include "motor_config.h"

// Include motor-specific implementations
#if MOTOR_TYPE == MOTOR_28BYJ48
  #include "motor_28byj48.h"
  using MotorState = Motor28BYJ48State;
#elif MOTOR_TYPE == MOTOR_NEMA17_TMC
  #include "motor_nema17_tmc.h"
  using MotorState = MotorNEMA17TMCState;
#endif

class SplitflapModule {
private:
    // Motor state (type selected at compile time)
    MotorState motor_state;

    // Motor output reference (shift register buffer)
    uint8_t& motor_out;
    uint8_t motor_bitshift;

    // Sensor input reference
    const uint8_t& sensor_in;
    uint8_t sensor_bitmask;

    // Position tracking
    uint16_t current_step;      // Current position (0 to STEPS_PER_REVOLUTION-1)
    uint16_t target_step;       // Target position
    uint16_t delta_steps;       // Steps remaining to target

    // Motion control
    uint8_t current_accel_step; // Current speed level (0-72)
    uint16_t current_period;    // Microseconds between steps
    unsigned long last_update_micros;

    // Calibration
    uint8_t target_flap_index;
    int16_t offset_steps;
    // ... (rest of calibration state)

public:
    SplitflapModule(
        uint8_t& motor_output_byte,
        uint8_t motor_bitshift,
        const uint8_t& sensor_input_byte,
        uint8_t sensor_bitmask
    ) : motor_out(motor_output_byte),
        motor_bitshift(motor_bitshift),
        sensor_in(sensor_input_byte),
        sensor_bitmask(sensor_bitmask),
        current_step(0),
        target_step(0),
        delta_steps(0),
        current_accel_step(0),
        current_period(ACCEL_STEP_PERIODS[0]),
        last_update_micros(0),
        target_flap_index(0),
        offset_steps(0)
    {
        // Motor-specific initialization
        Motor_Init(0);  // Module ID passed if needed
    }

    // Main update loop (called ~100 Hz)
    inline void Update() {
        unsigned long now = micros();
        unsigned long delta_time = now - last_update_micros;

        if (delta_time >= current_period) {
            last_update_micros = now;

            // Calculate target speed based on remaining distance
            uint8_t target_accel_step;
            if (delta_steps > MAX_ACCEL_STEP) {
                target_accel_step = MAX_ACCEL_STEP;  // Full speed
            } else {
                target_accel_step = delta_steps;      // Decelerate
            }

            // Smooth acceleration (±1 per update)
            if (current_accel_step < target_accel_step) {
                current_accel_step++;
            } else if (current_accel_step > target_accel_step) {
                current_accel_step--;
            }

            // Update period from acceleration table
            current_period = ACCEL_STEP_PERIODS[current_accel_step];

            // Take a step if moving
            if (current_accel_step > 0 && delta_steps > 0) {
                // Motor-specific step function
                Motor_Step(motor_state, motor_out, motor_bitshift, true);

                // Update position
                current_step++;
                if (current_step >= STEPS_PER_REVOLUTION) {
                    current_step = 0;
                }
                delta_steps--;

                // Check home sensor
                CheckSensor();

#if MOTOR_TYPE == MOTOR_NEMA17_TMC
                // Clear STEP pulse for next cycle
                Motor_ClearStep(motor_state, motor_out, motor_bitshift);
#endif
            } else {
                // Stopped
                Motor_Stop(motor_state, motor_out, motor_bitshift);
            }
        }
    }

    // Go to specific flap position
    inline void GoToFlapIndex(uint8_t index) {
        target_flap_index = index;
        target_step = GetTargetStepForFlapIndex(index);

        // Calculate shortest path
        if (current_step < target_step) {
            delta_steps = target_step - current_step;
        } else {
            delta_steps = STEPS_PER_REVOLUTION - current_step + target_step;
        }
    }

    // Calculate target step for flap index
    inline uint16_t GetTargetStepForFlapIndex(uint8_t flap) {
        uint32_t intermediate = (uint32_t)flap * (uint32_t)STEPS_PER_REVOLUTION;
        uint16_t result = (intermediate + NUM_FLAPS - 1) / NUM_FLAPS;  // Round up
        result += offset_steps;
        result %= STEPS_PER_REVOLUTION;
        return result;
    }

    // ... (rest of methods: CheckSensor, calibration, etc.)
};

#endif // SPLITFLAP_MODULE_H
```

---

### Step 5: Update `platformio.ini`

**File:** `platformio.ini` (add new environments)

```ini
# Existing environment (28BYJ-48, 6 modules)
[env:chainlink]
extends = esp32base
build_flags =
    ${esp32base.build_flags}
    -DCHAINLINK
    -DNUM_MODULES=6
    -DMOTOR_TYPE=1              # MOTOR_28BYJ48
    -DSPI_IO

# New environment (NEMA 17, 6 modules for testing)
[env:chainlink_nema17_test]
extends = esp32base
build_flags =
    ${esp32base.build_flags}
    -DCHAINLINK
    -DNUM_MODULES=6
    -DMOTOR_TYPE=2              # MOTOR_NEMA17_TMC
    -DSPI_IO
    -DTMC2209_UART_ENABLED

# New environment (NEMA 17, 48 modules)
[env:chainlink_nema17_48modules]
extends = esp32base
build_flags =
    ${esp32base.build_flags}
    -DCHAINLINK
    -DNUM_MODULES=48
    -DMOTOR_TYPE=2              # MOTOR_NEMA17_TMC
    -DSPI_IO
    -DTMC2209_UART_ENABLED

# Chainlink Base with NEMA 17 (large display)
[env:chainlink_base_nema17]
extends = esp32base
build_flags =
    ${esp32base.build_flags}
    -DCHAINLINK
    -DCHAINLINK_BASE
    -DNUM_MODULES=48
    -DMOTOR_TYPE=2              # MOTOR_NEMA17_TMC
    -DSPI_IO
    -DTMC2209_UART_ENABLED
```

---

### Step 6: Create `tmc2209_uart.h` (Optional, for advanced features)

**File:** `firmware/src/tmc2209_uart.h`

```cpp
#ifndef TMC2209_UART_H
#define TMC2209_UART_H

#if defined(TMC2209_UART_ENABLED)

#include <Arduino.h>

// TMC2209 Register Addresses
#define TMC_REG_GCONF      0x00
#define TMC_REG_GSTAT      0x01
#define TMC_REG_IOIN       0x04
#define TMC_REG_IHOLD_IRUN 0x10
#define TMC_REG_TPOWERDOWN 0x11
#define TMC_REG_TSTEP      0x12
#define TMC_REG_CHOPCONF   0x6C
#define TMC_REG_DRV_STATUS 0x6F
#define TMC_REG_PWMCONF    0x70

// TMC2209 UART configuration
#define TMC_UART_BAUD 115200
#define TMC_UART_RX_PIN 16  // Configure based on your hardware
#define TMC_UART_TX_PIN 17

// Initialize TMC2209 UART communication
void TMC2209_InitUART() {
    Serial2.begin(TMC_UART_BAUD, SERIAL_8N1, TMC_UART_RX_PIN, TMC_UART_TX_PIN);
    delay(100);
}

// Write register to TMC2209
// addr: Driver address (0-63)
// reg: Register address
// value: 32-bit value to write
void TMC2209_WriteRegister(uint8_t addr, uint8_t reg, uint32_t value) {
    // TODO: Implement TMC2209 UART write protocol
    // For now, recommend using TMCStepper library
    // Example: driver.write(reg, value);
}

// Read register from TMC2209
uint32_t TMC2209_ReadRegister(uint8_t addr, uint8_t reg) {
    // TODO: Implement TMC2209 UART read protocol
    // For now, recommend using TMCStepper library
    // Example: return driver.read(reg);
    return 0;
}

// Configure all TMC2209 drivers
void TMC2209_ConfigureAll(uint8_t num_drivers) {
    TMC2209_InitUART();

    for (uint8_t addr = 0; addr < num_drivers; addr++) {
        // GCONF: Enable UART, disable legacy mode
        TMC2209_WriteRegister(addr, TMC_REG_GCONF,
            (1 << 2) |  // PDN_DISABLE: Use UART
            (1 << 6)    // MSTEP_REG_SELECT: Microstep via register
        );

        // CHOPCONF: Configure microstepping and chopper
        uint32_t chopconf = 0;
        chopconf |= (4 << 24);  // MRES = 4 (1/16 microstepping)
        chopconf |= (2 << 15);  // TBL = 2
        TMC2209_WriteRegister(addr, TMC_REG_CHOPCONF, chopconf);

        // IHOLD_IRUN: Configure current
        // Current scaling: I_RMS = (CS + 1) / 32 * V_FS / (R_SENSE * sqrt(2))
        // For 1.0A RMS with 0.11Ω sense resistor: CS ≈ 16
        uint32_t ihold_irun = 0;
        ihold_irun |= (16 << 8);   // IRUN = 16 (~1.0A)
        ihold_irun |= (8 << 0);    // IHOLD = 8 (~0.5A)
        ihold_irun |= (10 << 16);  // IHOLDDELAY = 10
        TMC2209_WriteRegister(addr, TMC_REG_IHOLD_IRUN, ihold_irun);

        // TPOWERDOWN: Automatic current reduction timeout
        TMC2209_WriteRegister(addr, TMC_REG_TPOWERDOWN, 128);  // ~2 seconds

        delay(10);
    }
}

#endif // TMC2209_UART_ENABLED

#endif // TMC2209_UART_H
```

---

### Step 7: Modify `splitflap_task.cpp`

**File:** `firmware/esp32/core/splitflap_task.cpp` (add TMC2209 init)

```cpp
#include "config.h"
#include "motor_config.h"

#if defined(TMC2209_UART_ENABLED)
  #include "tmc2209_uart.h"
#endif

void splitflap_task_setup() {
    // ... existing setup code ...

#if MOTOR_TYPE == MOTOR_NEMA17_TMC && defined(TMC2209_UART_ENABLED)
    // Initialize TMC2209 drivers via UART
    log("Initializing TMC2209 drivers...");
    TMC2209_ConfigureAll(NUM_MODULES);
    log("TMC2209 initialization complete");
#endif

    // ... rest of setup ...
}
```

---

## Build Commands

### Build for 28BYJ-48 (existing hardware)
```bash
pio run -e chainlink
pio run -e chainlink --target upload
```

### Build for NEMA 17 (6 modules, testing)
```bash
pio run -e chainlink_nema17_test
pio run -e chainlink_nema17_test --target upload
```

### Build for NEMA 17 (48 modules, production)
```bash
pio run -e chainlink_nema17_48modules
pio run -e chainlink_nema17_48modules --target upload
```

### Build all configurations (CI/CD)
```bash
pio run -e chainlink
pio run -e chainlink_nema17_test
pio run -e chainlink_nema17_48modules
```

---

## Testing Strategy

### Phase 1: Verify 28BYJ-48 Still Works
```bash
# Build and upload to existing hardware
pio run -e chainlink --target upload

# Monitor output
pio device monitor -e chainlink

# Test: Send characters, verify motion
# Expected: Same behavior as before
```

**Success Criteria:**
- ✅ Firmware compiles without errors
- ✅ Existing 28BYJ-48 systems work identically
- ✅ No behavioral changes
- ✅ Binary size similar to before

### Phase 2: Test NEMA 17 (Single Module)
```bash
# Build for NEMA 17 (6 modules)
pio run -e chainlink_nema17_test --target upload

# Monitor output
pio device monitor -e chainlink_nema17_test

# Test with 1 module connected:
# - STEP/DIR signals on oscilloscope
# - Verify motor rotates smoothly
# - Verify home sensor detection
# - Verify position accuracy
```

**Success Criteria:**
- ✅ Firmware compiles with MOTOR_TYPE=2
- ✅ TMC2209 UART initialization succeeds
- ✅ STEP pulses visible on scope
- ✅ DIR signal changes rotation direction
- ✅ Motor rotates smoothly (no stalling)
- ✅ Home sensor detected correctly

### Phase 3: Test NEMA 17 (Full System)
```bash
# Build for 48 modules
pio run -e chainlink_nema17_48modules --target upload

# Test all modules:
# - Display all characters sequentially
# - Random character stress test
# - Verify independent control
# - Check for timing issues
```

**Success Criteria:**
- ✅ All 48 modules operational
- ✅ Independent control verified
- ✅ No SPI timing issues
- ✅ Position accuracy maintained
- ✅ System stable over 24 hours

---

## Compile-Time Verification

The preprocessor ensures only one motor type is compiled:

```bash
# Check what's compiled for 28BYJ-48
pio run -e chainlink -t compiledb
grep "MOTOR_TYPE" .pio/build/chainlink/compile_commands.json

# Check what's compiled for NEMA 17
pio run -e chainlink_nema17_test -t compiledb
grep "MOTOR_TYPE" .pio/build/chainlink_nema17_test/compile_commands.json
```

**Expected output:**
- `chainlink`: `-DMOTOR_TYPE=1`
- `chainlink_nema17_test`: `-DMOTOR_TYPE=2`

---

## Binary Size Comparison

Check that unused code is optimized away:

```bash
# Build both configurations
pio run -e chainlink
pio run -e chainlink_nema17_test

# Compare sizes
ls -lh .pio/build/chainlink/firmware.bin
ls -lh .pio/build/chainlink_nema17_test/firmware.bin
```

**Expected:** Similar sizes (within 5%), proving unused code is compiled out.

---

## Troubleshooting

### Issue: Both motor types compiled (binary too large)
**Cause:** Preprocessor directives not working correctly
**Solution:** Verify `MOTOR_TYPE` is defined in `platformio.ini` build_flags

### Issue: 28BYJ-48 system broken after changes
**Cause:** Accidentally changed shared code
**Solution:** Test both configurations in parallel during development

### Issue: TMC2209 UART communication fails
**Cause:** Wrong UART pins or baud rate
**Solution:** Verify pin assignments, use logic analyzer to debug UART

### Issue: STEP pulses too fast/slow
**Cause:** Wrong acceleration profile
**Solution:** Regenerate `acceleration.h` with correct `STEPS_PER_REVOLUTION`

---

## Future Extensions

### Adding More Motor Types

To add a third motor type (e.g., closed-loop servo):

1. Define new motor type:
```cpp
#define MOTOR_CLOSED_LOOP_SERVO 3
```

2. Create `motor_servo.h` with Motor_Init, Motor_Step, Motor_Stop

3. Update `motor_config.h`:
```cpp
#elif MOTOR_TYPE == MOTOR_CLOSED_LOOP_SERVO
  #define STEPS_PER_REVOLUTION 4096
  #define MOTOR_BITS_PER_MODULE 8
  #include "motor_servo.h"
  using MotorState = MotorServoState;
#endif
```

4. Add new PlatformIO environment

### Runtime Motor Detection (Advanced)

For mixed systems with different motor types per module:

```cpp
enum MotorTypeEnum { MOTOR_28BYJ48, MOTOR_NEMA17 };

class SplitflapModule {
    MotorTypeEnum motor_type;

    void Step() {
        switch(motor_type) {
            case MOTOR_28BYJ48: /* 4-phase */ break;
            case MOTOR_NEMA17:  /* STEP/DIR */ break;
        }
    }
};
```

**Note:** Runtime detection adds overhead. Only use if truly needed.

---

## Benefits Summary

| Aspect | Before | After (Compile-Time Selection) |
|--------|--------|--------------------------------|
| Motor support | 28BYJ-48 only | 28BYJ-48 + NEMA 17 + future |
| Code duplication | N/A | ~5% motor-specific code |
| Runtime overhead | N/A | Zero (compiled out) |
| Binary size | Baseline | +0-5% (negligible) |
| Maintainability | Good | Good (95% shared code) |
| Testing effort | Baseline | +50% (test both configs) |
| Migration path | Breaking change | Non-breaking (backward compatible) |

---

## References

### Related Documents
- `docs/NEMA17_TMC2209_Upgrade.md` - Hardware design and specifications
- `docs/MotorControlLogic.md` - Current motor control algorithm explanation
- `CLAUDE.md` - General development guide

### External References
- [TMC2209 Datasheet](https://www.trinamic.com/fileadmin/assets/Products/ICs_Documents/TMC2209_Datasheet_V103.pdf)
- [TMCStepper Arduino Library](https://github.com/teemuatlut/TMCStepper)
- [PlatformIO Build Flags](https://docs.platformio.org/en/latest/projectconf/section_env_build.html)

---

## Implementation Checklist

- [ ] Create `motor_config.h` with motor type selection
- [ ] Create `motor_28byj48.h` with existing motor code
- [ ] Create `motor_nema17_tmc.h` with new motor code
- [ ] Modify `splitflap_module.h` to use motor abstraction
- [ ] Update `platformio.ini` with new environments
- [ ] Create `tmc2209_uart.h` for TMC2209 configuration
- [ ] Modify `splitflap_task.cpp` to initialize TMC2209
- [ ] Regenerate `acceleration.h` for 3200 steps/rev
- [ ] Test build: `pio run -e chainlink` (verify no regressions)
- [ ] Test build: `pio run -e chainlink_nema17_test`
- [ ] Update documentation and CLAUDE.md
- [ ] CI/CD: Add both configurations to GitHub Actions

---

**Document Status:**
- **2025-12-31:** Implementation guide created
- **Next:** Begin Phase 1 implementation
- **Target:** Both motor types working within 2 weeks
