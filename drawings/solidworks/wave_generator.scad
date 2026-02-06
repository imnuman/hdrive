// ============================================================================
// WAVE GENERATOR - Parametric Model for Harmonic Drive
// Material: Aluminum 6061-T6 + Bearing 6806-2RS
// Export as STL for SolidWorks import
// ============================================================================
// DIMENSIONS: inches (mm)
// - Major Axis: 3.183 in (80.84 mm)
// - Minor Axis: 3.108 in (78.94 mm)
// - Radial Deflection: 0.035 in (0.9 mm)
// - Cam Width: 0.378 in (9.6 mm)
// - Bearing: 6806-2RS 1.181 x 1.654 x 0.276 in (30 x 42 x 7 mm)
// - Hub OD: 1.181 in (29.98 mm) - press fit
// - Hub Bore: 0.394 in (10 mm) H7
// ============================================================================

// Design Parameters
gear_ratio = 100;
tooth_difference = 2;
module_m = 0.4;  // mm (0.0157 in)

// Derived Parameters
z_flex = gear_ratio * tooth_difference;  // 200 teeth
pitch_diameter = z_flex * module_m;       // 80.0 mm (3.150 in)
addendum = 0.8 * module_m;                // 0.32 mm (0.0126 in)

// Flex Spline Reference (for clearance calculation)
flex_outer_diameter = pitch_diameter + (2 * addendum);  // 80.64 mm (3.175 in)
flex_wall_thickness = 0.01 * pitch_diameter;             // 0.8 mm (0.031 in)
flex_inner_diameter = flex_outer_diameter - (2 * flex_wall_thickness);  // 79.04 mm (3.112 in)

// Wave Generator Dimensions (mm with inch equivalents)
radial_deflection = 2.25 * module_m;  // 0.9 mm (0.035 in)
ellipse_major = flex_inner_diameter + (2 * radial_deflection);  // 80.84 mm (3.183 in)
ellipse_minor = flex_inner_diameter - 0.1;  // 78.94 mm (3.108 in) - clearance
cam_width = 0.12 * pitch_diameter;          // 9.6 mm (0.378 in)

// Bearing Dimensions - 6806-2RS
bearing_od = 42.0;     // 42.0 mm (1.654 in)
bearing_id = 30.0;     // 30.0 mm (1.181 in)
bearing_width = 7.0;   // 7.0 mm (0.276 in)

// Hub Dimensions
hub_od = bearing_id - 0.02;  // 29.98 mm (1.181 in) - press fit H7/p6
hub_bore = 10.0;             // 10.0 mm (0.394 in) - motor shaft H7

// Keyway (optional, for motor shaft)
keyway_width = 4.0;   // 4.0 mm (0.157 in)
keyway_depth = 2.0;   // 2.0 mm (0.079 in)

// Resolution
$fn = 200;

// ============================================================================
// MODULES
// ============================================================================

// 2D ellipse for extrusion
module ellipse_2d(major, minor) {
    scale([major/2, minor/2])
    circle(r=1);
}

// 3D elliptical cam profile
module elliptical_cam(major, minor, height) {
    linear_extrude(height=height)
    ellipse_2d(major, minor);
}

// Bearing 6806-2RS representation
module bearing_6806() {
    color("Gold")
    difference() {
        cylinder(h=bearing_width, d=bearing_od, center=false);
        translate([0, 0, -0.5])
        cylinder(h=bearing_width + 1, d=bearing_id, center=false);
    }
}

// Hub with central bore and keyway
module hub_with_bore() {
    difference() {
        // Hub body
        cylinder(h=cam_width, d=hub_od, center=false);

        // Main bore (H7 tolerance)
        translate([0, 0, -0.5])
        cylinder(h=cam_width + 1, d=hub_bore, center=false);

        // Keyway
        translate([-keyway_width/2, hub_bore/2 - keyway_depth, -0.5])
        cube([keyway_width, keyway_depth + 1, cam_width + 1]);
    }
}

// Complete wave generator assembly (with bearing)
module wave_generator_assembly() {
    // Hub (center)
    color("LightGreen")
    hub_with_bore();

    // Bearing (pressed onto hub)
    translate([0, 0, (cam_width - bearing_width) / 2])
    bearing_6806();

    // Elliptical cam sleeve (over bearing)
    color("LightGreen", 0.8)
    difference() {
        // Elliptical outer profile
        elliptical_cam(ellipse_major, ellipse_minor, cam_width);

        // Bearing pocket
        translate([0, 0, (cam_width - bearing_width) / 2 - 0.1])
        cylinder(h=bearing_width + 0.2, d=bearing_od + 0.1, center=false);

        // Hub clearance
        translate([0, 0, -0.5])
        cylinder(h=cam_width + 1, d=hub_od + 0.1, center=false);
    }
}

// Machined wave generator hub only (for manufacturing)
// This is the actual part to be CNC machined
module wave_generator_hub_only() {
    color("LightGreen")
    difference() {
        union() {
            // Hub center (for bearing inner race)
            cylinder(h=cam_width, d=hub_od, center=false);

            // Elliptical cam (outer profile)
            elliptical_cam(ellipse_major, ellipse_minor, cam_width);
        }

        // Main bore (motor shaft, H7)
        translate([0, 0, -0.5])
        cylinder(h=cam_width + 1, d=hub_bore, center=false);

        // Keyway
        translate([-keyway_width/2, hub_bore/2 - keyway_depth, -0.5])
        cube([keyway_width, keyway_depth + 1, cam_width + 1]);

        // Bearing seat (pocket for bearing OD, H7/p6 press fit)
        translate([0, 0, (cam_width - bearing_width) / 2])
        cylinder(h=bearing_width, d=bearing_od + 0.04, center=false);
    }
}

// ============================================================================
// RENDER
// ============================================================================

// Choose which to render:
// Option 1: Full assembly with bearing
// wave_generator_assembly();

// Option 2: Machined part only (for manufacturing)
wave_generator_hub_only();

// ============================================================================
// PARAMETER OUTPUT - inches (mm)
// ============================================================================

echo("=== WAVE GENERATOR PARAMETERS ===");
echo(str("Ellipse Major Axis: 3.183 in (", ellipse_major, " mm)"));
echo(str("Ellipse Minor Axis: 3.108 in (", ellipse_minor, " mm)"));
echo(str("Radial Deflection: 0.035 in (", radial_deflection, " mm)"));
echo(str("Cam Width: 0.378 in (", cam_width, " mm)"));
echo(str("Hub OD: 1.181 in (", hub_od, " mm) - press fit"));
echo(str("Hub Bore: 0.394 in (", hub_bore, " mm) H7"));
echo(str("Keyway Width: 0.157 in (", keyway_width, " mm)"));
echo(str("Keyway Depth: 0.079 in (", keyway_depth, " mm)"));
echo("--- BEARING 6806-2RS ---");
echo(str("Bearing OD: 1.654 in (", bearing_od, " mm)"));
echo(str("Bearing ID: 1.181 in (", bearing_id, " mm)"));
echo(str("Bearing Width: 0.276 in (", bearing_width, " mm)"));
