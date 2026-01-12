# Chainlink Driver TMC2209 Modification Plan

**Target:** Modify existing Chainlink Driver for NEMA 17 + TMC2209
**Configuration:** 6 modules per board, JLCPCB SMD assembly
**Date:** 2026-01-11

---

## 1. Overview of Changes

### Current Design (28BYJ-48 + ULN2003A)
```
Shift Registers: 3× 74HC595 (24 outputs: 6 motors × 4 phases)
Motor Drivers: 6× ULN2003A transistor arrays
Control: 4-bit phase pattern per motor
Power: 5V @ ~1.5A
Motor Connectors: 4-pin (Phase A/B/C/D)
```

### New Design (NEMA 17 + TMC2209)
```
Shift Registers: 2× 74HC595 (12 outputs: 6 motors × 2 bits STEP/DIR)
Motor Drivers: 6× TMC2209 stepper driver modules
Control: 2-bit STEP/DIR per motor
UART: Shared bus for TMC2209 configuration
Power: 12V @ ~6-10A motor power + 5V logic
Motor Connectors: 4-pin (A+/A-/B+/B-)
```

---

## 2. Major Component Changes

### REMOVE from BOM:
- ❌ 3× 74HC595 shift registers (reduce to 2×)
- ❌ 6× ULN2003A transistor arrays
- ❌ Associated resistors/capacitors for ULN2003A

### ADD to BOM:
- ✅ 6× TMC2209 stepper driver modules
  - Option A: BTT TMC2209 V1.2 module (solder pads)
  - Option B: Standalone TMC2209 IC (harder to solder, requires support circuit)
  - **Recommendation:** Use modules for easier assembly
- ✅ 12V power input (barrel jack or XT30 connector)
- ✅ 5V buck converter (12V → 5V for logic, if not using external 5V)
- ✅ UART connector or header (TX/RX for TMC2209 config)
- ✅ Bulk capacitors for motor power (100µF × 6, one per driver)
- ✅ Ferrite beads for noise suppression

### KEEP from original:
- ✅ 1× 74HC165 shift register (sensor input)
- ✅ RJ45 connectors (for daisy chaining)
- ✅ ESP32 connection header
- ✅ Hall sensor connectors (6×)
- ✅ Power and ground distribution

---

## 3. Schematic Modifications

### 3.1 Shift Register Changes

**Old (3× 74HC595 for 24 bits):**
```
U1 (74HC595): Outputs Q0-Q7 → Motor A/B phases
U5 (74HC595): Outputs Q0-Q7 → Motor C/D phases
U7 (74HC595): Outputs Q0-Q7 → Motor E/F phases
```

**New (2× 74HC595 for 12 bits):**
```
U1 (74HC595):
  Q0 → Motor A STEP
  Q1 → Motor A DIR
  Q2 → Motor B STEP
  Q3 → Motor B DIR
  Q4 → Motor C STEP
  Q5 → Motor C DIR
  Q6 → Motor D STEP
  Q7 → Motor D DIR

U5 (74HC595):
  Q0 → Motor E STEP
  Q1 → Motor E DIR
  Q2 → Motor F STEP
  Q3 → Motor F DIR
  Q4-Q7 → Not used (or future expansion)
```

**Actions:**
1. Delete U7 (third shift register)
2. Relabel signals from `MOTOR_X_PHASE_Y` to `MOTOR_X_STEP` and `MOTOR_X_DIR`
3. Update daisy-chain connection between U1 → U5

### 3.2 Motor Driver Section

**Old (ULN2003A):**
```
[74HC595] → [ULN2003A] → [28BYJ-48 Motor]
     4 bits     Darlington    4-phase coils
               transistors
```

**New (TMC2209):**
```
[74HC595] → [TMC2209] → [NEMA 17 Motor]
  2 bits    Stepper      4-wire bipolar
            driver       (2 coils)
```

**Actions:**
1. Delete all ULN2003A symbols (U2, U6, U8, etc.)
2. Add 6× TMC2209 modules (U10-U15)
3. Connect:
   - STEP pin ← from 74HC595
   - DIR pin ← from 74HC595
   - EN pin ← shared enable signal (or individual per driver)
   - VM+ ← 12V motor power
   - VDD ← 5V logic power
   - GND ← common ground
   - A1, A2, B1, B2 → motor connector

### 3.3 TMC2209 UART Bus

**New section:**
```
ESP32 UART TX ──┬─→ TMC2209 #1 PDN_UART
                ├─→ TMC2209 #2 PDN_UART
                ├─→ TMC2209 #3 PDN_UART
                ├─→ TMC2209 #4 PDN_UART
                ├─→ TMC2209 #5 PDN_UART
                └─→ TMC2209 #6 PDN_UART

ESP32 UART RX ──┬─→ (shared, bidirectional)
                └─→ Pull-up resistor to 3.3V
```

