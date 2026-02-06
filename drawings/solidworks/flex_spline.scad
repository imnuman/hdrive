// ============================================================================
// FLEX SPLINE - Parametric Model for Harmonic Drive
// Material: 17-4 PH Stainless Steel (H900)
// Export as STL for SolidWorks import
// ============================================================================
// DIMENSIONS: inches (mm)
// - Outer Diameter: 3.175 in (80.64 mm)
// - Inner Diameter: 3.112 in (79.04 mm)
// - Wall Thickness: 0.031 in (0.8 mm) CRITICAL
// - Cup Depth: 0.945 in (24.0 mm)
// - Tooth Zone: 0.378 in (9.6 mm)
// - 200 external teeth, module 0.0157 in (0.4 mm)
// ============================================================================

// Design Parameters
gear_ratio = 100;
tooth_difference = 2;
module_m = 0.4;  // mm (0.0157 in)

// Derived Parameters
z_flex = gear_ratio * tooth_difference;  // 200 teeth
pitch_diameter = z_flex * module_m;       // 80.0 mm (3.150 in)
addendum = 0.8 * module_m;                // 0.32 mm (0.0126 in)
dedendum = 1.0 * module_m;                // 0.40 mm (0.0157 in)
tooth_height = addendum + dedendum;       // 0.72 mm (0.0283 in)

// Flex Spline Dimensions (mm with inch equivalents)
outer_diameter = pitch_diameter + (2 * addendum);  // 80.64 mm (3.175 in)
wall_thickness = 0.01 * pitch_diameter;             // 0.8 mm (0.031 in)
inner_diameter = outer_diameter - (2 * wall_thickness);  // 79.04 mm (3.112 in)
cup_depth = 0.30 * pitch_diameter;                  // 24.0 mm (0.945 in)
base_thickness = 3.0 * wall_thickness;              // 2.4 mm (0.094 in)
fillet_radius = 2.5 * wall_thickness;               // 2.0 mm (0.079 in)
tooth_zone_width = 0.12 * pitch_diameter;           // 9.6 mm (0.378 in)

// Tooth profile radii
tip_radius = 0.8 * module_m;   // 0.32 mm (0.0126 in) - R0.32
root_radius = 1.2 * module_m;  // 0.48 mm (0.0189 in) - R0.48
profile_shift = 0.2;           // +0.2 mm (+0.008 in) positive shift

// Resolution
$fn = 100;

// Number of teeth to render (50 for preview, 200 for production)
render_teeth = 50;

// ============================================================================
// MODULES
// ============================================================================

// Gear tooth profile using polygon rotation
module gear_ring(teeth, pitch_r, tooth_depth, height) {
    tooth_angle = 360 / teeth;

    // Create toothed ring using rotate_extrude with polygon
    points_per_tooth = 6;
    total_points = teeth * points_per_tooth;

    // Generate points for gear profile
    gear_points = [
        for (t = [0:teeth-1])
            let(base_angle = t * tooth_angle)
            each [
                // Root
                [(pitch_r - tooth_depth/2) * cos(base_angle),
                 (pitch_r - tooth_depth/2) * sin(base_angle)],
                // Rising flank
                [(pitch_r - tooth_depth/4) * cos(base_angle + tooth_angle*0.15),
                 (pitch_r - tooth_depth/4) * sin(base_angle + tooth_angle*0.15)],
                // Tip start
                [(pitch_r + tooth_depth/2) * cos(base_angle + tooth_angle*0.3),
                 (pitch_r + tooth_depth/2) * sin(base_angle + tooth_angle*0.3)],
                // Tip end
                [(pitch_r + tooth_depth/2) * cos(base_angle + tooth_angle*0.5),
                 (pitch_r + tooth_depth/2) * sin(base_angle + tooth_angle*0.5)],
                // Falling flank
                [(pitch_r - tooth_depth/4) * cos(base_angle + tooth_angle*0.65),
                 (pitch_r - tooth_depth/4) * sin(base_angle + tooth_angle*0.65)],
                // Root
                [(pitch_r - tooth_depth/2) * cos(base_angle + tooth_angle*0.85),
                 (pitch_r - tooth_depth/2) * sin(base_angle + tooth_angle*0.85)]
            ]
    ];

    linear_extrude(height=height)
    difference() {
        polygon(gear_points);
        circle(r=pitch_r - tooth_depth - wall_thickness, $fn=teeth);
    }
}

// Main flex spline cup module
module flex_spline_cup() {
    pitch_r = pitch_diameter / 2;

    union() {
        // Main cup body (without teeth zone)
        difference() {
            cylinder(h=cup_depth - tooth_zone_width, d=outer_diameter, center=false, $fn=100);
            translate([0, 0, base_thickness])
            cylinder(h=cup_depth, d=inner_diameter, center=false, $fn=100);
        }

        // External teeth using gear_ring
        translate([0, 0, cup_depth - tooth_zone_width])
        gear_ring(
            teeth = render_teeth,
            pitch_r = pitch_r,
            tooth_depth = tooth_height,
            height = tooth_zone_width
        );
    }
}

// ============================================================================
// RENDER
// ============================================================================

// Render the flex spline
color("Silver")
flex_spline_cup();

// ============================================================================
// PARAMETER OUTPUT - inches (mm)
// ============================================================================

echo("=== FLEX SPLINE PARAMETERS ===");
echo(str("Number of Teeth: ", z_flex, " (rendering ", render_teeth, " for preview)"));
echo(str("Module: 0.0157 in (", module_m, " mm)"));
echo(str("Pitch Diameter: 3.150 in (", pitch_diameter, " mm)"));
echo(str("Outer Diameter: 3.175 in (", outer_diameter, " mm)"));
echo(str("Inner Diameter: 3.112 in (", inner_diameter, " mm)"));
echo(str("Wall Thickness: 0.031 in (", wall_thickness, " mm) CRITICAL"));
echo(str("Cup Depth: 0.945 in (", cup_depth, " mm)"));
echo(str("Base Thickness: 0.094 in (", base_thickness, " mm)"));
echo(str("Tooth Zone: 0.378 in (", tooth_zone_width, " mm)"));
