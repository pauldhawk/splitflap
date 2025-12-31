# Phase 1 Basic Motor Test - Hardware Shopping List

**Purpose:** Components needed to test a single NEMA 17 motor with TMC2209 driver before building the full 48-module system.

**Date:** 2025-12-31
**Phase:** Phase 1 - Basic Motor Test (STEP/DIR control)

---

## 🛒 **Shopping List Summary**

| Item | Quantity | Est. Cost | Priority |
|------|----------|-----------|----------|
| NEMA 17 Motor | 1 | $12-15 | ✅ Required |
| TMC2209 Driver Board | 1 | $8-12 | ✅ Required |
| ESP32 Dev Board | 1 | $6-10 | ✅ Required |
| 12V Power Supply | 1 | $10-15 | ✅ Required |
| Breadboard | 1 | $5-8 | ✅ Required |
| Jumper Wires | 1 pack | $5-8 | ✅ Required |
| USB Cable (Micro/C) | 1 | $3-5 | ✅ Required |
| Multimeter | 1 | $15-25 | ⭐ Recommended |
| Wire Strippers | 1 | $8-12 | ⭐ Recommended |
| Small Screwdriver Set | 1 | $10-15 | Optional |

**Total Estimated Cost:** $82-135 (depending on what you already have)

---

## 📦 **REQUIRED COMPONENTS**

### 1. NEMA 17 Stepper Motor

**What You Need:**
- **Model:** Stepperonline 17HS19-2004S1 (you mentioned this already)
- **Specs:**
  - 42×42×48mm body
  - 200 steps/revolution
  - 2.0A rated current
  - 5mm D-shaft
  - 4-wire bipolar configuration

**Where to Buy:**
- ✅ **Stepperonline.com** - $11.99
  - Link: https://www.omc-stepperonline.com/nema-17-bipolar-59ncm-84oz-in-2a-42x48mm-4-wires-w-1m-cable-connector-17hs19-2004s1
  - Ships worldwide, good quality
- **Amazon** - $12-15
  - Search: "NEMA 17 stepper motor 2A 84oz"
  - Get one with pre-attached cable (saves soldering)
- **AliExpress** - $8-12 (slower shipping)

**What to Check:**
- [ ] Has 4 wires (bipolar configuration)
- [ ] Rated for 2.0A or close to it
- [ ] Comes with cable connector (preferred) or bare wires

**Do You Already Have This?**
- You mentioned "17HS19-2004S1" in your original request
- If you already have the motor, check it off! ✅

---

### 2. TMC2209 Driver Board

**What You Need:**
- **Type:** TMC2209 Stepper Motor Driver Module
- **Features:**
  - STEP/DIR interface
  - UART configuration support
  - Up to 2A RMS (2.8A peak)
  - StealthChop (silent operation)
  - 256 microstepping capability
  - 5V logic compatible

**Recommended Models:**

**Option A: BIGTREETECH TMC2209 V1.2** ⭐ **RECOMMENDED**
- **Cost:** $8-12
- **Where:** Amazon, AliExpress
- **Search:** "BIGTREETECH TMC2209 V1.2"
- **Why:** Very popular, well-documented, Arduino libraries available
- **Features:** Built-in heatsink, screw terminals for easy wiring

**Option B: MKS TMC2209**
- **Cost:** $10-15
- **Where:** Amazon, AliExpress
- **Features:** Similar to BTT, different pinout

**Option C: Generic TMC2209 Module**
- **Cost:** $6-10
- **Where:** AliExpress, eBay
- **Caution:** Check pinout carefully, may vary

**What to Look For:**
- [ ] Says "TMC2209" (NOT TMC2208 or TMC2130)
- [ ] Has UART pins exposed (PDN_UART, often labeled)
- [ ] Screw terminals for motor wires (easier than soldering)
- [ ] Comes with heatsink
- [ ] 5V-compatible logic inputs

**Links:**
- Amazon: Search "BIGTREETECH TMC2209"
- AliExpress: Search "TMC2209 stepper driver"

---

### 3. ESP32 Development Board

**What You Need:**
- **Type:** ESP32 development board with USB
- **Must Have:**
  - At least 3 free GPIO pins (STEP, DIR, EN)
  - Micro USB or USB-C for programming
  - 3.3V/5V tolerant pins

**Recommended Models:**

