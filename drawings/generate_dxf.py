#!/usr/bin/env python3
"""
Harmonic Drive DXF Generator
Generates 2D profiles for CNC machining / Wire EDM

Requirements: pip install ezdxf

Usage: python generate_dxf.py
"""

import math

try:
    import ezdxf
    from ezdxf import units
    HAS_EZDXF = True
except ImportError:
    HAS_EZDXF = False
    print("Note: Install ezdxf for DXF output: pip install ezdxf")
    print("Generating coordinate files instead...")

# =============================================================================
#                           DESIGN PARAMETERS
# =============================================================================

# Input parameters
GEAR_RATIO = 100
TOOTH_DIFFERENCE = 2
MODULE = 0.4  # mm
OUTPUT_TORQUE = 40  # Nm

# Derived parameters
Z_FLEX = GEAR_RATIO * TOOTH_DIFFERENCE  # 200 teeth
Z_CIRC = Z_FLEX + TOOTH_DIFFERENCE       # 202 teeth

# Pitch diameters
D_PITCH_FLEX = Z_FLEX * MODULE  # 80.0 mm
D_PITCH_CIRC = Z_CIRC * MODULE  # 80.8 mm

# Tooth geometry
ADDENDUM = 0.8 * MODULE      # 0.32 mm
DEDENDUM = 1.0 * MODULE      # 0.40 mm
TOOTH_HEIGHT = ADDENDUM + DEDENDUM
PRESSURE_ANGLE = math.radians(20)

# Flex spline
D_OUTER_FLEX = D_PITCH_FLEX + (2 * ADDENDUM)  # 80.64 mm
T_WALL = 0.01 * D_PITCH_FLEX                   # 0.8 mm
D_INNER_FLEX = D_OUTER_FLEX - (2 * T_WALL)    # 79.04 mm
CUP_DEPTH = 0.30 * D_PITCH_FLEX               # 24.0 mm
BASE_THICKNESS = 3.0 * T_WALL                  # 2.4 mm
FILLET_RADIUS = 2.5 * T_WALL                   # 2.0 mm
TOOTH_ZONE_WIDTH = 0.12 * D_PITCH_FLEX        # 9.6 mm

# Circular spline
D_INNER_CIRC = D_PITCH_CIRC - (2 * ADDENDUM)  # 80.16 mm
D_OUTER_CIRC = 100.0  # mm
RING_HEIGHT = TOOTH_ZONE_WIDTH + 4             # 13.6 mm
BOLT_CIRCLE = 94.0
BOLT_HOLES = 6
BOLT_HOLE_DIA = 4.2  # M4 clearance

# Wave generator
RADIAL_DEFLECTION = 2.25 * MODULE             # 0.9 mm
ELLIPSE_MAJOR = D_INNER_FLEX + (2 * RADIAL_DEFLECTION)  # 80.84 mm
ELLIPSE_MINOR = D_INNER_FLEX - 0.1                       # 78.94 mm
BEARING_OD = 42.0
BEARING_ID = 30.0
HUB_BORE = 10.0


def generate_tooth_profile(num_points=20):
    """
    Generate S-curve tooth profile points.
    Returns list of (x, y) tuples for one tooth centered at origin.
    """
    points = []
    circular_pitch = math.pi * MODULE
    tooth_width_at_pitch = circular_pitch / 2

    # Generate S-curve profile (simplified double-arc)
    for i in range(num_points + 1):
        t = i / num_points  # 0 to 1

        # X position along tooth (from -pitch/2 to +pitch/2)
        x = (t - 0.5) * circular_pitch

        # Y position (S-curve from dedendum to addendum)
        # Using sine wave approximation
        if t < 0.5:
            # Rising portion
            angle = math.pi * (t / 0.5)
            y = -DEDENDUM + (DEDENDUM + ADDENDUM) * (1 - math.cos(angle)) / 2
        else:
            # Falling portion
            angle = math.pi * ((t - 0.5) / 0.5)
            y = ADDENDUM - (DEDENDUM + ADDENDUM) * (1 - math.cos(angle)) / 2

        points.append((x, y))

    return points


