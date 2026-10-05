#!/usr/bin/env python3
"""Quarter of a W x H plate with a central hole of radius R (gmsh, 2D triangles).

Symmetry: x = 0 (boundary `left`) and y = 0 (boundary `bottom`, the ligament where the
crack grows). Load on `top`. Elements of size h_crack in a band along y = 0 from the hole
edge outwards (the crack path), graded to h_max far away.

  python3 make_mesh.py R l out.msh [--W 40 --H 40 --band 3.0]
"""
import argparse
import gmsh

p = argparse.ArgumentParser()
p.add_argument("R", type=float, help="hole radius [mm]")
p.add_argument("l", type=float, help="phase-field length scale [mm]")
p.add_argument("out")
p.add_argument("--W", type=float, default=40.0, help="plate width [mm]")
p.add_argument("--H", type=float, default=40.0, help="plate height [mm]")
p.add_argument("--band", type=float, default=3.0, help="length of the refined crack band beyond the hole [mm]")
p.add_argument("--elems_per_l", type=float, default=4.0, help="element size in the band = l / this")
a = p.parse_args()

R, l, X, Y = a.R, a.l, a.W / 2, a.H / 2
h = l / a.elems_per_l
hmax = min(X, Y) / 20.0

gmsh.initialize()
gmsh.option.setNumber("General.Terminal", 0)
gmsh.model.add("quarter_plate_hole")
occ = gmsh.model.occ
o = occ.addPoint(0, 0, 0)
p1, p2, p3, p4, p5 = (occ.addPoint(*c, 0) for c in [(R, 0), (X, 0), (X, Y), (0, Y), (0, R)])
bottom = occ.addLine(p1, p2)
right = occ.addLine(p2, p3)
top = occ.addLine(p3, p4)
left = occ.addLine(p4, p5)
hole = occ.addCircleArc(p5, o, p1)
loop = occ.addCurveLoop([bottom, right, top, left, hole])
surf = occ.addPlaneSurface([loop])
occ.synchronize()

for dim, tags, name in [(2, [surf], "plate"), (1, [bottom], "bottom"), (1, [right], "right"),
                        (1, [top], "top"), (1, [left], "left"), (1, [hole], "hole")]:
    gmsh.model.addPhysicalGroup(dim, tags, name=name)

f = gmsh.model.mesh.field
box = f.add("Box")
f.setNumber(box, "VIn", h)
f.setNumber(box, "VOut", hmax)
f.setNumber(box, "XMin", max(0.0, R - 3 * l))
f.setNumber(box, "XMax", R + a.band)
f.setNumber(box, "YMin", 0.0)
f.setNumber(box, "YMax", 4 * l)
f.setNumber(box, "Thickness", 20 * l)
dist = f.add("Distance")
f.setNumbers(dist, "CurvesList", [hole])
f.setNumber(dist, "Sampling", 200)
thr = f.add("Threshold")
f.setNumber(thr, "InField", dist)
f.setNumber(thr, "SizeMin", min(hmax, max(h, R / 10.0)))
f.setNumber(thr, "SizeMax", hmax)
f.setNumber(thr, "DistMin", R / 5.0)
f.setNumber(thr, "DistMax", R + 2.0)
fmin = f.add("Min")
f.setNumbers(fmin, "FieldsList", [box, thr])
f.setAsBackgroundMesh(fmin)
gmsh.option.setNumber("Mesh.MeshSizeExtendFromBoundary", 0)
gmsh.option.setNumber("Mesh.MeshSizeFromPoints", 0)
gmsh.option.setNumber("Mesh.MeshSizeFromCurvature", 0)
gmsh.option.setNumber("Mesh.Algorithm", 6)
gmsh.model.mesh.generate(2)
gmsh.option.setNumber("Mesh.MshFileVersion", 4.1)
gmsh.write(a.out)
n = sum(len(t) for t in gmsh.model.mesh.getElements(2)[1])
print("%s: R=%g l=%g h=%.4g hmax=%.3g -> %d triangles" % (a.out, R, l, h, hmax, n))
gmsh.finalize()
