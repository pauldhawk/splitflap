# Chainlink Driver TMC2209 - Detailed Schematic Modifications

**Project:** chainlinkDriver_TMC2209
**Date:** 2026-01-11
**Purpose:** Step-by-step guide to modify existing Chainlink Driver schematic for TMC2209

---

## Important Note

KiCad schematic files (.sch) should be edited using the KiCad Schematic Editor, not a text editor. This document provides detailed instructions for making changes in KiCad.

**To open the schematic:**
1. Install KiCad 6 or newer
2. Open KiCad
3. File → Open Project
4. Select `chainlinkDriver_TMC2209.pro`
5. Double-click the `.sch` file to open schematic editor

---

## Section 1: Shift Register Modifications

### 1.1 Remove Third Shift Register (U7)

**Current:** 3× 74HC595 (24 outputs for 6 motors × 4 phases)
**New:** 2× 74HC595 (12 outputs for 6 motors × 2 bits STEP/DIR)

**Steps:**
1. In schematic, select U7 (74HC595) and all connected wires
2. Press Delete
3. Delete associated labels:
   - MOTOR_E_PHASE_A/B/C/D
   - MOTOR_F_PHASE_A/B/C/D

### 1.2 Update U1 Outputs (Motors A, B, C, D)

**Old labels → New labels:**
```
U1 Pin 15 (Q0): MOTOR_A_PHASE_A → MOTOR_A_STEP
U1 Pin 1  (Q1): MOTOR_A_PHASE_B → MOTOR_A_DIR
U1 Pin 2  (Q2): MOTOR_A_PHASE_C → MOTOR_B_STEP
U1 Pin 3  (Q3): MOTOR_A_PHASE_D → MOTOR_B_DIR
U1 Pin 4  (Q4): MOTOR_B_PHASE_A → MOTOR_C_STEP
U1 Pin 5  (Q5): MOTOR_B_PHASE_B → MOTOR_C_DIR
U1 Pin 6  (Q6): MOTOR_B_PHASE_C → MOTOR_D_STEP
U1 Pin 7  (Q7): MOTOR_B_PHASE_D → MOTOR_D_DIR
```

**Steps:**
1. Select each net label on U1 outputs
2. Press 'E' (Edit) or double-click
3. Change text to new label name
4. Repeat for all 8 outputs

### 1.3 Update U5 Outputs (Motors E, F)

**Old labels → New labels:**
```
U5 Pin 15 (Q0): MOTOR_C_PHASE_A → MOTOR_E_STEP
U5 Pin 1  (Q1): MOTOR_C_PHASE_B → MOTOR_E_DIR
U5 Pin 2  (Q2): MOTOR_C_PHASE_C → MOTOR_F_STEP
U5 Pin 3  (Q3): MOTOR_C_PHASE_D → MOTOR_F_DIR
U5 Pin 4  (Q4): MOTOR_D_PHASE_A → NC (Not Connected)
U5 Pin 5  (Q5): MOTOR_D_PHASE_B → NC
U5 Pin 6  (Q6): MOTOR_D_PHASE_C → NC
U5 Pin 7  (Q7): MOTOR_D_PHASE_D → NC
```

**Steps:**
1. Edit labels for Q0-Q3 as above
2. For Q4-Q7: delete net labels (leave pins unconnected)

---

## Section 2: Remove ULN2003A Motor Drivers

### 2.1 Delete All ULN2003A Symbols

**Components to delete:**
- U2 (ULN2003A for motors A/B)
- U6 (ULN2003A for motors C/D)
- U8 (ULN2003A for motors E/F)

**Steps:**
1. Select U2 and all connected wires
2. Press Delete
3. Repeat for U6 and U8
4. Delete associated power connections and capacitors

---

## Section 3: Add TMC2209 Stepper Drivers

### 3.1 Add TMC2209 Module Symbols

Since TMC2209 modules are not in standard KiCad library, we need to create a custom symbol.

**Create Custom Symbol:**
1. Tools → Symbol Editor
2. File → New Symbol
3. Name: "TMC2209_Module"
4. Add pins:

```
Left side (inputs):
Pin 1:  EN   (Input, Enable)
Pin 2:  STEP (Input, Step pulse)
Pin 3:  DIR  (Input, Direction)
Pin 4:  VDD  (Power, 3.3-5V logic)
Pin 5:  GND  (Power, Ground)
Pin 6:  VM+  (Power, Motor power 12-24V)

Right side (outputs):
Pin 7:  A1   (Output, Motor coil A+)
Pin 8:  A2   (Output, Motor coil A-)
Pin 9:  B1   (Output, Motor coil B+)
Pin 10: B2   (Output, Motor coil B-)

Bottom (configuration):
Pin 11: MS1  (Input, Microstep config)
Pin 12: MS2  (Input, Microstep config)
Pin 13: PDN_UART (Bidirectional, UART)
Pin 14: DIAG (Output, Diagnostic)
Pin 15: INDEX (Output, Index pulse)
```

