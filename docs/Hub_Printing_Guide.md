# NEMA 17 Coupling Hub - Printing & Testing Guide

**Part:** Coupling Hub for NEMA 17 Motor to Spool Connection
**File:** `3d/nema17_coupling_hub.stl`
**Purpose:** Connects NEMA 17 motor shaft to laser-cut spool
**Print Time:** ~30 minutes
**Cost:** ~$0.20 in filament

---

## 📋 **Pre-Print Checklist**

Before you start, make sure you have:

### **Files**
- [x] STL file exported: `3d/nema17_coupling_hub.stl` (173 KB)

### **Hardware (for testing after print)**
- [ ] 2× M3 grub screws (set screws), 6-8mm length
  - Type: Cup point or cone point (NOT flat point)
  - Where to buy: Hardware store, Amazon, McMaster-Carr
  - Cost: ~$0.50 for pack of 10
- [ ] 1× NEMA 17 motor (17HS19-2004S1)
- [ ] 1.5mm hex key (Allen key) for M3 grub screws

### **Tools**
- [ ] 3D printer with PLA or PETG filament
- [ ] Slicer software (Cura, PrusaSlicer, Bambu Studio, etc.)
- [ ] Calipers or ruler (for measurements)
- [ ] Marker (for marking alignment)

---

## 🖨️ **STEP 1: Slice the STL File**

### **1.1 Import STL into Slicer**

1. Open your slicer software
2. Click **"Add"** or **"Import"**
3. Navigate to: `/Users/paulhawk/Dropbox/projects/splitflap/splitflap/3d/`
4. Select: `nema17_coupling_hub.stl`
5. Click **"Open"**

### **1.2 Check Orientation**

The hub should be positioned **flat on the build plate** with:
- Large circular top facing UP
- Grub screw holes on the sides (horizontal)
- No rotation needed

**Correct orientation:**
```
     Top view:          Side view:
    ___________         ___________
   (     o     )       |           |  ← 12mm tall
   (   o   o   )       |___________|
   (_____o_____)
```

**If rotated incorrectly, rotate it so it sits flat!**

### **1.3 Apply Print Settings**

**CRITICAL SETTINGS:**

| Setting | Value | Why? |
|---------|-------|------|
| **Material** | PLA or PETG | PLA easier, PETG stronger |
| **Layer Height** | 0.2mm | Good balance of quality/speed |
| **Infill** | **100%** | **MUST BE SOLID - this part takes torque!** |
| **Infill Pattern** | Grid, Gyroid, or Cubic | Any pattern, just 100% |
| **Wall/Perimeter Count** | 4+ walls | Adds strength |
| **Top Layers** | 5+ | Solid top |
| **Bottom Layers** | 5+ | Solid bottom |
| **Supports** | **NONE** | No overhangs, prints flat |
| **Brim/Raft** | Optional | Use if adhesion is poor |
| **Print Speed** | 50-60mm/s | Standard speed |
| **Nozzle Temp (PLA)** | 200-210°C | Standard PLA temp |
| **Bed Temp (PLA)** | 60°C | Standard PLA bed |

**⚠️ WARNING: If infill is not 100%, the hub WILL crack under motor torque!**

### **1.4 Verify in Slicer Preview**

- [ ] Check layer view - should be completely solid (no gaps inside)
- [ ] Check estimated time (~30 minutes)
- [ ] Check estimated filament (~10-12 grams)
- [ ] Verify no supports generated

### **1.5 Slice and Export**

1. Click **"Slice"** button
2. Review estimated time and material
3. Save to SD card / USB / Send to printer
4. File name: `nema17_hub.gcode`

---

## 🖨️ **STEP 2: Print the Hub**

### **2.1 Prepare Printer**

- [ ] Clean build plate (IPA wipe)
- [ ] Level bed (if needed)
- [ ] Load filament (PLA or PETG)
- [ ] Preheat to print temperature

### **2.2 Start Print**

1. Insert SD card / connect printer
2. Select file: `nema17_hub.gcode`
3. Start print
4. **Watch first layer!** - should adhere well

### **2.3 First Layer Check (Critical!)**

**After first layer:**
- [ ] Lines are squished and adhered well
- [ ] No gaps between lines
- [ ] Extruder not too high (lines separate) or too low (dragging)

