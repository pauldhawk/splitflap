# Phase 1 - Wiring Diagram & Setup

**Purpose:** Connect one NEMA 17 motor + TMC2209 driver to ESP32 for basic STEP/DIR testing

**Date:** 2025-12-31
**Phase:** Phase 1 - Basic Motor Test

---

## 🔌 **System Overview**

```
┌─────────────┐
│   12V PSU   │
│  (2A min)   │
└──────┬──────┘
       │ 12V + GND
       ↓
┌─────────────────────┐
│   TMC2209 Driver    │
│  ┌──────────────┐   │
│  │  VM+ = 12V   │   │
│  │  GND = GND   │   │
│  │              │   │
│  │  STEP ←──────┼───┼─── GPIO 25 (ESP32)
│  │  DIR  ←──────┼───┼─── GPIO 26 (ESP32)
│  │  EN   ←──────┼───┼─── GPIO 27 (ESP32)
│  │  GND  ←──────┼───┼─── GND (ESP32)
│  │              │   │
│  │  A1, A2  →───┼───┼─── Motor Coil A
│  │  B1, B2  →───┼───┼─── Motor Coil B
│  └──────────────┘   │
└─────────────────────┘
       ↓
┌─────────────────┐
│  NEMA 17 Motor  │
│  17HS19-2004S1  │
│                 │
│  4 wires:       │
│  - Coil A (2w)  │
│  - Coil B (2w)  │
└─────────────────┘

┌─────────────┐
│  ESP32 Dev  │
│             │
│  USB ←──────┼─── Computer (programming/serial monitor)
│             │
│  5V (not    │
│  used)      │
└─────────────┘
```

---

## 📋 **Pin Assignments**

### ESP32 to TMC2209

| ESP32 Pin | TMC2209 Pin | Function | Direction |
|-----------|-------------|----------|-----------|
| **GPIO 25** | **STEP** | Step pulse | ESP32 → TMC2209 |
| **GPIO 26** | **DIR** | Direction | ESP32 → TMC2209 |
| **GPIO 27** | **EN** | Enable (active LOW) | ESP32 → TMC2209 |
| **GND** | **GND** | Common ground | - |

### Power to TMC2209

| Source | TMC2209 Pin | Voltage | Current |
|--------|-------------|---------|---------|
| 12V PSU + | **VM+** | 12V DC | 2A |
| 12V PSU - | **GND** | Ground | - |

### TMC2209 to Motor

| TMC2209 Pin | Motor Wire | Notes |
|-------------|------------|-------|
| **B2** | Coil 1 - Wire 1 | Usually red or black |
| **B1** | Coil 1 - Wire 2 | Usually green or white |
| **A1** | Coil 2 - Wire 1 | Usually blue or yellow |
| **A2** | Coil 2 - Wire 2 | Usually black or red |

**Note:** Motor wire colors vary! You'll identify correct pairs by measuring resistance.

---

## 🛠️ **STEP-BY-STEP WIRING INSTRUCTIONS**

### **SAFETY FIRST:**
- [ ] Unplug 12V power supply before wiring
- [ ] Disconnect USB from ESP32
- [ ] Work on non-conductive surface
- [ ] Keep multimeter nearby

---

### **Step 1: Identify Motor Coil Pairs**

Your NEMA 17 has 4 wires - need to find which 2 belong to each coil.

1. **Set multimeter to resistance mode (Ω)**
2. **Test all wire combinations:**
   - Coil A: Should measure ~1-2Ω between two wires
   - Coil B: Should measure ~1-2Ω between different two wires
   - Non-matching wires: Infinite resistance (open circuit)

**Example:**
```
Motor Wires: Red, Blue, Green, Black

Test Results:
- Red ↔ Green: 1.5Ω ✅ → Coil A
- Blue ↔ Black: 1.6Ω ✅ → Coil B
- Red ↔ Blue: ∞Ω (open)
- Red ↔ Black: ∞Ω (open)
- Green ↔ Blue: ∞Ω (open)
- Green ↔ Black: ∞Ω (open)

Result:
- Coil A = Red + Green
- Coil B = Blue + Black
```

