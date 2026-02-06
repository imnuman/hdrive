// Arm Links and Brackets for 7-DOF Robotic Arm
// Structural components connecting RobStride actuators
//
// KUKA iiwa-style configuration:
// - Alternating joint axes (perpendicular)
// - Smooth fairings for cable routing
// - Structural aluminum brackets

$fn = 48;

// Material colors
LINK_COLOR = [0.85, 0.85, 0.85];      // Light aluminum
BRACKET_COLOR = [0.7, 0.7, 0.75];     // Darker aluminum
COVER_COLOR = [0.2, 0.2, 0.22];       // Dark plastic covers

// ============================================
// BASE MOUNT
// ============================================
module base_mount() {
    // Mounting plate to table/structure
    base_od = 150;
    base_height = 15;
    mount_holes_pcd = 130;
    mount_holes = 8;
    mount_hole_dia = 8.5;
    center_bore = 30;

    color(BRACKET_COLOR)
    difference() {
        union() {
            // Main plate
            cylinder(d=base_od, h=base_height);

            // Raised ring for motor mounting
            translate([0, 0, base_height])
            cylinder(d=90, h=8);
        }

        // Center bore for cables
        translate([0, 0, -1])
        cylinder(d=center_bore, h=base_height + 10);

        // Mounting holes to table
        for (i = [0:mount_holes-1]) {
            rotate([0, 0, i * 360/mount_holes])
            translate([mount_holes_pcd/2, 0, -1])
            cylinder(d=mount_hole_dia, h=base_height + 2);
        }

        // Motor mounting holes (match RobStride 04 back flange)
        for (i = [0:5]) {
            rotate([0, 0, i * 60])
            translate([35, 0, base_height - 1])
            cylinder(d=4.3, h=10);
        }
    }
}

// ============================================
// LINK MODULES
// ============================================

// Generic link tube with flanges
module link_tube(length, inner_dia=40, outer_dia=50, flange_dia=70, flange_height=10) {
    color(LINK_COLOR)
    difference() {
        union() {
            // Main tube
            cylinder(d=outer_dia, h=length);

            // Bottom flange
            cylinder(d=flange_dia, h=flange_height);

            // Top flange
            translate([0, 0, length - flange_height])
            cylinder(d=flange_dia, h=flange_height);
        }

        // Hollow core
        translate([0, 0, -1])
        cylinder(d=inner_dia, h=length + 2);

        // Cable routing slots
        for (i = [0:3]) {
            rotate([0, 0, i * 90 + 45])
            translate([outer_dia/2 - 3, -5, flange_height])
            cube([10, 10, length - 2*flange_height]);
        }
    }
}

// Shoulder Link 1 (J1 to J2) - 150mm
module shoulder_link_1() {
    length = 150;

    color(LINK_COLOR)
    difference() {
        union() {
            // Base section (vertical tube)
            cylinder(d=55, h=80);

            // Transition to horizontal
            translate([0, 0, 80])
            rotate([0, 0, 0])
            hull() {
                cylinder(d=55, h=1);
                translate([0, 0, 40])
                rotate([90, 0, 0])
                cylinder(d=55, h=1);
            }

            // Horizontal section
            translate([0, -40, 120])
            rotate([-90, 0, 0])
            cylinder(d=55, h=length - 120 + 40);
        }

        // Hollow for cables
        translate([0, 0, -1])
        cylinder(d=35, h=85);

        translate([0, -35, 115])
        rotate([-90, 0, 0])
        cylinder(d=35, h=length);
    }

    // Motor mount adapter at top
    color(BRACKET_COLOR)
    translate([0, length - 80, 120])
    rotate([-90, 0, 0])
    difference() {
        cylinder(d=70, h=12);
        translate([0, 0, -1])
        cylinder(d=35, h=14);
        // Bolt holes
        for (i = [0:5]) {
            rotate([0, 0, i * 60])
            translate([30, 0, -1])
            cylinder(d=4.3, h=14);
        }
    }
}

// Shoulder Link 2 (J2 to J3) - 150mm offset bracket
module shoulder_link_2() {
    color(LINK_COLOR)
    difference() {
        union() {
            // Input side bracket
            cylinder(d=65, h=15);

            // Offset arm
            hull() {
                translate([0, 0, 5])
                cylinder(d=50, h=10);

                translate([0, 80, 5])
                cylinder(d=50, h=10);
            }

            // Output side
            translate([0, 80, 0])
            cylinder(d=65, h=15);

            // Vertical section for J3 motor
            translate([0, 80, 0])
            rotate([0, 0, 0])
            cylinder(d=55, h=70);
        }

        // Hollow cores
        translate([0, 0, -1])
        cylinder(d=35, h=20);

        translate([0, 80, -1])
        cylinder(d=35, h=75);

        // Cable channel
        translate([-15, 0, 7])
        cube([30, 80, 6]);
    }
}

// Upper arm link (J3 to J4) - 200mm
module upper_arm_link() {
    length = 200;