**Option A: ESP32-DevKitC V4** ⭐ **RECOMMENDED**
- **Cost:** $6-10
- **Where:** Amazon, AliExpress, Adafruit, SparkFun
- **Chip:** ESP32-WROOM-32
- **Pins:** 30 GPIO pins
- **USB:** Micro USB
- **Why:** Standard board, widely supported, lots of documentation

**Option B: ESP32-WROOM-32 Development Board (Generic)**
- **Cost:** $5-8
- **Where:** Amazon, AliExpress
- **Same as DevKitC but generic brand**

**Option C: Use Existing Chainlink Hardware**
- If you already have Chainlink Buddy or other ESP32 board, you can use that!
- Just need 3 free GPIO pins for testing

**What to Avoid:**
- ❌ ESP8266 (not ESP32)
- ❌ Boards without USB (harder to program)
- ❌ ESP32-S2/C3 (different architecture, stick with standard ESP32 for now)

**Links:**
- Adafruit: https://www.adafruit.com/product/3405 ($9.95)
- Amazon: Search "ESP32 DevKitC"
- AliExpress: Search "ESP32 development board"

---

### 4. 12V Power Supply

**What You Need:**
- **Voltage:** 12V DC
- **Current:** At least 2A (for one motor)
- **Connector:** Barrel jack (5.5mm×2.1mm standard) OR screw terminals

**Options:**

**Option A: 12V 2A Wall Adapter** ⭐ **EASIEST FOR TESTING**
- **Cost:** $8-12
- **Where:** Amazon, local electronics store
- **Specs:** 12V 2A (24W)
- **Connector:** Barrel jack, 5.5mm×2.1mm center positive
- **Search:** "12V 2A power supply adapter"
- **Pros:** Plug and play, safe
- **Cons:** Need barrel jack connector or cut wire

**Option B: 12V 5A Bench Power Supply** (if you have larger PSU)
- **Cost:** $15-30
- **Where:** Amazon
- **Use:** If you're planning to test multiple motors
- **Benefit:** Adjustable voltage, current limiting

**Option C: Reuse Existing PSU**
- If you have 12V PSU from another project, use it!
- Must supply at least 2A

**What to Check:**
- [ ] 12V DC output (not AC!)
- [ ] At least 2A current rating
- [ ] Center positive (standard)
- [ ] Has safety certifications (UL, CE, FCC)

**Links:**
- Amazon: Search "12V 2A power adapter"

---

### 5. Breadboard

**What You Need:**
- **Size:** 830-point breadboard (standard size)
- **Alternative:** 400-point half-size (works too)

**Cost:** $5-8
**Where:** Amazon, AliExpress, local electronics store

**Why:**
- Allows you to connect everything without soldering
- Easy to swap wires and troubleshoot
- Reusable for future projects

**Recommended:**
- Standard 830-point breadboard with dual power rails
- Should have adhesive backing (convenient)

**Link:**
- Amazon: Search "solderless breadboard 830"

---

### 6. Jumper Wires

**What You Need:**
- **Type:** Male-to-male jumper wires
- **Quantity:** At least 20 wires
- **Length:** 10cm-20cm (variety pack is good)

**Cost:** $5-8 for pack of 65-120 wires
**Where:** Amazon, AliExpress

**Recommended Pack:**
- Get a variety kit with:
  - Male-to-male (for breadboard to breadboard)
  - Male-to-female (for ESP32 to breadboard)
  - Female-to-female (optional, for motor connector)

**Why:**
- Connect ESP32 GPIOs to TMC2209
- Connect power supply to breadboard
- Temporary connections (no soldering needed)

**Link:**
- Amazon: Search "dupont jumper wire kit"

---

### 7. USB Cable (for ESP32)

**What You Need:**
- **Type:** Depends on your ESP32 board
  - **Micro USB** (DevKitC V4)
  - **USB-C** (newer boards)
- **Length:** 3-6 feet (1-2 meters)
- **Data capable:** Must support data, not just charging

**Cost:** $3-5
**Where:** Amazon, local electronics store

**Check:**
- [ ] Matches your ESP32 board's USB port
- [ ] Supports data transfer (not just power)
- [ ] Long enough to reach your computer

**Link:**
- Amazon: Search "micro USB cable data" or "USB-C cable data"

---

## ⭐ **RECOMMENDED COMPONENTS**

### 8. Multimeter (Highly Recommended!)

