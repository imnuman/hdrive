# Harmonic Drive - SolidWorks Files

## Quick Start

### Option 1: Import STEP Files (Recommended)
1. Install OpenSCAD: https://openscad.org/downloads.html
2. Open `harmonic_drive_assembly.scad`
3. Render (F6) then Export as STEP (File > Export > Export as STL, then use FreeCAD to convert)
4. Import STEP into SolidWorks

### Option 2: Use FreeCAD to Generate STEP
1. Install FreeCAD: https://www.freecad.org/downloads.php
2. Run `python generate_step.py` (requires FreeCAD Python bindings)
3. Import generated STEP files into SolidWorks

### Option 3: Run SolidWorks Macros
1. Copy macro files to SolidWorks
2. Tools > Macro > Run
3. Select the .swp file

---

## File List

| File | Description |
|------|-------------|
| `flex_spline.scad` | Parametric flex spline (OpenSCAD) |
| `circular_spline.scad` | Parametric circular spline (OpenSCAD) |
| `wave_generator.scad` | Parametric wave generator (OpenSCAD) |
| `harmonic_drive_assembly.scad` | Complete assembly (OpenSCAD) |
| `FlexSpline_Macro.swp` | SolidWorks VBA macro |
| `generate_step.py` | Python STEP generator |

---

## Design Parameters

All models use these parameters (modify in source files):

```
Gear Ratio:        100:1
Tooth Difference:  2
Module:            0.4 mm
Output Torque:     40 Nm
```

### Calculated Dimensions

**Flex Spline:**
- Number of Teeth: 200
- Pitch Diameter: 80.00 mm
- Outer Diameter: 80.64 mm
- Inner Diameter: 79.04 mm
- Wall Thickness: 0.80 mm
- Cup Depth: 24.0 mm

**Circular Spline:**
- Number of Teeth: 202
- Pitch Diameter: 80.80 mm
- Inner Diameter: 80.16 mm
- Outer Diameter: 100.0 mm
- Ring Height: 13.6 mm

**Wave Generator:**
- Ellipse Major: 80.84 mm
- Ellipse Minor: 78.94 mm
- Width: 9.6 mm
- Bearing: 6806-2RS (30×42×7)

---

## Converting OpenSCAD to STEP

### Using FreeCAD (Free)

1. Export from OpenSCAD as STL
2. Open FreeCAD
3. File > Import > Select STL
4. Select imported mesh
5. Part > Convert to Solid
6. File > Export > STEP

### Using OpenSCAD + Meshlab + FreeCAD

```bash
# 1. Export STL from OpenSCAD
openscad -o flex_spline.stl flex_spline.scad

# 2. Import to FreeCAD and convert
freecad flex_spline.stl -e flex_spline.step
```

### Using Online Converters

- https://www.makexyz.com/convert/stl-to-step
- https://www.convertio.co/stl-step/

---

## SolidWorks Import Tips

1. **STEP Import Settings:**
   - File > Open > Select STEP file
   - Options > "Import as solid bodies"
   - Check "Run Import Diagnostics"

2. **After Import:**
   - Use "Import Diagnostics" to heal any gaps
   - Assign materials from library
   - Add dimensions as reference

3. **Creating Native Features:**
   - Use imported geometry as reference
   - Create new sketches on imported faces
   - Rebuild features if needed for parametric control

---

## Materials

Configure in SolidWorks:

| Part | Material | SolidWorks Material |
|------|----------|---------------------|
| Flex Spline | 17-4 PH SS | "17-4PH stainless steel" |
| Circular Spline | 7075-T6 | "7075 Alloy" |
| Wave Generator | 6061-T6 | "6061 Alloy" |

---

## Tolerances

Add these as annotations in SolidWorks:

| Dimension | Tolerance |
|-----------|-----------|
| Flex spline OD | ±0.02 mm |
| Flex spline wall | ±0.05 mm |
| Circular spline ID | ±0.02 mm |
| Wave generator major | ±0.02 mm |
| Wave generator minor | ±0.02 mm |
| Bearing seat | H7 (+0.000/+0.025) |
| Hub bore | H7 (+0.000/+0.015) |
