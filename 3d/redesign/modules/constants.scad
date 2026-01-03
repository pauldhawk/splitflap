// ============================================
// CONSTANTS - Split-flap Display v2
// ============================================
// All dimensional constants for parametric design
// Using NEMA 17 motor + GT2 belt drive system
material_thickness = 3.0;      // mm (typical 3D print thickness)
// ============================================
// FLAP DIMENSIONS (from current design)
// ============================================
flap_width = 50;              // mm (left-right dimension of flap card)
flap_height = 70;             // mm (vertical dimension of flap card)
flap_thickness = 0.3;         // mm (cardstock with sticker)
// flap_gap = 1.0;               // mm (gap between flaps on drum)
flap_pin_width = 1.4;

flap_hole_radius = (flap_pin_width + 0.8) / 2;
flap_hole_separation = 1.2;  // additional spacing between hole edges
flap_gap = (flap_hole_radius * 2 - flap_pin_width) + flap_hole_separation;
// ============================================
// DRUM
// ============================================
num_flaps = 50;
drum_diameter = 127;          // mm 
flap_pitch_actual = drum_diameter / num_flaps;  // ~7.98mm per flap
drum_width = material_thickness;  // 54mm (flap width + clearance)
drum_inner_diameter = drum_diameter - 50;    // mm (wall thickness for strength)

// Drum spacers (connect left/right drum)
drum_spacer_count = 4;
drum_spacer_diameter = 10;    // mm

// ============================================
// MOTOR (NEMA 17)
// ============================================
nema17_size = 42.3;           // mm (body width)
nema17_length = 40;           // mm (choose: 34/40/48mm based on torque needs)
nema17_shaft_diameter = 5;    // mm (standard)
nema17_shaft_length = 24;     // mm (standard)

// ============================================
// BELT DRIVE (GT2, 2:1 ratio)
// ============================================
belt_type = "GT2";
belt_width = 6;               // mm (GT2-6mm is common)
belt_pitch = 2;               // mm (GT2 = 2mm tooth pitch)

motor_pulley_teeth = 20;      // 20T pulley on motor shaft
drum_pulley_teeth = 40;       // 40T pulley on drum (2:1 ratio)
gear_ratio = 2;               // drum_pulley_teeth / motor_pulley_teeth

// Pulley dimensions (calculated)
motor_pulley_diameter = (motor_pulley_teeth * belt_pitch) / PI;  // ~12.7mm
drum_pulley_diameter = (drum_pulley_teeth * belt_pitch) / PI;    // ~25.5mm

// Belt path
center_distance = 105;        // mm (motor center to drum center)
belt_length = 280;            // mm (GT2 standard length)

// ============================================
// UNIT DIMENSIONS
// ============================================
unit_width = 65;              // mm (left-right, for connecting units)
unit_height = 100;            // mm (vertical)
unit_depth = 120;             // mm (front-back, 2x current for belt clearance)

wall_thickness = 2.5;         // mm (3D print walls)

// ============================================
// FASTENERS (M3 heat-set inserts primary)
// ============================================
// M3 heat-set inserts (M3x5x4mm standard)
insert_outer_dia = 4.0;       // mm (insert body)
insert_length = 4.0;          // mm
insert_hole_dia = 4.2;        // mm (print hole slightly larger)
insert_hole_depth = 4.5;      // mm (slightly deeper than insert)

// M3 screws
screw_dia = 3.0;              // mm
screw_clearance_dia = 3.2;    // mm (clearance holes)
screw_head_dia = 5.5;         // mm (socket cap)
screw_head_height = 3.0;      // mm

// Standard screw lengths to stock
screw_length_short = 10;      // mm (most joints)
screw_length_medium = 16;     // mm (through 2 parts)
screw_length_long = 20;       // mm (through 3+ parts)

// M4 structural connections (unit-to-unit flanges)
m4_screw_dia = 4.0;           // mm
m4_clearance_dia = 4.3;       // mm
m4_head_dia = 7.0;            // mm

// ============================================
// SENSORS (hall effect, keeping from current)
// ============================================
hall_sensor_width = 3.0;      // mm (sensor PCB from current design)
hall_sensor_height = 1.5;     // mm
magnet_diameter = 6;          // mm (neodymium disc magnet)
magnet_thickness = 2;         // mm

// ============================================
// CONNECTORS (for unit-to-unit attachment)
// ============================================
flange_width = 8;             // mm (extending from unit edges)
flange_thickness = 2.5;       // mm (overlap thickness)
flange_bolt_count_side = 3;   // bolts per side edge (left/right)
flange_bolt_count_vertical = 2; // bolts per top/bottom edge
