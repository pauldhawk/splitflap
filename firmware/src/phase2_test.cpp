/*
  Phase 2: TMC2209 UART Configuration

  Configure TMC2209 via UART for optimal settings:
  - 1/16 microstepping
  - 1.0A RMS current
  - StealthChop for quiet operation

  Hardware Connections:
  - ESP32 GPIO 25 -> TMC2209 STEP
  - ESP32 GPIO 26 -> TMC2209 DIR
  - ESP32 GPIO 27 -> TMC2209 EN (enable)
  - ESP32 GPIO 16 -> TMC2209 TX (TMC2209 RX)
  - ESP32 GPIO 17 -> TMC2209 RX (TMC2209 TX)

  Power:
  - ESP32: 5V via USB
  - TMC2209 VM+: 12-24V (motor power)
  - Common ground between ESP32 and TMC2209!
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
  delay(1000);
  Serial.println("\n=== Phase 2: TMC2209 UART Configuration ===\n");

  // Setup UART for TMC2209 (16/17 are default Serial2 pins on ESP32)
  SERIAL_PORT.begin(115200, SERIAL_8N1, 12, 13);

  // Setup step/dir pins
  pinMode(STEP_PIN, OUTPUT);
  pinMode(DIR_PIN, OUTPUT);
  pinMode(EN_PIN, OUTPUT);

  digitalWrite(EN_PIN, LOW);  // Enable driver (LOW = enabled)
  digitalWrite(DIR_PIN, HIGH); // Set initial direction

  delay(100);

  Serial.println("Configuring TMC2209 via UART...");

  // Configure TMC2209 via UART
  driver.begin();
  driver.toff(5);                 // Enable driver
  driver.rms_current(1000);       // Set current to 1000mA (1.0A RMS)
  driver.microsteps(16);          // 1/16 microstepping
  driver.pwm_autoscale(true);     // Automatic current scaling
  driver.en_spreadCycle(false);   // Use StealthChop (quiet mode)

  Serial.println("TMC2209 configured!");

  // Read back settings to verify
  Serial.print("  RMS Current: ");
  Serial.print(driver.rms_current());
  Serial.println(" mA");

  Serial.print("  Microsteps: ");
  Serial.println(driver.microsteps());

  Serial.print("  StealthChop: ");
  Serial.println(!driver.en_spreadCycle() ? "Enabled" : "Disabled");

  delay(1000);
  Serial.println("\nStarting motor rotation...");
  Serial.println("(Motor should be MUCH quieter than Phase 1!)\n");
}

void loop() {
  // Same stepping code as Phase 1, but faster now
  digitalWrite(STEP_PIN, HIGH);
  delayMicroseconds(5);  // Minimum pulse width
  digitalWrite(STEP_PIN, LOW);
  delayMicroseconds(800);  // 800µs = 1250 steps/sec

  // Every 3200 steps (1 rotation), print status
  static int step_count = 0;
  step_count++;

  if (step_count % 3200 == 0) {
    int rotation = step_count / 3200;
    Serial.print("Rotation ");
    Serial.print(rotation);
    Serial.print(" - Status: ");

    // Read driver status
    uint32_t drv_status = driver.DRV_STATUS();

    // Check for errors
    if (drv_status & 0x80000000) {
      Serial.println("ERROR: STALL DETECTED!");
    } else if (drv_status & 0x01000000) {
      Serial.println("WARNING: Overtemp!");
    } else if (drv_status & 0x02000000) {
      Serial.println("WARNING: Overtemp pre-warning!");
    } else {
      Serial.print("OK");

      // Print temperature estimate
      uint16_t sg_result = (drv_status >> 0) & 0x3FF;
      Serial.print(" (StallGuard: ");
      Serial.print(sg_result);
      Serial.println(")");
    }
  }

  // Optional: Change direction every 10 rotations
  if (step_count % (3200 * 10) == 0) {
    digitalWrite(DIR_PIN, !digitalRead(DIR_PIN));
    Serial.println("\n>>> Reversing direction <<<\n");
  }
}
