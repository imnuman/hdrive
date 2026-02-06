// 7-DOF Redundant Robotic Arm Assembly
// KUKA iiwa-style configuration with RobStride actuators
//
// Joint Configuration:
// J1: Base rotation (vertical axis)
// J2: Shoulder pitch (horizontal axis)
// J3: Shoulder roll (in-line with upper arm)
// J4: Elbow pitch (horizontal axis)
// J5: Wrist pitch (horizontal axis)
// J6: Wrist roll (in-line with forearm)
// J7: Tool rotation (vertical axis)
//
// Actuators:
// J1-J4: RobStride 04 (40Nm rated)
// J5: RobStride 03 (20Nm rated)
// J6-J7: RobStride 02 (8Nm rated)

use <robstride_04.scad>
use <robstride_03.scad>
use <robstride_02.scad>
use <arm_links.scad>

$fn = 48;

// ============================================
// POSE SELECTION
// ============================================
// Set pose variable to select arm position:
// "home" - all joints at 0 degrees
// "extended" - arm fully stretched out
// "folded" - compact folded position
// "custom" - use joint angle parameters

pose = "home";  // Change this to switch poses

// Custom joint angles (degrees) - used when pose = "custom"
custom_j1 = 0;
custom_j2 = 0;
custom_j3 = 0;
custom_j4 = 0;
custom_j5 = 0;
custom_j6 = 0;
custom_j7 = 0;

// ============================================
// LINK LENGTHS (mm)
// ============================================
L1 = 100;   // Base height to J1
L2 = 150;   // J1 to J2 (shoulder offset)
L3 = 100;   // J2 to J3 (shoulder width)
L4 = 200;   // J3 to J4 (upper arm)
L5 = 150;   // J4 to J5 (forearm)
L6 = 100;   // J5 to J6 (wrist 1)
L7 = 80;    // J6 to J7 (wrist 2)
L8 = 60;    // J7 to end effector flange

// Actuator lengths (including shaft)
RS04_LEN = 85;  // RobStride 04 total length
RS03_LEN = 70;  // RobStride 03 total length
RS02_LEN = 55;  // RobStride 02 total length

// ============================================
// PREDEFINED POSES
// ============================================
function get_pose(p) =
    p == "home" ? [0, 0, 0, 0, 0, 0, 0] :
    p == "extended" ? [0, 45, 0, 0, 0, 0, 0] :
    p == "folded" ? [0, -30, 0, 120, 90, 0, 0] :
    p == "wave" ? [45, -20, 30, 60, -30, 45, 0] :
    [custom_j1, custom_j2, custom_j3, custom_j4, custom_j5, custom_j6, custom_j7];

// Get current pose angles
angles = get_pose(pose);
j1 = angles[0];
j2 = angles[1];
j3 = angles[2];
j4 = angles[3];
j5 = angles[4];
j6 = angles[5];
j7 = angles[6];

// ============================================
// COLORS
// ============================================
MOTOR_COLOR = [0.15, 0.15, 0.17];
LINK_COLOR = [0.85, 0.85, 0.88];
ACCENT_COLOR = [0.9, 0.3, 0.2];

// ============================================
// MAIN ARM ASSEMBLY MODULE
// ============================================
module robotic_arm_7dof(j1=0, j2=0, j3=0, j4=0, j5=0, j6=0, j7=0) {

    // ---- BASE ----
    color(LINK_COLOR) base_mount();

