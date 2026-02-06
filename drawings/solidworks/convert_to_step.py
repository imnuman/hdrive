#!/usr/bin/env python3
"""
Convert STL to STEP using Open CASCADE via gmsh
This creates a brep/step approximation from mesh
"""
import subprocess
import os

def stl_to_step_gmsh(stl_file, step_file):
    """Convert STL to STEP using gmsh"""
    geo_content = f'''
Merge "{stl_file}";
Surface Loop(1) = {{1}};
Volume(1) = {{1}};
'''
    geo_file = stl_file.replace('.stl', '.geo')
    
    with open(geo_file, 'w') as f:
        f.write(geo_content)
    
    # Try conversion
    cmd = ['gmsh', '-3', '-format', 'step', '-o', step_file, geo_file]
    result = subprocess.run(cmd, capture_output=True, text=True)
    
    if os.path.exists(step_file):
        print(f"  Created: {step_file}")
        return True
    else:
        print(f"  Failed: {stl_file} - {result.stderr[:100]}")
        return False

# List of files to convert
files = [
    ('flex_spline.stl', 'flex_spline.step'),
    ('circular_spline.stl', 'circular_spline.step'),
    ('wave_generator.stl', 'wave_generator.step'),
    ('harmonic_drive_assembly.stl', 'harmonic_drive_assembly.step'),
]

print("Converting STL to STEP...")
for stl, step in files:
    if os.path.exists(stl):
        stl_to_step_gmsh(stl, step)
    else:
        print(f"  Not found: {stl}")

print("\nDone!")
