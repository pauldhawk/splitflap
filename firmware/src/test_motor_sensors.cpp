/**
 * Motor and Sensor Test Script
 * Tests breadboard wiring for ESP32 + TMC2209 + Shift Registers
 *
 * Spins motors 50 times and logs each sensor hit.
 *
 * Hardware:
 * - ESP32 TTGO T-Display
 * - 74HC595 (output shift register) for STEP signals
 * - 74HC165 (input shift register) for hall sensors
 * - TMC2209 motor drivers (2x)
 * - Hall sensors (2x)
 */

#include <Arduino.h>
#include <SPI.h>

// SPI Pins (from breadboard checklist)
#define SPI_MOSI  25
#define SPI_MISO  26
#define SPI_SCK   27
#define SPI_CS    32

// Motor configuration
#define NUM_MOTORS 2
#define STEPS_PER_REV 3200  // 200 steps/rev * 16 microstepping
#define STEP_DELAY_US 500   // Delay between steps (microseconds) - adjust for speed

// 74HC595 output bits
#define OUTPUT_MOTOR_A_STEP  0  // QA (Pin 15)
#define OUTPUT_MOTOR_B_STEP  4  // QE (Pin 4)

// 74HC165 input bits
#define INPUT_SENSOR_A  0  // D0 (Pin 11)
#define INPUT_SENSOR_B  1  // D1 (Pin 12)

// State tracking
uint8_t outputState = 0x00;  // Current 74HC595 output state
bool lastSensorA = false;
bool lastSensorB = false;
uint32_t sensorHitsA = 0;
uint32_t sensorHitsB = 0;
uint32_t stepsA = 0;
uint32_t stepsB = 0;

SPIClass *spi = nullptr;

// Forward declarations
void writeOutputRegister(uint8_t data);
uint8_t readInputRegister();
void stepMotor(uint8_t motorBit);
void readSensors();
void printProgress();
void printFinalReport();

void setup() {
  Serial.begin(115200);
  while (!Serial && millis() < 3000) {
    delay(10);
  }

  Serial.println("\n\n=== Motor & Sensor Test ===");
  Serial.println("Breadboard Wiring Verification");
  Serial.println("===============================\n");

  // Initialize SPI
  spi = new SPIClass(VSPI);
  spi->begin(SPI_SCK, SPI_MISO, SPI_MOSI, SPI_CS);

  pinMode(SPI_CS, OUTPUT);
  digitalWrite(SPI_CS, HIGH);

  Serial.println("SPI initialized:");
  Serial.printf("  MOSI: GPIO%d\n", SPI_MOSI);
  Serial.printf("  MISO: GPIO%d\n", SPI_MISO);
  Serial.printf("  SCK:  GPIO%d\n", SPI_SCK);
  Serial.printf("  CS:   GPIO%d\n\n", SPI_CS);

  // Clear output register
  writeOutputRegister(0x00);
  delay(100);

  // Read initial sensor state
  uint8_t sensors = readInputRegister();
  lastSensorA = (sensors >> INPUT_SENSOR_A) & 0x01;
  lastSensorB = (sensors >> INPUT_SENSOR_B) & 0x01;

  Serial.println("Initial sensor state:");
  Serial.printf("  Sensor A: %s\n", lastSensorA ? "ACTIVE" : "inactive");
  Serial.printf("  Sensor B: %s\n\n", lastSensorB ? "ACTIVE" : "inactive");

  Serial.println("Starting test: 50 revolutions per motor...\n");
  delay(1000);
}

void loop() {
  static uint32_t targetSteps = 50 * STEPS_PER_REV;

  // Run until both motors complete 50 revolutions
  if (stepsA < targetSteps || stepsB < targetSteps) {
    // Step Motor A
    if (stepsA < targetSteps) {
      stepMotor(OUTPUT_MOTOR_A_STEP);
      stepsA++;
    }

    // Step Motor B
    if (stepsB < targetSteps) {
      stepMotor(OUTPUT_MOTOR_B_STEP);
      stepsB++;
    }

    // Read sensors and detect edges
    readSensors();

    delayMicroseconds(STEP_DELAY_US);

    // Progress update every revolution
    if (stepsA % STEPS_PER_REV == 0 || stepsB % STEPS_PER_REV == 0) {
      printProgress();
    }
  } else {
    // Test complete
    if (stepsA == targetSteps && stepsB == targetSteps) {
      printFinalReport();
      stepsA++;  // Prevent repeated printing
    }
    delay(1000);
  }
}