**What You Need:**
- **Type:** Basic digital multimeter
- **Features:**
  - Voltage measurement (DC)
  - Current measurement (up to 10A)
  - Continuity test
  - Resistance

**Cost:** $15-25
**Where:** Amazon, Harbor Freight, Home Depot

**Why You Need This:**
- Verify 12V power supply output
- Check motor coil resistance (~1-2Ω)
- Diagnose wiring issues
- Measure current draw
- Essential for troubleshooting!

**Recommended Models:**
- **Fluke 101** - $50 (premium, very good)
- **Klein Tools MM400** - $25 (good quality)
- **Generic Harbor Freight** - $15 (works fine for basic use)

**Link:**
- Amazon: Search "digital multimeter"

---

### 9. Wire Strippers (Recommended)

**What You Need:**
- **Type:** Basic wire stripper/cutter
- **Gauge:** 22-30 AWG range

**Cost:** $8-12
**Where:** Amazon, Home Depot, Harbor Freight

**Why:**
- Strip power supply wires if needed
- Clean wire ends for screw terminals
- Cut jumper wires to length

**Not Required If:**
- You have pre-made jumper wires
- Power supply has barrel jack connector
- TMC2209 has screw terminals (no soldering)

**Link:**
- Amazon: Search "wire stripper tool"

---

## 🔧 **OPTIONAL COMPONENTS**

### 10. Barrel Jack Adapter (Optional)

**What You Need:**
- **Type:** Barrel jack to screw terminal adapter
- **Size:** 5.5mm×2.1mm (standard)

**Cost:** $5-8 for pack of 5-10
**Where:** Amazon

**Why:**
- Easier to connect 12V wall adapter to breadboard
- No cutting wires
- Reusable

**Alternative:**
- Cut barrel jack off power supply and strip wires (permanent)

**Link:**
- Amazon: Search "barrel jack screw terminal"

---

### 11. Small Screwdriver Set (Optional)

**What You Need:**
- **Type:** Precision screwdriver set
- **Sizes:** Phillips and flat head, small sizes

**Cost:** $10-15
**Where:** Amazon, hardware store

**Why:**
- Tighten screw terminals on TMC2209
- Adjust potentiometer on driver (if needed)

**Not Required If:**
- TMC2209 has spring-loaded terminals
- You already have screwdrivers

---

### 12. Heatsink & Thermal Pad (Usually Included)

**What You Need:**
- Small aluminum heatsink for TMC2209
- Thermal adhesive pad

**Cost:** Usually included with TMC2209 driver
**If Not Included:** $2-5 for pack on Amazon

**Why:**
- TMC2209 can get hot at 2A
- Heatsink prevents thermal shutdown

**Check:**
- Most TMC2209 boards come with heatsink pre-installed or included

---

## 🔌 **WIRING COMPONENTS SUMMARY**

**What You're Connecting:**

```
12V Power Supply → TMC2209 Motor Driver → NEMA 17 Motor
                            ↕
                       ESP32 (STEP/DIR/EN)
```

**Wire Connections Needed:**

1. **Power to TMC2209:**
   - 12V+ from power supply → VM+ on TMC2209
   - GND from power supply → GND on TMC2209

2. **ESP32 to TMC2209:**
   - ESP32 GPIO (e.g., 25) → STEP pin
   - ESP32 GPIO (e.g., 26) → DIR pin
   - ESP32 GPIO (e.g., 27) → EN pin (enable)
   - ESP32 GND → TMC2209 GND (common ground)

3. **TMC2209 to Motor:**
   - TMC2209 B2 → Motor coil 1 wire 1
   - TMC2209 B1 → Motor coil 1 wire 2
   - TMC2209 A1 → Motor coil 2 wire 1
   - TMC2209 A2 → Motor coil 2 wire 2

**Total Wire Count:** ~12 jumper wires

---

## 🛍️ **WHERE TO BUY - QUICK LINKS**

### All-in-One Kits (Not Available)
Unfortunately, there's no "NEMA 17 + TMC2209 + ESP32 starter kit." You'll need to buy components separately.

### Recommended Vendors:

**For Speed (USA):**
- **Amazon** - 2-day shipping with Prime
  - Search terms: "NEMA 17 stepper motor", "TMC2209 driver", "ESP32 DevKitC"

