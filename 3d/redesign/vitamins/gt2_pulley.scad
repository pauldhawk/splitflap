// ============================================
// GT2 Belt Pulleys
// ============================================
// Parametric GT2 pulley generator using BOSL2
// GT2 = 2mm pitch timing belt

include <BOSL2/std.scad>
include <BOSL2/gears.scad>
include <../modules/constants.scad>

// GT2 Pulley module
// Parameters:
//   teeth - number of teeth (default 20)
//   width - belt width in mm (default from constants)
//   bore - shaft bore diameter (default 5mm for NEMA 17)
module gt2_pulley(teeth=20, width=belt_width, bore=5) {
    pitch_dia = (teeth * belt_pitch) / PI;

    color("gray") {
        difference() {
            union() {
                // Main pulley body with GT2 tooth profile
                // TODO: Implement accurate GT2 tooth profile using BOSL2
                // For now: simple cylinder approximation
                cyl(d=pitch_dia, h=width, anchor=CENTER);

                // Flanges (keep belt on pulley)
                up(width/2 + 0.5)
                    cyl(d=pitch_dia + 2, h=1, anchor=CENTER);
                down(width/2 + 0.5)
                    cyl(d=pitch_dia + 2, h=1, anchor=CENTER);
            }

            // Center bore for shaft
            cyl(d=bore, h=width+2, anchor=CENTER);
        }
    }
}

// Preset pulleys
module motor_pulley() {
    gt2_pulley(teeth=motor_pulley_teeth,
               width=belt_width,
               bore=nema17_shaft_diameter);
}

module drum_pulley() {
    gt2_pulley(teeth=drum_pulley_teeth,
               width=belt_width,
               bore=10);  // TODO: Define drum shaft diameter
}

// Example/test render
if ($preview) {
    motor_pulley();
    right(30) drum_pulley();
}
