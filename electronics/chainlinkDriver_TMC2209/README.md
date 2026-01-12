# Chainlink Driver TMC2209

**6-Module NEMA 17 + TMC2209 Stepper Driver Board**

Modified from original Chainlink Driver for use with NEMA 17 motors and TMC2209 stepper drivers.

---

## Project Status

**Current Phase:** 🔨 Design Phase
**Schematic:** Modification guide complete
**PCB Layout:** Ready to modify
**Manufacturing:** Not yet ordered

---

## Quick Links

- **[MODIFICATION_PLAN.md](MODIFICATION_PLAN.md)** - Complete modification strategy
- **[SCHEMATIC_CHANGES.md](SCHEMATIC_CHANGES.md)** - Step-by-step schematic modifications
- **[BOM_TEMPLATE.csv](BOM_TEMPLATE.csv)** - Bill of Materials with LCSC part numbers

---

## Board Specifications

| Parameter | Value |
|-----------|-------|
| **Board Size** | 100mm × 80mm |
| **Modules per Board** | 6 (populate 2-6 as needed) |
| **Motor Type** | NEMA 17 bipolar stepper |
| **Motor Driver** | TMC2209 (1/16 microstepping) |
| **Motor Power** | 12V @ 6-10A (6× 1.0A motors) |
| **Logic Power** | 5V @ 0.5A |
| **Steps per Revolution** | 3200 (200 × 16 microsteps) |
| **Communication** | SPI (shift registers) + UART (TMC2209 config) |
| **Daisy Chain** | RJ45 (up to 8 boards) |

---

## Key Features

✅ **6× TMC2209 Stepper Drivers**
- Silent operation (StealthChop mode)
- 1/16 microstepping for smooth motion
- 1.0A RMS current (adjustable via UART)
- Built-in current limiting

✅ **Shift Register I/O**
- 2× 74HC595 (motor STEP/DIR outputs)
- 1× 74HC165 (hall sensor inputs)
- Efficient SPI bus control

✅ **Power Management**
- 12V motor power input
- Optional 5V buck converter
- Bulk capacitors for stable operation

✅ **Expandable Architecture**
- RJ45 daisy-chaining
- UART bus for TMC2209 configuration
- Supports up to 48 modules (8 boards)

✅ **JLCPCB Assembly Ready**
- All SMD components from JLCPCB library
- Minimal hand-soldering required

---

## What's Changed from Original

### Removed
- ❌ 1× 74HC595 (reduced from 3 to 2)
- ❌ 6× ULN2003A transistor arrays
- ❌ 4-phase motor control

### Added
- ✅ 6× TMC2209 stepper driver modules
- ✅ UART bus for driver configuration
- ✅ 12V power input
- ✅ 5V buck converter (optional)
- ✅ STEP/DIR motor control

### Modified
- 🔄 Shift register outputs (24→12 bits)
- 🔄 Motor connector pinout (4-phase → bipolar)
- 🔄 RJ45 pinout (added UART line)
- 🔄 Power distribution (5V → 12V + 5V)

---

## Cost Breakdown

| Item | Cost | Notes |
|------|------|-------|
| **PCB Fabrication** | $5 | JLCPCB, 2-layer, 2oz copper |
| **SMD Assembly Fee** | $25-30 | JLCPCB assembly service |
| **SMD Components** | $10 | Shift registers, passives, buck converter |
| **TMC2209 Modules** | $24 | 6× $4 (buy separately, hand-solder) |
| **Through-hole Parts** | $3 | RJ45, JST connectors, barrel jack |
| **TOTAL per Board** | **$67-72** | Complete assembled board |

**For 2 modules:** Populate only 2× TMC2209 positions = **~$55 per board**

---

## Manufacturing Options

### Option A: JLCPCB Full Service (Recommended)
**What they do:**
- PCB fabrication
- SMD component assembly (shift registers, passives)
- Quality testing

**What you do:**
- Hand-solder 6× TMC2209 modules (~15 min)
- Hand-solder through-hole connectors (~15 min)

**Lead time:** 10-14 days
**Skill level:** Basic soldering

---

### Option B: DIY Assembly
**What you do:**
- Order PCBs from JLCPCB (no assembly)
- Order all components separately
- Solder all components yourself

**Lead time:** 7-10 days (PCB) + component shipping
**Skill level:** Advanced soldering (SMD + THT)
**Cost savings:** ~$25-30 per board

---

## Assembly Guide

### 1. Receive Board from JLCPCB
- PCB with SMD components already soldered
- Inspect for defects