**For Cost Savings:**
- **AliExpress** - Cheapest, but 2-4 weeks shipping
  - Good for buying multiple items

**For Quality/Support:**
- **Stepperonline.com** - Motors
- **Adafruit** - ESP32 boards ($9.95)
- **SparkFun** - ESP32 boards ($21.95, higher quality)

---

## 💰 **COST BREAKDOWN**

### Minimum Required (if you have nothing):

| Item | Cost |
|------|------|
| NEMA 17 Motor | $12 |
| TMC2209 Driver | $10 |
| ESP32 DevKitC | $8 |
| 12V 2A PSU | $10 |
| Breadboard | $6 |
| Jumper Wires | $6 |
| USB Cable | $4 |
| **TOTAL** | **$56** |

### Recommended Setup (includes tools):

| Item | Cost |
|------|------|
| NEMA 17 Motor | $12 |
| TMC2209 Driver | $10 |
| ESP32 DevKitC | $8 |
| 12V 2A PSU | $10 |
| Breadboard | $6 |
| Jumper Wires | $6 |
| USB Cable | $4 |
| Multimeter | $20 |
| Wire Strippers | $10 |
| Barrel Jack Adapter | $6 |
| **TOTAL** | **$92** |

---

## ✅ **WHAT YOU MIGHT ALREADY HAVE**

Check if you already own:
- [ ] NEMA 17 motor (17HS19-2004S1) - you mentioned this!
- [ ] ESP32 board (from Chainlink Buddy or other project)
- [ ] USB cable (probably have one lying around)
- [ ] Breadboard (from Arduino/electronics kits)
- [ ] Jumper wires (from previous projects)
- [ ] 12V power supply (from old router, monitor, etc.)
- [ ] Multimeter (any electrician has one)
- [ ] Wire strippers/cutters

**If you have most of these, you only need to buy:**
- TMC2209 driver board (~$10)
- Maybe some additional jumper wires (~$6)
- Barrel jack adapter if PSU doesn't match (~$6)

**Estimated additional cost: $22**

---

## 📦 **SHOPPING CART TEMPLATE**

**Copy this to a text file when ordering:**

```
Phase 1 Basic Motor Test - Shopping List
Date: ___________

REQUIRED:
[ ] NEMA 17 Motor (17HS19-2004S1) - $12 - Vendor: _______
[ ] TMC2209 Driver Board (BIGTREETECH) - $10 - Vendor: _______
[ ] ESP32 DevKitC V4 - $8 - Vendor: _______
[ ] 12V 2A Power Supply - $10 - Vendor: _______
[ ] 830-point Breadboard - $6 - Vendor: _______
[ ] Jumper Wire Kit (120pcs) - $6 - Vendor: _______
[ ] Micro USB Cable (data) - $4 - Vendor: _______

RECOMMENDED:
[ ] Digital Multimeter - $20 - Vendor: _______
[ ] Wire Strippers - $10 - Vendor: _______

OPTIONAL:
[ ] Barrel Jack Adapters (5pk) - $6 - Vendor: _______

TOTAL ESTIMATED: $______

NOTES:
- Shipping time: _______
- Order date: _______
- Expected arrival: _______
```

---

## 🚚 **SHIPPING & TIMELINE**

**Amazon Prime (USA):**
- Shipping: 2 days
- Total time to start: 2-3 days

**Amazon Standard (USA):**
- Shipping: 5-7 days
- Total time to start: 7-10 days

**AliExpress (International):**
- Shipping: 15-45 days
- Total time to start: 3-6 weeks
- **Tip:** Order from "Choice" or "Plus" sellers for faster shipping

**Local Electronics Store:**
- Some items available same-day at:
  - Micro Center (if near you)
  - Fry's Electronics
  - Local maker spaces

---

## 📸 **WHAT TO EXPECT WHEN IT ARRIVES**

### NEMA 17 Motor:
- Box with 1 motor
- Should have 4 wires coming out (red, blue, green, black - colors vary)
- May include connector (JST or Dupont)
- Motor should spin freely by hand (no power)

### TMC2209 Driver:
- Small PCB (~1 inch × 1.5 inch)
- Heatsink on chip (or separate in package)
- Screw terminals or pin headers
- May include manual (often in Chinese, ignore it - we have our own docs!)

### ESP32:
- PCB with ESP32 module
- Micro USB port on one end
- Lots of pins on both sides
- May include pin header (sometimes pre-soldered)

