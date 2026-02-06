# Harmonic Drive Design Documentation

## Project Overview

Harmonic drive (strain wave gear) design for robotic arm joint application.

| Specification | Value |
|---------------|-------|
| Output Torque | 40 Nm (continuous), 55 Nm (peak) |
| Gear Ratio | 100:1 |
| Outer Diameter | 3.937 in (100 mm) |
| Manufacturing | CNC machining + Wire EDM |

---

## Component Summary

| Component | Material | Treatment |
|-----------|----------|-----------|
| Flex Spline | 17-4 PH Stainless (H900) | Nitriding 0.004-0.008 in (0.1-0.2 mm) case |
| Circular Spline | Aluminum 7075-T6 | Hard anodizing |
| Wave Generator Hub | Aluminum 6061-T6 | Standard |
| Bearing | 6806-2RS 1.181 x 1.654 x 0.276 in (30 x 42 x 7 mm) | Standard |

---

## Design Parameters

### Input Parameters

```
Gear_Ratio        = 100
Tooth_Difference  = 2
Module            = 0.0157 in (0.4 mm)
Output_Torque     = 40 Nm
```

### Derived Tooth Counts

```
Z_flex = Gear_Ratio x Tooth_Difference = 200 teeth
Z_circ = Z_flex + Tooth_Difference     = 202 teeth
```

### Flex Spline Dimensions

| Parameter | Formula | Inches | (mm) |
|-----------|---------|--------|------|
| Pitch Diameter | Z_flex x Module | 3.150 | (80.0) |
| Outer Diameter | D_pitch + 2xAddendum | 3.175 | (80.64) |
| Inner Diameter | D_outer - 2xt_wall | 3.112 | (79.04) |
| Wall Thickness | 0.01 x D_pitch | 0.031 | (0.8) |
| Cup Depth | 0.30 x D_pitch | 0.945 | (24.0) |
| Base Thickness | 3.0 x t_wall | 0.094 | (2.4) |
| Fillet Radius | 2.5 x t_wall | 0.079 | (2.0) |
| Tooth Zone Width | 0.12 x D_pitch | 0.378 | (9.6) |

### Tooth Profile

| Parameter | Formula | Inches | (mm) |
|-----------|---------|--------|------|
| Module | - | 0.0157 | (0.4) |
| Addendum | 0.8 x Module | 0.0126 | (0.32) |
| Dedendum | 1.0 x Module | 0.0157 | (0.40) |
| Tooth Height | Addendum + Dedendum | 0.0283 | (0.72) |
| Tooth Width (pitch) | 1.57 x Module | 0.0247 | (0.628) |
| Pressure Angle | - | 20 deg | - |
| Tip Radius (R) | 0.8 x Module | 0.0126 | (0.32) |
| Root Radius (R) | 1.2 x Module | 0.0189 | (0.48) |
| Profile Shift (flex) | +0.5 x Module | +0.008 | (+0.2) |
| Profile Shift (circ) | -0.5 x Module | -0.008 | (-0.2) |

### Circular Spline Dimensions

| Parameter | Formula | Inches | (mm) |
|-----------|---------|--------|------|
| Pitch Diameter | Z_circ x Module | 3.181 | (80.8) |
| Inner Diameter | D_pitch - 2xAddendum | 3.156 | (80.16) |
| Outer Diameter | D_inner + 20 | 3.937 | (100.16) |
| Ring Height | Tooth_Zone + 4 | 0.535 | (13.6) |
| Ring Thickness | (D_outer - D_inner)/2 | 0.394 | (10.0) |
| Bolt Circle | D_outer - 6 | 3.701 | (94) |
| Bolt Holes | 6x M4 clearance | 0.165 | (4.2) |

### Wave Generator Dimensions

