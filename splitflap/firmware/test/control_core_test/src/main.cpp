
  /*
   * Control Core PCB Test
   * Tests: SPI loopback (74HC595 QB/QC → 74HC165 D6/D7)
   *        STEP_A output (74HC595 QA)
   *        STEP_B output (74HC595 QE)
   *        HALL_A input  (74HC165 D0)
   *        HALL_B input  (74HC165 D1)
   *
   * Pin assignments per breadboard_prototype_2motor.yaml
   */

  #include <Arduino.h>
  #include <SPI.h>

  // === Pin assignments from YAML spec ===
  #define SPI_MOSI_PIN  25
  #define SPI_MISO_PIN  26
  #define SPI_SCK_PIN   27
  #define SPI_CS_PIN    32   // shared latch: 74HC595 RCLK and 74HC165 PL

  // SPI settings: 74HC595/165 support up to 25 MHz, but start slow
  static SPISettings spi_settings(1000000, MSBFIRST, SPI_MODE0);

  // -------------------------------------------------------
  // Low-level SPI transfer: send 1 output byte, receive 1 input byte
  // The 74HC165 latches on CS LOW pulse, then clocks out on SCK.
  // The 74HC595 latches outputs on CS HIGH pulse.
  // -------------------------------------------------------
  uint8_t spi_transfer(uint8_t out_byte) {
      SPI.beginTransaction(spi_settings);

      // Latch 74HC165 inputs (active-low load pulse)
      digitalWrite(SPI_CS_PIN, LOW);
      delayMicroseconds(2);
      digitalWrite(SPI_CS_PIN, HIGH);
      delayMicroseconds(2);

      // Shift out motor byte, shift in sensor byte
      uint8_t in_byte = SPI.transfer(out_byte);

      // Latch 74HC595 outputs (rising edge on RCLK = CS high pulse)
      digitalWrite(SPI_CS_PIN, LOW);
      delayMicroseconds(2);
      digitalWrite(SPI_CS_PIN, HIGH);

      SPI.endTransaction();
      return in_byte;
  }

  // -------------------------------------------------------
  // Test 1: Loopback verification
  //   74HC595 QB (bit 1) is wired to 74HC165 D6 (bit 6)
  //   74HC595 QC (bit 2) is wired to 74HC165 D7 (bit 7)
  //
  //   Bit layout for the output byte (sent to 74HC595):
  //     bit 0 = QA  → STEP_A
  //     bit 1 = QB  → loopback input D6
  //     bit 2 = QC  → loopback input D7
  //     bit 4 = QE  → STEP_B
  //
  //   Bit layout for the input byte (read from 74HC165):
  //     bit 0 = D0  → HALL_A
  //     bit 1 = D1  → HALL_B
  //     bit 6 = D6  → loopback from QB
  //     bit 7 = D7  → loopback from QC
  // -------------------------------------------------------
  bool test_loopback() {
      bool pass = true;

      Serial.println("\n--- Test 1: SPI Loopback ---");

      // Pattern A: QB=1, QC=0 → expect D6=1, D7=0
      // (do two transfers: first sets output, second reads it back)
      spi_transfer(0b00000010);  // set QB high
      uint8_t result_a = spi_transfer(0b00000010);
      bool loopback_a = (result_a & 0b11000000) == 0b01000000;  // D6=1, D7=0

      Serial.printf("  QB=1,QC=0 → sensor byte: 0b%08b  (expect D6=1,D7=0)  %s\n",
                    result_a, loopback_a ? "PASS" : "FAIL");
      pass &= loopback_a;

      // Pattern B: QB=0, QC=1 → expect D6=0, D7=1
      spi_transfer(0b00000100);
      uint8_t result_b = spi_transfer(0b00000100);
      bool loopback_b = (result_b & 0b11000000) == 0b10000000;  // D6=0, D7=1

      Serial.printf("  QB=0,QC=1 → sensor byte: 0b%08b  (expect D6=0,D7=1)  %s\n",
                    result_b, loopback_b ? "PASS" : "FAIL");
      pass &= loopback_b;

      // Pattern C: QB=1, QC=1 → expect D6=1, D7=1
      spi_transfer(0b00000110);
      uint8_t result_c = spi_transfer(0b00000110);
      bool loopback_c = (result_c & 0b11000000) == 0b11000000;

      Serial.printf("  QB=1,QC=1 → sensor byte: 0b%08b  (expect D6=1,D7=1)  %s\n",
                    result_c, loopback_c ? "PASS" : "FAIL");
      pass &= loopback_c;

      // Pattern D: QB=0, QC=0 → expect D6=0, D7=0
      spi_transfer(0b00000000);
      uint8_t result_d = spi_transfer(0b00000000);
      bool loopback_d = (result_d & 0b11000000) == 0b00000000;

      Serial.printf("  QB=0,QC=0 → sensor byte: 0b%08b  (expect D6=0,D7=0)  %s\n",
                    result_d, loopback_d ? "PASS" : "FAIL");
      pass &= loopback_d;

      Serial.printf("  Loopback result: %s\n", pass ? "PASS" : "FAIL");
      return pass;
  }

  // -------------------------------------------------------
  // Test 2: STEP signal output
  //   Toggle QA (STEP_A) and QE (STEP_B) 10 times each.
  //   Measure with multimeter at STEP_A / STEP_B terminals:
  //   - In DC voltage mode: ~1.65V average (50% duty cycle at 3.3V logic)
  //   - Or use oscilloscope/logic analyzer to see pulses
  // -------------------------------------------------------
  void test_step_outputs() {
      Serial.println("\n--- Test 2: STEP Output Toggling ---");
      Serial.println("  Toggling STEP_A (QA, bit 0) 10 times...");
      Serial.println("  Measure at STEP_A terminal: expect ~1.6V avg or pulses");

      for (int i = 0; i < 10; i++) {
          spi_transfer(0b00000001);  // QA high
          delay(200);
          spi_transfer(0b00000000);  // QA low
          delay(200);
      }

      Serial.println("  Done toggling STEP_A.");
      Serial.println("  Toggling STEP_B (QE, bit 4) 10 times...");
      Serial.println("  Measure at STEP_B terminal: expect ~1.6V avg or pulses");

      for (int i = 0; i < 10; i++) {
          spi_transfer(0b00010000);  // QE high
          delay(200);
          spi_transfer(0b00000000);  // QE low
          delay(200);
      }

      Serial.println("  Done. Confirm signal presence with multimeter.");
  }

  // -------------------------------------------------------
  // Test 3: Hall sensor input reading (continuous)
  //   Short HALL_A terminal to 3.3V or GND with a jumper wire.
  //   Watch the serial output to verify D0 bit changes.
  //   Repeat for HALL_B.
  // -------------------------------------------------------
  void test_hall_inputs() {
      Serial.println("\n--- Test 3: Hall Sensor Input Reading ---");
      Serial.println("  Watching D0 (HALL_A) and D1 (HALL_B) for 10 seconds.");
      Serial.println("  Bridge HALL_A terminal to 3.3V → D0 should go HIGH.");
      Serial.println("  Bridge HALL_A terminal to GND  → D0 should go LOW.");
      Serial.println("  Repeat for HALL_B.");

      uint32_t start = millis();
      uint8_t last_hall = 0xFF;
      while (millis() - start < 10000) {
          uint8_t sensor = spi_transfer(0b00000000);
          uint8_t hall = sensor & 0b00000011;  // bits 0 and 1 = D0, D1
          if (hall != last_hall) {
              Serial.printf("  HALL inputs changed: HALL_A=%d  HALL_B=%d  (raw: 0b%08b)\n",
                            (hall >> 0) & 1, (hall >> 1) & 1, sensor);
              last_hall = hall;
          }
          delay(50);
      }
      Serial.println("  Hall sensor test done.");
  }

  void setup() {
      Serial.begin(115200);
      delay(1000);
      Serial.println("\n========================================");
      Serial.println("  Control Core PCB Test");
      Serial.println("========================================");

      // Init SPI
      SPI.begin(SPI_SCK_PIN, SPI_MISO_PIN, SPI_MOSI_PIN);
      pinMode(SPI_CS_PIN, OUTPUT);
      digitalWrite(SPI_CS_PIN, HIGH);

      delay(100);
      Serial.println("SPI initialized. Starting tests...");

      bool loopback_ok = test_loopback();
      test_step_outputs();
      test_hall_inputs();

      Serial.println("\n========================================");
      Serial.printf("  LOOPBACK TEST: %s\n", loopback_ok ? "PASS" : "FAIL");
      Serial.println("  Check STEP signals: confirmed by multimeter?");
      Serial.println("  Check HALL inputs: confirmed by jumper wire test?");
      Serial.println("========================================");
  }

  void loop() {
      // Continuously display sensor state for debugging
      uint8_t sensor = spi_transfer(0b00000000);
      Serial.printf("Sensor byte: 0b%08b  D0(HALL_A)=%d  D1(HALL_B)=%d  D6(loop)=%d  D7(loop)=%d\n",
          sensor,
          (sensor >> 0) & 1,
          (sensor >> 1) & 1,
          (sensor >> 6) & 1,
          (sensor >> 7) & 1);
      delay(500);
  }