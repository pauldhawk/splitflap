/*
   Coupling Hub for NEMA 17 to Spool Connection

   This hub connects the NEMA 17 motor shaft (5mm D-shaft) to the
   laser-cut spool. It's designed to be 3D printed in PLA or PETG.

   Features:
   - 5mm D-shaft center hole (matches NEMA 17 shaft)
   - 2x M3 grub screws on flats for secure clamping
   - 4x M3 mounting holes to bolt to spool
   - Designed to print without supports
*/

// ===== PARAMETERS =====

// Hub dimensions
hub_outer_diameter = 20;      // Outer diameter of hub
hub_height = 12;               // Total height of hub
hub_center_rim_dia = 8;       // Raised center rim around shaft

// Motor shaft (NEMA 17: 5mm D-shaft)
motor_shaft_diameter = 5.0;   // Motor shaft diameter
motor_shaft_flat_depth = 0.5; // Depth of D-flat on shaft
shaft_hole_clearance = 0.1;   // Clearance for shaft fit (tight fit)

// Grub screws (M3 set screws)
grub_screw_diameter = 3.0;    // M3 grub screw
grub_screw_hole_dia = 3.2;    // Clearance for M3 screw
grub_screw_depth = 8;         // How deep grub screw goes
grub_screw_position = 6;      // Height from bottom for grub screw
grub_screw_angle_offset = 0;  // Angle offset (0 = on flats)

// Mounting holes (to attach to spool)
mounting_hole_diameter = 3.2;  // M3 clearance hole
mounting_hole_count = 4;       // 4 holes for symmetry
mounting_hole_circle_dia = 16; // Diameter of hole circle
mounting_hole_countersink = false; // Countersink holes?
countersink_diameter = 6;      // Countersink diameter
countersink_depth = 2;         // Countersink depth

// Print settings
layer_height = 0.2;            // For chamfer calculations
$fn = 60;                      // Circle resolution

// ===== HELPER MODULES =====

// 5mm D-shaft profile (matches NEMA 17)
// This is the hole that the motor shaft fits into
module motor_shaft_profile_2d() {
    shaft_radius = motor_shaft_diameter / 2 - shaft_hole_clearance;
    flat_distance = shaft_radius - motor_shaft_flat_depth;

    difference() {
        // Main circular hole
        circle(r=shaft_radius);

        // Cut flats on two sides (D-shaft profile)
        // Flats are 180° apart for D-shaft
        for (angle = [0, 180]) {
            rotate([0, 0, angle]) {
                translate([flat_distance, 0, 0]) {
                    square([shaft_radius, shaft_radius * 3], center=true);
                }
            }
        }
    }
}

// Grub screw hole (positioned to bite into flat)
module grub_screw_hole() {
    rotate([0, 90, 0]) {
        cylinder(d=grub_screw_hole_dia, h=grub_screw_depth, $fn=20);
    }
}

// Mounting hole with optional countersink
module mounting_hole() {
    translate([0, 0, -0.01]) {
        cylinder(d=mounting_hole_diameter, h=hub_height + 0.02, $fn=30);

        if (mounting_hole_countersink) {
            translate([0, 0, hub_height - countersink_depth]) {
                cylinder(d1=mounting_hole_diameter,
                        d2=countersink_diameter,
                        h=countersink_depth + 0.01,
                        $fn=30);
            }
        }
    }
}

// ===== MAIN HUB =====

