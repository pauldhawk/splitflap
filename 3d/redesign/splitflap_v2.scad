// ============================================
// SPLIT-FLAP DISPLAY v2
// ============================================
// Complete redesign for 3D printing with NEMA 17 motors
//
// Key features:
// - NEMA 17 + TMC2209 driver (replacing 28BYJ-48)
// - GT2 belt drive (2:1 ratio, 20T/40T pulleys)
// - 50 flaps per unit (same size as v1)
// - M3 heat-set inserts for assembly
// - Modular with integrated flanges for grid assembly
//
// Design: 65mm W × 100mm H × 120mm D per unit

include <BOSL2/std.scad>
include <modules/constants.scad>

// Import all parts
include <parts/drum.scad>
include <parts/case.scad>
include <parts/motor_mount.scad>
include <parts/gears.scad>

// Import vitamins for reference
include <vitamins/nema17.scad>
include <vitamins/gt2_pulley.scad>
include <vitamins/fasteners.scad>
include <vitamins/sensors.scad>

// Complete unit assembly
module splitflap_unit() {
    // Case structure
    case_assembly();

    // Drum assembly (centered in unit)
    // TODO: Position drum correctly within case
    drum_assembly();

    // Motor mount and motor (at back)
    // TODO: Position motor at correct location for belt alignment
    back(unit_depth/2 - nema17_length/2 - wall_thickness)
        rotate([90, 0, 0]) {
            motor_mount_assembly();
        }

    // Belt drive (connects motor to drum)
    // TODO: Position pulleys and belt correctly
    // belt_drive_assembly();
}

// Multiple unit example (shows connectivity)
module splitflap_grid(cols=2, rows=2) {
    for (x = [0:cols-1], y = [0:rows-1]) {
        translate([x * unit_width,
                   0,
                   y * unit_height])
            splitflap_unit();
    }
}

// Render modes
render_mode = "single";  // Options: "single", "grid", "exploded"

if (render_mode == "single") {
    splitflap_unit();
} else if (render_mode == "grid") {
    splitflap_grid(cols=3, rows=2);
} else if (render_mode == "exploded") {
    // TODO: Create exploded view for assembly instructions
    splitflap_unit();
}
