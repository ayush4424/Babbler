# STEP → mesh → MOOSE static structural

A small ANSYS-like workflow: import a CAD part (STEP), name the faces that are
supported and loaded, mesh it with tetrahedra, solve linear elasticity with
Babbler (MOOSE solid mechanics) and plot von Mises stress on the part.

| File | Purpose |
|---|---|
| `step2mesh.py` | `inspect` a STEP file (faces, areas, positions) and `mesh` it with named boundaries (gmsh) |
| `static_structural.i` | MOOSE input: clamped faces `fixed`, traction on faces `load`, von Mises output |
| `plot_results.py` | Surface plot of a result (`.e`) on the deformed shape |
| `examples/make_plate_with_hole.py` | Builds `plate_with_hole.step`, the validation case below |

Requirements: `pip install gmsh matplotlib netCDF4` (gmsh also needs `libglu1-mesa`
on Ubuntu) and a built `babbler-opt`.

## Workflow

1. **Look at the part** and note which faces are supports and loads:

   ```
   python3 step2mesh.py inspect part.step
   ```

   Every face is listed with its id, type (Plane, Cylinder, ...), area, centroid and
   bounding box. Units are whatever the STEP file uses (usually mm).

2. **Mesh it**, naming the faces. Selectors: `ids:3,7`, `x=min` (faces lying on the
   part's minimum-x plane; also `max`, `y`, `z`), or `box:x0,y0,z0,x1,y1,z1`
   (faces completely inside a box). Combine with `;`. Use `--refine` for smaller
   elements near notches and holes.

   ```
   python3 step2mesh.py mesh part.step -o part.msh --size 5 \
       --boundary fixed "x=min" --boundary load "x=max" --refine "ids:7" 0.6
   ```

   Boundary names must not contain spaces. The default is quadratic tetrahedra
   (TET10); use `--order 1` for TET4, which is much stiffer and underestimates stresses.

3. **Solve.** Give the mesh as an absolute path (MOOSE resolves relative paths
   against the input file's folder) and override material and load as needed:

   ```
   babbler-opt -i static_structural.i mesh_file=$PWD/part.msh E=210e3 nu=0.3 traction=100 \
       Outputs/file_base=$PWD/part
   ```

   For a TET4 mesh also pass `order=FIRST`. Results: `part.e` (open in ParaView) and
   `part.csv` (maximum von Mises and principal stress, maximum displacement, volume).

4. **Plot:**

   ```
   python3 plot_results.py part.e -o part.png --scale 50
   ```

## Validation: plate with a hole

`examples/plate_with_hole.step` is a 200 × 100 × 5 mm plate with a 20 mm hole,
clamped at x = 0 and pulled with 100 MPa at x = 200 (24,682 TET10 elements, about
2 minutes on one core).

| Quantity | Reference | MOOSE |
|---|---|---|
| Peak stress at the hole | 313.5 MPa (Peterson, K_t = 2.51 on net stress 125 MPa) | 319.6 MPa max principal (+1.9 %) |
| Volume | 98,429.2 mm³ (STEP) | 98,429.2 mm³ |

The small excess over Peterson's plane-stress chart is expected: in a plate of
finite thickness the hole stress peaks slightly at mid-thickness.

## Current limits

- One linear elastic, isotropic material; faces are either clamped or carry a normal
  traction. Other supports (rollers, symmetry), forces, bolt loads, contact and
  multiple materials need extra blocks in `static_structural.i`.
- Assemblies with several solids are glued into one conformal mesh (bonded contact).