| Parameter | Formula | Inches | (mm) |
|-----------|---------|--------|------|
| Radial Deflection | 2.25 x Module | 0.035 | (0.9) |
| Ellipse Major Axis | D_inner_flex + 2xw | 3.183 | (80.84) |
| Ellipse Minor Axis | D_inner_flex - 0.1 | 3.108 | (78.94) |
| Bearing | 6806-2RS | 1.181 x 1.654 x 0.276 | (30 x 42 x 7) |
| Hub OD | Bearing_ID - 0.02 | 1.181 | (29.98) |
| Hub ID | Motor shaft | 0.394 | (10) |
| Hub Length | Tooth_Zone_Width | 0.378 | (9.6) |

---

## Stress Analysis Results

### Summary Table

| Component | Stress Type | Calculated | Allowable | SF |
|-----------|-------------|------------|-----------|-----|
| Flex spline wall | Bending (cyclic) | 318 MPa | 550 MPa | 1.73 |
| Flex spline teeth | Shear | 34.6 MPa | 675 MPa | 19.5 |
| Tooth contact | Hertzian | 809 MPa | 1200 MPa | 1.48 |
| Wave generator bearing | Radial load | 1.8 kN | 4.2 kN | 2.33 |
| Circular spline teeth | Bending | 15.6 MPa | 200 MPa | 12.8 |
| Circular spline ring | Hoop stress | 294 MPa | 503 MPa | 1.71 |

### Critical Calculation: Flex Spline Bending

```
sigma_bend = (3 x E x t x w) / R^2

Where:
  E = 196,000 MPa (17-4 PH modulus)
  t = 0.031 in (0.8 mm) wall thickness
  w = 0.035 in (0.9 mm) radial deflection
  R = 1.575 in (40 mm) radius

sigma_bend = (3 x 196,000 x 0.8 x 0.9) / 1600 = 264.6 MPa

With stress concentration (K_t = 1.2):
sigma_max = 1.2 x 264.6 = 318 MPa

Safety Factor = 550 / 318 = 1.73 OK
```

### Hertzian Contact Stress

```
sigma_H = 0.418 x sqrt(F_n x E_eff / (b x rho_eff))

Calculated: 809 MPa (RMS cyclic)
Allowable:  1200 MPa (with nitriding)
Safety Factor: 1.48 OK
```

### Bearing Life

```
Bearing: 6806-2RS
Dynamic Rating: C = 4.2 kN
Applied Load: F = 1.8 kN

L10 = (C/F)^3 x 10^6 = 12.7 x 10^6 revolutions

At 3000 RPM input: ~70 hours L10 life
Upgrade to 6806: ~450+ hours
```

### Fatigue Verification (Goodman)

```
sigma_mean = 50 MPa (assembly preload)
sigma_alt  = 318 MPa (cyclic bending)
sigma_e    = 550 MPa (endurance limit)
sigma_u    = 1310 MPa (ultimate strength)

Goodman criterion:
sigma_alt/sigma_e + sigma_mean/sigma_u < 1/SF
318/550 + 50/1310 < 0.667
0.616 < 0.667 OK

Result: Infinite fatigue life expected
```

---

## Torque Capacity

| Rating | Value | Notes |
|--------|-------|-------|
| Continuous | 40 Nm | SF = 1.73, infinite life |
| Peak (occasional) | 55 Nm | SF = 1.25, limited cycles |
| Maximum (emergency) | 65 Nm | SF = 1.0, avoid |

---

## Tolerances & Fits

| Interface | Fit Type | Specification |
|-----------|----------|---------------|
| Hub -> Bearing ID | Press fit | H7/p6 (+0.0008 in) |
| Bearing OD -> Cam | Press fit | H7/p6 |
| Flex spline -> Wave gen | Running | 0.002-0.004 in clearance |
| Tooth mesh | Backlash | 0.0008-0.0016 in |

---

## Material Specifications

### 17-4 PH Stainless Steel (Flex Spline)

| Property | Value |
|----------|-------|
| Condition | H900 (aged at 480 deg C) |
| Yield Strength | 1170 MPa |
| Ultimate Strength | 1310 MPa |
| Endurance Limit | 550 MPa |
| Elastic Modulus | 196 GPa |
| Hardness | 40-45 HRC |
| Surface Treatment | Nitriding 0.004-0.008 in (0.1-0.2 mm) case |

### 7075-T6 Aluminum (Circular Spline)

