// ============================================
// DRUM - Flap holder assembly
// ============================================
// Left drum (with pulley), right drum (with magnet), spacers

include <BOSL2/std.scad>
include <../modules/constants.scad>
// include <../vitamins/sensors.scad>
// include <../vitamins/gt2_pulley.scad>

// Flap slots (reusable for both drums)
// Creates holes around circumference for flap pins
module drum_flap_slots() {
    for (i = [0:num_flaps-1]) {
        angle = i * 360 / num_flaps;
        rotate([0, 0, angle])
            translate([drum_diameter/2 - 3, 0, 0])
                cyl(r=flap_hole_radius,
                    h=drum_width + 1,
                    anchor=CENTER);
    }
}

// Spoke/shaft connection (reusable for both drums)
// Radial spokes connecting drum to central shaft
module drum_spokes() {
    shaft_diameter = 8;        // 8mm shaft (for bearing or M8 bolt)
    num_spokes = 6;            // 6 radial spokes
    spoke_width = 4;           // 4mm wide spokes
    spoke_thickness = 3;       // 3mm thick (less than drum_width for clearance)

    difference() {
        union() {
            // Radial spokes from center to inner wall
            for (i = [0:num_spokes-1]) {
                angle = i * 360 / num_spokes;
                rotate([0, 0, angle])
                    cuboid([drum_inner_diameter/2, spoke_width, spoke_thickness],
                           anchor=LEFT);
            }

            // Central hub (reinforcement around shaft)
            cyl(d=shaft_diameter + 6,
                h=spoke_thickness,
                anchor=CENTER);
        }

        // Central shaft hole
        cyl(d=shaft_diameter,
            h=spoke_thickness + 1,
            anchor=CENTER);
    }
}

// Spacer mounting holes (reusable for both drums)
// Clearance holes for M3 screws to attach spacers
module drum_spacer_holes() {
    for (i = [0:drum_spacer_count-1]) {
        angle = i * 360 / drum_spacer_count;
        rotate([0, 0, angle])
            translate([drum_inner_diameter/1.75, 0, 0])
                rotate([0, 0, 0])
                    cyl(d=screw_clearance_dia,
                        h=20,  // Deep enough to go through drum wall
                        anchor=CENTER);
    }
}

// Left drum (connects to belt pulley)
module drum_left() {
    color("lightblue") {
        difference() {
            union() {
                // Main drum body
                cyl(d=drum_diameter,
                    h=drum_width,
                    anchor=CENTER);

                // Spoke/shaft connection
                drum_spokes();
            }

            // Hollow interior
            cyl(d=drum_inner_diameter,
                h=drum_width + 1,
                anchor=CENTER);

            // Flap slots (50 positions around circumference, 3mm from outer edge)
            drum_flap_slots();

            // Spacer mounting holes (4 positions for M3 screws)
            drum_spacer_holes();
        }

        // Pulley mounting interface
        // TODO: Design pulley mount (could be integrated or separate)
    }
}

// Right drum (with magnet for hall sensor)
module drum_right() {
    color("lightblue") {
        difference() {
            union() {
                // Main drum body (mirror of left)
                cyl(d=drum_diameter,
                    h=drum_width,
                    anchor=CENTER);

                // Spoke/shaft connection
                drum_spokes();
            }

            // Hollow interior
            cyl(d=drum_inner_diameter,
                h=drum_width + 1,
                anchor=CENTER);

            // Flap slots (50 positions around circumference, 3mm from outer edge)
            drum_flap_slots();

            // Spacer mounting holes (4 positions for M3 screws)
            drum_spacer_holes();
        }

        // Magnet mounting position
        // TODO: Add magnet pocket on outer edge
    }
}

// Drum spacer (connects left and right drums)
// Uses heat-set inserts for assembly
module drum_spacer() {
    color("gray") {
        difference() {
            cyl(d=drum_spacer_diameter,
                h=drum_spacer_height,
                anchor=CENTER);

            // Heat-set insert holes at both ends
            // TODO: Add insert holes
        }
    }
}

// Full drum assembly
module drum_assembly() {
    drum_z = drum_spacer_height / 2;
    // Left drum with pulley
    translate([0, 0, drum_z])
        drum_left();

    // Right drum with magnet
    translate([0, 0, -drum_z])
        drum_right();

    // Spacers (4 positions around drum)
    for (i = [0:drum_spacer_count-1]) {
        angle = i * 360 / drum_spacer_count;
        rotate([0, 0, angle])
            translate([drum_diameter/2 - 10, 0, 0])
                rotate([0, 0, 0])
                    drum_spacer();
    }
}

// Example/test render
if ($preview) {
    drum_assembly();
}
