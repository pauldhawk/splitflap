// ============================================
// MOTOR MOUNT - NEMA 17 mounting bracket
// ============================================
// Holds stepper motor, mounts to case back

include <BOSL2/std.scad>
include <../modules/constants.scad>
// include <../vitamins/nema17.scad>
include <../vitamins/fasteners.scad>

// Motor mount plate
module motor_mount() {
    color("orange") {
        difference() {
            // Base plate
            // TODO: Define plate dimensions based on case and motor position
            cuboid([nema17_size + 10,
                    nema17_size + 10,
                    wall_thickness],
                   anchor=CENTER);

            // Motor mounting holes (4x M3, 31mm spacing on diagonal)
            // NEMA 17 standard: 31mm between holes on diagonal
            motor_hole_spacing = 31;
            for (x = [-1, 1], y = [-1, 1]) {
                translate([x * motor_hole_spacing/2,
                          y * motor_hole_spacing/2,
                          0])
                    cyl(d=screw_clearance_dia,
                        h=wall_thickness + 1,
                        anchor=CENTER);
            }

            // Central clearance for motor boss
            cyl(d=24, h=wall_thickness + 1, anchor=CENTER);

            // TODO: Add mounting holes for attaching to case
        }
    }
}

// Motor mount assembly (with motor shown for reference)
module motor_mount_assembly() {
    motor_mount();

    // Show motor position
    %back(nema17_length/2 + wall_thickness/2)
        rotate([90, 0, 0])
            nema17();
}

// Example/test render
if ($preview) {
    motor_mount_assembly();
}