def generate_flex_spline_teeth(num_teeth=None, num_points_per_tooth=20):
    """
    Generate complete flex spline external tooth profile.
    Returns list of (x, y) tuples on the pitch circle.
    """
    if num_teeth is None:
        num_teeth = Z_FLEX

    points = []
    radius = D_PITCH_FLEX / 2
    tooth_profile = generate_tooth_profile(num_points_per_tooth)

    for tooth in range(num_teeth):
        angle_offset = (2 * math.pi * tooth) / num_teeth

        for px, py in tooth_profile:
            # Convert tooth profile to polar, add to radius
            tooth_angle = px / radius
            total_angle = angle_offset + tooth_angle
            r = radius + py

            x = r * math.cos(total_angle)
            y = r * math.sin(total_angle)
            points.append((x, y))

    return points


def generate_circular_spline_teeth(num_teeth=None, num_points_per_tooth=20):
    """
    Generate complete circular spline internal tooth profile.
    Returns list of (x, y) tuples.
    """
    if num_teeth is None:
        num_teeth = Z_CIRC

    points = []
    radius = D_PITCH_CIRC / 2
    tooth_profile = generate_tooth_profile(num_points_per_tooth)

    for tooth in range(num_teeth):
        angle_offset = (2 * math.pi * tooth) / num_teeth

        for px, py in tooth_profile:
            # For internal teeth, invert the profile
            tooth_angle = px / radius
            total_angle = angle_offset + tooth_angle
            r = radius - py  # Subtract for internal teeth

            x = r * math.cos(total_angle)
            y = r * math.sin(total_angle)
            points.append((x, y))

    return points


def generate_ellipse(major_axis, minor_axis, num_points=360):
    """Generate ellipse points."""
    points = []
    a = major_axis / 2
    b = minor_axis / 2

    for i in range(num_points):
        angle = (2 * math.pi * i) / num_points
        x = a * math.cos(angle)
        y = b * math.sin(angle)
        points.append((x, y))

    points.append(points[0])  # Close the ellipse
    return points


def generate_circle(diameter, num_points=360):
    """Generate circle points."""
    points = []
    r = diameter / 2

    for i in range(num_points):
        angle = (2 * math.pi * i) / num_points
        x = r * math.cos(angle)
        y = r * math.sin(angle)
        points.append((x, y))

    points.append(points[0])  # Close the circle
    return points


def save_coordinates(filename, points, description):
    """Save points to a text file for manual CAD import."""
    with open(filename, 'w') as f:
        f.write(f"# {description}\n")
        f.write(f"# {len(points)} points\n")
        f.write("# X, Y\n")
        for x, y in points:
            f.write(f"{x:.6f}, {y:.6f}\n")
    print(f"Saved: {filename}")


def create_dxf_files():
    """Create DXF files for each component."""
    if not HAS_EZDXF:
        print("ezdxf not available, creating coordinate files instead")
        create_coordinate_files()
        return

    # Flex Spline
    print("Generating flex_spline.dxf...")
    doc = ezdxf.new('R2010')
    doc.units = units.MM
    msp = doc.modelspace()

    # External teeth profile
    teeth_points = generate_flex_spline_teeth()
    msp.add_lwpolyline(teeth_points, close=True, dxfattribs={'layer': 'TEETH'})

    # Inner diameter circle
    msp.add_circle((0, 0), D_INNER_FLEX / 2, dxfattribs={'layer': 'INNER'})

    doc.saveas('flex_spline.dxf')
    print("  Created: flex_spline.dxf")

    # Circular Spline
    print("Generating circular_spline.dxf...")
    doc = ezdxf.new('R2010')
    doc.units = units.MM
    msp = doc.modelspace()

    # Outer diameter
    msp.add_circle((0, 0), D_OUTER_CIRC / 2, dxfattribs={'layer': 'OUTER'})

    # Internal teeth profile
    teeth_points = generate_circular_spline_teeth()
    msp.add_lwpolyline(teeth_points, close=True, dxfattribs={'layer': 'TEETH'})

    # Bolt holes
    for i in range(BOLT_HOLES):
        angle = (2 * math.pi * i) / BOLT_HOLES
        x = (BOLT_CIRCLE / 2) * math.cos(angle)
        y = (BOLT_CIRCLE / 2) * math.sin(angle)
        msp.add_circle((x, y), BOLT_HOLE_DIA / 2, dxfattribs={'layer': 'HOLES'})

    doc.saveas('circular_spline.dxf')
    print("  Created: circular_spline.dxf")

    # Wave Generator
    print("Generating wave_generator.dxf...")
    doc = ezdxf.new('R2010')
    doc.units = units.MM
    msp = doc.modelspace()

    # Elliptical cam profile
    ellipse_points = generate_ellipse(ELLIPSE_MAJOR, ELLIPSE_MINOR)
    msp.add_lwpolyline(ellipse_points, close=True, dxfattribs={'layer': 'CAM'})

    # Bearing seat
    msp.add_circle((0, 0), BEARING_OD / 2, dxfattribs={'layer': 'BEARING'})

    # Hub
    msp.add_circle((0, 0), BEARING_ID / 2, dxfattribs={'layer': 'HUB'})

    # Bore
    msp.add_circle((0, 0), HUB_BORE / 2, dxfattribs={'layer': 'BORE'})

    doc.saveas('wave_generator.dxf')
    print("  Created: wave_generator.dxf")

    print("\nDXF files generated successfully!")


