// ============================================
// NEMA 17 Stepper Motor
// ============================================
// 3D model of NEMA 17 stepper motor for clearance checking
// Built with BOSL2 primitives for fast rendering

include <BOSL2/std.scad>
include <../modules/constants.scad>

// NEMA 17 motor module
// Parameters:
//   length - motor body length (default from constants)
//   show_shaft - whether to show the shaft (default true)
module nema17(length=nema17_length, show_shaft=true) {
    color("silver") {
        // Motor body (42.3mm square)
        cuboid([nema17_size, nema17_size, length],
               rounding=2,
               edges=[FRONT+LEFT, FRONT+RIGHT, BACK+LEFT, BACK+RIGHT],
               anchor=BOTTOM);

        // Center boss (22mm diameter, 2mm tall)
        up(length)
            cyl(d=22, h=2, anchor=BOTTOM);

        // Mounting holes (4x M3, 31mm spacing on diagonal)
        // TODO: Add mounting hole positions for reference

        if (show_shaft) {
            // Shaft (5mm diameter, 24mm long)
            up(length)
                cyl(d=nema17_shaft_diameter,
                    h=nema17_shaft_length,
                    anchor=BOTTOM);
        }
    }
}

// Example/test render
if ($preview) {
    nema17();
}