**Actions:**
1. Add UART_TX and UART_RX net labels
2. Connect to RJ45 connector for ESP32 interface
3. Add 10kΩ pull-up on RX line
4. Configure MS1/MS2 pins for addressing (hardwire or jumpers)

### 3.4 Power Distribution

**Old:**
```
5V input → ULN2003A → Motors
```

**New:**
```
12V input ──┬─→ TMC2209 VM+ (motor power)
            └─→ Buck converter → 5V logic

5V logic ───→ 74HC595, 74HC165, TMC2209 VDD
```

**Actions:**
1. Add 12V power input (barrel jack or screw terminal)
2. Add 5V buck converter (if not using external 5V via RJ45)
3. Add bulk capacitors: 100µF electrolytic per TMC2209 VM+ pin
4. Add ceramic capacitors: 0.1µF per IC
5. Design wide power traces (12V @ 6A = need 20-40 mil traces)

### 3.5 Connectors

**Motor Connectors (change from 4-pin to 4-pin, different pinout):**

Old pinout:
```
Pin 1: Phase A
Pin 2: Phase B
Pin 3: Phase C
Pin 4: Phase D
```

New pinout:
```
Pin 1: Coil A+ (A1)
Pin 2: Coil A- (A2)
Pin 3: Coil B+ (B1)
Pin 4: Coil B- (B2)
```

**Actions:**
1. Update silkscreen labels on PCB
2. Same connector type (JST-XH or screw terminal), different signals

---

## 4. PCB Layout Modifications

### 4.1 Component Placement Strategy

**Zone 1: Input (left side)**
```
[RJ45 In] → [74HC165 (sensors)] → [74HC595 #1] → [74HC595 #2]
```

**Zone 2: Motor Drivers (center)**
```
Row 1: [TMC #1] [TMC #2] [TMC #3]
Row 2: [TMC #4] [TMC #5] [TMC #6]
```

**Zone 3: Connectors (right side)**
```
[Motor Connector 1-6 (4-pin each)]
[Sensor Connector 1-6 (3-pin each)]
```

**Zone 4: Power (bottom)**
```
[12V Input] → [Buck Converter] → [5V rail]
[Bulk caps] [Ferrite beads]
```

**Zone 5: Output (right edge)**
```
[RJ45 Out] (daisy chain to next board)
```

### 4.2 Critical Layout Requirements

**Motor Power Traces:**
- 12V and GND: Minimum 40 mil (1mm) width for 6A
- Use 2oz copper if possible
- Consider power planes on inner layers

**Signal Integrity:**
- STEP/DIR traces: Keep short, <50mm if possible
- UART traces: Match length, add series termination resistors
- SPI traces: Keep together, match lengths

**Thermal Management:**
- TMC2209 modules get warm (~50-60°C under load)
- Add thermal vias under TMC2209 if using bare IC
- Consider heatsink pads or airflow

