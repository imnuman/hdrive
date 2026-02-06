// RobStride 02 Integrated Actuator Model
// 8Nm rated, 25Nm peak torque
// 9:1 planetary gearbox, integrated FOC driver, 19-bit encoder
//
// Dimensions based on specifications:
// - Housing diameter: 62mm
// - Length: 45mm
// - Output flange: 45mm
// - Weight: 0.54kg

$fn = 64;

// Main dimensions (mm)
HOUSING_OD = 62;
HOUSING_LENGTH = 45;
OUTPUT_FLANGE_OD = 45;
OUTPUT_FLANGE_THICKNESS = 5;
OUTPUT_SHAFT_OD = 16;
OUTPUT_SHAFT_LENGTH = 8;
BACK_FLANGE_OD = 52;
BACK_FLANGE_THICKNESS = 3.5;
BACK_MOUNT_PCD = 44;
BACK_MOUNT_HOLES = 6;
BACK_MOUNT_HOLE_DIA = 3.4; // M3 clearance
OUTPUT_MOUNT_PCD = 36;
OUTPUT_MOUNT_HOLES = 6;
OUTPUT_MOUNT_HOLE_DIA = 3.4; // M3 clearance
CABLE_EXIT_WIDTH = 10;
CABLE_EXIT_HEIGHT = 5;
CABLE_EXIT_DEPTH = 6;

// Colors
HOUSING_COLOR = [0.15, 0.15, 0.15];  // Dark gray/black
FLANGE_COLOR = [0.7, 0.7, 0.7];       // Silver/aluminum

module robstride_02(show_output_shaft=true) {
    // Main housing body
    color(HOUSING_COLOR)
    difference() {
        union() {
            // Main cylindrical housing
            cylinder(d=HOUSING_OD, h=HOUSING_LENGTH - BACK_FLANGE_THICKNESS - OUTPUT_FLANGE_THICKNESS);

            // Decorative ribs/cooling fins
            for (i = [0:11]) {
                rotate([0, 0, i * 30])
                translate([HOUSING_OD/2 - 1.2, -1.2, 3])
                cube([2, 2.4, HOUSING_LENGTH - BACK_FLANGE_THICKNESS - OUTPUT_FLANGE_THICKNESS - 6]);
            }
        }

        // Cable exit cutout
        translate([HOUSING_OD/2 - CABLE_EXIT_DEPTH, -CABLE_EXIT_WIDTH/2, HOUSING_LENGTH/2 - CABLE_EXIT_HEIGHT/2])
        cube([CABLE_EXIT_DEPTH + 1, CABLE_EXIT_WIDTH, CABLE_EXIT_HEIGHT]);

        // Internal hollow
        translate([0, 0, -1])
        cylinder(d=HOUSING_OD - 10, h=HOUSING_LENGTH - 6);
    }

    // Output flange (front)
    color(FLANGE_COLOR)
    translate([0, 0, HOUSING_LENGTH - BACK_FLANGE_THICKNESS - OUTPUT_FLANGE_THICKNESS])
    difference() {
        cylinder(d=OUTPUT_FLANGE_OD, h=OUTPUT_FLANGE_THICKNESS);

        // Center bore
        translate([0, 0, -1])
        cylinder(d=OUTPUT_SHAFT_OD - 3, h=OUTPUT_FLANGE_THICKNESS + 2);

        // Mounting holes
        for (i = [0:OUTPUT_MOUNT_HOLES-1]) {
            rotate([0, 0, i * 360/OUTPUT_MOUNT_HOLES])
            translate([OUTPUT_MOUNT_PCD/2, 0, -1])
            cylinder(d=OUTPUT_MOUNT_HOLE_DIA, h=OUTPUT_FLANGE_THICKNESS + 2);
        }
    }

    // Output shaft
    if (show_output_shaft) {
        color(FLANGE_COLOR)
        translate([0, 0, HOUSING_LENGTH - BACK_FLANGE_THICKNESS])
        difference() {
            cylinder(d=OUTPUT_SHAFT_OD, h=OUTPUT_SHAFT_LENGTH);

            // Center bore
            translate([0, 0, -1])
            cylinder(d=6, h=OUTPUT_SHAFT_LENGTH + 2);

            // Keyway
            translate([-1, OUTPUT_SHAFT_OD/2 - 2.5, OUTPUT_SHAFT_LENGTH/2])
            cube([2, 3, OUTPUT_SHAFT_LENGTH/2 + 1]);
        }
    }

    // Back mount flange
    color(FLANGE_COLOR)
    translate([0, 0, -BACK_FLANGE_THICKNESS])
    difference() {
        cylinder(d=BACK_FLANGE_OD, h=BACK_FLANGE_THICKNESS);

        // Center bore for wiring
        translate([0, 0, -1])
        cylinder(d=12, h=BACK_FLANGE_THICKNESS + 2);

        // Mounting holes
        for (i = [0:BACK_MOUNT_HOLES-1]) {
            rotate([0, 0, i * 360/BACK_MOUNT_HOLES])
            translate([BACK_MOUNT_PCD/2, 0, -1])
            cylinder(d=BACK_MOUNT_HOLE_DIA, h=BACK_FLANGE_THICKNESS + 2);
        }
    }

    // Encoder bump on back
    color(HOUSING_COLOR)
    translate([0, 0, -BACK_FLANGE_THICKNESS - 3])
    cylinder(d=20, h=3);

    // Cable connector
    color([0.2, 0.2, 0.2])
    translate([HOUSING_OD/2 - 3, -4.5, HOUSING_LENGTH/2 - 3])
    cube([10, 9, 6]);
}

// Render the actuator
robstride_02();