    // ---- J1: BASE ROTATION ----
    translate([0, 0, L1])
    rotate([0, 0, j1]) {
        // J1 Motor (RobStride 04)
        rotate([180, 0, 0])
        robstride_04();

        // Shoulder structure
        translate([0, 0, 0]) {
            // Vertical riser to J2
            color(LINK_COLOR)
            difference() {
                cylinder(d=60, h=L2);
                translate([0, 0, -1])
                cylinder(d=35, h=L2+2);
            }

            // ---- J2: SHOULDER PITCH ----
            translate([0, 0, L2])
            rotate([0, 90, 0])
            rotate([0, 0, j2]) {
                // J2 Motor (RobStride 04)
                translate([0, 0, -RS04_LEN/2 + 20])
                rotate([0, 0, 0])
                robstride_04();

                // Shoulder offset to J3
                translate([0, 0, 20]) {
                    color(LINK_COLOR)
                    difference() {
                        cylinder(d=55, h=L3);
                        translate([0, 0, -1])
                        cylinder(d=30, h=L3+2);
                    }

                    // ---- J3: SHOULDER ROLL ----
                    translate([0, 0, L3])
                    rotate([0, 0, j3]) {
                        // J3 Motor (RobStride 04)
                        robstride_04();

                        // Upper arm link to J4
                        translate([0, 0, RS04_LEN]) {
                            color(LINK_COLOR)
                            difference() {
                                cylinder(d=50, h=L4);
                                translate([0, 0, -1])
                                cylinder(d=28, h=L4+2);
                            }

                            // ---- J4: ELBOW PITCH ----
                            translate([0, 0, L4])
                            rotate([0, 90, 0])
                            rotate([0, 0, j4]) {
                                // J4 Motor (RobStride 04)
                                translate([0, 0, -RS04_LEN/2 + 15])
                                robstride_04();

                                // Forearm link to J5
                                translate([0, 0, 15]) {
                                    color(LINK_COLOR)
                                    difference() {
                                        cylinder(d=45, h=L5);
                                        translate([0, 0, -1])
                                        cylinder(d=25, h=L5+2);
                                    }

                                    // ---- J5: WRIST PITCH ----
                                    translate([0, 0, L5])
                                    rotate([0, 90, 0])
                                    rotate([0, 0, j5]) {
                                        // J5 Motor (RobStride 03 - smaller)
                                        translate([0, 0, -RS03_LEN/2 + 10])
                                        robstride_03();

                                        // Wrist link 1 to J6
                                        translate([0, 0, 10]) {
                                            color(LINK_COLOR)
                                            difference() {
                                                cylinder(d=40, h=L6);
                                                translate([0, 0, -1])
                                                cylinder(d=20, h=L6+2);
                                            }

                                            // ---- J6: WRIST ROLL ----
                                            translate([0, 0, L6])
                                            rotate([0, 0, j6]) {
                                                // J6 Motor (RobStride 02 - compact)
                                                robstride_02();

                                                // Wrist link 2 to J7
                                                translate([0, 0, RS02_LEN]) {
                                                    color(LINK_COLOR)
                                                    difference() {
                                                        cylinder(d=35, h=L7);
                                                        translate([0, 0, -1])
                                                        cylinder(d=16, h=L7+2);
                                                    }

                                                    // ---- J7: TOOL ROTATION ----
                                                    translate([0, 0, L7])
                                                    rotate([0, 0, j7]) {
                                                        // J7 Motor (RobStride 02 - compact)
                                                        robstride_02();

                                                        // End effector flange
                                                        translate([0, 0, RS02_LEN])
                                                        end_effector_flange();
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

// ============================================
// END EFFECTOR FLANGE
// ============================================
module end_effector_flange() {
    color(LINK_COLOR)
    difference() {
        union() {
            // Adapter plate
            cylinder(d=50, h=8);

            // Tool flange (ISO 9409-1-50-4-M6)
            translate([0, 0, 8])
            cylinder(d=50, h=10);
        }

        // Center bore
        translate([0, 0, -1])
        cylinder(d=12, h=25);

        // Tool mounting holes (4x M6 on 31.5mm radius)
        for (i = [0:3]) {
            rotate([0, 0, i * 90 + 45])
            translate([31.5/2, 0, 8])
            cylinder(d=6.6, h=12);
        }

        // Locating pin holes
        for (i = [0:1]) {
            rotate([0, 0, i * 180])
            translate([20, 0, 8])
            cylinder(d=4, h=12);
        }
    }

    // Visual indicator for tool center point (TCP)
    color(ACCENT_COLOR)
    translate([0, 0, 18])
    cylinder(d=5, h=L8);

    color(ACCENT_COLOR)
    translate([0, 0, 18 + L8])
    sphere(d=8);
}

// ============================================
// SIMPLE GRIPPER (for visualization)
// ============================================
module simple_gripper() {
    color([0.3, 0.3, 0.35])
    translate([0, 0, 0]) {
        // Gripper body
        difference() {
            cylinder(d=45, h=30);
            translate([0, 0, -1])
            cylinder(d=25, h=32);
        }

        // Fingers
        for (i = [0:1]) {
            mirror([i, 0, 0])
            translate([15, -8, 30]) {
                cube([5, 16, 50]);
                translate([0, 3, 50])
                cube([5, 10, 15]);
            }
        }
    }
}

// ============================================
// COORDINATE FRAME VISUALIZATION
// ============================================
module coord_frame(size=30) {
    // X axis - Red
    color([1, 0, 0])
    rotate([0, 90, 0])
    cylinder(d=2, h=size);

    // Y axis - Green
    color([0, 1, 0])
    rotate([-90, 0, 0])
    cylinder(d=2, h=size);

    // Z axis - Blue
    color([0, 0, 1])
    cylinder(d=2, h=size);
}

// ============================================
// WORKSPACE VISUALIZATION
// ============================================
module workspace_sphere() {
    // Approximate reach envelope
    total_reach = L2 + L3 + L4 + L5 + L6 + L7 + L8;

    color([0.2, 0.5, 0.8, 0.1])
    translate([0, 0, L1])
    sphere(r=total_reach);
}

// ============================================
// FLOOR GRID
// ============================================
module floor_grid(size=500, spacing=50) {
    color([0.3, 0.3, 0.3])
    translate([-size/2, -size/2, -2])
    for (x = [0:spacing:size]) {
        translate([x, 0, 0])
        cube([1, size, 1]);
    }

    color([0.3, 0.3, 0.3])
    translate([-size/2, -size/2, -2])
    for (y = [0:spacing:size]) {
        translate([0, y, 0])
        cube([size, 1, 1]);
    }
}

// ============================================
// RENDER THE ARM
// ============================================

// Floor reference
floor_grid();

// Main arm with selected pose
robotic_arm_7dof(j1, j2, j3, j4, j5, j6, j7);

// Optional: Show workspace envelope
// workspace_sphere();

// Optional: Add gripper
// translate([0, 0, total_arm_height]) simple_gripper();

// Info output
echo("=== 7-DOF Robotic Arm ===");
echo("Pose: ", pose);
echo("Joint angles (deg): J1=", j1, " J2=", j2, " J3=", j3, " J4=", j4, " J5=", j5, " J6=", j6, " J7=", j7);
echo("Approximate reach: ", L2 + L3 + L4 + L5 + L6 + L7 + L8, "mm");
echo("Actuators: 4x RobStride 04, 1x RobStride 03, 2x RobStride 02");