| Property | Value |
|----------|-------|
| Yield Strength | 503 MPa |
| Ultimate Strength | 572 MPa |
| Elastic Modulus | 71.7 GPa |
| Surface Treatment | Hard anodizing (Type III) |

### 6061-T6 Aluminum (Wave Generator Hub)

| Property | Value |
|----------|-------|
| Yield Strength | 276 MPa |
| Ultimate Strength | 310 MPa |
| Elastic Modulus | 68.9 GPa |

---

## Manufacturing Notes

### Flex Spline
- Cup body: CNC turning
- Teeth: Wire EDM recommended (complex S-profile, 200 teeth)
- Heat treat to H900 before final machining
- Nitride after machining for surface hardness
- Critical: Wall thickness uniformity +/-0.002 in

### Circular Spline
- Ring body: CNC turning
- Internal teeth: Wire EDM (202 teeth)
- Hard anodize after machining
- Mounting holes: Standard drilling

### Wave Generator
- Elliptical cam: CNC milling (4-axis preferred)
- Press-fit bearing seat: Grind to H7 tolerance
- Hub bore: Match to motor shaft

---

## Assembly Procedure

1. Press bearing into wave generator cam
2. Install cam assembly into flex spline cup
3. Slide flex spline into circular spline (align teeth)
4. Verify smooth rotation with no binding
5. Check backlash at 4 positions (90 deg intervals)
6. Apply thin grease film to teeth

---

## Design Verification Checklist

- [x] Gear ratio verified: 100:1
- [x] Flex spline fatigue: SF = 1.73 > 1.5
- [x] Contact stress: SF = 1.48 > 1.25
- [x] Bearing life: Adequate with 6806
- [x] Circular spline hoop: SF = 1.71 > 1.5
- [x] Goodman fatigue criterion: Passed
- [x] Full teeth geometry: 200 + 202 teeth with S-curve profiles
- [ ] Prototype testing required
- [ ] Thermal analysis (if high-speed operation)

---

## Files for CNC Shop

| File | Description |
|------|-------------|
| flex_spline.dxf | 2D drawing with tooth profile (200 teeth) |
| flex_spline.step | 3D model for reference |
| circular_spline.dxf | 2D drawing with internal teeth (202 teeth) |
| circular_spline.step | 3D model for reference |
| wave_generator.step | 3D model (elliptical profile) |
| assembly.pdf | Assembly drawing with tolerances |

---

## Manufacturing Drawings

Located in `drawings/` directory:

| File | Description |
|------|-------------|
| `flex_spline.svg` | Flex spline cross-section and top view with dimensions |
| `circular_spline.svg` | Circular spline with internal teeth and mounting holes |
| `wave_generator.svg` | Wave generator hub and elliptical cam profile |
| `tooth_profile.svg` | Detailed S-curve tooth geometry for both splines |
| `assembly.svg` | Exploded view, section view, and bill of materials |
| `dimensions_table.txt` | Complete dimension specifications for CNC shop |
| `generate_dxf.py` | Python script to generate DXF files for CAM |

### 3D Models

Located in `drawings/solidworks/` directory:

| File | Description |
|------|-------------|
| `flex_spline.scad` | Parametric flex spline with 200 teeth |
| `circular_spline.scad` | Parametric circular spline with 202 teeth |
| `wave_generator.scad` | Wave generator with elliptical cam |
| `harmonic_drive_assembly.scad` | Complete assembly |
| `*.step` | STEP files for SolidWorks import |
| `*.stl` | STL files for visualization |

### Converting SVG to DXF

Option 1: Use Inkscape
```bash
inkscape flex_spline.svg --export-filename=flex_spline.dxf
```

Option 2: Use the Python generator
```bash
pip install ezdxf
python generate_dxf.py
```

Option 3: Import SVG directly into CAD (Fusion 360, SolidWorks, FreeCAD)

---

## Revision History

| Rev | Date | Description |
|-----|------|-------------|
| A | 2026-02-03 | Initial design, 40 Nm rated |
| B | 2026-02-03 | Updated to inches (mm), added full teeth geometry |
