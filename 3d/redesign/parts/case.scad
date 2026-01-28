// ============================================
// CASE - Enclosure for split-flap unit
// ============================================
// Bottom, left, right, back, front-top sections
// Includes flanges for unit-to-unit connections

include <BOSL2/std.scad>
include <../modules/constants.scad>
include <../vitamins/fasteners.scad>

// Bottom case - connects left and right, mounts motor
module case_bottom() {
    color("tan") {
        difference() {
            // Base plate
            cuboid([unit_width, unit_depth, wall_thickness],
                   anchor=CENTER);

            // TODO: Add mounting holes for motor mount
            // TODO: Add mounting holes for left/right case sides
            // TODO: Add holes for heat-set inserts
        }

        // Flanges for unit-to-unit connection (left/right edges)
        // TODO: Add flanges with M4 bolt holes
    }
}

// Left case - connects to drum, has belt
module case_left() {
    color("tan") {
        difference() {
            // Side wall
            cuboid([wall_thickness, unit_depth, unit_height],
                   anchor=CENTER);

            // Drum shaft/spoke hole
            // TODO: Add hole for drum shaft bearing/connection

            // Belt clearance slot
            // TODO: Add slot for belt to pass through
        }

        // Mounting tabs for bottom attachment
        // TODO: Add mounting features

        // Flanges for unit-to-unit connection (top/bottom edges)
        // TODO: Add flanges with M4 bolt holes
    }
}

// Right case - connects to drum, has hall sensor
module case_right() {
    color("tan") {
        difference() {
            // Side wall (mirror of left)
            cuboid([wall_thickness, unit_depth, unit_height],
                   anchor=CENTER);

            // Drum shaft/spoke hole
            // TODO: Add hole for drum shaft bearing/connection

            // Hall sensor mounting
            // TODO: Add pocket/mounting for hall sensor PCB
        }

        // Mounting tabs for bottom attachment
        // TODO: Add mounting features

        // Flanges for unit-to-unit connection (top/bottom edges)
        // TODO: Add flanges with M4 bolt holes
    }
}

// Back case - structural support, wire management
module case_back() {
    color("tan") {
        difference() {
            // Back wall
            cuboid([unit_width, wall_thickness, unit_height],
                   anchor=CENTER);

            // TODO: Add holes for wiring pass-through
            // TODO: Add mounting holes to connect to left/right/bottom
        }

        // Wire management features
        // TODO: Add cable routing channels or clips
    }
}

// Front top - holds flaps up, provides viewing window
module case_front_top() {
    color("tan") {
        difference() {
            // Top front section
            // TODO: Define geometry for flap support and viewing window
            // This is complex - needs to hold flaps at correct angle
            // while providing viewing window

            cuboid([unit_width, 20, 20],
                   anchor=CENTER);

            // Flap clearance/support
            // TODO: Add geometry to support flaps in display position
        }
    }
}

// Full case assembly
module case_assembly() {
    // Bottom
    down(unit_height/2)
        case_bottom();

    // Left side
    left(unit_width/2)
        case_left();

    // Right side
    right(unit_width/2)
        case_right();

    // Back
    back(unit_depth/2)
        case_back();

    // Front top
    fwd(unit_depth/2 - 10)
        up(unit_height/2 - 10)
            case_front_top();
}

// Example/test render
if ($preview) {
    case_assembly();
}