**Record your results:**
```
My Motor:
- Coil A = _______ + _______
- Coil B = _______ + _______
```

---

### **Step 2: Prepare TMC2209 Driver**

1. **Inspect TMC2209 board:**
   - [ ] Heatsink installed on chip (or install it now)
   - [ ] Screw terminals or pin headers present
   - [ ] No visible damage

2. **Locate pins on TMC2209:**
   - **Power:** VM+, GND
   - **Logic:** STEP, DIR, EN, GND
   - **Motor:** A1, A2, B1, B2

**Common TMC2209 Layouts:**

**BIGTREETECH TMC2209 V1.2:**
```
┌─────────────────┐
│  [Heatsink]     │
│                 │
│  VM+  A1  B1    │  ← Screw terminals (power & motor)
│  GND  A2  B2    │
│                 │
│  EN   MS1  TX   │  ← Pin headers (logic)
│  STEP MS2  RX   │
│  DIR  MS3       │
│  GND            │
└─────────────────┘
```

3. **Check jumpers/switches (if any):**
   - UART mode: Usually enabled by default
   - MS1/MS2/MS3: Don't connect (we'll configure via UART later)
   - Standalone mode: Remove any jumpers

---

### **Step 3: Wire Power Supply to TMC2209**

**⚠️ POWER SUPPLY MUST BE UNPLUGGED!**

#### **Option A: Power Supply with Barrel Jack**

1. **If using barrel jack adapter:**
   - Plug barrel jack into adapter
   - Adapter has screw terminals: + and -
   - Use multimeter to verify polarity (should be ~12V)

2. **Connect to TMC2209:**
   - Red jumper wire: Adapter + → TMC2209 VM+
   - Black jumper wire: Adapter - → TMC2209 GND

#### **Option B: Power Supply with Bare Wires**

1. **Strip wire ends (~5mm)**
2. **Verify polarity with multimeter** (should measure ~12V when plugged in, then unplug!)
3. **Connect to TMC2209:**
   - Positive wire → TMC2209 VM+
   - Negative wire → TMC2209 GND

4. **Tighten screw terminals firmly**

---

### **Step 4: Wire Motor to TMC2209**

**Using the coil pairs you identified in Step 1:**

1. **Connect Coil A to TMC2209:**
   - Coil A Wire 1 → TMC2209 **A1**
   - Coil A Wire 2 → TMC2209 **A2**

2. **Connect Coil B to TMC2209:**
   - Coil B Wire 1 → TMC2209 **B1**
   - Coil B Wire 2 → TMC2209 **B2**

**Notes:**
- Polarity within each coil doesn't matter initially (we can swap later if rotation is backwards)
- If motor vibrates but doesn't turn: swap one coil pair (A1↔A2 or B1↔B2)
- Tighten all screw terminals firmly

---

### **Step 5: Wire ESP32 to TMC2209**

**⚠️ ESP32 MUST BE DISCONNECTED FROM USB!**

Use breadboard for clean connections:

1. **Power rails on breadboard:**
   - Not used in this test (ESP32 powered via USB, TMC2209 via 12V)

2. **ESP32 to breadboard:**
   - Insert ESP32 into breadboard
   - Leave room for jumper wires

3. **Connect control signals:**

| From (ESP32) | To (TMC2209) | Wire Color (Suggested) | Function |
|--------------|--------------|------------------------|----------|
| **GPIO 25** | **STEP** | Yellow | Step pulses |
| **GPIO 26** | **DIR** | Green | Direction |
| **GPIO 27** | **EN** | Blue | Enable |
| **GND** | **GND** | Black | Common ground ⚠️ CRITICAL |

**⚠️ IMPORTANT: Common Ground**
- ESP32 GND **MUST** connect to TMC2209 GND
- Without common ground, logic signals won't work
- Use a short black jumper wire