### 2. Hand-Solder TMC2209 Modules
```
Tools needed:
- Soldering iron (temperature controlled, 350°C)
- Solder (60/40 or lead-free)
- Flux
- Tweezers
- Multimeter

Steps:
1. Apply flux to pads
2. Tack one corner pin first
3. Align module
4. Solder remaining pins
5. Check for bridges with multimeter
```

### 3. Hand-Solder Through-Hole Connectors
```
Components:
- 2× RJ45 jacks
- 6× JST-XH 4-pin (motors)
- 6× JST-XH 3-pin (sensors)
- 1× Barrel jack (12V power)

Tips:
- Insert from top, solder from bottom
- Use plenty of solder for mechanical strength
- Check for cold joints
```

### 4. Initial Testing
```
Before powering on:
1. Visual inspection (no bridges, all pins soldered)
2. Continuity test (12V to GND = open circuit)
3. Resistance test (5V to GND > 10kΩ)

First power-up:
1. Connect 12V power supply (no motors yet)
2. Check 12V rail with multimeter
3. Check 5V rail (if using onboard buck converter)
4. Look for smoke or hot components (if so, POWER OFF immediately)
```

### 5. Firmware Upload
```
1. Connect ESP32 to board via RJ45 or programming header
2. Upload Phase 4 firmware (see firmware/README.md)
3. Open serial monitor
4. Should see TMC2209 initialization messages
```

### 6. Motor Testing
```
1. Connect 1 NEMA 17 motor to J10 (Motor A)
2. Connect 1 hall sensor to J20 (Sensor A)
3. Power on
4. Motor should home automatically
5. Test position commands via serial (g10, g20, etc.)
6. Repeat for additional motors
```

---

## Firmware Configuration

**Required build flags in `platformio.ini`:**
```ini
[env:chainlink_nema17]
build_flags =
    -DMOTOR_TYPE=MOTOR_NEMA17_TMC
    -DNUM_MODULES=6
    -DSTEPS_PER_REVOLUTION=3200
    -DTMC2209_ENABLED=true
    -DTMC_RUN_CURRENT_MA=1000
    -DTMC_HOLD_CURRENT_MA=500
```

**See:** `docs/Firmware_Motor_Selection.md` for complete integration guide

---

## Expansion

**To add more modules:**
1. Populate additional TMC2209 positions
2. Add motor and sensor connectors
3. Update firmware `NUM_MODULES` setting
4. No PCB changes needed!

**To daisy-chain boards:**
1. Connect RJ45 OUT of board 1 to RJ45 IN of board 2
2. Each board adds 6 modules
3. Update firmware for total module count

---

## Troubleshooting

### Motor doesn't move
- Check 12V power supply
- Verify TMC2209 soldering (especially EN, STEP, DIR pins)
- Check UART configuration (serial monitor for errors)
- Verify motor wiring (A+/A-/B+/B- correct)

### Motor stutters or vibrates
- Increase TMC2209 current setting
- Check for loose motor connections
- Verify acceleration profile not too aggressive

### TMC2209 UART communication fails
- Check UART_TX connection to all drivers
- Verify pull-up resistor on UART line
- Check baud rate (115200 for TMC2209)

### Motor overheats
- Reduce TMC2209 current setting
- Check for mechanical binding
- Verify proper cooling/airflow

---

## Design Files

```
electronics/chainlinkDriver_TMC2209/
├── README.md (this file)
├── MODIFICATION_PLAN.md
├── SCHEMATIC_CHANGES.md
├── BOM_TEMPLATE.csv
├── chainlinkDriver_TMC2209.sch
├── chainlinkDriver_TMC2209.kicad_pcb
└── chainlinkDriver_TMC2209.pro
```

---

## Next Steps

**To complete this design:**

1. **Open KiCad** and follow `SCHEMATIC_CHANGES.md`
2. **Update PCB layout** to match new schematic
3. **Run Design Rules Check** (DRC)
4. **Generate manufacturing files:**
   - Gerber files
   - BOM (Bill of Materials)
   - CPL (Component Placement List)
5. **Upload to JLCPCB** for quote and ordering

**Estimated time to complete:** 2-3 weeks (design + manufacturing + assembly)

---

## Support

**Questions?**
- Check `MODIFICATION_PLAN.md` for detailed design decisions
- See `docs/NEMA17_TMC2209_Upgrade.md` for firmware integration
- Review Phase 1-3 testing results for single-motor validation

**Ready to order?**
- All LCSC part numbers provided in `BOM_TEMPLATE.csv`
- TMC2209 modules: Available on Amazon, AliExpress, or BigTreeTech directly
- PCB fabrication + assembly: JLCPCB.com

---

**Project Version:** 1.0
**Last Updated:** 2026-01-11
**License:** MIT (same as main splitflap project)
