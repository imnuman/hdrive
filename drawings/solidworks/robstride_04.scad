// RobStride 04 Integrated Actuator Model
// 40Nm rated, 120Nm peak torque
// 9:1 planetary gearbox, integrated FOC driver, 19-bit encoder
//
// Dimensions based on specifications:
// - Housing diameter: 98mm
// - Length: 68mm
// - Output flange: 70mm with 6×M5 holes on 60mm PCD
// - Back mount: 80mm with 6×M4 holes on 70mm PCD
// - Weight: 1.42kg

$fn = 64;

// Main dimensions (mm)
HOUSING_OD = 98;
HOUSING_LENGTH = 68;
OUTPUT_FLANGE_OD = 70;
OUTPUT_FLANGE_THICKNESS = 8;
OUTPUT_SHAFT_OD = 25;
OUTPUT_SHAFT_LENGTH = 12;
BACK_FLANGE_OD = 80;
BACK_FLANGE_THICKNESS = 5;
BACK_MOUNT_PCD = 70;
BACK_MOUNT_HOLES = 6;
BACK_MOUNT_HOLE_DIA = 4.3; // M4 clearance
OUTPUT_MOUNT_PCD = 60;
OUTPUT_MOUNT_HOLES = 6;
OUTPUT_MOUNT_HOLE_DIA = 5.5; // M5 clearance
CABLE_EXIT_WIDTH = 15;
CABLE_EXIT_HEIGHT = 8;
CABLE_EXIT_DEPTH = 10;

// Colors
HOUSING_COLOR = [0.15, 0.15, 0.15];  // Dark gray/black
FLANGE_COLOR = [0.7, 0.7, 0.7];       // Silver/aluminum

module robstride_04(show_output_shaft=true) {
    // Main housing body
    color(HOUSING_COLOR)
    difference() {
        union() {
            // Main cylindrical housing
            cylinder(d=HOUSING_OD, h=HOUSING_LENGTH - BACK_FLANGE_THICKNESS - OUTPUT_FLANGE_THICKNESS);

            // Decorative ribs/cooling fins
            for (i = [0:11]) {
                rotate([0, 0, i * 30])
                translate([HOUSING_OD/2 - 2, -2, 5])
                cube([3, 4, HOUSING_LENGTH - BACK_FLANGE_THICKNESS - OUTPUT_FLANGE_THICKNESS - 10]);
            }
        }

        // Cable exit cutout
        translate([HOUSING_OD/2 - CABLE_EXIT_DEPTH, -CABLE_EXIT_WIDTH/2, HOUSING_LENGTH/2 - CABLE_EXIT_HEIGHT/2])
        cube([CABLE_EXIT_DEPTH + 1, CABLE_EXIT_WIDTH, CABLE_EXIT_HEIGHT]);

        // Internal hollow (for weight reduction in model)
        translate([0, 0, -1])
        cylinder(d=HOUSING_OD - 15, h=HOUSING_LENGTH - 10);
    }

    // Output flange (front)
    color(FLANGE_COLOR)
    translate([0, 0, HOUSING_LENGTH - BACK_FLANGE_THICKNESS - OUTPUT_FLANGE_THICKNESS])
    difference() {
        cylinder(d=OUTPUT_FLANGE_OD, h=OUTPUT_FLANGE_THICKNESS);

        // Center bore
        translate([0, 0, -1])
        cylinder(d=OUTPUT_SHAFT_OD - 5, h=OUTPUT_FLANGE_THICKNESS + 2);

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

            // Spline/key pattern (simplified)
            translate([0, 0, -1])
            cylinder(d=10, h=OUTPUT_SHAFT_LENGTH + 2);

            // Keyway
            translate([-2, OUTPUT_SHAFT_OD/2 - 4, OUTPUT_SHAFT_LENGTH/2])
            cube([4, 5, OUTPUT_SHAFT_LENGTH/2 + 1]);
        }
    }

    // Back mount flange
    color(FLANGE_COLOR)
    translate([0, 0, -BACK_FLANGE_THICKNESS])
    difference() {
        cylinder(d=BACK_FLANGE_OD, h=BACK_FLANGE_THICKNESS);

        // Center bore for wiring
        translate([0, 0, -1])
        cylinder(d=20, h=BACK_FLANGE_THICKNESS + 2);

        // Mounting holes
        for (i = [0:BACK_MOUNT_HOLES-1]) {
            rotate([0, 0, i * 360/BACK_MOUNT_HOLES])
            translate([BACK_MOUNT_PCD/2, 0, -1])
            cylinder(d=BACK_MOUNT_HOLE_DIA, h=BACK_FLANGE_THICKNESS + 2);
        }
    }

    // Encoder bump on back
    color(HOUSING_COLOR)
    translate([0, 0, -BACK_FLANGE_THICKNESS - 5])
    cylinder(d=30, h=5);

    // Cable connector
    color([0.2, 0.2, 0.2])
    translate([HOUSING_OD/2 - 5, -7, HOUSING_LENGTH/2 - 5])
    cube([15, 14, 10]);
}

// Render the actuator
robstride_04();

// Info text (comment out for STL export)
// echo("RobStride 04 - 40Nm rated torque");
// echo("Housing: ", HOUSING_OD, "mm dia x ", HOUSING_LENGTH + BACK_FLANGE_THICKNESS, "mm total length");
