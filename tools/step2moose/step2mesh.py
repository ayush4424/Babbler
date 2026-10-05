#!/usr/bin/env python3
"""STEP -> gmsh mesh with named boundaries, ready for a MOOSE static structural run.

Two sub-commands:

  inspect  List the solids and faces in a STEP file (id, area, centroid, bounding
           box) so you can decide which faces are supports and which carry loads.

  mesh     Mesh the solid with tetrahedra and write a .msh file in which the chosen
           faces are named boundaries (physical groups) that MOOSE can refer to.

Faces are chosen with selectors (several can be combined with ';'):
  ids:3,7,12          face ids as printed by `inspect`
  x=min / y=max ...   faces lying flat on the part's minimum/maximum x, y or z plane
  box:x0,y0,z0,x1,y1,z1
                      faces whose bounding box lies completely inside this box

Boundary names must not contain spaces (MOOSE splits names on spaces).

Examples:
  python3 step2mesh.py inspect part.step
  python3 step2mesh.py mesh part.step -o part.msh --size 4 \
      --boundary fixed "x=min" --boundary load "x=max" \
      --refine "box:90,40,-1,110,60,6" 0.8
"""

import argparse
import math
import re
import sys

import gmsh


def load_step(path, scale):
    gmsh.initialize()
    gmsh.option.setNumber("General.Terminal", 0)
    gmsh.option.setNumber("Geometry.OCCScaling", scale)
    gmsh.model.add("part")
    gmsh.model.occ.importShapes(path)
    gmsh.model.occ.synchronize()
    vols = gmsh.model.getEntities(3)
    if not vols:
        sys.exit("No solid (volume) found in %s; is it a surface-only STEP?" % path)
    if len(vols) > 1:
        # Glue touching solids so they share faces and nodes (conformal mesh).
        gmsh.model.occ.fragment(vols, [])
        gmsh.model.occ.synchronize()
    return gmsh.model.getEntities(3)


def face_info(tag):
    bb = gmsh.model.getBoundingBox(2, tag)
    area = gmsh.model.occ.getMass(2, tag)
    c = gmsh.model.occ.getCenterOfMass(2, tag)
    kind = gmsh.model.getType(2, tag)
    return {"id": tag, "area": area, "centroid": c, "bbox": bb, "type": kind}


def part_bbox():
    return gmsh.model.getBoundingBox(-1, -1)


def select_faces(selector):
    """Return the set of face ids matched by a selector string."""
    faces = [t for _, t in gmsh.model.getEntities(2)]
    pb = part_bbox()
    span = max(pb[3] - pb[0], pb[4] - pb[1], pb[5] - pb[2])
    tol = 1e-6 * span
    chosen = set()
    for sel in [s.strip() for s in selector.split(";") if s.strip()]:
        if sel.startswith("ids:"):
            chosen |= {int(v) for v in sel[4:].split(",") if v.strip()}
            continue
        m = re.fullmatch(r"([xyz])\s*=\s*(min|max)", sel)
        if m:
            ax = "xyz".index(m.group(1))
            target = pb[ax] if m.group(2) == "min" else pb[ax + 3]
            for t in faces:
                bb = gmsh.model.getBoundingBox(2, t)
                if abs(bb[ax] - target) < tol and abs(bb[ax + 3] - target) < tol:
                    chosen.add(t)
            continue
        if sel.startswith("box:"):
            b = [float(v) for v in sel[4:].split(",")]
            if len(b) != 6:
                sys.exit("box selector needs 6 numbers: %s" % sel)
            for t in faces:
                bb = gmsh.model.getBoundingBox(2, t)
                if all(b[i] - tol <= bb[i] and bb[i + 3] <= b[i + 3] + tol for i in range(3)):
                    chosen.add(t)
            continue
        sys.exit("Unknown selector '%s'" % sel)
    missing = chosen - set(faces)
    if missing:
        sys.exit("Face ids %s do not exist (run `inspect`)" % sorted(missing))
    return chosen


def cmd_inspect(a):
    vols = load_step(a.step, a.scale)
    pb = part_bbox()
    print("Part bounding box: x [%.4g, %.4g]  y [%.4g, %.4g]  z [%.4g, %.4g]"
          % (pb[0], pb[3], pb[1], pb[4], pb[2], pb[5]))
    for _, v in vols:
        print("Solid %d: volume %.6g" % (v, gmsh.model.occ.getMass(3, v)))
    print("\n%5s %-10s %12s   %-32s %s" % ("face", "type", "area", "centroid", "bounding box"))
    for _, t in gmsh.model.getEntities(2):
        f = face_info(t)
        c, bb = f["centroid"], f["bbox"]
        print("%5d %-10s %12.5g   (%9.4g,%9.4g,%9.4g)   [%.4g..%.4g, %.4g..%.4g, %.4g..%.4g]"
              % (t, f["type"], f["area"], c[0], c[1], c[2], bb[0], bb[3], bb[1], bb[4], bb[2], bb[5]))
    gmsh.finalize()