**Grounding:**
- Single ground plane (don't split analog/digital)
- Star ground from power input
- Via stitching around high-current areas

### 4.3 Board Dimensions

**Target size:** 100mm × 80mm (same as original Chainlink Driver)
- Fits in standard enclosures
- JLCPCB standard size (cheap)
- Room for 6 TMC2209 modules

---

## 5. BOM (Bill of Materials)

### Core ICs
| Qty | Part | Package | LCSC Part # | Price (ea) | Notes |
|-----|------|---------|-------------|------------|-------|
| 2 | 74HC595 | SOIC-16 | C5947 | $0.10 | Output shift register |
| 1 | 74HC165 | SOIC-16 | C7597 | $0.12 | Input shift register |
| 6 | TMC2209 module | Module | - | $4.00 | Stepper driver (NOT on JLCPCB) |

### Power Management
| Qty | Part | Package | LCSC Part # | Price (ea) | Notes |
|-----|------|---------|-------------|------------|-------|
| 1 | MP2307 Buck | SOIC-8 | C14259 | $0.30 | 12V→5V converter (if needed) |
| 1 | Inductor 22µH | 4.8×4.8mm | C439978 | $0.15 | For buck converter |
| 6 | 100µF electrolytic | 6.3×5.8mm | C249966 | $0.08 | Bulk caps for motors |
| 10 | 0.1µF ceramic | 0805 | C49678 | $0.01 | Decoupling |

### Connectors
| Qty | Part | Package | LCSC Part # | Price (ea) | Notes |
|-----|------|---------|-------------|------------|-------|
| 2 | RJ45 jack | Through-hole | C86580 | $0.50 | Daisy chain |
| 6 | 4-pin JST-XH | Through-hole | C144395 | $0.15 | Motor output |
| 6 | 3-pin JST-XH | Through-hole | C144394 | $0.10 | Hall sensors |
| 1 | Barrel jack 5.5×2.1mm | Through-hole | C16214 | $0.20 | 12V power input |

### Passives
| Qty | Part | Package | LCSC Part # | Price (ea) | Notes |
|-----|------|---------|-------------|------------|-------|
| 10 | 10kΩ resistor | 0805 | C17414 | $0.01 | Pull-ups |
| 5 | 1kΩ resistor | 0805 | C17513 | $0.01 | Current limiting |
| 2 | Ferrite bead | 0805 | C1017 | $0.02 | Noise suppression |

### **TOTAL (excluding TMC2209 modules):** ~$10 per board
### **TOTAL (including TMC2209 modules):** ~$34 per board

**Note:** TMC2209 modules must be hand-soldered (not available for JLCPCB assembly)

---

## 6. JLCPCB Assembly Strategy

### What JLCPCB Will Assemble (SMD parts):
- ✅ 74HC595, 74HC165 shift registers
- ✅ Buck converter (if using)
- ✅ All resistors, capacitors
- ✅ Ferrite beads

### What You Must Hand-Solder:
- ❌ TMC2209 modules (6×) - not in JLCPCB library
- ❌ RJ45 jacks (through-hole)
- ❌ JST-XH connectors (through-hole)
- ❌ Barrel jack (through-hole)

**Estimated hand-soldering time:** 30-45 minutes per board

---

## 7. Implementation Steps

### Week 1: Schematic Design
- [ ] Day 1-2: Install KiCad, open existing project
- [ ] Day 3-4: Modify schematic (delete ULN2003A, add TMC2209)
- [ ] Day 5: Add UART bus, update power section
- [ ] Day 6: Electrical rules check (ERC)
- [ ] Day 7: Review and validation

### Week 2: PCB Layout
- [ ] Day 1-2: Update footprints for new components
- [ ] Day 3-5: Place components, route traces
- [ ] Day 6: Power plane design, thermal vias
- [ ] Day 7: Design rules check (DRC), review

### Week 3: Manufacturing Prep
- [ ] Day 1: Generate Gerber files
- [ ] Day 2: Generate BOM and CPL (pick-and-place) files
- [ ] Day 3: Upload to JLCPCB, check preview
- [ ] Day 4: Order TMC2209 modules separately
- [ ] Day 5: Order PCBs + assembly from JLCPCB
- [ ] Day 6-7: Wait for shipping

### Week 4-5: Assembly & Testing
- [ ] Receive PCBs and parts
- [ ] Hand-solder TMC2209 modules and connectors
- [ ] Visual inspection, continuity testing
- [ ] Power-on test (no motors connected)
- [ ] Single motor test
- [ ] Full 6-motor test
- [ ] Firmware integration

---

## 8. Design Files Structure

```
electronics/chainlinkDriver_TMC2209/
├── MODIFICATION_PLAN.md (this file)
├── chainlinkDriver_TMC2209.kicad_pro (KiCad 6+ project)
├── chainlinkDriver_TMC2209.kicad_sch (schematic)
├── chainlinkDriver_TMC2209.kicad_pcb (board layout)
├── BOM_JLCPCB.csv (bill of materials)
├── CPL_JLCPCB.csv (component placement list)
├── gerbers/
│   └── chainlinkDriver_TMC2209_gerbers.zip
└── docs/
    ├── assembly_instructions.md
    ├── testing_procedure.md
    └── schematic.pdf
```

---

## 9. Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| TMC2209 modules don't fit footprint | Medium | High | Verify dimensions before ordering |
| Insufficient current capacity on traces | Low | High | Use 2oz copper, 40+ mil traces |
| UART addressing issues | Low | Medium | Test with 2 drivers first |
| Thermal issues with TMC2209 | Medium | Medium | Add thermal vias, test under load |
| Hand-soldering TMC2209 modules difficult | Low | Low | Modules have large pads, easy to solder |

---

## 10. Next Steps

**IMMEDIATE:**
1. Install KiCad (if not installed): https://www.kicad.org/download/
2. Copy existing Chainlink Driver files to new directory
3. Start schematic modifications

**Would you like me to:**
- A) Guide you through KiCad installation
- B) Start modifying the schematic (I can edit the files)
- C) Something else?

Let me know and we'll proceed!