4. **Double-check connections:**
   - [ ] GPIO 25 → STEP
   - [ ] GPIO 26 → DIR
   - [ ] GPIO 27 → EN
   - [ ] ESP32 GND → TMC2209 GND

---

### **Step 6: Verify Wiring Before Power-On**

**CRITICAL SAFETY CHECK - DO NOT SKIP!**

#### **Power Connections:**
- [ ] 12V PSU + → TMC2209 VM+
- [ ] 12V PSU - → TMC2209 GND
- [ ] 12V PSU is **UNPLUGGED**

#### **Motor Connections:**
- [ ] Motor Coil A → TMC2209 A1, A2
- [ ] Motor Coil B → TMC2209 B1, B2
- [ ] All screw terminals tight

#### **Logic Connections:**
- [ ] ESP32 GPIO 25 → TMC2209 STEP
- [ ] ESP32 GPIO 26 → TMC2209 DIR
- [ ] ESP32 GPIO 27 → TMC2209 EN
- [ ] ESP32 GND → TMC2209 GND

#### **What NOT to Connect:**
- [ ] Verify: ESP32 5V/3.3V pins NOT connected to anything
- [ ] Verify: TMC2209 VM+ NOT connected to ESP32
- [ ] Verify: No shorts between power rails

#### **Multimeter Checks:**
- [ ] Resistance between 12V+ and GND: Should be >100Ω (no short)
- [ ] Resistance between ESP32 3.3V and GND: High (no short)

---

### **Step 7: Photo Documentation**

**Take photos before power-on for troubleshooting:**

1. **Top view of entire setup**
   - Shows breadboard, ESP32, TMC2209, motor
2. **Close-up of TMC2209 connections**
   - Shows all screw terminals and wire colors
3. **Close-up of ESP32 connections**
   - Shows GPIO pins and jumper wires
4. **Power supply connection**
   - Shows 12V wiring to TMC2209

---

## ⚡ **FIRST POWER-ON PROCEDURE**

**Now we'll power on step-by-step to verify everything works:**

### **Test 1: Power TMC2209 Only**

1. **Disconnect ESP32 from USB** (if connected)
2. **Plug in 12V power supply**
3. **Observe TMC2209:**
   - [ ] No smoke, burning smell, or sparks ✅
   - [ ] LED on TMC2209 lights up (if present) ✅
   - [ ] Motor does NOT move ✅ (expected - no signals yet)
   - [ ] Motor may "lock" (feels stiff) - this is normal ✅

4. **Check with hand:**
   - Try to rotate motor shaft by hand
   - Should feel resistance (motor is energized)
   - If motor spins freely: EN pin might be enabled (HIGH), this is OK for now

5. **Temperature check after 30 seconds:**
   - Touch TMC2209 heatsink - should be warm, not hot
   - Touch motor body - should be room temp or slightly warm

**If anything smells burnt or gets very hot, UNPLUG IMMEDIATELY and recheck wiring!**

### **Test 2: Power ESP32 Only**

1. **Unplug 12V power supply**
2. **Connect ESP32 to computer via USB**
3. **Observe:**
   - [ ] ESP32 LED lights up ✅
   - [ ] ESP32 feels slightly warm (normal) ✅
   - [ ] Motor does nothing ✅

### **Test 3: Power Both (Before Firmware Upload)**

1. **Keep ESP32 connected to USB**
2. **Plug in 12V power supply**
3. **Observe:**
   - [ ] Both ESP32 and TMC2209 powered ✅
   - [ ] Motor doesn't move (no firmware yet) ✅
   - [ ] No unusual behavior ✅

**If everything looks good, you're ready for firmware upload!**

---

## 🔍 **Troubleshooting - Common Issues**

### **Issue: TMC2209 LED doesn't light up**
- Check 12V PSU is plugged in and switch is ON
- Verify 12V at TMC2209 VM+ and GND with multimeter
- Check screw terminals are tight

### **Issue: TMC2209 gets very hot immediately**
- UNPLUG POWER!
- Check for short between VM+ and GND
- Verify motor coils are correct (measure resistance)
- Check current limit setting (VREF, covered in Phase 2)

