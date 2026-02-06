// ============================================================================
// HARMONIC DRIVE COMPLETE ASSEMBLY
// Parametric Model - 100:1 Ratio, 40Nm
// Export as STL for SolidWorks import
// ============================================================================
// FULL TEETH GEOMETRY: 200 external (flex), 202 internal (circular)
// ALL DIMENSIONS: inches (mm)
// ============================================================================

// ============================================================================
// DESIGN PARAMETERS (Modify these to change the design)
// ============================================================================

// Primary inputs
gear_ratio = 100;           // Gear reduction ratio
tooth_difference = 2;        // Teeth difference (always 2 for harmonic drives)
module_m = 0.4;             // Tooth module: 0.0157 in (0.4 mm)
output_torque = 40;         // Nm (for reference)

// ============================================================================
// DERIVED PARAMETERS (Calculated automatically)
// ============================================================================

// Tooth counts
z_flex = gear_ratio * tooth_difference;   // 200 teeth
z_circ = z_flex + tooth_difference;       // 202 teeth

// Tooth geometry - inches (mm)
addendum = 0.8 * module_m;                // 0.0126 in (0.32 mm)
dedendum = 1.0 * module_m;                // 0.0157 in (0.40 mm)
tooth_height = addendum + dedendum;       // 0.0283 in (0.72 mm)
circular_pitch = PI * module_m;           // 0.0495 in (1.257 mm)

// Pitch diameters - inches (mm)
pitch_dia_flex = z_flex * module_m;       // 3.150 in (80.0 mm)
pitch_dia_circ = z_circ * module_m;       // 3.181 in (80.8 mm)

// Flex Spline dimensions - inches (mm)
flex_outer_dia = pitch_dia_flex + (2 * addendum);      // 3.175 in (80.64 mm)
flex_wall = 0.01 * pitch_dia_flex;                      // 0.031 in (0.8 mm)
flex_inner_dia = flex_outer_dia - (2 * flex_wall);     // 3.112 in (79.04 mm)
flex_cup_depth = 0.30 * pitch_dia_flex;                 // 0.945 in (24.0 mm)
flex_base_thick = 3.0 * flex_wall;                      // 0.094 in (2.4 mm)
flex_fillet = 2.5 * flex_wall;                          // 0.079 in (2.0 mm)
flex_tooth_zone = 0.12 * pitch_dia_flex;                // 0.378 in (9.6 mm)

// Circular Spline dimensions - inches (mm)
circ_inner_dia = pitch_dia_circ - (2 * addendum);      // 3.156 in (80.16 mm)
circ_outer_dia = 100.0;                                 // 3.937 in (100 mm)
circ_height = flex_tooth_zone + 4;                      // 0.535 in (13.6 mm)
bolt_circle = 94.0;                                     // 3.701 in (94 mm)
num_bolts = 6;
bolt_hole_dia = 4.2;                                    // 0.165 in (4.2 mm) M4 clearance

// Wave Generator dimensions - inches (mm)
wave_deflection = 2.25 * module_m;                      // 0.035 in (0.9 mm)
wave_major = flex_inner_dia + (2 * wave_deflection);   // 3.183 in (80.84 mm)
wave_minor = flex_inner_dia - 0.1;                      // 3.108 in (78.94 mm)
wave_width = flex_tooth_zone;                           // 0.378 in (9.6 mm)

// Bearing 6806-2RS - inches (mm)
bearing_od = 42.0;    // 1.654 in (42.0 mm)
bearing_id = 30.0;    // 1.181 in (30.0 mm)
bearing_width = 7.0;  // 0.276 in (7.0 mm)

// Hub - inches (mm)
hub_od = bearing_id - 0.02;   // 1.181 in (29.98 mm)
hub_bore = 10.0;              // 0.394 in (10.0 mm)

// Resolution
$fn = 100;

// ============================================================================
// TOOTH PROFILE MODULES
// ============================================================================

// S-curve tooth profile for external teeth (flex spline)
module external_tooth_2d(m, shift=0) {
    pitch = PI * m;
    tw = pitch / 2;
    add = addendum + shift;
    ded = dedendum - shift;

    points = [
        [-tw/2, -ded],
        [-tw/3, -ded * 0.6],
        [-tw/4, -ded * 0.2],
        [-tw/6, add * 0.3],
        [-tw/10, add * 0.7],
        [0, add],
        [tw/10, add * 0.7],
        [tw/6, add * 0.3],
        [tw/4, -ded * 0.2],
        [tw/3, -ded * 0.6],
        [tw/2, -ded]
    ];
    polygon(points);
}