**Footprint:** Create custom footprint or use standard 2.54mm header pins

### 3.2 Place TMC2209 Symbols (U10-U15)

**Steps:**
1. Place → Add Symbol
2. Select TMC2209_Module
3. Place 6 instances (U10, U11, U12, U13, U14, U15)
4. Arrange in a row or 2×3 grid

### 3.3 Connect TMC2209 to Shift Register Outputs

**Motor A (U10):**
```
MOTOR_A_STEP → U10 Pin 2 (STEP)
MOTOR_A_DIR  → U10 Pin 3 (DIR)
```

**Motor B (U11):**
```
MOTOR_B_STEP → U11 Pin 2
MOTOR_B_DIR  → U11 Pin 3
```

**Motor C (U12):**
```
MOTOR_C_STEP → U12 Pin 2
MOTOR_C_DIR  → U12 Pin 3
```

**Motor D (U13):**
```
MOTOR_D_STEP → U13 Pin 2
MOTOR_D_DIR  → U13 Pin 3
```

**Motor E (U14):**
```
MOTOR_E_STEP → U14 Pin 2
MOTOR_E_DIR  → U14 Pin 3
```

**Motor F (U15):**
```
MOTOR_F_STEP → U15 Pin 2
MOTOR_F_DIR  → U15 Pin 3
```

**Steps:**
1. Place wire from each MOTOR_X_STEP net to corresponding TMC STEP pin
2. Place wire from each MOTOR_X_DIR net to corresponding TMC DIR pin
3. Use net labels to keep schematic clean

---

## Section 4: TMC2209 Power Connections

### 4.1 Motor Power (VM+) Distribution

**Add power symbol:**
1. Place → Power Symbol
2. Select +12V or create custom "VM+" symbol
3. Connect to all TMC2209 VM+ pins (Pin 6)

**Add bulk capacitors:**
```
For each TMC2209:
  C_bulk (100µF, 25V electrolytic) between VM+ and GND
  C_ceramic (0.1µF) between VM+ and GND
```

### 4.2 Logic Power (VDD) Distribution

**Connect all TMC2209 VDD pins (Pin 4) to +5V:**
1. Place wire from +5V to U10 Pin 4
2. Continue daisy-chain to U11-U15
3. Add decoupling capacitors (0.1µF) at each driver

### 4.3 Ground Connections

**Connect all GND pins:**
- All TMC2209 Pin 5 (GND) → GND symbol
- Use ground symbols, don't wire point-to-point

---

## Section 5: UART Bus

### 5.1 Add UART Net Labels

**Create two nets:**
- TMC_UART_TX (from ESP32 to all TMC2209)
- TMC_UART_RX (shared, bidirectional)

### 5.2 Connect UART to TMC2209

**All TMC2209 Pin 13 (PDN_UART) → TMC_UART_TX**

**Steps:**
1. Place net label "TMC_UART_TX" on U10 Pin 13
2. Place net label "TMC_UART_TX" on U11-U15 Pin 13
3. All pins with same net label are connected

### 5.3 Add UART Connector

**Add 4-pin header:**
```
Pin 1: GND
Pin 2: TMC_UART_TX
Pin 3: TMC_UART_RX (for future, currently tied to TX)
Pin 4: +5V
```

**Add pull-up resistor:**
```
R_pullup (10kΩ) between TMC_UART_TX and +5V
```

---

## Section 6: TMC2209 Configuration Pins

### 6.1 Enable (EN) Pins

**Option A: Shared enable (recommended):**
- Create net "TMC_EN"
- Connect all U10-U15 Pin 1 (EN) to TMC_EN
- Add pull-down resistor (10kΩ) to GND
- Connect TMC_EN to ESP32 GPIO or leave floating (drivers enabled by default)

**Option B: Individual enables:**
- Connect each EN pin to separate GPIO

### 6.2 Microstepping Configuration (MS1/MS2)

**For 1/16 microstepping, hardwire:**
```
All TMC2209 Pin 11 (MS1) → +5V (via 10kΩ resistor)
All TMC2209 Pin 12 (MS2) → +5V (via 10kΩ resistor)
```

**Alternative: Add jumpers for configuration**

### 6.3 Diagnostic Pins (Optional)

**DIAG and INDEX pins (Pin 14, 15):**
- Leave unconnected for basic operation
- Or add test points for debugging

---

## Section 7: Motor Connectors

### 7.1 Update Connector Pinout

