#!/usr/bin/env python3
"""Plot a 3D MOOSE result (Exodus .e) on the part surface, ANSYS-style.

Draws the outer surface of the tetrahedral mesh coloured by a nodal or element
variable (von Mises stress by default), on the deformed shape with an exaggeration factor.

  python3 plot_results.py result.e -o result.png
  python3 plot_results.py result.e --var max_principal_stress --scale 200 --view 30 -60
"""

import argparse
from collections import Counter

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
from mpl_toolkits.mplot3d.art3d import Poly3DCollection
from netCDF4 import Dataset


def names(ds, key):
    if key not in ds.variables:
        return []
    return [b"".join(r).decode().strip("\x00").strip() for r in ds.variables[key][:].data]


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("exodus")
    p.add_argument("-o", "--output", default="result.png")
    p.add_argument("--var", default="vonmises_stress", help="element variable to colour by")
    p.add_argument("--scale", type=float, default=None, help="displacement exaggeration (default: auto, 5%% of part size)")
    p.add_argument("--view", type=float, nargs=2, default=(25, -60), metavar=("ELEV", "AZIM"))
    p.add_argument("--title", default=None)
    a = p.parse_args()

    ds = Dataset(a.exodus)
    x, y, z = (ds.variables[k][:].data for k in ("coordx", "coordy", "coordz"))
    step = len(ds.variables["time_whole"][:]) - 1
    nodal = names(ds, "name_nod_var")
    elem = names(ds, "name_elem_var")
    if a.var not in elem and a.var not in nodal:
        raise SystemExit("variable %s not found; nodal: %s, element: %s" % (a.var, nodal, elem))
    nodal_var = a.var not in elem

    u = [ds.variables["vals_nod_var%d" % (nodal.index(c) + 1)][step].data if c in nodal else 0 * x
         for c in ("disp_x", "disp_y", "disp_z")]
    size = max(np.ptp(x), np.ptp(y), np.ptp(z))
    umax = np.sqrt(u[0] ** 2 + u[1] ** 2 + u[2] ** 2).max()
    scale = a.scale if a.scale is not None else (0.05 * size / umax if umax > 0 else 0.0)
    X = np.c_[x + scale * u[0], y + scale * u[1], z + scale * u[2]]

    # Collect tetrahedra (corner nodes only) and their values from every block
    tets, vals = [], []
    for b in range(1, ds.dimensions["num_el_blk"].size + 1):
        conn = ds.variables["connect%d" % b][:].data[:, :4] - 1
        tets.append(conn)
        if not nodal_var:
            vals.append(ds.variables["vals_elem_var%deb%d" % (elem.index(a.var) + 1, b)][step].data)
    tets = np.vstack(tets)
    if nodal_var:  # e.g. FIRST-order stress fields: average the corner values per tet
        nv = ds.variables["vals_nod_var%d" % (nodal.index(a.var) + 1)][step].data
        vals = nv[tets].mean(1)
    else:
        vals = np.concatenate(vals)

    # Surface = triangles that belong to exactly one tetrahedron
    local = ((0, 1, 2), (0, 1, 3), (0, 2, 3), (1, 2, 3))
    faces = np.vstack([tets[:, f] for f in local])
    owner = np.tile(np.arange(len(tets)), 4)
    key = [tuple(sorted(f)) for f in faces]
    count = Counter(key)
    surf = np.array([i for i, k in enumerate(key) if count[k] == 1])
    tri = faces[surf]
    tv = nv[tri].mean(1) if nodal_var else vals[owner[surf]]

    fig = plt.figure(figsize=(11, 7))
    ax = fig.add_subplot(projection="3d")
    norm = plt.Normalize(tv.min(), tv.max())
    pc = Poly3DCollection(X[tri], facecolors=plt.cm.turbo(norm(tv)), edgecolors="none")
    ax.add_collection3d(pc)
    # True proportions (thin parts stay thin), with a small minimum so plates remain visible
    lo, hi = X.min(0), X.max(0)
    ext = np.maximum(hi - lo, 0.04 * size)
    mid = (lo + hi) / 2
    ax.set_xlim(mid[0] - ext[0] / 2, mid[0] + ext[0] / 2)
    ax.set_ylim(mid[1] - ext[1] / 2, mid[1] + ext[1] / 2)
    ax.set_zlim(mid[2] - ext[2] / 2, mid[2] + ext[2] / 2)
    ax.set_box_aspect(tuple(ext / ext.max()))
    ax.view_init(*a.view)
    ax.set_xlabel("x"), ax.set_ylabel("y"), ax.set_zlabel("z")
    sm = plt.cm.ScalarMappable(norm=norm, cmap="turbo")
    fig.colorbar(sm, ax=ax, shrink=0.6, label=a.var)
    i = int(np.argmax(vals))
    c = X[tets[i]].mean(0)
    ax.scatter(*c, color="k", s=25)
    peak = nv.max() if nodal_var else vals.max()
    ax.text(*c, "  max %.4g" % peak, fontsize=9)
    ax.set_title(a.title or "%s   (deformation x %.3g, max |u| = %.3g)" % (a.var, scale, umax))
    fig.savefig(a.output, dpi=130, bbox_inches="tight")
    print("Wrote %s: %s surface range %.4g .. %.4g, %d surface triangles" % (a.output, a.var, tv.min(), tv.max(), len(tri)))


if __name__ == "__main__":
    main()
