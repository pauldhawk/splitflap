// ============================================
// Sensors - Hall effect sensor and magnet
// ============================================
// Models for hall effect sensor PCB and calibration magnet

include <BOSL2/std.scad>
include <../modules/constants.scad>

// Hall effect sensor PCB
// (Keeping same sensor from current design)
module hall_sensor() {
    color("green")
        cuboid([hall_sensor_width,
                hall_sensor_width,
                hall_sensor_height],
               anchor=CENTER);
}

// Neodymium disc magnet for calibration
module calibration_magnet() {
    color("silver")
        cyl(d=magnet_diameter,
            h=magnet_thickness,
            anchor=CENTER);
}

// Example/test render
if ($preview) {
    hall_sensor();
    right(15) calibration_magnet();
}
