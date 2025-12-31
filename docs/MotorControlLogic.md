# Motor Control Logic: How Split-Flap Modules Move to New Positions

This document explains the complete motor control algorithm used to move split-flap modules from one position to another.

## Overview

The motor control system uses a sophisticated trapezoidal velocity profile with smooth acceleration and deceleration. Each stepper motor has 2048 steps per revolution, and the controller continuously updates at approximately 100Hz to maintain precise timing and smooth motion.

## Step 1: Convert Target Letter to Step Position

```cpp
// Called when: splitflap.set_text("H") → GoToFlapIndex(7)
void GoToFlapIndex(uint8_t index) {
    target_flap_index = index;  // Store: 7 (letter 'H')
    GoToTargetFlapIndex();
}
```

**Calculate exact step position:**
```cpp
uint16_t GetTargetStepForFlapIndex(uint8_t flap) {
    // flap=7, STEPS_PER_REVOLUTION=2048, NUM_FLAPS=52
    uint32_t intermediate = 7 * 2048 = 14,336
    uint16_t result = 14,336 / 52 = 275.69... → 276 (round UP)

    result += offset_steps;  // Add calibration offset
    result %= STEPS_PER_REVOLUTION;  // Wrap around if needed

    return result;  // target_step = 276
}
```

**Key Constants:**
- `STEPS_PER_REVOLUTION = 2048` (28BYJ-48 stepper motor with built-in gearbox)
- `NUM_FLAPS = 52` (typically, for alphabet + numbers + symbols)
- Each flap ≈ 39.4 steps (2048 ÷ 52)

## Step 2: Calculate Shortest Path (with Deceleration Check)

```cpp
void GoToTargetFlapIndex() {
    uint16_t target_step = 276;  // From above
    uint16_t current_step = 100; // Where we are now

    // Can we stop in time?
    uint16_t minimum_stopping_step = current_step + current_accel_step;
    //                              = 100 + 30 = 130

    if (target_step <= minimum_stopping_step) {
        // Too close! Must go the long way around
        delta_steps = STEPS_PER_REVOLUTION - current_step + target_step;
        //          = 2048 - 100 + 276 = 2,224 steps
    } else {
        // Can reach target directly
        delta_steps = target_step - current_step;
        //          = 276 - 100 = 176 steps
    }
}
```

**Key insight:** If the motor is moving fast and the target is too close, it can't decelerate in time, so it must go "the long way" around the full circle.

## Step 3: The Main Update Loop (called ~100 Hz)

This is where the magic happens. The `Update()` function runs continuously:

```cpp
void Update() {
    // Only step when enough time has elapsed
    unsigned long now = micros();
    unsigned long delta_time = now - last_update_micros;

    if (delta_time >= current_period) {  // Time to take a step?
        last_update_micros = now;

        // Calculate target speed based on remaining distance
        uint8_t target_accel_step;

        if (delta_steps > MAX_ACCEL_STEP) {
            // Far from target → go full speed
            target_accel_step = 72;  // MAX_ACCEL_STEP
        } else {
            // Close to target → decelerate proportionally
            target_accel_step = delta_steps;  // Mirror remaining distance
        }

        // SMOOTH ACCELERATION: Change speed gradually (±1 per update)
        if (current_accel_step < target_accel_step) {
            current_accel_step++;  // Speed up
        } else if (current_accel_step > target_accel_step) {
            current_accel_step--;  // Slow down
        }

        // Update step period from acceleration table
        current_period = ACCEL_STEP_PERIODS[current_accel_step];

        // TAKE A STEP (if moving)
        if (current_accel_step > 0) {
            current_step++;  // Advance position (0-2047)
            if (current_step == 2048) current_step = 0;  // Wrap

            current_phase++;  // Advance motor phase (0-3)
            if (current_phase == 4) current_phase = 0;  // Wrap

            delta_steps--;  // One step closer to target

            // Apply motor phase pattern
            SetMotor(step_pattern[current_phase]);
        } else {
            SetMotor(0);  // Stop motor (no coils energized)
        }
    }
}
```

**Key Variables:**
- `current_step`: Current position (0-2047)
- `delta_steps`: Remaining steps to target
- `current_accel_step`: Current speed level (0-72)
- `target_accel_step`: Desired speed level
- `current_period`: Time to wait before next step (microseconds)
- `current_phase`: Motor coil phase (0-3)

## Step 4: Acceleration Profile (The Secret Sauce)

The acceleration table controls motor speed through step **period** (time between steps):

```cpp
// Acceleration table (auto-generated, in microseconds)
const uint16_t ACCEL_STEP_PERIODS[] = {
    1600,   // accel_step=0:  IDLE (slowest)
    10000,  // accel_step=1:  Starting
    7920,   // accel_step=2:  Accelerating...
    6800,   // accel_step=3:
    6064,   // accel_step=4:
    5530,   // ...continues ramping...
    // ... (72 values total) ...
    1606    // accel_step=72: MAX SPEED (fastest)
};
```

