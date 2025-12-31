/*
   NEMA 17 Stepper Motor Model

   Model of NEMA 17 stepper motor (17HS19-2004S1 from STEPPERONLINE)
   for visualization in assemblies.

   Origin is centered on the shaft, on the front face of the motor,
   with the shaft in the +z direction (same convention as 28byj-48.scad)
*/

// ===== NEMA 17 DIMENSIONS (17HS19-2004S1) =====

// Body dimensions
nema17_body_width = 42.3;           // 42mm + tolerance
nema17_body_depth = 48;             // Motor body depth
nema17_body_corner_radius = 3;      // Rounded corners

// Front face raised section
nema17_front_face_diameter = 22;    // Raised circular section
nema17_front_face_height = 2;       // Height of raised section

// Shaft dimensions
nema17_shaft_diameter = 5.0;        // 5mm diameter
nema17_shaft_length = 24;           // Shaft length from front face
nema17_shaft_flat_width = 4.5;      // Width of flat (D-shaft)
nema17_shaft_flat_depth = 0.5;      // Depth of flat cut

// Mounting holes (M3)
nema17_mount_hole_diameter = 3.0;   // M3 hole
nema17_mount_hole_spacing = 31;     // 31mm between holes
nema17_mount_hole_depth = 4.5;      // Depth of mounting holes

// Rear shaft (optional, some motors have it)
nema17_rear_shaft_diameter = 5.0;   // Rear shaft diameter
nema17_rear_shaft_length = 15;      // Rear shaft length

// Wire connector
nema17_connector_width = 14;
nema17_connector_depth = 10;
nema17_connector_height = 12;

// Export functions for use in other files
function nema17_body_width() = nema17_body_width;
function nema17_body_depth() = nema17_body_depth;
function nema17_shaft_diameter() = nema17_shaft_diameter;
function nema17_shaft_length() = nema17_shaft_length;
function nema17_mount_hole_spacing() = nema17_mount_hole_spacing;

// ===== MOTOR MODEL =====

module nema17_motor() {
    $fn = 60;

    eps = 0.01;

    // Colors
    motor_body_color = [0.2, 0.2, 0.2];      // Dark gray
    shaft_color = [0.8, 0.8, 0.85];          // Steel
    connector_color = [0.1, 0.1, 0.1];       // Black

    // Main motor body
    module motor_body() {
        color(motor_body_color) {
            translate([0, 0, -nema17_body_depth]) {
                // Main body (rounded square)
                linear_extrude(height=nema17_body_depth) {
                    offset(r=nema17_body_corner_radius) {
                        square([nema17_body_width - nema17_body_corner_radius*2,
                                nema17_body_width - nema17_body_corner_radius*2],
                               center=true);
                    }
                }
            }

            // Front face raised section
            translate([0, 0, -eps]) {
                cylinder(d=nema17_front_face_diameter,
                        h=nema17_front_face_height + eps);
            }
        }
    }

    // Mounting holes
    module mounting_holes() {
        color(motor_body_color) {
            for (x = [-1, 1], y = [-1, 1]) {
                translate([x * nema17_mount_hole_spacing/2,
                          y * nema17_mount_hole_spacing/2,
                          -nema17_mount_hole_depth]) {
                    cylinder(d=nema17_mount_hole_diameter,
                            h=nema17_mount_hole_depth + eps,
                            $fn=20);
                }
            }
        }
    }

    // Shaft (5mm D-shaft)
    module shaft() {
        color(shaft_color) {
            difference() {
                // Main cylindrical shaft
                cylinder(d=nema17_shaft_diameter,
                        h=nema17_shaft_length,
                        $fn=40);

                // Cut flats (D-shaft profile)
                for (side = [-1, 1]) {
                    translate([side * (nema17_shaft_diameter/2 - nema17_shaft_flat_depth),
                              0,
                              -eps]) {
                        cube([nema17_shaft_flat_depth + eps,
                              nema17_shaft_diameter,
                              nema17_shaft_length + eps*2]);
                    }
                }
            }
        }
    }

    // Rear shaft (optional)
    module rear_shaft() {
        color(shaft_color) {
            translate([0, 0, -nema17_body_depth - nema17_rear_shaft_length]) {
                cylinder(d=nema17_rear_shaft_diameter,
                        h=nema17_rear_shaft_length + eps,
                        $fn=40);
            }
        }
    }

    // Wire connector on back
    module wire_connector() {
        color(connector_color) {
            translate([0,
                      -nema17_body_width/2,
                      -nema17_body_depth - nema17_connector_depth]) {
                cube([nema17_connector_width,
                      nema17_connector_depth,
                      nema17_connector_height],
                     center=true);
            }
        }
    }

    // Assemble motor
    motor_body();
    mounting_holes();
    shaft();
    // rear_shaft();  // Uncomment if your motor has rear shaft
    wire_connector();
}

// ===== MOUNTING BRACKET HELPERS =====

// 2D pattern for motor mounting holes (use in difference() for cutting)
module nema17_mount_holes_2d() {
    for (x = [-1, 1], y = [-1, 1]) {
        translate([x * nema17_mount_hole_spacing/2,
                  y * nema17_mount_hole_spacing/2]) {
            circle(d=3.2, $fn=30);  // 3.2mm for M3 clearance
        }
    }
}

// 2D motor body outline (for clearance cutouts)
module nema17_body_outline_2d(clearance=0.5) {
    offset(r=nema17_body_corner_radius + clearance) {
        square([nema17_body_width - nema17_body_corner_radius*2 + clearance*2,
                nema17_body_width - nema17_body_corner_radius*2 + clearance*2],
               center=true);
    }
}

// Example: render the motor
nema17_motor();
