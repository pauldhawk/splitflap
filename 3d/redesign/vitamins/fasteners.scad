// ============================================
// Fasteners - Heat-set inserts, screws, bolts
// ============================================
// Models of fasteners for assembly visualization and clearance

include <BOSL2/std.scad>
include <BOSL2/screws.scad>
include <../modules/constants.scad>

// Heat-set insert (M3x5x4mm standard)
module heat_set_insert_m3() {
    color("brass")
        cyl(d=insert_outer_dia,
            h=insert_length,
            anchor=CENTER);
}

// M3 socket cap screw
// Parameters:
//   length - screw length below head (default 10mm)
module m3_screw(length=screw_length_short) {
    color("silver") {
        // Head
        cyl(d=screw_head_dia,
            h=screw_head_height,
            anchor=TOP);

        // Shaft
        down(screw_head_height)
            cyl(d=screw_dia,
                h=length,
                anchor=TOP);
    }
}

// M4 socket cap screw (for unit-to-unit connections)
// Parameters:
//   length - screw length below head (default 16mm)
module m4_screw(length=16) {
    color("silver") {
        // Head
        cyl(d=m4_head_dia,
            h=4,
            anchor=TOP);

        // Shaft
        down(4)
            cyl(d=m4_screw_dia,
                h=length,
                anchor=TOP);
    }
}

// M3 hex nut
module m3_nut() {
    color("silver")
        linear_extrude(2.4)
            hexagon(id=5.5);  // M3 nut is 5.5mm across flats
}

// Example/test render
if ($preview) {
    heat_set_insert_m3();
    right(10) m3_screw(length=10);
    right(20) m4_screw(length=16);
    right(30) m3_nut();
}
