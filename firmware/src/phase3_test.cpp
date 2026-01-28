/*
  Phase 3: Hall Sensor & Closed-Loop Control

  Adds hall sensor for position feedback and automatic homing.
  - Motor finds home position automatically
  - Can command specific flap positions
  - Position stays accurate over time

  Hardware Connections:
  - ESP32 GPIO 25 -> TMC2209 STEP
  - ESP32 GPIO 26 -> TMC2209 DIR
  - ESP32 GPIO 27 -> TMC2209 EN (enable)
  - ESP32 GPIO 12 -> TMC2209 PDN_UART (TX)
  - ESP32 GPIO 13 -> TMC2209 PDN_UART (RX)
  - ESP32 GPIO 2  -> Hall Sensor OUT
  - ESP32 3.3V    -> Hall Sensor VCC
  - ESP32 GND     -> Hall Sensor GND

  Serial Commands:
  - h        : Start homing
  - g<pos>   : Go to position (e.g., g10 = go to position 10)
  - s        : Show current status
*/

#include <Arduino.h>
#include <TMCStepper.h>

// Pin definitions
#define STEP_PIN       25
#define DIR_PIN        26
#define EN_PIN         27
#define HALL_SENSOR_PIN 2
#define SERIAL_PORT    Serial2
#define DRIVER_ADDRESS 0b00
#define R_SENSE        0.11f

// Motor configuration
#define STEPS_PER_REVOLUTION 3200  // 200 steps × 16 microsteps
#define NUM_FLAPS           50     // Number of flaps on drum
#define STEPS_PER_FLAP      (STEPS_PER_REVOLUTION / NUM_FLAPS)  // 64 steps per flap

// Create TMC2209 driver object
TMC2209Stepper driver(&SERIAL_PORT, R_SENSE, DRIVER_ADDRESS);

// State machine
enum State {
  STATE_INIT,
  STATE_HOMING,
  STATE_IDLE,
  STATE_MOVING
};

State current_state = STATE_INIT;
bool is_homed = false;
int32_t current_position = 0;  // Current position in steps
int32_t target_position = 0;   // Target position in steps
uint32_t last_hall_trigger = 0;
bool last_hall_state = HIGH;

void setup() {
  Serial.begin(115200);
  delay(1000);
  Serial.println("\n=== Phase 3: Hall Sensor & Homing ===\n");

  // Setup UART for TMC2209
  SERIAL_PORT.begin(115200, SERIAL_8N1, 12, 13);

  // Setup pins
  pinMode(STEP_PIN, OUTPUT);
  pinMode(DIR_PIN, OUTPUT);
  pinMode(EN_PIN, OUTPUT);
  pinMode(HALL_SENSOR_PIN, INPUT_PULLUP);  // Use internal pullup

  digitalWrite(EN_PIN, LOW);   // Enable driver
  digitalWrite(DIR_PIN, HIGH); // Set initial direction

  delay(100);

  // Configure TMC2209 via UART
  Serial.println("Configuring TMC2209...");
  driver.begin();
  driver.toff(5);
  driver.rms_current(1000);      // 1.0A RMS
  driver.microsteps(16);         // 1/16 microstepping
  driver.pwm_autoscale(true);
  driver.en_spreadCycle(false);  // StealthChop mode

  Serial.println("TMC2209 configured!");
  Serial.print("  Microsteps: ");
  Serial.println(driver.microsteps());
  Serial.print("  RMS Current: ");
  Serial.print(driver.rms_current());
  Serial.println(" mA");

  // Check initial hall sensor state
  bool hall = digitalRead(HALL_SENSOR_PIN);
  Serial.print("\nInitial hall sensor state: ");
  Serial.println(hall ? "HIGH (no magnet)" : "LOW (magnet detected)");

  Serial.println("\nCommands:");
  Serial.println("  h       - Start homing");
  Serial.println("  g<pos>  - Go to flap position (e.g., g10)");
  Serial.println("  s       - Show status");
  Serial.println();

  // Auto-start homing
  Serial.println("Starting automatic homing...");
  Serial.println("(Hold magnet near sensor when motor is spinning)");
  current_state = STATE_HOMING;
}

void takeStep(bool direction) {
  digitalWrite(DIR_PIN, direction ? HIGH : LOW);
  digitalWrite(STEP_PIN, HIGH);
  delayMicroseconds(5);
  digitalWrite(STEP_PIN, LOW);

  // Update position
  if (direction) {
    current_position++;
    if (current_position >= STEPS_PER_REVOLUTION) {
      current_position = 0;
    }
  } else {
    current_position--;
    if (current_position < 0) {
      current_position = STEPS_PER_REVOLUTION - 1;
    }
  }
}

