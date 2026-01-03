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
  for (i = [0:drum_spacer_count - 1]) {
    angle = i * 360 / drum_spacer_count;
    rotate([0, 0, angle])
      translate([drum_diameter / 2 - 10, 0, 0])
        rotate([0, 0, 0])
          drum_spacer();
  }
}

module spoked_wheel(

) {
  wheel_r=40;       // overall radius
  th=6;               // thickness
  hub_hole_d=10;      // center hole diameter

  // Rim hole pattern
  rim_hole_n=48;
  rim_hole_d=2.2;
  rim_hole_r=36;     // radius where the small holes sit (near the edge)

  // Spokes & windows
  spoke_w=30;         // width of each spoke arm (the solid cross thickness)
  win_inner_r=14;
  win_outer_r=29;

  // Optional 4 bolt holes on the cross
  bolt_hole_n=4;
  bolt_hole_d=4;
  bolt_hole_r=22;
  difference() {
    // 1) Solid disk
    cyl(r=wheel_r, h=th, anchor=CENTER);

    // 2) Center hub hole
    cyl(d=hub_hole_d, h=th+1, anchor=CENTER);

    // 3) Big quadrant windows (between spokes)
    // Make an annulus, then intersect it with a quadrant mask, repeat 4x rotated.
    zrot_copies(n=4) {
      rotate([0,0,45])  // windows sit between the + spokes
      intersection() {
        // annulus region to remove
        difference() {
          cyl(r=win_outer_r, h=th+2, anchor=CENTER);
          cyl(r=win_inner_r, h=th+3, anchor=CENTER);
        }
        // quadrant mask (a big square in +X,+Y)
        right(win_outer_r/2)
          back(win_outer_r/2)
            cuboid([win_outer_r, win_outer_r, th+4], anchor=CENTER);
      }
      }
    }

    // 4) Carve the cross "gap" control:
    // If you want *exactly* a plus-shaped spoke, don't cut here.
    // If your windows are too round/too big, adjust win_inner_r/win_outer_r/spoke_w.
    //
    // This extra cut "trims" windows so spokes remain thick and crisp:
    // zrot_copies(n=2) { // X and Y axes
    //   cuboid([2*wheel_r+2, 2*wheel_r+2, th+4], anchor=CENTER); // placeholder
    // }

    // (Instead of the placeholder above, we do a real trim:)
    // Cut everything EXCEPT a + spoke shape by removing four big rectangles,
    // leaving a plus. Easier: subtract two thin rectangles? We want keep spokes,
    // so we remove the corners outside the spokes by cutting 4 corner blocks.
    for (a=[45,135,225,315]) {
      rotate([0,0,a])
        right(wheel_r/2)
        cuboid([wheel_r - 5, wheel_r-spoke_w, th+4], anchor=CENTER);
        //   cuboid([wheel_r, wheel_r-spoke_w, th+4], anchor=CENTER);
    }

//   }
}
// Example/test render
if ($preview) {
spoked_wheel();
}
