// ============================================
// GEARS - Belt drive system (GT2 pulleys)
// ============================================
// Motor pulley (20T) and drum pulley (40T) for 2:1 ratio

include <BOSL2/std.scad>
include <../modules/constants.scad>
include <../vitamins/gt2_pulley.scad>

// Motor pulley (prints separately, mounts on motor shaft)
// 20T GT2, 5mm bore for NEMA 17 shaft
module motor_pulley_printable() {
    color("blue") {
        difference() {
            // Use vitamin module as base
            gt2_pulley(teeth=motor_pulley_teeth,
                      width=belt_width,
                      bore=nema17_shaft_diameter);

            // Add set screw hole for shaft retention
            // TODO: Add set screw hole (M3 tapped perpendicular to bore)
        }
    }
}

// Drum pulley (integrates with or mounts to drum)
// 40T GT2
module drum_pulley_printable() {
    color("green") {
        difference() {
            // Use vitamin module as base
            gt2_pulley(teeth=drum_pulley_teeth,
                      width=belt_width,
                      bore=10);  // TODO: Define drum shaft diameter in constants

            // Mounting interface to drum
            // TODO: Add mounting holes or integration features
        }
    }
}

// Belt path visualization (for clearance checking)
module belt_path() {
    color("black", alpha=0.3) {
        // TODO: Create belt path visualization using hull() or path_sweep()
        // Connect motor pulley and drum pulley with belt profile
        // This is for visualization only, not printed
    }
}

// Belt drive assembly (for visualization)
module belt_drive_assembly() {
    // Motor pulley at origin
    motor_pulley_printable();

    // Drum pulley at center_distance
    translate([center_distance, 0, 0])
        drum_pulley_printable();

    // Belt path (visualization only)
    %belt_path();
}

// Example/test render
if ($preview) {
    belt_drive_assembly();
}