**Speed Calculation:**
- Shorter period = faster speed
- Idle: 1600µs between steps = 625 steps/sec
- Max: 1606µs between steps = 622 steps/sec (similar, but ramps through table)
- The table provides smooth transitions between speeds

**Visual representation of speed control:**
```
Distance to target: [====================================] 200 steps
Target speed:       [████████████████████████████████████] accel_step=72 (max)
Current speed:      [████████░░░░░░░░░░░░░░░░░░░░░░░░░░░░] accel_step=35
                    → Increment current_accel_step++ (speed up)

Distance to target: [=======] 25 steps
Target speed:       [█████████░░░] accel_step=25 (decelerate!)
Current speed:      [████████████████] accel_step=40
                    → Decrement current_accel_step-- (slow down)

Distance to target: [] 0 steps - ARRIVED!
Target speed:       [] accel_step=0 (stop)
Current speed:      [] accel_step=0
                    → Motor stops, current_period=1600µs (idle)
```

## Step 5: Motor Phase Stepping (28BYJ-48 Stepper)

The 4-phase pattern energizes two coils at a time for smooth motion:

```cpp
#define MOT_PHASE_A 0b00001000  // Coil A
#define MOT_PHASE_B 0b00000100  // Coil B
#define MOT_PHASE_C 0b00000010  // Coil C
#define MOT_PHASE_D 0b00000001  // Coil D

const uint8_t step_pattern[] = {
    MOT_PHASE_A | MOT_PHASE_B,  // Phase 0: A+B
    MOT_PHASE_B | MOT_PHASE_C,  // Phase 1: B+C
    MOT_PHASE_C | MOT_PHASE_D,  // Phase 2: C+D
    MOT_PHASE_D | MOT_PHASE_A,  // Phase 3: D+A
};

void SetMotor(uint8_t out) {
    // Write 4-bit pattern to GPIO/shift register
    motor_out = (motor_out & ~(0x0F << motor_bitshift))
              | ((out & 0x0F) << motor_bitshift);
}
```

**Visual motor coil sequence:**
```
Phase:  0    1    2    3    0 (repeat)
Coil A: █    ░    ░    █    █
Coil B: █    █    ░    ░    █
Coil C: ░    █    █    ░    ░
Coil D: ░    ░    █    █    ░

4 phases × 512 cycles = 2048 steps per revolution
```

**How the motor turns:**
1. Each phase energizes 2 of the 4 coils
2. The magnetic field pulls the rotor to align with energized coils
3. Switching to the next phase rotates the field 90°
4. The rotor follows, advancing 1/2048th of a revolution
5. The internal gearbox (1:64 reduction) provides torque and precision

## Complete Example: Moving from Flap 10 to Flap 15

```
INITIAL STATE:
- current_step = 390 (≈ flap 10)
- current_accel_step = 0 (idle)
- delta_steps = 0

USER COMMAND: GoToFlapIndex(15)
1. Calculate target_step = 15 * 2048 / 52 = 591
2. Calculate delta_steps = 591 - 390 = 201 steps
3. current_accel_step = 0 → target_accel_step = 72

UPDATE LOOP (iterations over ~2 seconds):

Iteration 1:
  current_accel_step: 0 → 1 (speed up)
  current_period: 1600µs → 10000µs
  Wait 10000µs before next step

Iteration 2:
  current_accel_step: 1 → 2
  current_period: 10000µs → 7920µs
  Take step: current_step=391, phase=1, delta_steps=200

Iteration 3-70:
  Gradually accelerate to max speed
  current_accel_step increases: 2→3→4...→72
  Taking steps faster and faster

Iteration 71-130:
  Cruising at max speed (accel_step=72)
  current_period = 1606µs (fastest)
  Each iteration: step++, delta_steps--

Iteration 131: (delta_steps=72, starting deceleration)
  target_accel_step changes: 72 → 72 (still max)

Iteration 132: (delta_steps=71)
  target_accel_step: 72 → 71 (time to slow down!)
  current_accel_step: 72 → 71
  current_period: 1606µs → 1617µs (slightly slower)

Iteration 133-200:
  Mirror deceleration ramp
  current_accel_step decreases: 71→70→...→1→0
  Smoothly slowing to a stop

Iteration 201:
  delta_steps = 0 (arrived!)
  target_accel_step = 0
  current_accel_step = 0
  SetMotor(0) - motor stops
  current_step = 591 ≈ flap 15 ✓

FINAL STATE:
- current_step = 591 (flap 15)
- current_accel_step = 0 (idle)
- delta_steps = 0
- Motor coils de-energized
```

