Split-Flap Build Plan

This document is the running plan for building the split-flap display, starting with swapping the drive motor from a 28BYJ-48 (12V geared stepper) to a STEPPERONLINE NEMA 17 (17HS19-2004S1) + TMC2209.

⸻

0. Project intent
   • Build a reliable split-flap module that can:
   • move accurately to any character
   • home/index consistently
   • run for long periods without losing alignment
   • be maintainable (easy access to belt/gear/motor)

⸻

1. Motor swap: 28BYJ-48 → NEMA 17 + TMC2209

1.1 What’s changing

Old
• Motor: 28BYJ-48 (12V, 4-phase geared stepper)
• Typical drive: ULN2003-style transistor board (on/off coils)
• Strengths: cheap, simple, very low speed, quiet-ish
• Weaknesses: low torque at output (especially at speed), gearbox backlash, inconsistent step counts across variants

New
• Motor: NEMA 17 bipolar, 1.8° (200 steps/rev), 2.0A/phase, ~59 Ncm holding torque, 48mm body, 4-lead
• Driver: TMC2209 (Step/Dir) with current limiting + microstepping
• Strengths: far more torque, higher speed capability, better control, easier tuning with acceleration profiles
• Weaknesses: more current/heat, needs correct driver configuration and decent mechanics (coupling/alignment)

1.2 Design decisions to lock in now
• Drive method: direct drive vs belt vs gears
• If you keep the existing gearbox/belt design, note the new motor will expose any backlash/slop.
• Target speed: “quiet and reliable” vs “snappy and fast”
• This affects acceleration limits and current.
• Homing method: physical switch / hall sensor / sensorless (TMC2209 stall detection)
• Recommend: hall sensor + magnet for split-flap repeatability.

⸻

2. Mechanical tasks for the motor swap

2.1 Motor mounting
• Create/modify the motor mount for NEMA 17 face pattern.
• Add:
• slotted holes (or an idler) for belt tensioning without disassembly
• cable strain relief for the 1m motor cable

Gotchas
• NEMA17 is heavier; vibration will shake flimsy mounts.
• Keep the motor plate stiff (thicker walls, ribs, or metal bracket).

2.2 Shaft coupling and interface
• NEMA 17 shaft is 5mm.
• Decide coupling:
• Direct to drum shaft (coupler)
• Pulley (GT2, etc.)
• Gear (printed gear + grub screw)

Gotchas
• Printed press-fit couplers slip. Prefer a clamp-style coupler or a gear/pulley with set screw onto the D-flat.

2.3 Re-derive motion ratios

You must recompute “how many steps equals one full drum revolution.”
• NEMA 17: 200 full steps per motor rev
• With microstepping: steps_per_rev = 200 \* microsteps

Examples:
• 1/16 microstepping → 200 _ 16 = 3200 microsteps per motor rev
• 1/32 microstepping → 200 _ 32 = 6400 microsteps per motor rev

If you have a gear/belt ratio:
• drum_steps_per_rev = motor_steps_per_rev \* (driven_teeth / drive_teeth)

If direct drive:
• drum_steps_per_rev = motor_steps_per_rev

Why this matters
• Your character indexing will drift if this number is wrong.

⸻

3. Electrical tasks

3.1 Power
• NEMA 17 + TMC2209 typically uses 12V or 24V motor supply.
• Ensure your supply can handle peak load:
• rule of thumb: size PSU for ~1.5× expected average draw across all motors

Gotchas
• A NEMA17 at high current can get hot quickly.
• If you run multiple modules, power distribution and grounding matter a lot.

3.2 Wiring
• TMC2209 needs:
• VMOT + GND (motor power)
• STEP, DIR, EN (from MCU)
• Motor coils A+/A-, B+/B-

Gotchas
• If coil pairs are mixed up, the motor will buzz or move erratically.
• Always disconnect power before re-plugging motor wires (drivers can die instantly).

3.3 Driver configuration
• Set current limit for your motor below the motor’s rated current at first.
• Pick microstepping:
• start at 1/16 (good balance)
• increase if you need smoother/quiet motion

Gotchas
• Higher microstepping ≠ more accuracy if your mechanics are sloppy; it mostly improves smoothness.

⸻

4. Firmware / control changes

4.1 Step generation

If your old system used ULN2003 coil sequencing, you are switching to Step/Dir.

Minimum you need:
• a step pulse generator
• acceleration control (recommended)
• a homing routine

4.2 Motion profile

Split-flaps benefit from:
• controlled acceleration to prevent slipping/skipping
• a consistent approach direction at final index (reduces backlash effects)

Recommended behaviors:
• always “overshoot then approach” from the same direction (software backlash compensation)
• slow down for the last ~10–30% of a character move

⸻

5. Homing & indexing plan (recommended)

Option A (recommended): Hall sensor + magnet
• One magnet on the drum
• One hall sensor fixed to the chassis
• Home by rotating slowly until the sensor triggers

Why: repeatable, simple, robust.

Option B: Mechanical switch
• Endstop switch triggered by a cam

Option C: Sensorless homing (TMC2209)
• Possible, but requires tuning and mechanical consistency
• More false triggers with light loads and flexible mounts

⸻

6. Bring-up checklist

Phase 1: Bench test (no drum)
• Verify motor coil pairs
• Verify direction
• Verify driver current setting (start low)
• Run 1–2 minutes at moderate speed and check:
• motor temp
• driver temp
• missed steps (audible stalls)

Phase 2: Mechanical integration (with drum)
• Confirm coupling doesn’t slip
• Confirm belt/gear mesh
• Add tensioning adjustment

Phase 3: Indexing calibration
• Find true drum_steps_per_rev
• Determine:
• number of flaps
• steps per flap: drum_steps_per_rev / flap_count
• Validate by commanding 20–50 random characters and checking alignment

⸻

7. Risks & gotchas to watch
   • Backlash: may worsen visible alignment; fix with approach direction + mechanical preload.
   • Over-current: driver/motor overheating; start conservative.
   • Skipping: too aggressive acceleration; reduce accel, increase current slightly, improve belt tension.
   • Mechanical resonance: certain speeds will buzz; change microstepping, speed, or add stiffness.

⸻

8. Next tasks (action list)
   1. Update CAD: NEMA17 mount + tensioning feature
   2. Choose drive interface: coupler vs pulley vs gear
   3. Wire TMC2209 to MCU and confirm STEP/DIR works
   4. Implement homing (hall sensor recommended)
   5. Calibrate steps-per-rev and steps-per-character
   6. Run long test (500+ character changes) and log any drift
