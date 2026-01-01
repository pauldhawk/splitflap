/*
 * Phase 1 - Basic NEMA 17 Motor Test
 *
 * Simple STEP/DIR control test for NEMA 17 + TMC2209
 *
 * Hardware:
 * - ESP32 DevKit
 * - TMC2209 Driver Board
 * - NEMA 17 Motor (17HS19-2004S1)
 * - 12V 2A Power Supply
 *
 * Connections:
 * - GPIO 25 → TMC2209 STEP
 * - GPIO 26 → TMC2209 DIR
 * - GPIO 27 → TMC2209 EN (active LOW)
 * - ESP32 GND → TMC2209 GND
 *
 * What this does:
 * - Rotates motor slowly in one direction (200 steps)
 * - Pauses
 * - Rotates in opposite direction (200 steps)
 * - Repeats forever
 */

#include <Arduino.h>

// ===== PIN DEFINITIONS =====
#define STEP_PIN  25    // Step pulse
#define DIR_PIN   26    // Direction (HIGH = CW, LOW = CCW)
#define EN_PIN    27    // Enable (LOW = enabled, HIGH = disabled)

// ===== MOTOR PARAMETERS =====
#define STEPS_PER_REV        200    // Native steps (1.8° motor)
#define MICROSTEPS           16     // TMC2209 default microstepping
#define TOTAL_STEPS_PER_REV  (STEPS_PER_REV * MICROSTEPS)  // 3200 steps

// ===== TIMING PARAMETERS =====
#define STEP_DELAY_US  1000   // Microseconds between steps (1000us = 1ms = 1 step/ms)
                              // At 1000us: 1000 steps/sec = 18.75 RPM (slow and visible)
#define STEP_PULSE_US  5      // Step pulse width (5us minimum for TMC2209)

// ===== TEST PARAMETERS =====
#define TEST_STEPS     200    // How many steps per test rotation
#define PAUSE_MS       1000   // Pause between direction changes

// ===== GLOBAL STATE =====
volatile long step_count = 0;

// ===== FUNCTIONS =====

/**
 * Send one step pulse to motor
 */
void send_step() {
    digitalWrite(STEP_PIN, HIGH);
    delayMicroseconds(STEP_PULSE_US);
    digitalWrite(STEP_PIN, LOW);
    step_count++;
}

/**
 * Set motor direction
 * @param clockwise true = clockwise, false = counter-clockwise
 */
void set_direction(bool clockwise) {
    digitalWrite(DIR_PIN, clockwise ? HIGH : LOW);
    delayMicroseconds(5);  // Give TMC2209 time to register direction change
}

/**
 * Enable motor (allow movement)
 */
void enable_motor() {
    digitalWrite(EN_PIN, LOW);  // Active LOW
    delay(10);  // Give driver time to power up
}

/**
 * Disable motor (prevent movement, save power)
 */
void disable_motor() {
    digitalWrite(EN_PIN, HIGH);  // Active HIGH = disabled
}

/**
 * Move motor a specific number of steps
 * @param steps Number of steps to move
 * @param clockwise Direction (true = CW, false = CCW)
 */
void move_steps(int steps, bool clockwise) {
    set_direction(clockwise);

    for (int i = 0; i < steps; i++) {
        send_step();
        delayMicroseconds(STEP_DELAY_US);
    }
}

/**
 * Arduino setup - runs once at startup
 */
void setup() {
    // Initialize serial for debugging
    Serial.begin(115200);
    delay(1000);  // Give serial time to initialize

    Serial.println("\n\n===== Phase 1: NEMA 17 Motor Test =====");
    Serial.println("Initializing...");

    // Configure pins as outputs
    pinMode(STEP_PIN, OUTPUT);
    pinMode(DIR_PIN, OUTPUT);
    pinMode(EN_PIN, OUTPUT);

    // Set initial states
    digitalWrite(STEP_PIN, LOW);
    digitalWrite(DIR_PIN, LOW);
    digitalWrite(EN_PIN, HIGH);  // Start disabled

    Serial.println("Pin configuration complete");

    // Print configuration
    Serial.println("\nConfiguration:");
    Serial.printf("  STEP pin: GPIO %d\n", STEP_PIN);
    Serial.printf("  DIR pin:  GPIO %d\n", DIR_PIN);
    Serial.printf("  EN pin:   GPIO %d\n", EN_PIN);
    Serial.printf("  Steps per revolution: %d\n", TOTAL_STEPS_PER_REV);
    Serial.printf("  Step delay: %d us\n", STEP_DELAY_US);
    Serial.printf("  Speed: ~%.1f RPM\n", (1000000.0 / STEP_DELAY_US) / TOTAL_STEPS_PER_REV * 60.0);

    // Enable motor
    Serial.println("\nEnabling motor...");
    enable_motor();
    Serial.println("Motor enabled!");

    // Wait before starting movement
    Serial.println("\nStarting movement in 3 seconds...");
    delay(3000);

    Serial.println("GO!\n");
}

/**
 * Arduino loop - runs repeatedly
 */
void loop() {
    // Test 1: Rotate clockwise
    Serial.printf("[%lu] Rotating CLOCKWISE %d steps...\n", millis(), TEST_STEPS);
    move_steps(TEST_STEPS, true);
    Serial.printf("    Total steps: %ld\n", step_count);

    // Pause
    Serial.printf("[%lu] Pause %d ms\n", millis(), PAUSE_MS);
    delay(PAUSE_MS);

    // Test 2: Rotate counter-clockwise
    Serial.printf("[%lu] Rotating COUNTER-CLOCKWISE %d steps...\n", millis(), TEST_STEPS);
    move_steps(TEST_STEPS, false);
    Serial.printf("    Total steps: %ld\n", step_count);

    // Pause
    Serial.printf("[%lu] Pause %d ms\n", millis(), PAUSE_MS);
    delay(PAUSE_MS);

    Serial.println("--- Cycle complete ---\n");
}

/*
 * ===== EXPECTED BEHAVIOR =====
 *
 * When you upload and run this code:
 *
 * 1. Serial monitor will show initialization messages
 * 2. After 3 seconds, motor will start rotating
 * 3. Motor rotates 200 steps clockwise (slow, visible)
 * 4. Pauses 1 second
 * 5. Motor rotates 200 steps counter-clockwise
 * 6. Pauses 1 second
 * 7. Repeats forever
 *
 * At STEP_DELAY_US = 1000:
 * - Speed: ~18.75 RPM (very slow, easy to see)
 * - Each 200 step movement takes ~0.2 seconds
 * - Each full cycle (CW + CCW + pauses) takes ~2.4 seconds
 *
 * ===== TROUBLESHOOTING =====
 *
 * Motor doesn't move:
 * - Check EN pin connection (should be LOW to enable)
 * - Verify 12V power to TMC2209
 * - Check common ground (ESP32 GND to TMC2209 GND)
 * - Verify motor coil connections
 *
 * Motor vibrates but doesn't rotate:
 * - Swap one coil pair (A1↔A2 or B1↔B2)
 *
 * Motor rotates wrong direction:
 * - Swap DIR pin logic, or
 * - Swap one coil pair
 *
 * Motor is too fast/slow:
 * - Adjust STEP_DELAY_US (bigger = slower)
 *
 * Serial monitor shows nothing:
 * - Check USB cable
 * - Verify correct COM port selected
 * - Set baud rate to 115200
 */