    color(LINK_COLOR)
    difference() {
        union() {
            // Input flange
            cylinder(d=60, h=12);

            // Tapered tube section
            translate([0, 0, 12])
            cylinder(d1=55, d2=50, h=length - 24);

            // Output flange
            translate([0, 0, length - 12])
            cylinder(d=55, h=12);
        }

        // Hollow core
        translate([0, 0, -1])
        cylinder(d=30, h=length + 2);

        // Bolt holes at input
        for (i = [0:5]) {
            rotate([0, 0, i * 60])
            translate([27, 0, -1])
            cylinder(d=4.3, h=14);
        }

        // Bolt holes at output
        for (i = [0:5]) {
            rotate([0, 0, i * 60])
            translate([25, 0, length - 11])
            cylinder(d=4.3, h=14);
        }
    }
}

// Forearm link (J4 to J5) - 150mm
module forearm_link() {
    length = 150;

    color(LINK_COLOR)
    difference() {
        union() {
            // Input flange
            cylinder(d=55, h=10);

            // Main tube
            translate([0, 0, 10])
            cylinder(d=45, h=length - 20);

            // Output flange (smaller for RS03)
            translate([0, 0, length - 10])
            cylinder(d=50, h=10);
        }

        // Hollow core
        translate([0, 0, -1])
        cylinder(d=25, h=length + 2);

        // Bolt holes
        for (i = [0:5]) {
            rotate([0, 0, i * 60])
            translate([23, 0, -1])
            cylinder(d=4.3, h=12);
        }
    }
}

// Wrist link 1 (J5 to J6) - 100mm
module wrist_link_1() {
    length = 100;

    color(LINK_COLOR)
    difference() {
        union() {
            // Input flange
            cylinder(d=48, h=8);

            // Tube
            translate([0, 0, 8])
            cylinder(d=40, h=length - 16);

            // Output flange
            translate([0, 0, length - 8])
            cylinder(d=42, h=8);
        }

        // Hollow
        translate([0, 0, -1])
        cylinder(d=20, h=length + 2);
    }
}

// Wrist link 2 (J6 to J7) - 80mm
module wrist_link_2() {
    length = 80;

    color(LINK_COLOR)
    difference() {
        union() {
            // Input flange
            cylinder(d=42, h=6);

            // Tube
            translate([0, 0, 6])
            cylinder(d=35, h=length - 12);

            // Output flange
            translate([0, 0, length - 6])
            cylinder(d=38, h=6);
        }

        // Hollow
        translate([0, 0, -1])
        cylinder(d=16, h=length + 2);
    }
}

// End effector mount (after J7)
module end_effector_mount() {
    color(BRACKET_COLOR)
    difference() {
        union() {
            // Mounting plate
            cylinder(d=50, h=10);

            // Tool flange (ISO 9409-1-50-4-M6)
            translate([0, 0, 10])
            cylinder(d=50, h=8);
        }

        // Center bore
        translate([0, 0, -1])
        cylinder(d=15, h=20);

        // Tool mounting holes (4x M6 on 31.5mm radius)
        for (i = [0:3]) {
            rotate([0, 0, i * 90 + 45])
            translate([31.5, 0, 10])
            cylinder(d=6.6, h=10);
        }

        // Locating pin holes
        for (i = [0:1]) {
            rotate([0, 0, i * 180])
            translate([20, 0, 10])
            cylinder(d=4, h=10);
        }
    }
}

// ============================================
// JOINT COVERS / FAIRINGS
// ============================================
module joint_cover_large() {
    // Covers the junction between actuator and link
    color(COVER_COLOR)
    difference() {
        hull() {
            cylinder(d=95, h=5);
            translate([0, 0, 25])
            cylinder(d=75, h=5);
        }
        translate([0, 0, -1])
        cylinder(d=60, h=35);
    }
}

module joint_cover_medium() {
    color(COVER_COLOR)
    difference() {
        hull() {
            cylinder(d=75, h=4);
            translate([0, 0, 20])
            cylinder(d=60, h=4);
        }
        translate([0, 0, -1])
        cylinder(d=50, h=28);
    }
}

module joint_cover_small() {
    color(COVER_COLOR)
    difference() {
        hull() {
            cylinder(d=58, h=3);
            translate([0, 0, 15])
            cylinder(d=48, h=3);
        }
        translate([0, 0, -1])
        cylinder(d=40, h=22);
    }
}

// ============================================
// CABLE MANAGEMENT
// ============================================
module cable_clip() {
    // Small clip for routing cables along links
    color([0.3, 0.3, 0.3])
    difference() {
        cube([15, 8, 10]);
        translate([2, -1, 2])
        cube([11, 10, 6]);
        translate([7.5, 4, -1])
        cylinder(d=3.5, h=12);
    }
}

// Test render individual components
// base_mount();
// translate([0, 0, 50]) shoulder_link_1();
// translate([0, 0, 200]) shoulder_link_2();
// translate([0, 0, 350]) upper_arm_link();
// translate([0, 0, 600]) forearm_link();
// translate([0, 0, 800]) wrist_link_1();
// translate([0, 0, 950]) wrist_link_2();
// translate([0, 0, 1050]) end_effector_mount();