### Power Supply:
- Wall adapter with cable and barrel jack plug
- Or bare wire output
- Should have label showing: "OUTPUT: 12V DC 2A"

---

## 🔍 **VERIFICATION CHECKLIST**

**When components arrive, verify:**

### Motor:
- [ ] 4 wires present
- [ ] Shaft rotates freely by hand
- [ ] No visible damage
- [ ] Measure coil resistance: ~1-2Ω between wire pairs

### TMC2209:
- [ ] Chip markings say "TMC2209"
- [ ] Heatsink present
- [ ] No broken pins or screw terminals
- [ ] Potentiometer present (small screw on top)

### ESP32:
- [ ] USB port intact
- [ ] No bent pins
- [ ] Powers on when connected to USB (LED lights up)

### Power Supply:
- [ ] Measures 12V on multimeter when plugged in
- [ ] No burning smell when powered
- [ ] Correct polarity (center positive for barrel jack)

---

## ⚠️ **SAFETY NOTES**

1. **Power Supply:**
   - Never exceed 24V on TMC2209 (12V is safe)
   - Don't connect/disconnect motor while powered (can damage driver)
   - Check polarity before connecting

2. **Current Limit:**
   - TMC2209 will current-limit to ~2A RMS by default
   - Motor is rated 2A, so this is safe
   - Driver may get warm - this is normal

3. **Wiring:**
   - Double-check all connections before applying power
   - Use common ground (ESP32 GND = TMC2209 GND = PSU GND)
   - Don't connect 12V to ESP32 directly (it's 3.3V logic!)

4. **First Power-On:**
   - Connect everything
   - Check wiring with multimeter
   - Apply 12V power to TMC2209
   - Motor should be stationary (not moving)
   - If motor gets hot immediately, disconnect and check wiring!

---

## 📞 **WHAT IF I GET STUCK?**

**Common Issues When Ordering:**

1. **"I can't find TMC2209 V1.2"**
   - Search "TMC2209 stepper driver UART"
   - Any TMC2209 with UART support will work
   - Avoid TMC2208 or TMC2225 (different chips)

2. **"ESP32 has different pinout than expected"**
   - Most ESP32-WROOM-32 boards have similar pinouts
   - We can adapt pin numbers in code
   - Just need 3 free GPIO pins

3. **"Power supply only has bare wires, no barrel jack"**
   - This is fine! Strip and connect directly to breadboard
   - Check polarity with multimeter before connecting

4. **"Motor has 6 wires instead of 4"**
   - You got a unipolar motor (28BYJ-48 style)
   - Can be converted to bipolar, but easier to return and get 4-wire version
   - Make sure you order "bipolar" NEMA 17

---

## 🎯 **READY TO ORDER?**

**Fastest Path to Testing:**
1. Order TMC2209 from Amazon (~$10, 2-day shipping)
2. Check if you already have ESP32, breadboard, wires
3. Find a 12V power supply (old laptop charger, LED strip PSU, etc.)
4. Verify you have the NEMA 17 motor (17HS19-2004S1)

**Within 2-3 days, you can start Phase 1 testing!**

---

## 📚 **NEXT STEPS AFTER ORDERING**

While waiting for components:

1. **Install PlatformIO:**
   - Install VS Code
   - Install PlatformIO extension
   - Verify it works

2. **Read Phase 1 Code:**
   - Review `docs/Firmware_Implementation_Path.md`
   - Understand STEP/DIR control
   - Plan GPIO pin assignments

3. **Study TMC2209 Datasheet:**
   - Download from Trinamic website
   - Understand STEP/DIR interface
   - Learn about current limiting

4. **Prepare Workspace:**
   - Clear desk area
   - Get multimeter ready
   - Have computer nearby for programming

**When components arrive, you'll be ready to start immediately!**

---

## ✉️ **REPORT BACK**

Once you've ordered (or verified you have) the components, let me know:

- [ ] Which components you already have
- [ ] Which components you ordered
- [ ] Estimated arrival date
- [ ] Any questions about specific parts

**Then we can prepare the wiring diagram and code for Phase 1!**

---

**Document Status:** Complete
**Ready for:** Ordering components
**Next Document:** Phase 1 Wiring Diagram & Test Code

**Estimated time to start testing after ordering:** 2-7 days (depending on shipping)
