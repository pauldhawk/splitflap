// ============================================
// DRUM - Flap holder assembly
// ============================================
// Modular 3D-printed drum design (Option 5 approach)
//
// DESIGN APPROACH:
// - Two drum sides (left/right) print flat for best quality
// - Connected by 4 spacer posts with M3 heat-set inserts
// - 40mm spacing between drums (drum_spacer_height)
// - 50 flap holes around circumference
// - Radial spoke design for strength and reduced print time
//
// ASSEMBLY:
// 1. Print left drum, right drum, and 4 spacers separately
// 2. Install M3 heat-set inserts in spacer ends (8 total inserts)
// 3. Attach spacers to one drum side with M3x10 screws
// 4. Attach second drum side to complete assembly
// 5. Mount pulley to left drum hub

include <BOSL2/std.scad>
include <../modules/constants.scad>
// include <../vitamins/sensors.scad>
// include <../vitamins/gt2_pulley.scad>

// Flap slots (reusable for both drums)
// Creates holes around circumference for flap pins
module drum_flap_slots() {
  for (i = [0:num_flaps - 1]) {
    angle = i * 360 / num_flaps;
    rotate([0, 0, angle])
      translate([drum_diameter / 2 - 3, 0, 0])
        cyl(
          r=flap_hole_radius,
          h=drum_width + 1,
          anchor=CENTER
        );
  }
}

// Spoke/shaft connection (reusable for both drums)
// Radial spokes connecting drum to central shaft
module drum_spokes() {
  shaft_diameter = 8; // 8mm shaft (for bearing or M8 bolt)
  num_spokes = 6; // 6 radial spokes
  spoke_width = 4; // 4mm wide spokes
  spoke_thickness = 3; // 3mm thick (less than drum_width for clearance)

  difference() {
    union() {
      // Radial spokes from center to inner wall
      for (i = [0:num_spokes - 1]) {
        angle = i * 360 / num_spokes;
        rotate([0, 0, angle])
          cuboid(
            [drum_inner_diameter / 2, spoke_width, spoke_thickness]
          );
      }

      // Central hub (reinforcement around shaft)
      cyl(
        d=shaft_diameter + 6,
        h=spoke_thickness,
        anchor=CENTER
      );
    }

    // Central shaft hole
    cyl(
      d=shaft_diameter,
      h=spoke_thickness + 1,
      anchor=CENTER
    );
  }
}

// Spacer mounting holes (reusable for both drums)
// Clearance holes for M3 screws to attach spacers
module drum_spacer_holes() {
  for (i = [0:drum_spacer_count - 1]) {
    angle = i * 360 / drum_spacer_count;
    rotate([0, 0, angle])
      translate([drum_inner_diameter / 1.75, 0, 0])
        rotate([0, 0, 0])
          cyl(
            d=screw_clearance_dia,
            h=20, // Deep enough to go through drum wall
            anchor=CENTER
          );
  }
}

// Left drum (connects to belt pulley)
module drum_left() {
  color("lightblue") {
    difference() {
      union() {
        // Main drum body
        cyl(
          d=drum_diameter,
          h=drum_width,
          anchor=CENTER
        );

        // Spoke/shaft connection
        drum_spokes();
      }

      // Hollow interior
      cyl(
        d=drum_inner_diameter,
        h=drum_width + 1,
        anchor=CENTER
      );

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
        cyl(
          d=drum_diameter,
          h=drum_width,
          anchor=CENTER
        );

        // Spoke/shaft connection
        drum_spokes();
      }

      // Hollow interior
      cyl(
        d=drum_inner_diameter,
        h=drum_width + 1,
        anchor=CENTER
      );

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
      cyl(
        d=drum_spacer_diameter,
        h=drum_spacer_height,
        anchor=CENTER
      );

      // Heat-set insert holes at both ends
      // Top insert (for screw from left drum)
      translate([0, 0, drum_spacer_height/2 - insert_hole_depth/2])
        cyl(
          d=insert_hole_dia,
          h=insert_hole_depth,
          anchor=CENTER
        );

      // Bottom insert (for screw from right drum)
      translate([0, 0, -drum_spacer_height/2 + insert_hole_depth/2])
        cyl(
          d=insert_hole_dia,
          h=insert_hole_depth,
          anchor=CENTER
        );

      // Through hole for screw (smaller than insert diameter)
      cyl(
        d=screw_clearance_dia,
        h=drum_spacer_height + 1,
        anchor=CENTER
      );
    }
  }
}

// Full drum assembly
// Left and right drums connected by spacers with heat-set inserts
module drum_assembly() {
  drum_z = drum_spacer_height / 2;
  spacer_radius = drum_inner_diameter / 1.75; // Match drum_spacer_holes() position

  // Left drum with pulley (top)
  translate([0, 0, drum_z])
    drum_left();

  // Right drum with magnet (bottom)
  translate([0, 0, -drum_z])
    drum_right();

  // Spacers (positioned to align with screw holes in drums)
  for (i = [0:drum_spacer_count - 1]) {
    angle = i * 360 / drum_spacer_count;
    rotate([0, 0, angle])
      translate([spacer_radius, 0, 0])
        drum_spacer();
  }
}

// ============================================
// PREVIEW / TEST RENDER
// ============================================
// Uncomment the module you want to preview:

// Full assembly (default)
drum_assembly();

// Individual parts for printing:
// drum_left();
// drum_right();
// drum_spacer();