### **Issue: Motor vibrates/buzzes but doesn't turn**
- Coil wires might be swapped
- Swap one coil pair (e.g., A1↔A2) and try again

### **Issue: ESP32 won't power on via USB**
- Try different USB cable (must be data cable, not charge-only)
- Try different USB port on computer
- Check ESP32 for visible damage

### **Issue: Motor moves randomly when powering on**
- This can happen if EN pin is floating
- Firmware will fix this by setting EN LOW (enabled)

---

## 📸 **Expected Setup Photos**

### **Breadboard Layout Example:**

```
┌────────────────────────────────────┐
│  [===== ESP32 DevKitC =====]       │  ← Breadboard
│   │ │ │ │ │ │ │ │ │ │ │ │ │ │      │
│   • • • • • • • • • • • • • •      │
│   • • • • • • • • • • • • • •      │
│     │   │   │   │                  │
│     │   │   │   └─ GND (black) ────┼──→ TMC2209 GND
│     │   │   └─ GPIO 27 (blue) ─────┼──→ TMC2209 EN
│     │   └─ GPIO 26 (green) ────────┼──→ TMC2209 DIR
│     └─ GPIO 25 (yellow) ───────────┼──→ TMC2209 STEP
│                                     │
│  [USB cable] ←─────────────────────┼──→ Computer
└────────────────────────────────────┘

┌─────────────────┐
│   TMC2209       │
│  ┌──────────┐   │
│  │ Heatsink │   │
│  └──────────┘   │
│                 │
│  VM+ ←──────────┼──── Red wire ←──── 12V PSU +
│  GND ←──────────┼──── Black wire ←── 12V PSU -
│                 │
│  A1  ←──────────┼──── Motor wire 1 (Coil A)
│  A2  ←──────────┼──── Motor wire 2 (Coil A)
│  B1  ←──────────┼──── Motor wire 3 (Coil B)
│  B2  ←──────────┼──── Motor wire 4 (Coil B)
│                 │
│  STEP ←─────────┼──── Yellow wire ←── ESP32 GPIO 25
│  DIR  ←─────────┼──── Green wire ←──── ESP32 GPIO 26
│  EN   ←─────────┼──── Blue wire ←───── ESP32 GPIO 27
│  GND  ←─────────┼──── Black wire ←──── ESP32 GND
└─────────────────┘
```

---

## ✅ **Wiring Complete Checklist**

Before proceeding to firmware upload:

### **Connections:**
- [ ] 12V PSU connected to TMC2209 VM+ and GND
- [ ] Motor Coil A connected to TMC2209 A1, A2
- [ ] Motor Coil B connected to TMC2209 B1, B2
- [ ] ESP32 GPIO 25 → TMC2209 STEP
- [ ] ESP32 GPIO 26 → TMC2209 DIR
- [ ] ESP32 GPIO 27 → TMC2209 EN
- [ ] ESP32 GND → TMC2209 GND (⚠️ CRITICAL!)

### **Safety Checks:**
- [ ] No shorts between power rails
- [ ] No loose wires
- [ ] TMC2209 heatsink installed
- [ ] Workspace clear of metal objects

### **Power-On Tests:**
- [ ] TMC2209 powered on successfully (LED lit, no smoke)
- [ ] ESP32 powered on successfully (LED lit)
- [ ] Both powered together with no issues
- [ ] Motor doesn't overheat

### **Documentation:**
- [ ] Photos taken of wiring
- [ ] Motor coil pairs identified and recorded
- [ ] Wire colors documented

---

## 🎯 **Next Steps**

**You're now ready for:**
1. **Upload test firmware** (next document)
2. **Verify motor rotates**
3. **Test direction control**
4. **Test speed control**

**Proceed to:** `Phase1_Test_Firmware.md`

---

**Document Status:** Complete
**Setup Time:** 30-45 minutes (first time)
**Wiring Verified:** ☐ Pending (check when complete)
**Ready for Firmware:** ☐ Pending