module coupling_hub() {
    difference() {
        // Solid hub body
        union() {
            // Main hub cylinder
            cylinder(d=hub_outer_diameter, h=hub_height);

            // Raised center rim (for extra strength around shaft)
            translate([0, 0, 0]) {
                cylinder(d=hub_center_rim_dia, h=hub_height);
            }

            // Bottom chamfer (makes it easier to print, looks nice)
            translate([0, 0, 0]) {
                cylinder(d1=hub_outer_diameter + 1, d2=hub_outer_diameter, h=0.5);
            }
        }

        // Cut out center shaft hole (5mm D-shaft)
        translate([0, 0, -0.01]) {
            linear_extrude(height=hub_height + 0.02) {
                motor_shaft_profile_2d();
            }
        }

        // Grub screw holes (2 screws, 180° apart, on the flats)
        for (i = [0, 1]) {
            rotate([0, 0, i * 180 + grub_screw_angle_offset]) {
                translate([0, 0, grub_screw_position]) {
                    grub_screw_hole();
                }
            }
        }

        // Mounting holes to spool (4 holes, evenly spaced)
        for (i = [0 : mounting_hole_count - 1]) {
            rotate([0, 0, i * 360 / mounting_hole_count + 45]) {
                translate([mounting_hole_circle_dia / 2, 0, 0]) {
                    mounting_hole();
                }
            }
        }
    }
}

// ===== VISUALIZATION HELPERS =====

// Show motor shaft for reference
module show_motor_shaft() {
    color("silver", 0.5) {
        translate([0, 0, -30]) {
            difference() {
                cylinder(d=motor_shaft_diameter, h=50, $fn=40);

                // Cut flats (same as hole, but actual shaft)
                for (angle = [0, 180]) {
                    rotate([0, 0, angle]) {
                        translate([motor_shaft_diameter/2 - motor_shaft_flat_depth, 0, -1]) {
                            cube([motor_shaft_diameter, motor_shaft_diameter, 52]);
                        }
                    }
                }
            }
        }
    }
}

// Show grub screws for reference
module show_grub_screws() {
    color("gray", 0.7) {
        for (i = [0, 1]) {
            rotate([0, 0, i * 180 + grub_screw_angle_offset]) {
                translate([hub_outer_diameter/2, 0, grub_screw_position]) {
                    rotate([0, 90, 0]) {
                        cylinder(d=3, h=6, $fn=20);
                    }
                }
            }
        }
    }
}

// Show mounting bolts for reference
module show_mounting_bolts() {
    color("gray", 0.7) {
        for (i = [0 : mounting_hole_count - 1]) {
            rotate([0, 0, i * 360 / mounting_hole_count + 45]) {
                translate([mounting_hole_circle_dia / 2, 0, -5]) {
                    cylinder(d=3, h=hub_height + 10, $fn=20);
                }
            }
        }
    }
}

// ===== RENDER OPTIONS =====

// Render mode
show_motor_shaft_reference = true;   // Show motor shaft for visualization
show_grub_screws_reference = true;   // Show grub screws
show_mounting_bolts_reference = false; // Show mounting bolts
print_orientation = true;             // Orient for 3D printing

// Main render
if (print_orientation) {
    // Print orientation (flat on bed, no supports needed!)
    coupling_hub();
} else {
    // Assembly orientation (for visualization)
    rotate([180, 0, 0]) {
        coupling_hub();

        if (show_motor_shaft_reference) {
            show_motor_shaft();
        }
        if (show_grub_screws_reference) {
            show_grub_screws();
        }
        if (show_mounting_bolts_reference) {
            show_mounting_bolts();
        }
    }
}

// ===== NOTES FOR PRINTING =====

/*
PRINT SETTINGS:
- Material: PLA or PETG (PETG stronger)
- Layer height: 0.2mm
- Infill: 100% (this part needs to be SOLID)
- Perimeters: 4+
- No supports needed!
- Print orientation: Flat on bed (top of hub facing up)

ASSEMBLY:
1. Press hub onto motor shaft (should be snug but not impossible)
2. Rotate hub so grub screws align with flats
3. Tighten both M3 grub screws (alternate tightening)
4. Use 4× M3 bolts (10mm length) to attach hub to spool
5. Apply threadlocker to grub screws (recommended)

TESTING:
- Hub should NOT slip on shaft even with high torque
- If it slips, tighten grub screws more or reduce shaft_hole_clearance
- If hub won't fit on shaft, increase shaft_hole_clearance by 0.05mm

TROUBLESHOOTING:
- Won't fit on shaft: Increase shaft_hole_clearance
- Slips on shaft: Decrease shaft_hole_clearance or add roughness to shaft
- Grub screws strip: Pre-tap M3 threads, use steel grub screws
*/