// S-curve tooth space for internal teeth (circular spline)
module internal_tooth_space_2d(m, shift=0) {
    pitch = PI * m;
    tw = pitch / 2;
    add = addendum - shift;
    ded = dedendum + shift;

    points = [
        [-tw/2, ded],
        [-tw/3, ded * 0.6],
        [-tw/4, ded * 0.2],
        [-tw/6, -add * 0.3],
        [-tw/10, -add * 0.7],
        [0, -add],
        [tw/10, -add * 0.7],
        [tw/6, -add * 0.3],
        [tw/4, ded * 0.2],
        [tw/3, ded * 0.6],
        [tw/2, ded]
    ];
    polygon(points);
}

// ============================================================================
// COMPONENT MODULES
// ============================================================================

// --- FLEX SPLINE with 200 external teeth ---
module flex_spline(show_teeth = true) {
    profile_shift = 0.2;  // +0.008 in (+0.2 mm)

    color("Silver", 0.9)
    difference() {
        union() {
            // Cup body (below tooth zone)
            difference() {
                cylinder(h = flex_cup_depth - flex_tooth_zone, d = flex_outer_dia);
                translate([0, 0, flex_base_thick])
                    cylinder(h = flex_cup_depth, d = flex_inner_dia);
            }

            // Tooth zone with full 200 teeth
            if (show_teeth) {
                translate([0, 0, flex_cup_depth - flex_tooth_zone])
                difference() {
                    // Outer ring at tooth tip diameter
                    cylinder(h = flex_tooth_zone, d = flex_outer_dia + 2*addendum);

                    // Cut tooth spaces (200 teeth)
                    for (i = [0:z_flex-1]) {
                        rotate([0, 0, i * 360/z_flex + 0.9])
                        translate([pitch_dia_flex/2, 0, -0.1])
                        linear_extrude(height = flex_tooth_zone + 0.2)
                        rotate([0, 0, 90])
                        scale([1.1, 1])
                        external_tooth_2d(module_m, profile_shift);
                    }

                    // Inner bore
                    translate([0, 0, -0.1])
                    cylinder(h = flex_tooth_zone + 0.2, d = flex_inner_dia);
                }
            } else {
                // Simplified (no teeth detail)
                translate([0, 0, flex_cup_depth - flex_tooth_zone])
                difference() {
                    cylinder(h = flex_tooth_zone, d = flex_outer_dia + 0.64);
                    translate([0, 0, -0.1])
                        cylinder(h = flex_tooth_zone + 0.2, d = flex_inner_dia);
                }
            }
        }

        // Fillet at base (stress relief)
        translate([0, 0, flex_base_thick])
        rotate_extrude()
        translate([flex_inner_dia/2 - flex_fillet, 0, 0])
        difference() {
            square([flex_fillet + 1, flex_fillet + 1]);
            translate([flex_fillet, flex_fillet, 0])
            circle(r = flex_fillet);
        }
    }
}

// --- CIRCULAR SPLINE with 202 internal teeth ---
module circular_spline(show_teeth = true) {
    profile_shift = -0.2;  // -0.008 in (-0.2 mm)

    color("LightSteelBlue", 0.9)
    difference() {
        // Ring body
        cylinder(h = circ_height, d = circ_outer_dia);

        // Inner bore with teeth
        if (show_teeth) {
            translate([0, 0, -0.1])
            difference() {
                // Bore at tooth root diameter
                cylinder(h = circ_height + 0.2, d = circ_inner_dia + 2*dedendum);

                // Add teeth by keeping material (cut spaces)
                for (i = [0:z_circ-1]) {
                    rotate([0, 0, i * 360/z_circ])
                    translate([pitch_dia_circ/2, 0, 0])
                    linear_extrude(height = circ_height + 0.4)
                    rotate([0, 0, 90])
                    scale([1.1, 1])
                    internal_tooth_space_2d(module_m, profile_shift);
                }
            }
        } else {
            // Simplified (no teeth detail)
            translate([0, 0, -0.1])
                cylinder(h = circ_height + 0.2, d = circ_inner_dia);
        }

        // Bolt holes (6x M4)
        for (i = [0:num_bolts-1]) {
            rotate([0, 0, i * 360/num_bolts])
            translate([bolt_circle/2, 0, -0.1])
                cylinder(h = circ_height + 0.2, d = bolt_hole_dia);
        }
    }
}

