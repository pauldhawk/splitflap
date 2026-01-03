// ============================================
// DRUM - Flap holder assembly
// ============================================
// Left drum (with pulley), right drum (with magnet), spacers

include <BOSL2/std.scad>
include <../modules/constants.scad>
include <../vitamins/sensors.scad>
include <../vitamins/gt2_pulley.scad>

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

// Left drum (connects to belt pulley)
module drum_left() {
    color("lightblue") {
        difference() {
            // Main drum body
            cyl(d=drum_diameter,
                h=drum_width,
                anchor=CENTER);

            // Hollow interior
            cyl(d=drum_inner_diameter,
                h=drum_width + 1,
                anchor=CENTER);

            // Flap slots (50 positions around circumference, 3mm from outer edge)
            drum_flap_slots();

            // TODO: Add spoke/shaft connection points
            // TODO: Add spacer mounting holes
        }

        // Pulley mounting interface
        // TODO: Design pulley mount (could be integrated or separate)
    }
}

// Right drum (with magnet for hall sensor)
module drum_right() {
    color("lightblue") {
        difference() {
            // Main drum body (mirror of left)
            cyl(d=drum_diameter,
                h=drum_width,
                anchor=CENTER);

            // Hollow interior
            cyl(d=drum_inner_diameter,
                h=drum_width + 1,
                anchor=CENTER);

            // Flap slots (50 positions around circumference, 3mm from outer edge)
            drum_flap_slots();

            // TODO: Add spoke/shaft connection points
            // TODO: Add spacer mounting holes
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
                h=drum_width - 10,  // TODO: Calculate proper length
                anchor=CENTER);

            // Heat-set insert holes at both ends
            // TODO: Add insert holes
        }
    }
}

// Full drum assembly
module drum_assembly() {
    // Left drum with pulley
    left(drum_width/2 + 5)
        drum_left();

    // Right drum with magnet
    right(drum_width/2 + 5)
        drum_right();

    // Spacers (4 positions around drum)
    for (i = [0:drum_spacer_count-1]) {
        angle = i * 360 / drum_spacer_count;
        rotate([0, 0, angle])
            translate([drum_inner_diameter/2, 0, 0])
                rotate([0, 90, 0])
                    drum_spacer();
    }
}

// Example/test render
if ($preview) {
    drum_assembly();
}