**Change connector labels:**

**Old (4-phase):**
```
J_MOTOR_A:
  Pin 1: MOTOR_A_PHASE_A
  Pin 2: MOTOR_A_PHASE_B
  Pin 3: MOTOR_A_PHASE_C
  Pin 4: MOTOR_A_PHASE_D
```

**New (bipolar stepper):**
```
J_MOTOR_A:
  Pin 1: MOTOR_A_A1 (from U10 Pin 7)
  Pin 2: MOTOR_A_A2 (from U10 Pin 8)
  Pin 3: MOTOR_A_B1 (from U10 Pin 9)
  Pin 4: MOTOR_A_B2 (from U10 Pin 10)
```

**Repeat for all 6 motor connectors:**
- J_MOTOR_A → U10 outputs
- J_MOTOR_B → U11 outputs
- J_MOTOR_C → U12 outputs
- J_MOTOR_D → U13 outputs
- J_MOTOR_E → U14 outputs
- J_MOTOR_F → U15 outputs

---

## Section 8: Power Input

### 8.1 Add 12V Power Input

**Add connector:**
```
J_12V_IN (Barrel jack or screw terminal):
  Pin 1: +12V
  Pin 2: GND
```

**Add reverse polarity protection:**
```
D1 (Schottky diode, SS34 or similar)
  Anode → +12V input
  Cathode → VM+ rail
```

**Add input capacitors:**
```
C1 (220µF, 25V electrolytic) between VM+ and GND
C2 (0.1µF ceramic) between VM+ and GND
```

### 8.2 Add 5V Buck Converter (Optional)

**If external 5V not available via RJ45:**

**Use MP2307 buck converter:**
```
Components:
- U_BUCK: MP2307DN (SOIC-8)
- L1: 22µH inductor
- C_IN: 10µF ceramic
- C_OUT: 22µF ceramic
- R1: 51kΩ (feedback upper)
- R2: 10kΩ (feedback lower)
- D_SCHOTTKY: SS34

Circuit:
  VM+ → MP2307 VIN
  MP2307 SW → L1 → +5V
  Feedback network sets output to 5.0V
```

**Alternatively:** Use pre-made buck module (easier)

---

## Section 9: RJ45 Connections

### 9.1 Update RJ45 Pinout

**Add UART to existing SPI signals:**

**Original pinout:**
```
Pin 1-2: Power (+5V or GND, varies)
Pin 3: GND
Pin 4: SPI MOSI (MOTOR_IN)
Pin 5: SPI MISO (sensor data)
Pin 6: SPI CLK (CLOCK_IN)
Pin 7: SPI Latch (LATCH_IN)
Pin 8: Not used
```

**New pinout (add UART):**
```
Pin 1: +5V
Pin 2: +12V (or additional +5V)
Pin 3: GND
Pin 4: SPI MOSI (MOTOR_IN)
Pin 5: SPI MISO (sensor data)
Pin 6: SPI CLK (CLOCK_IN)
Pin 7: SPI Latch (LATCH_IN)
Pin 8: TMC_UART_TX
```

**Connect:**
- RJ45_IN Pin 8 → TMC_UART_TX net
- RJ45_OUT Pin 8 → TMC_UART_TX net (pass-through)

---

## Section 10: Electrical Rules Check

**After making all changes:**

1. Tools → Electrical Rules Checker
2. Run ERC
3. Fix any errors:
   - Unconnected pins
   - Power pins not connected
   - Net conflicts

**Common issues to check:**
- All power pins (+5V, +12V, GND) connected
- All TMC2209 pins connected or marked "No Connect"
- Net labels spelled correctly
- No duplicate reference designators

---

## Section 11: Generate Netlist

**Once ERC passes:**

1. Tools → Generate Netlist
2. Format: KiCad (default)
3. Save as `chainlinkDriver_TMC2209.net`

This netlist is used when updating the PCB layout.

---

## Summary of Major Changes

**Removed:**
- 1× 74HC595 (U7)
- 6× ULN2003A (U2, U6, U8, etc.)
- 4-phase signal labels

**Added:**
- 6× TMC2209 modules (U10-U15)
- UART bus and connector
- 12V power input
- 5V buck converter (optional)
- New power distribution (12V + 5V)
- STEP/DIR signal labels

**Modified:**
- Shift register outputs (24→12 bits)
- Motor connector pinout
- RJ45 pinout (added UART)

---

## Next Steps

After completing schematic:
1. Save schematic
2. Generate netlist
3. Update PCB layout (see PCB_LAYOUT_CHANGES.md)
4. Run Design Rules Check
5. Generate manufacturing files

---

**Need Help?**
If you get stuck, take a screenshot and I can guide you through the specific step!