// --- WAVE GENERATOR ---
module wave_generator(show_bearing = true) {
    // Elliptical cam with hub
    color("LightGreen", 0.9)
    difference() {
        union() {
            // Elliptical cam
            scale([wave_major/wave_minor, 1, 1])
                cylinder(h = wave_width, d = wave_minor);
        }

        // Bearing seat
        translate([0, 0, (wave_width - bearing_width)/2])
            cylinder(h = bearing_width + 0.1, d = bearing_od + 0.04);

        // Bore
        translate([0, 0, -0.1])
            cylinder(h = wave_width + 0.2, d = hub_bore);

        // Keyway
        translate([-2, hub_bore/2 - 2, -0.1])
            cube([4, 3, wave_width + 0.2]);
    }

    // Bearing
    if (show_bearing) {
        color("Gold", 0.8)
        translate([0, 0, (wave_width - bearing_width)/2])
        difference() {
            cylinder(h = bearing_width, d = bearing_od);
            translate([0, 0, -0.1])
                cylinder(h = bearing_width + 0.2, d = bearing_id);
        }
    }
}

// ============================================================================
// ASSEMBLY VIEWS
// ============================================================================

// --- EXPLODED VIEW ---
module assembly_exploded() {
    // Wave Generator (bottom)
    translate([0, 0, 0])
        wave_generator();

    // Flex Spline (middle)
    translate([0, 0, 50])
        rotate([180, 0, 0])
        translate([0, 0, -flex_cup_depth])
            flex_spline(show_teeth=true);

    // Circular Spline (top)
    translate([0, 0, 100])
        circular_spline(show_teeth=true);
}

// --- ASSEMBLED VIEW ---
module assembly_complete() {
    // Circular Spline (fixed, output)
    translate([0, 0, flex_cup_depth - flex_tooth_zone])
        circular_spline(show_teeth=true);

    // Flex Spline (deforms, connects to output)
    rotate([180, 0, 0])
    translate([0, 0, -flex_cup_depth])
        flex_spline(show_teeth=true);

    // Wave Generator (input, rotates)
    translate([0, 0, flex_cup_depth - flex_tooth_zone + (circ_height - wave_width)/2])
        wave_generator();
}

// --- SECTION VIEW ---
module assembly_section() {
    difference() {
        assembly_complete();

        // Cut plane
        translate([-200, 0, -50])
            cube([200, 200, 200]);
    }
}

// ============================================================================
// RENDER SELECTION
// ============================================================================

// Uncomment ONE of the following to render:

// Individual parts:
// flex_spline(show_teeth=true);
// circular_spline(show_teeth=true);
// wave_generator();

// Assembly views:
// assembly_exploded();
assembly_complete();
// assembly_section();

// ============================================================================
// PARAMETER OUTPUT - inches (mm)
// ============================================================================

echo("============================================");
echo("HARMONIC DRIVE DESIGN PARAMETERS");
echo("Full Teeth Geometry: 200 + 202 teeth");
echo("============================================");
echo(str("Gear Ratio: ", gear_ratio, ":1"));
echo(str("Output Torque: ", output_torque, " Nm"));
echo(str("Module: 0.0157 in (", module_m, " mm)"));
echo("");
echo("FLEX SPLINE:");
echo(str("  Teeth: ", z_flex, " (external, S-curve profile)"));
echo(str("  Pitch Diameter: 3.150 in (", pitch_dia_flex, " mm)"));
echo(str("  Outer Diameter: 3.175 in (", flex_outer_dia, " mm)"));
echo(str("  Inner Diameter: 3.112 in (", flex_inner_dia, " mm)"));
echo(str("  Wall Thickness: 0.031 in (", flex_wall, " mm) CRITICAL"));
echo(str("  Cup Depth: 0.945 in (", flex_cup_depth, " mm)"));
echo("");
echo("CIRCULAR SPLINE:");
echo(str("  Teeth: ", z_circ, " (internal, S-curve profile)"));
echo(str("  Inner Diameter: 3.156 in (", circ_inner_dia, " mm)"));
echo(str("  Outer Diameter: 3.937 in (", circ_outer_dia, " mm)"));
echo(str("  Height: 0.535 in (", circ_height, " mm)"));
echo(str("  Bolt Circle: 3.701 in (", bolt_circle, " mm)"));
echo("");
echo("WAVE GENERATOR:");
echo(str("  Major Axis: 3.183 in (", wave_major, " mm)"));
echo(str("  Minor Axis: 3.108 in (", wave_minor, " mm)"));
echo(str("  Deflection: 0.035 in (", wave_deflection, " mm)"));
echo(str("  Bearing: 6806-2RS 1.181x1.654x0.276 in"));
echo("============================================");
