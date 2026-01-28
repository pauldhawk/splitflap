/*
   NEMA 17 Assembly Visualization

   This file shows how the NEMA 17 motor, coupling hub, and spool
   all fit together in the splitflap module.

   Use this to visualize the complete assembly before building.
*/

use <nema17.scad>
use <nema17_coupling_hub.scad>
use <spool.scad>

// Import parameters from main splitflap file
include <flap_dimensions.scad>
include <global_constants.scad>

// ===== ASSEMBLY PARAMETERS =====

num_flaps = 52;                    // Number of flaps
flap_hole_radius = 1.6;            // Flap pin hole radius
flap_hole_separation = 1.2;        // Spacing between flap holes
flap_spool_outset = 0.8;           // Spool outer rim
thickness = 3.0;                   // Laser-cut material thickness

// Visualization options
show_motor = true;
show_hub = true;
show_spool = true;
show_exploded = false;             // Exploded view for assembly instructions
explode_distance = 20;             // Distance for exploded view

// Colors
spool_color = [0.15, 0.15, 0.15];  // Dark gray (MDF/acrylic)
hub_color = [1.0, 0.8, 0.0];       // Yellow (3D printed PLA)

// ===== ASSEMBLY =====

module nema17_splitflap_assembly() {
    // Calculate spool dimensions
    pitch_radius = flap_spool_pitch_radius(num_flaps, flap_hole_radius, flap_hole_separation);
    outer_radius = flap_spool_outer_radius(num_flaps, flap_hole_radius, flap_hole_separation, flap_spool_outset);

    echo("Spool pitch radius:", pitch_radius);
    echo("Spool outer radius:", outer_radius);

    // NEMA 17 Motor
    if (show_motor) {
        translate([0, 0, show_exploded ? -explode_distance : 0]) {
            nema17_motor();
        }
    }

    // Coupling Hub
    if (show_hub) {
        translate([0, 0, nema17_shaft_length()]) {
            color(hub_color) {
                coupling_hub();
            }
        }
    }

    // Spool (two disks)
    if (show_spool) {
        hub_height = 12;  // From coupling hub
        spool_offset = nema17_shaft_length() + hub_height;

        // Motor-side spool (with hub mounting)
        translate([0, 0, spool_offset + (show_exploded ? explode_distance : 0)]) {
            rotate([0, 0, 0]) {
                color(spool_color) {
                    // Main spool disk
                    flap_spool(num_flaps, flap_hole_radius, flap_hole_separation, flap_spool_outset, thickness);

                    // Home indicator notch
                    translate([0, 0, 0]) {
                        flap_spool_home_indicator(num_flaps, flap_hole_radius, flap_hole_separation, flap_spool_outset, thickness);
                    }

                    // Hub mounting holes (4× M3)
                    translate([0, 0, -0.5]) {
                        for (i = [0 : 3]) {
                            rotate([0, 0, i * 90 + 45]) {
                                translate([8, 0, 0]) {
                                    cylinder(d=3.2, h=thickness + 1, $fn=20);
                                }
                            }
                        }
                    }
                }
            }
        }

        // Opposite spool (standard, no hub)
        spool_width = 40;  // Approximate distance between spools
        translate([0, 0, spool_offset + spool_width + (show_exploded ? explode_distance*2 : 0)]) {
            rotate([0, 0, 0]) {
                color(spool_color) {
                    flap_spool(num_flaps, flap_hole_radius, flap_hole_separation, flap_spool_outset, thickness);
                }
            }
        }
    }
}

// ===== CROSS-SECTION VIEW =====

module assembly_cross_section() {
    difference() {
        nema17_splitflap_assembly();

        // Cut away half to show internal details
        translate([-100, 0, -100]) {
            cube([200, 100, 300]);
        }
    }
}

// ===== DIMENSION ANNOTATIONS =====

module dimension_line(length, label, height=0) {
    color("red") {
        // Line
        translate([0, 0, height]) {
            cube([length, 0.5, 0.5], center=true);
        }

        // End marks
        for (x = [-length/2, length/2]) {
            translate([x, 0, height]) {
                cube([0.5, 3, 0.5], center=true);
            }
        }

        // Label (as text would require text module)
        translate([0, 5, height]) {
            cube([1, 1, 1], center=true);  // Placeholder
        }
    }
}

module assembly_with_dimensions() {
    nema17_splitflap_assembly();

    // Show key dimensions
    translate([0, nema17_body_width()/2 + 10, 0]) {
        dimension_line(nema17_shaft_length(), "Shaft: 24mm", 0);
        dimension_line(12, "Hub: 12mm", nema17_shaft_length());
    }
}

// ===== RENDER OPTIONS =====

// Change this to see different views:
view_mode = "normal";  // Options: "normal", "exploded", "cross_section", "dimensions"

if (view_mode == "normal") {
    nema17_splitflap_assembly();
} else if (view_mode == "exploded") {
    show_exploded = true;
    nema17_splitflap_assembly();
} else if (view_mode == "cross_section") {
    assembly_cross_section();
} else if (view_mode == "dimensions") {
    assembly_with_dimensions();
}

// ===== NOTES =====

/*
ASSEMBLY ORDER:
1. Mount NEMA 17 motor to motor mount plate
2. Press coupling hub onto motor shaft
3. Tighten 2× M3 grub screws on hub
4. Bolt motor-side spool to hub (4× M3 bolts)
5. Install opposite spool
6. Insert flaps
7. Test rotation

KEY MEASUREMENTS:
- Motor shaft: 24mm long, 5mm D-shaft
- Coupling hub: 12mm tall, 20mm diameter
- Spool thickness: 3mm (laser-cut)
- Total stack height: 24mm (shaft) + 12mm (hub) + 3mm (spool) = 39mm

CRITICAL ALIGNMENT:
- Hub grub screws MUST align with shaft flats
- Spool must be perpendicular to shaft (use hub as reference)
- Both spools must be parallel (flaps will bind otherwise)
*/