void writeOutputRegister(uint8_t data) {
  // Write to 74HC595 via SPI
  digitalWrite(SPI_CS, LOW);
  spi->transfer(data);
  digitalWrite(SPI_CS, HIGH);

  outputState = data;
}

uint8_t readInputRegister() {
  // Read from 74HC165 via SPI
  // CS LOW -> pulse load, CS HIGH -> shift data
  digitalWrite(SPI_CS, LOW);
  delayMicroseconds(1);
  digitalWrite(SPI_CS, HIGH);
  delayMicroseconds(1);

  // Read shifted data
  digitalWrite(SPI_CS, LOW);
  uint8_t data = spi->transfer(0x00);
  digitalWrite(SPI_CS, HIGH);

  return data;
}

void stepMotor(uint8_t motorBit) {
  // Generate step pulse (rising edge triggers step)
  uint8_t stepHigh = outputState | (1 << motorBit);
  uint8_t stepLow = outputState & ~(1 << motorBit);

  writeOutputRegister(stepLow);
  delayMicroseconds(2);  // Minimum pulse width for TMC2209
  writeOutputRegister(stepHigh);
  delayMicroseconds(2);
  writeOutputRegister(stepLow);
}

void readSensors() {
  uint8_t sensors = readInputRegister();
  bool sensorA = (sensors >> INPUT_SENSOR_A) & 0x01;
  bool sensorB = (sensors >> INPUT_SENSOR_B) & 0x01;

  // Detect rising edge (sensor activation)
  if (sensorA && !lastSensorA) {
    sensorHitsA++;
    Serial.printf("[%6lu] Motor A: Sensor HIT #%lu (step %lu)\n",
                  millis(), sensorHitsA, stepsA);
  }

  if (sensorB && !lastSensorB) {
    sensorHitsB++;
    Serial.printf("[%6lu] Motor B: Sensor HIT #%lu (step %lu)\n",
                  millis(), sensorHitsB, stepsB);
  }

  lastSensorA = sensorA;
  lastSensorB = sensorB;
}

void printProgress() {
  static uint32_t lastPrintA = 0;
  static uint32_t lastPrintB = 0;

  uint32_t revsA = stepsA / STEPS_PER_REV;
  uint32_t revsB = stepsB / STEPS_PER_REV;

  if (revsA > lastPrintA) {
    Serial.printf("Motor A: %2lu/50 revolutions (%lu sensor hits)\n",
                  revsA, sensorHitsA);
    lastPrintA = revsA;
  }

  if (revsB > lastPrintB) {
    Serial.printf("Motor B: %2lu/50 revolutions (%lu sensor hits)\n",
                  revsB, sensorHitsB);
    lastPrintB = revsB;
  }
}

void printFinalReport() {
  Serial.println("\n\n===============================");
  Serial.println("=== TEST COMPLETE ===");
  Serial.println("===============================\n");

  Serial.printf("Motor A:\n");
  Serial.printf("  Total steps:       %lu\n", stepsA);
  Serial.printf("  Total revolutions: %lu\n", stepsA / STEPS_PER_REV);
  Serial.printf("  Sensor hits:       %lu\n", sensorHitsA);
  Serial.printf("  Expected hits:     ~50 (1 per revolution)\n");
  Serial.printf("  Status:            %s\n\n",
                (sensorHitsA >= 45 && sensorHitsA <= 55) ? "✓ PASS" : "✗ FAIL");

  Serial.printf("Motor B:\n");
  Serial.printf("  Total steps:       %lu\n", stepsB);
  Serial.printf("  Total revolutions: %lu\n", stepsB / STEPS_PER_REV);
  Serial.printf("  Sensor hits:       %lu\n", sensorHitsB);
  Serial.printf("  Expected hits:     ~50 (1 per revolution)\n");
  Serial.printf("  Status:            %s\n\n",
                (sensorHitsB >= 45 && sensorHitsB <= 55) ? "✓ PASS" : "✗ FAIL");

  Serial.println("===============================");
  Serial.println("Troubleshooting:");
  Serial.println("- If no sensor hits: Check hall sensor wiring and magnet position");
  Serial.println("- If too many hits: Check for noise/bouncing on sensor lines");
  Serial.println("- If motors don't move: Check STEP signal with oscilloscope");
  Serial.println("- If direction wrong: Flip DIR_FIXED connection (5V <-> GND)");
  Serial.println("===============================\n");
}
