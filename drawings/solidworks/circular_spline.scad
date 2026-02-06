// ============================================================================
// CIRCULAR SPLINE - Parametric Model for Harmonic Drive
// Material: Aluminum 7075-T6
// Export as STL for SolidWorks import
// ============================================================================
// DIMENSIONS: inches (mm)
// - Outer Diameter: 3.937 in (100.0 mm)
// - Inner Diameter (at teeth): 3.156 in (80.16 mm)
// - Pitch Diameter: 3.181 in (80.8 mm)
// - Ring Height: 0.535 in (13.6 mm)
// - 202 internal teeth, module 0.0157 in (0.4 mm)
// - 6x M4 holes on 3.701 in (94 mm) bolt circle
// ============================================================================

// Design Parameters
gear_ratio = 100;
tooth_difference = 2;
module_m = 0.4;  // mm (0.0157 in)

// Derived Parameters
z_flex = gear_ratio * tooth_difference;  // 200 teeth
z_circ = z_flex + tooth_difference;      // 202 teeth
pitch_diameter = z_circ * module_m;       // 80.8 mm (3.181 in)
addendum = 0.8 * module_m;
dedendum = 1.0 * module_m;
tooth_height = addendum + dedendum;

// Circular Spline Dimensions
inner_diameter = pitch_diameter - (2 * addendum);  // 80.16 mm
outer_diameter = 100.0;                             // 100.0 mm
ring_height = 13.6;                                 // 13.6 mm

// Mounting Holes
bolt_circle = 94.0;
num_holes = 6;
hole_diameter = 4.2;

// Resolution
$fn = 100;

// Number of teeth to render (51 for preview to show internal, 202 for production)
render_teeth = 51;

// ============================================================================
// MODULES
// ============================================================================

// Internal gear tooth profile using polygon
module internal_gear_ring(teeth, pitch_r, tooth_depth, height) {
    tooth_angle = 360 / teeth;

    // Generate points for internal gear profile
    gear_points = [
        for (t = [0:teeth-1])
            let(base_angle = t * tooth_angle)
            each [
                // Tip (innermost)
                [(pitch_r - tooth_depth/2) * cos(base_angle),
                 (pitch_r - tooth_depth/2) * sin(base_angle)],
                // Rising flank
                [(pitch_r - tooth_depth/4) * cos(base_angle + tooth_angle*0.15),
                 (pitch_r - tooth_depth/4) * sin(base_angle + tooth_angle*0.15)],
                // Root start
                [(pitch_r + tooth_depth/2) * cos(base_angle + tooth_angle*0.3),
                 (pitch_r + tooth_depth/2) * sin(base_angle + tooth_angle*0.3)],
                // Root end
                [(pitch_r + tooth_depth/2) * cos(base_angle + tooth_angle*0.5),
                 (pitch_r + tooth_depth/2) * sin(base_angle + tooth_angle*0.5)],
                // Falling flank
                [(pitch_r - tooth_depth/4) * cos(base_angle + tooth_angle*0.65),
                 (pitch_r - tooth_depth/4) * sin(base_angle + tooth_angle*0.65)],
                // Tip
                [(pitch_r - tooth_depth/2) * cos(base_angle + tooth_angle*0.85),
                 (pitch_r - tooth_depth/2) * sin(base_angle + tooth_angle*0.85)]
            ]
    ];

    linear_extrude(height=height)
    difference() {
        circle(d=outer_diameter, $fn=100);
        polygon(gear_points);
    }
}

// Main circular spline ring module
module circular_spline_ring() {
    pitch_r = pitch_diameter / 2;

    difference() {
        // Ring with internal teeth
        internal_gear_ring(
            teeth = render_teeth,
            pitch_r = pitch_r,
            tooth_depth = tooth_height,
            height = ring_height
        );

        // Mounting holes (6x M4 clearance on bolt circle)
        for (i = [0:num_holes-1]) {
            rotate([0, 0, i * 360 / num_holes])
            translate([bolt_circle/2, 0, -1])
            cylinder(h=ring_height + 2, d=hole_diameter, center=false, $fn=20);
        }
    }
}

// ============================================================================
// RENDER
// ============================================================================

// Render the circular spline
color("LightBlue")
circular_spline_ring();

// ============================================================================
// PARAMETER OUTPUT - inches (mm)
// ============================================================================

echo("=== CIRCULAR SPLINE PARAMETERS ===");
echo(str("Number of Teeth: ", z_circ, " (rendering ", render_teeth, " for preview)"));
echo(str("Module: 0.0157 in (", module_m, " mm)"));
echo(str("Pitch Diameter: 3.181 in (", pitch_diameter, " mm)"));
echo(str("Inner Diameter: 3.156 in (", inner_diameter, " mm)"));
echo(str("Outer Diameter: 3.937 in (", outer_diameter, " mm)"));
echo(str("Ring Height: 0.535 in (", ring_height, " mm)"));
echo(str("Bolt Circle: 3.701 in (", bolt_circle, " mm)"));
