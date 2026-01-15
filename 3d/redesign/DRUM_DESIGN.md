# Drum Design - Modular 3D Printed Assembly

## Design Overview (Option 5)

Your drum uses a **modular design** with separately printed components:
- **Left drum side** - with hub for pulley/belt connection
- **Right drum side** - with magnet mount for hall sensor
- **4 spacer posts** - connect drums 40mm apart using M3 heat-set inserts

## Key Specifications

| Parameter | Value | Notes |
|-----------|-------|-------|
| Flap count | 50 | Around circumference |
| Drum diameter | 127mm | Outer diameter |
| Drum spacing | 40mm | Between left/right sides |
| Spacer posts | 4 | At 90° intervals |
| Hub design | 6 radial spokes | 3mm thick for printability |
| Central shaft | 8mm | For bearing or M8 bolt |
| Fasteners | M3 screws + heat-set inserts | 8 inserts total (2 per spacer) |

## File Structure

```
3d/redesign/
  parts/drum.scad          ← Main drum design file
  modules/constants.scad   ← All parameters (edit here for changes)
```

## Viewing the Design

### Preview in OpenSCAD

1. Open `3d/redesign/parts/drum.scad` in OpenSCAD
2. Press F5 for preview (or F6 for full render)
3. You'll see the full assembly with both drums and spacers

### Preview Individual Parts

Edit the bottom of `drum.scad` to uncomment the part you want:

```openscad
// Full assembly (default)
// drum_assembly();

// Individual parts for printing:
drum_left();
// drum_right();
// drum_spacer();
```

## Customizing Parameters

All dimensions are defined in `modules/constants.scad`. Key parameters:

```openscad
// Flap count
num_flaps = 50;                    // Change this for different flap counts

// Drum dimensions
drum_diameter = 127;               // Overall diameter
drum_width = material_thickness;   // Thickness of drum sides
drum_inner_diameter = 92;          // Inner hollow diameter (92 = 127 - 35)

// Spacer dimensions
drum_spacer_count = 4;             // Number of spacer posts
drum_spacer_diameter = 7;          // Post diameter
drum_spacer_height = 40;           // Distance between drums

// Heat-set inserts (M3x5x4mm standard)
insert_hole_dia = 4.2;             // Print hole slightly larger than insert
insert_hole_depth = 4.5;           // Slightly deeper than insert length
```

## Printing Instructions

### Recommended Print Settings

| Setting | Value | Notes |
|---------|-------|-------|
| Layer height | 0.2mm | Standard quality |
| Wall thickness | 2.4mm | (3 perimeters @ 0.8mm nozzle) |
| Infill | 20-30% | Gyroid or grid pattern |
| Support | None needed | If printed flat |
| Orientation | Drums: flat on build plate | Best surface finish for flap contact |
| | Spacers: standing vertical | Stronger in compression |

### Print Each Component Separately

**Quantity per module:**
- 1× Left drum
- 1× Right drum
- 4× Spacer posts

**Print time estimate:** ~4-6 hours total per module (depends on printer speed)

## Assembly Instructions

### Required Hardware (per module)

- **8× M3x5x4mm heat-set inserts** (2 per spacer post)
- **8× M3x10mm socket cap screws** (to attach spacers to drums)
- **1× GT2 pulley (40T, 8mm bore)** - mounts to left drum hub

### Assembly Steps

1. **Install heat-set inserts in spacers**
   - Use soldering iron at 200-220°C
   - Press insert into hole until flush with surface
   - Install 1 insert in each end of each spacer (8 total)

2. **Attach spacers to left drum**
   - Align spacer holes with clearance holes in drum
   - Thread M3x10 screw through drum into spacer insert
   - Tighten all 4 spacers (don't overtighten, just snug)

3. **Attach right drum**
   - Align holes on right drum with exposed spacer ends
   - Thread M3x10 screws through drum into spacer inserts
   - Tighten evenly in star pattern

4. **Mount pulley to left drum**
   - Attach GT2-40T pulley to central hub (mounting method TBD)
   - Ensure pulley is concentric with drum axis

## Design Features Explained

### Why Radial Spokes?

The 6-spoke radial design provides:
- ✓ Sufficient strength for rotating flaps
- ✓ Reduced print time vs solid disc
- ✓ Material efficiency
- ✓ Easy to inspect and clean
- ✓ Spoke thickness (3mm) prints well without supports

### Why Modular (Option 5)?

**Compared to printing as one piece:**
- ✓ Print drums flat = better surface finish for flap contact
- ✓ No supports needed
- ✓ Easier to maintain (can disassemble if needed)
- ✓ Serviceable (can replace damaged parts)
- ✗ Requires assembly step
- ✗ Need to buy heat-set inserts

### Spacer Positioning

The 4 spacers are positioned at radius = `drum_inner_diameter / 1.75 ≈ 52.6mm`:
- Inside the flap slot circle (won't interfere with flap pins)
- Outside the spoke web (provides mounting area)
- Evenly distributed at 90° intervals

## Next Steps / TODOs

The design is functional but has placeholders for:

1. **Pulley mounting interface** (left drum)
   - Current: Central hub with 8mm hole
   - TODO: Add mounting method for GT2-40T pulley
   - Options: grub screw holes, D-shaft, press-fit

2. **Magnet pocket** (right drum)
   - Current: Not implemented
   - TODO: Add pocket on outer edge for 6mm x 2mm magnet
   - For hall sensor homing/calibration

3. **Shaft/bearing mount** (optional)
   - Current: 8mm center hole (simple bolt pass-through)
   - Could add: bearing pockets if free-spinning drum desired

## Modifying for Your Needs

### Change number of flaps

Edit `modules/constants.scad`:
```openscad
num_flaps = 40;  // or 48, 52, 60, etc.
```

The flap holes will automatically redistribute around circumference.

### Change drum spacing

```openscad
drum_spacer_height = 50;  // Change from 40mm to 50mm
```

This affects spacer post length only - drums remain the same.

### Add more spacer posts

```openscad
drum_spacer_count = 6;  // Change from 4 to 6 posts
```

More posts = stronger but requires more screws/inserts.

### Adjust spoke count/thickness

In `parts/drum.scad`, modify the `drum_spokes()` module:
```openscad
num_spokes = 8;          // More spokes = stronger
spoke_thickness = 4;     // Thicker = stronger but heavier
```

## Questions?

Refer to main project docs:
- `CLAUDE.md` - Full project overview
- `modules/constants.scad` - All parametric values
- `3d/scripts/` - Rendering and export scripts (currently for laser-cut design)

---

**Design completed:** 2026-01-15
**Design approach:** Option 5 (Modular with heat-set inserts)
**Status:** Functional, ready for printing. Pulley mount and magnet pocket need final design.