**If first layer fails:** Stop, re-level bed, try again

### **2.4 Monitor Print**

- Check every ~10 minutes for first 30 minutes
- Make sure no layer shifting or detachment
- Print should complete in ~30-40 minutes total

### **2.5 Print Complete!**

When finished:
- [ ] Let cool for 2-3 minutes
- [ ] Remove from bed carefully (use scraper if needed)
- [ ] Part should pop off easily when cool

---

## 🔍 **STEP 3: Inspect Print Quality**

### **3.1 Visual Inspection**

Check for these issues:

| What to Check | Good ✅ | Bad ❌ | Fix |
|---------------|---------|--------|-----|
| **Center hole** | Clean, round | Stringing, debris | Clean with 5mm drill bit |
| **Grub screw holes** | Clear | Blocked | Poke with 3mm drill bit or hex key |
| **Top surface** | Smooth, solid | Gaps, holes | Re-slice with more top layers |
| **Walls** | Smooth | Layer separation | Reprint, check temp |
| **Overall shape** | Round, straight | Warped, bent | Reprint, improve bed adhesion |

### **3.2 Clean Up**

1. **Remove supports** (if any - there shouldn't be any!)
2. **Clean center hole:**
   - Use a 5mm drill bit or round file
   - Twist by hand to remove any blobs
   - Should be smooth inside
3. **Clean grub screw holes:**
   - Poke 1.5mm hex key through
   - Should thread easily

### **3.3 Measure Dimensions**

Use calipers to verify:

| Dimension | Target | Acceptable Range | Actual |
|-----------|--------|------------------|--------|
| Outer diameter | 20mm | 19.8-20.2mm | _____ mm |
| Height | 12mm | 11.8-12.2mm | _____ mm |
| Center hole | 5mm | 4.9-5.1mm | _____ mm |
| Weight | 10-12g | 8-15g | _____ g |

**If measurements are off by >0.5mm:** Check slicer scaling (should be 100%)

---

## 🧪 **STEP 4: Test Fit on Motor**

### **4.1 Prepare Motor**

- [ ] Have NEMA 17 motor ready
- [ ] Verify motor shaft is clean (no oil, debris)
- [ ] Check shaft is 5mm D-shaft (two flat sides)

### **4.2 Test Fit (WITHOUT Grub Screws First)**

1. **Align hub with motor shaft:**
   - Identify the two flats on motor shaft
   - Align hub so grub screw holes face the flats

2. **Press hub onto shaft:**
   - Apply firm, even pressure
   - Hub should slide on with some resistance
   - Push until hub is fully seated (5-10mm from motor face)

### **4.3 Evaluate Fit**

**GOOD FIT ✅:**
- Hub presses on with firm hand pressure (not easy, not impossible)
- Hub feels snug on shaft
- No side-to-side wobble
- Rotates smoothly when you twist it

**TOO TIGHT ❌:**
- Can't press on even with hard pressure
- Risk of cracking hub
- **FIX:** Increase `shaft_hole_clearance` in .scad file by 0.05mm and reprint

**TOO LOOSE ❌:**
- Hub slides on with no resistance
- Wobbles side-to-side
- Falls off easily
- **FIX:** Decrease `shaft_hole_clearance` in .scad file by 0.05mm and reprint

### **4.4 Check Grub Screw Alignment**

With hub on shaft:
- [ ] Look at grub screw holes from side
- [ ] They should point at the FLAT parts of the shaft (not the round parts)
- [ ] If misaligned, rotate hub 90° and check again

**Correct alignment:**
```
Top view of shaft:
    ___
   /   \
  |  D  |  ← Flat sides
   \___/

Grub screws → ● D ● ← Should point at flats
```

---

## 🔩 **STEP 5: Install Grub Screws**

### **5.1 Thread Test (Before Final Install)**

1. Get one M3 grub screw
2. Thread it into hole BY HAND (no hex key yet)
3. Should thread smoothly
4. If too tight, you may need to tap threads (see troubleshooting)

### **5.2 Position Hub on Shaft**

1. Press hub onto motor shaft fully
2. Rotate hub so grub screw holes align with flats (verify alignment!)
3. Hub should sit about 5-10mm from motor face

### **5.3 Insert First Grub Screw**

1. Get first M3 grub screw
2. Thread into hole by hand until it touches the shaft flat
3. Use 1.5mm hex key to tighten **gently**
4. Stop when you feel resistance (screw is biting into flat)
5. **Don't fully tighten yet!**

### **5.4 Insert Second Grub Screw**

1. Insert second grub screw on opposite side
2. Thread by hand, then tighten gently with hex key
3. Stop when it touches the shaft

### **5.5 Final Tightening (Alternate Method)**

Tighten screws alternately to prevent cocking:

```
Round 1:
- Screw 1: 1/4 turn
- Screw 2: 1/4 turn

Round 2:
- Screw 1: 1/4 turn
- Screw 2: 1/4 turn

Round 3:
- Screw 1: 1/4 turn (final tightness)
- Screw 2: 1/4 turn (final tightness)
```

**Tightness check:**
- Screws should be snug (firm resistance)
- DON'T over-tighten (will strip plastic or shaft)
- Should see slight indentation on shaft flats

### **5.6 Optional: Apply Threadlocker**

For permanent installation:
1. Remove grub screws
2. Apply 1 small drop of **blue** Loctite to threads
3. Reinstall and tighten as above
4. Let cure for 24 hours before heavy use

**⚠️ Use BLUE Loctite, NOT red! Red is permanent and you won't be able to remove screws!**

---

## ✅ **STEP 6: Test for Slip**

**This is the CRITICAL TEST - hub must not slip under torque!**

### **6.1 Hand Twist Test**

1. Hold motor body firmly in one hand
2. Grip hub with other hand
3. Try to twist/rotate hub with significant force
4. Hub should **NOT rotate at all** relative to motor shaft

**PASS ✅:** Hub doesn't move, feels locked solid
**FAIL ❌:** Hub rotates or slips → Tighten grub screws more

### **6.2 Mark Alignment Test**

1. Use a marker (Sharpie)
2. Draw a line from motor body → across hub
3. Try to twist hub again
4. Line should stay aligned (hub not rotating)

### **6.3 Powered Test (Optional - If You Have TMC2209 Driver)**

If you have electronics connected:

1. Connect NEMA 17 to TMC2209 driver
2. Send STEP commands (slow speed)
3. Watch hub rotate with motor
4. Should rotate smoothly, no jerking or slipping
5. Mark should stay aligned throughout rotation

### **6.4 Long-Term Test**

For production use:
- Run motor for 5-10 minutes continuously
- Check mark alignment after
- If slipped, tighten more or add Loctite

---

## 📊 **STEP 7: Document Results**

Fill out this checklist:

### **Print Quality**
- [ ] Print completed successfully
- [ ] No warping or defects
- [ ] Center hole clean and smooth
- [ ] Grub screw holes clear

### **Fit Test**
- [ ] Hub fits on motor shaft
- [ ] Fit quality: ☐ Tight  ☐ Good  ☐ Loose
- [ ] Grub screws align with flats
- [ ] Both screws threaded successfully

### **Torque Test**
- [ ] Hub doesn't slip when twisted by hand
- [ ] Grub screws tightened properly
- [ ] Mark alignment stays constant
- [ ] No visible damage to shaft or hub

### **Measurements**
- Hub outer diameter: _____ mm (target: 20mm)
- Hub height: _____ mm (target: 12mm)
- Hub weight: _____ grams (target: 10-12g)

### **Photos Taken**
- [ ] Hub by itself (top view)
- [ ] Hub on motor shaft (front view)
- [ ] Hub on motor shaft (side view)
- [ ] Close-up of grub screws installed

---

## 🔧 **STEP 8: Troubleshooting**

### **Problem: Hub won't fit on shaft**

**Symptoms:** Can't press hub onto shaft even with significant force

**Causes:**
- Center hole too small (tolerance too tight)
- Blobs or strings in hole
- Wrong motor shaft size

**Solutions:**
1. Clean center hole with 5mm drill bit (twist by hand)
2. Increase `shaft_hole_clearance` in .scad file by 0.05mm
3. Reprint
4. Verify motor is actually NEMA 17 with 5mm shaft

---

### **Problem: Hub too loose on shaft**

**Symptoms:** Hub slides on easily, wobbles, or falls off

**Causes:**
- Center hole too large
- Motor shaft undersized
- Print shrinkage

**Solutions:**
1. Decrease `shaft_hole_clearance` in .scad file by 0.05mm
2. Reprint
3. Temporary fix: Wrap shaft with thin tape before installing hub (not ideal)
4. Add texture to shaft with fine sandpaper (helps grub screws bite)

---

### **Problem: Grub screws strip threads**

**Symptoms:** Grub screws won't thread or cross-thread

**Causes:**
- Holes not printed cleanly
- Plastic too soft
- Forcing screw at wrong angle

**Solutions:**
1. Pre-clear holes with 3mm drill bit
2. Use an M3 tap to cut threads properly
3. Thread screws slowly and straight
4. Alternative: Use brass threaded inserts (M3 × 4mm)

---

### **Problem: Hub slips under torque**

**Symptoms:** Hub rotates on shaft when motor runs

**Causes:**
- Grub screws not tight enough
- Grub screws not aligned with flats
- Screws in wrong position

**Solutions:**
1. Verify grub screws are on the FLAT parts of shaft (not round)
2. Tighten screws more (alternate tightening)
3. Add blue Loctite to screws
4. Add second set of grub screws (drill holes 90° from first set)
5. Roughen shaft flats with sandpaper for better bite

---

### **Problem: Hub wobbles when shaft rotates**

**Symptoms:** Hub not concentric, visible wobble

**Causes:**
- Print defect (layers separated)
- Center hole not round
- Hub cocked on shaft (grub screws tightened unevenly)

**Solutions:**
1. Reprint with better settings (slower speed, better cooling)
2. Make sure both grub screws tightened equally
3. Check center hole with calipers - should be round

---

### **Problem: Can't access mounting holes**

**Symptoms:** Bolts won't fit through mounting holes to attach spool

**Causes:**
- Holes too small
- Holes filled with support material (shouldn't happen)

**Solutions:**
1. Clear holes with 3.2mm drill bit
2. Check slicer didn't add supports inside holes
3. If still blocked, increase `mounting_hole_diameter` to 3.5mm and reprint

---

## ✉️ **STEP 9: Report Results**

### **When to Contact**

After completing all steps above, report:

**If Successful ✅:**
- "Hub printed successfully!"
- "Fits on motor shaft perfectly"
- "Passes slip test"
- "Ready for spool attachment"
- Include photos

**If Issues ❌:**
- Describe specific problem
- Which test failed
- What you tried
- Include photos of issue

### **What Happens Next**

Once hub is tested and working:
1. Design motor mount plate (4× M3 holes, 31mm spacing)
2. Modify spool to bolt to hub (4× M3 mounting holes)
3. Create full assembly
4. Test full splitflap module!

---

## 📚 **Reference Information**

### **Hub Specifications**
- Material: 3D printed PLA or PETG
- Outer diameter: 20mm
- Height: 12mm
- Weight: ~10-12 grams
- Center hole: 5mm D-shaft
- Grub screws: 2× M3, 6-8mm length
- Mounting holes: 4× M3, on 16mm PCD

### **Motor Specifications (NEMA 17)**
- Model: 17HS19-2004S1
- Shaft: 5mm diameter, D-shaft (two flats)
- Shaft length: 24mm
- Mounting: 4× M3, 31mm spacing

### **Files Created**
- Design file: `3d/nema17_coupling_hub.scad`
- STL file: `3d/nema17_coupling_hub.stl` (173 KB)
- Assembly view: `3d/nema17_assembly_view.scad`
- This guide: `docs/Hub_Printing_Guide.md`

---

## ✅ **Success Criteria**

**You're ready to proceed if:**

- [x] Hub printed successfully with 100% infill
- [x] Hub fits snugly on NEMA 17 shaft
- [x] Grub screws align with shaft flats
- [x] Both grub screws tighten properly
- [x] Hub doesn't slip when twisted hard by hand
- [x] Hub looks concentric when shaft rotates
- [x] All 4 mounting holes are accessible

**Once all boxes checked, you're ready for the next phase!**

---

**Document Version:** 1.0
**Date:** 2025-12-31
**Part:** NEMA 17 Coupling Hub
**Status:** Ready for Printing