## Velocity Profile Diagram

```
Speed
  ↑
  │         ╱────────╲
  │        ╱          ╲
  │       ╱            ╲
  │      ╱              ╲
  │     ╱                ╲
  │    ╱                  ╲
  │   ╱                    ╲
  0  ─────────────────────────→ Time
     ↑    ↑         ↑      ↑
   Start Accel   Cruise  Decel Stop

Phase 1: Acceleration (0 → 72 steps)
  - current_accel_step increases by 1 each iteration
  - Period decreases (motor speeds up)
  - Smooth ramp from idle to max speed

Phase 2: Cruise (>72 steps remaining)
  - current_accel_step = 72 (constant)
  - Period = 1606µs (constant)
  - Maximum speed maintained

Phase 3: Deceleration (≤72 steps remaining)
  - target_accel_step = delta_steps (mirrors remaining distance)
  - current_accel_step decreases by 1 each iteration
  - Period increases (motor slows down)
  - Smooth ramp from max speed to stop
```

## Key Algorithm Features

1. **Trapezoidal velocity profile**: Smooth acceleration → constant speed → smooth deceleration
2. **Distance-based deceleration**: When `delta_steps < MAX_ACCEL_STEP`, speed mirrors remaining distance
3. **Look-ahead stopping**: Checks if target is too close given current speed
4. **Gentle ramping**: Speed changes by maximum ±1 step per update (no sudden jerks)
5. **Microsecond timing**: Uses `micros()` for precise step timing (sub-millisecond accuracy)
6. **Wrap-around math**: All position calculations modulo 2048 (circular buffer logic)
7. **Bidirectional control**: Can reverse motor direction via `REVERSE_MOTOR_DIRECTION` flag
8. **Zero-holding torque**: Motor coils de-energize when stopped (no power consumption at rest)

## Position Tracking & Error Detection

The hall-effect sensor provides continuous feedback:

### Home State Machine

```cpp
enum HomeState {
    IGNORE,      // Just passed home, ignore sensor
    UNEXPECTED,  // Far from home region (error if detected)
    EXPECTED     // Near home region (error if NOT detected)
};
```

**State Transitions:**
```
         current_step=0
              ↓
        ┌─[IGNORE]─┐
        │   (0-195) │  Sensor triggers here = ignored
        └───────────┘
              ↓ step 195
        ┌─[UNEXPECTED]──┐
        │   (195-2038)  │  Sensor triggers here = ERROR!
        └────────────────┘
              ↓ step 2038
        ┌─[EXPECTED]─┐
        │ (2038-2048) │  Sensor must trigger here or = ERROR!
        └─────────────┘
              ↓ sensor detected
        back to [IGNORE]
```

**Error Counters:**
- `count_unexpected_home`: Sensor triggered outside expected window
- `count_missed_home`: Sensor didn't trigger in expected window

When errors accumulate, the system automatically recalibrates by entering `LOOK_FOR_HOME` state.

## Performance Characteristics

**Typical Movement Times:**
- Adjacent flap (~39 steps): ~150ms
- Quarter rotation (~512 steps): ~1.2 seconds
- Full rotation (2048 steps): ~3.5 seconds

**Acceleration Characteristics:**
- Acceleration time: ~72 steps × ~2-10ms = 140-720ms
- Deceleration time: mirrors acceleration (symmetric profile)
- Max speed: ~625 steps/sec ≈ 18 RPM at the output shaft

**Power Characteristics:**
- Moving: 2 coils energized = ~240mA @ 5V per motor
- Stopped: 0 coils energized = 0mA (no holding torque)
- 6 modules per Chainlink Driver = up to 1.44A peak

## Source Code References

**Key Files:**
- `/firmware/src/splitflap_module.h` - Core motor control logic (lines 200-410)
- `/firmware/src/acceleration.h` - Speed ramp table (auto-generated)
- `/firmware/src/generate_acceleration.py` - Script to generate acceleration table
- `/firmware/esp32/core/splitflap_task.cpp` - Task orchestration and I/O updates

**Key Functions:**
- `GoToFlapIndex()` - Entry point for position commands
- `GoToTargetFlapIndex()` - Path calculation with look-ahead
- `Update()` - Main motor control loop (called ~100Hz)
- `SetMotor()` - Hardware actuation (GPIO/shift register)
- `CheckSensor()` - Hall sensor reading with edge detection

## Conclusion

This motor control algorithm provides:
- **Smooth motion**: Trapezoidal velocity profile prevents jerky movements
- **Reliability**: Closed-loop control with hall sensor feedback
- **Efficiency**: Zero holding torque when stopped
- **Precision**: Sub-flap position accuracy via calibration offsets
- **Robustness**: Automatic error detection and recalibration

The result is a reliable, self-correcting system that can run displays with 100+ modules simultaneously!
