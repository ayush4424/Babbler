#!/usr/bin/env python3
"""Quarter of a W x H plate with a central hole of radius R: 2D quad mesh (gmsh).
plate.i extrudes it to a thin 3D slab (plane stress). Boundaries: bottom (y = 0, symmetry),
left (x = 0, symmetry), top (load), right, hole.

  python3 make_mesh.py out.msh [--R 5 --W 40 --H 40 --h_hole 0.25 --h_max 2]
"""
import argparse
import gmsh

p = argparse.ArgumentParser()
p.add_argument("out")
p.add_argument("--R", type=float, default=5.0)
p.add_argument("--W", type=float, default=40.0)
p.add_argument("--H", type=float, default=40.0)
p.add_argument("--h_hole", type=float, default=0.25, help="element size at the hole")
p.add_argument("--h_max", type=float, default=2.0)
p.add_argument("--band_h", type=float, default=0.0,
               help="if > 0: element size in a band along y = 0 (the expected crack path)")
p.add_argument("--band_height", type=float, default=1.0, help="height of that band [mm]")
a = p.parse_args()
R, X, Y = a.R, a.W / 2, a.H / 2

gmsh.initialize()
gmsh.option.setNumber("General.Terminal", 0)
occ = gmsh.model.occ
o = occ.addPoint(0, 0, 0)
p1, p2, p3, p4, p5 = (occ.addPoint(x, y, 0) for x, y in [(R, 0), (X, 0), (X, Y), (0, Y), (0, R)])
lines = {"bottom": occ.addLine(p1, p2), "right": occ.addLine(p2, p3), "top": occ.addLine(p3, p4),
         "left": occ.addLine(p4, p5)}
lines["hole"] = occ.addCircleArc(p5, o, p1)
s = occ.addPlaneSurface([occ.addCurveLoop([lines[k] for k in ("bottom", "right", "top", "left", "hole")])])
occ.synchronize()
gmsh.model.addPhysicalGroup(2, [s], name="plate")
for k, t in lines.items():
    gmsh.model.addPhysicalGroup(1, [t], name=k)

f = gmsh.model.mesh.field
d = f.add("Distance")
f.setNumbers(d, "CurvesList", [lines["hole"]])
f.setNumber(d, "Sampling", 200)
t = f.add("Threshold")
f.setNumber(t, "InField", d)
f.setNumber(t, "SizeMin", a.h_hole)
f.setNumber(t, "SizeMax", a.h_max)
f.setNumber(t, "DistMin", 0.5 * R)
f.setNumber(t, "DistMax", 2.5 * R)
fields = [t]
if a.band_h > 0:
    b = f.add("Box")
    f.setNumber(b, "VIn", a.band_h)
    f.setNumber(b, "VOut", a.h_max)
    f.setNumber(b, "XMin", R - a.band_height)
    f.setNumber(b, "XMax", X)
    f.setNumber(b, "YMin", 0.0)
    f.setNumber(b, "YMax", a.band_height)
    f.setNumber(b, "Thickness", 4 * a.band_height)
    fields.append(b)
fmin = f.add("Min")
f.setNumbers(fmin, "FieldsList", fields)
f.setAsBackgroundMesh(fmin)
gmsh.option.setNumber("Mesh.MeshSizeExtendFromBoundary", 0)
gmsh.option.setNumber("Mesh.MeshSizeFromPoints", 0)
gmsh.option.setNumber("Mesh.RecombineAll", 1)          # quadrilaterals -> hexahedra after extrusion
gmsh.option.setNumber("Mesh.RecombinationAlgorithm", 1)
gmsh.option.setNumber("Mesh.Algorithm", 8)
gmsh.model.mesh.generate(2)
gmsh.option.setNumber("Mesh.MshFileVersion", 4.1)
gmsh.write(a.out)
types, tags, _ = gmsh.model.mesh.getElements(2)
print("%s: %d quads/triangles (types %s)" % (a.out, sum(len(x) for x in tags), list(types)))
gmsh.finalize()