bool checkHallSensor() {
  bool hall_state = digitalRead(HALL_SENSOR_PIN);

  // Detect falling edge (HIGH to LOW transition)
  if (last_hall_state == HIGH && hall_state == LOW) {
    // Debounce: ignore triggers within 100ms
    if (millis() - last_hall_trigger > 100) {
      last_hall_trigger = millis();
      last_hall_state = hall_state;
      return true;  // Magnet detected!
    }
  }

  last_hall_state = hall_state;
  return false;
}

void printStatus() {
  Serial.println("\n--- Status ---");
  Serial.print("State: ");
  switch (current_state) {
    case STATE_INIT:   Serial.println("INIT"); break;
    case STATE_HOMING: Serial.println("HOMING"); break;
    case STATE_IDLE:   Serial.println("IDLE"); break;
    case STATE_MOVING: Serial.println("MOVING"); break;
  }
  Serial.print("Homed: ");
  Serial.println(is_homed ? "YES" : "NO");
  Serial.print("Current Position: ");
  Serial.print(current_position);
  Serial.print(" steps (flap ");
  Serial.print(current_position / STEPS_PER_FLAP);
  Serial.println(")");
  Serial.print("Target Position: ");
  Serial.print(target_position);
  Serial.print(" steps (flap ");
  Serial.print(target_position / STEPS_PER_FLAP);
  Serial.println(")");
  Serial.print("Hall Sensor: ");
  Serial.println(digitalRead(HALL_SENSOR_PIN) ? "HIGH" : "LOW");
  Serial.println();
}

void goToFlap(int flap_number) {
  if (!is_homed) {
    Serial.println("ERROR: Not homed yet! Run 'h' to home first.");
    return;
  }

  if (flap_number < 0 || flap_number >= NUM_FLAPS) {
    Serial.print("ERROR: Flap number must be 0-");
    Serial.println(NUM_FLAPS - 1);
    return;
  }

  target_position = flap_number * STEPS_PER_FLAP;
  Serial.print("Moving to flap ");
  Serial.print(flap_number);
  Serial.print(" (position ");
  Serial.print(target_position);
  Serial.println(" steps)");
  current_state = STATE_MOVING;
}

void loop() {
  // Handle serial commands
  if (Serial.available()) {
    char cmd = Serial.read();

    if (cmd == 'h' || cmd == 'H') {
      Serial.println("Starting homing...");
      is_homed = false;
      current_state = STATE_HOMING;
    }
    else if (cmd == 's' || cmd == 'S') {
      printStatus();
    }
    else if (cmd == 'g' || cmd == 'G') {
      // Read position number
      if (Serial.available()) {
        int pos = Serial.parseInt();
        goToFlap(pos);
      }
    }
  }

  // State machine
  switch (current_state) {
    case STATE_INIT:
      // Wait for command
      break;

    case STATE_HOMING:
      // Spin slowly until hall sensor triggers
      takeStep(true);  // Forward direction
      delayMicroseconds(2000);  // Slow speed for homing

      if (checkHallSensor()) {
        Serial.println("\n*** HOME FOUND! ***");
        current_position = 0;  // Reset position to zero
        is_homed = true;
        current_state = STATE_IDLE;
        Serial.println("Motor is now at home position (flap 0)");
        Serial.println("Try: g5  (go to flap 5)");
        Serial.println("     g10 (go to flap 10)\n");
      }
      break;

    case STATE_IDLE:
      // Do nothing, wait for commands
      delay(10);
      break;

    case STATE_MOVING:
      // Move toward target position
      if (current_position != target_position) {
        // Determine direction (shortest path)
        int32_t delta = target_position - current_position;
        bool direction = true;  // Forward

        // Handle wraparound
        if (abs(delta) > STEPS_PER_REVOLUTION / 2) {
          direction = (delta < 0);  // Go the other way
        } else {
          direction = (delta > 0);
        }

        takeStep(direction);
        delayMicroseconds(800);  // Movement speed

        // Check if we've arrived
        if (current_position == target_position) {
          Serial.print("Arrived at position ");
          Serial.print(current_position);
          Serial.print(" (flap ");
          Serial.print(current_position / STEPS_PER_FLAP);
          Serial.println(")");
          current_state = STATE_IDLE;
        }
      } else {
        current_state = STATE_IDLE;
      }
      break;
  }

  // Check for position loss during movement (re-calibrate if sensor triggers unexpectedly)
  if (current_state == STATE_MOVING || current_state == STATE_IDLE) {
    if (checkHallSensor()) {
      Serial.println("\n>>> Hall sensor triggered - recalibrating position <<<");
      current_position = 0;  // Reset to home
      Serial.println("Position reset to home (flap 0)\n");
    }
  }
}