def cmd_mesh(a):
    vols = load_step(a.step, a.scale)
    named = []
    used = set()
    for name, sel in a.boundary:
        if " " in name:
            sys.exit("Boundary name '%s' contains a space; MOOSE would split it" % name)
        ids = select_faces(sel)
        if not ids:
            sys.exit("Selector '%s' for boundary '%s' matched no faces" % (sel, name))
        if ids & used:
            print("warning: faces %s are in more than one boundary" % sorted(ids & used))
        used |= ids
        named.append((name, sorted(ids)))

    gmsh.model.addPhysicalGroup(3, [v for _, v in vols], name=a.block)
    for name, ids in named:
        gmsh.model.addPhysicalGroup(2, ids, name=name)

    gmsh.option.setNumber("Mesh.MeshSizeMax", a.size)
    gmsh.option.setNumber("Mesh.MeshSizeMin", a.size / 20.0)
    gmsh.option.setNumber("Mesh.MeshSizeFromCurvature", a.curvature)

    fields = []
    for sel, h in a.refine:
        ids = sorted(select_faces(sel))
        dist = gmsh.model.mesh.field.add("Distance")
        gmsh.model.mesh.field.setNumbers(dist, "SurfacesList", ids)
        thr = gmsh.model.mesh.field.add("Threshold")
        gmsh.model.mesh.field.setNumber(thr, "InField", dist)
        gmsh.model.mesh.field.setNumber(thr, "SizeMin", float(h))
        gmsh.model.mesh.field.setNumber(thr, "SizeMax", a.size)
        gmsh.model.mesh.field.setNumber(thr, "DistMin", 2.0 * float(h))
        gmsh.model.mesh.field.setNumber(thr, "DistMax", 2.0 * float(h) + 4.0 * a.size)
        fields.append(thr)
    if fields:
        fmin = gmsh.model.mesh.field.add("Min")
        gmsh.model.mesh.field.setNumbers(fmin, "FieldsList", fields)
        gmsh.model.mesh.field.setAsBackgroundMesh(fmin)
        gmsh.option.setNumber("Mesh.MeshSizeExtendFromBoundary", 0)

    gmsh.option.setNumber("Mesh.Algorithm3D", 10)  # HXT, robust and parallel
    gmsh.model.mesh.generate(3)
    if a.order == 2:
        gmsh.model.mesh.setOrder(2)
    gmsh.model.mesh.optimize("Netgen" if a.order == 1 else "HighOrder")

    # MOOSE (libMesh) reads gmsh format 4.1 and 2.2; only the named groups are saved.
    gmsh.option.setNumber("Mesh.MshFileVersion", 4.1)
    gmsh.option.setNumber("Mesh.SaveAll", 0)
    gmsh.write(a.output)

    etypes, etags, _ = gmsh.model.mesh.getElements(3)
    n_el = sum(len(t) for t in etags)
    n_nodes = len(gmsh.model.mesh.getNodes()[0])
    print("Wrote %s: %d tetrahedra (order %d), %d nodes" % (a.output, n_el, a.order, n_nodes))
    print("  block    %s" % a.block)
    for name, ids in named:
        area = sum(gmsh.model.occ.getMass(2, t) for t in ids)
        print("  boundary %-12s faces %s  (area %.5g)" % (name, ids, area))
    gmsh.finalize()


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = p.add_subparsers(dest="cmd", required=True)

    pi = sub.add_parser("inspect", help="list solids and faces")
    pi.add_argument("step")
    pi.add_argument("--scale", type=float, default=1.0, help="multiply all lengths (e.g. 0.001 for mm -> m)")

    pm = sub.add_parser("mesh", help="mesh the solid and name boundaries")
    pm.add_argument("step")
    pm.add_argument("-o", "--output", required=True, help="output .msh file")
    pm.add_argument("--size", type=float, required=True, help="target element size away from refinements")
    pm.add_argument("--order", type=int, choices=(1, 2), default=2, help="1 = TET4, 2 = TET10 (default, much more accurate)")
    pm.add_argument("--boundary", nargs=2, action="append", default=[], metavar=("NAME", "SELECTOR"),
                    help="name a set of faces, e.g. --boundary fixed 'x=min'")
    pm.add_argument("--refine", nargs=2, action="append", default=[], metavar=("SELECTOR", "SIZE"),
                    help="smaller elements near these faces, e.g. --refine 'ids:9' 0.5")
    pm.add_argument("--curvature", type=int, default=12, help="elements per 2*pi of curvature (0 = off)")
    pm.add_argument("--block", default="solid", help="name of the volume block")
    pm.add_argument("--scale", type=float, default=1.0, help="multiply all lengths (e.g. 0.001 for mm -> m)")

    a = p.parse_args()
    cmd_inspect(a) if a.cmd == "inspect" else cmd_mesh(a)


if __name__ == "__main__":
    main()