def create_coordinate_files():
    """Create coordinate text files for manual import."""
    print("\nGenerating coordinate files...")

    # Flex spline teeth
    teeth_points = generate_flex_spline_teeth(num_points_per_tooth=10)
    save_coordinates(
        'flex_spline_teeth.csv',
        teeth_points,
        f'Flex Spline External Teeth - {Z_FLEX} teeth, m={MODULE}'
    )

    # Circular spline teeth
    teeth_points = generate_circular_spline_teeth(num_points_per_tooth=10)
    save_coordinates(
        'circular_spline_teeth.csv',
        teeth_points,
        f'Circular Spline Internal Teeth - {Z_CIRC} teeth, m={MODULE}'
    )

    # Wave generator ellipse
    ellipse_points = generate_ellipse(ELLIPSE_MAJOR, ELLIPSE_MINOR)
    save_coordinates(
        'wave_generator_ellipse.csv',
        ellipse_points,
        f'Wave Generator Ellipse - Major={ELLIPSE_MAJOR}, Minor={ELLIPSE_MINOR}'
    )

    # Single tooth profile (for detail)
    tooth_points = generate_tooth_profile(50)
    save_coordinates(
        'single_tooth_profile.csv',
        tooth_points,
        f'Single Tooth S-Curve Profile - m={MODULE}'
    )

    print("\nCoordinate files generated!")
    print("Import these into your CAD software as spline curves.")


def print_parameters():
    """Print all calculated parameters."""
    print("=" * 60)
    print("HARMONIC DRIVE PARAMETERS")
    print("=" * 60)
    print(f"\nGear Ratio: {GEAR_RATIO}:1")
    print(f"Output Torque: {OUTPUT_TORQUE} Nm")
    print(f"\nFLEX SPLINE:")
    print(f"  Number of Teeth: {Z_FLEX}")
    print(f"  Module: {MODULE} mm")
    print(f"  Pitch Diameter: {D_PITCH_FLEX:.2f} mm")
    print(f"  Outer Diameter: {D_OUTER_FLEX:.2f} mm")
    print(f"  Inner Diameter: {D_INNER_FLEX:.2f} mm")
    print(f"  Wall Thickness: {T_WALL:.2f} mm")
    print(f"  Cup Depth: {CUP_DEPTH:.1f} mm")
    print(f"\nCIRCULAR SPLINE:")
    print(f"  Number of Teeth: {Z_CIRC}")
    print(f"  Pitch Diameter: {D_PITCH_CIRC:.2f} mm")
    print(f"  Inner Diameter: {D_INNER_CIRC:.2f} mm")
    print(f"  Outer Diameter: {D_OUTER_CIRC:.1f} mm")
    print(f"\nWAVE GENERATOR:")
    print(f"  Ellipse Major Axis: {ELLIPSE_MAJOR:.2f} mm")
    print(f"  Ellipse Minor Axis: {ELLIPSE_MINOR:.2f} mm")
    print(f"  Radial Deflection: {RADIAL_DEFLECTION:.2f} mm")
    print(f"  Bearing: 6806-2RS ({BEARING_ID}x{BEARING_OD}x7 mm)")
    print("=" * 60)


if __name__ == '__main__':
    print_parameters()
    print()

    if HAS_EZDXF:
        create_dxf_files()
    else:
        create_coordinate_files()

    print("\nTo generate DXF files, install ezdxf:")
    print("  pip install ezdxf")
