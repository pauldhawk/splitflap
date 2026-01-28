use <lib/hardware.scad>;
module motor_mount() {
    // Parameters
    motor_length = 40; // Length of the motor
    motor_diameter = 42; // Diameter of the motor
    mount_thickness = 5; // Thickness of the mount
    hole_diameter = 3; // Diameter of mounting holes
    hole_offset = 30; // Distance between mounting holes

    // Motor body
    difference() {
        cylinder(h = motor_length, d = motor_diameter, center = true);
        // Mounting holes
        for (angle = [0, 90, 180, 270]) {
            rotate([0, 0, angle]) {
                translate([hole_offset / 2, 0, 0]) {
                    cylinder(h = mount_thickness + 1, d = hole_diameter, center = true);
                }
            }
        }
    }

    // Mount base
    translate([0, 0, -motor_length / 2 - mount_thickness / 2]) {
        cylinder(h = mount_thickness, d1 = motor_diameter + 20, d2 = motor_diameter + 20, center = true);
    }
}

motor_mount();