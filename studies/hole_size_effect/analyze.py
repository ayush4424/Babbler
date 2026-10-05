#!/usr/bin/env python3
"""Collect the failure stress of every run and plot it against hole size.

  python3 analyze.py runs_dir [out_dir]   (runs_dir contains R<radius>/out.csv from run_case.sh)
"""
import glob
import os
import sys

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np

L, SIGMA_C, W, K_IC = 0.08278, 350.0, 40.0, 164.44  # mm, MPa, mm, MPa sqrt(mm)


def kt_gross(R):
    """Peterson / Heywood K_t for a central hole in a finite-width plate, on gross stress."""
    a = 2 * R / W
    return (3 - 3.13 * a + 3.66 * a**2 - 1.53 * a**3) / (1 - a)


runs, out = sys.argv[1], (sys.argv[2] if len(sys.argv) > 2 else ".")
rows = []
for f in glob.glob(os.path.join(runs, "R*", "out.csv")):
    R = float(os.path.basename(os.path.dirname(f))[1:])
    d = np.genfromtxt(f, delimiter=",", names=True)
    rows.append((R, d["Fy"].max() / (W / 2)))  # nominal stress on the quarter model's top edge
rows = np.array(sorted(rows))
np.savetxt(os.path.join(out, "hole_size_effect_results.csv"),
           np.c_[rows[:, 0], rows[:, 0] / L, rows[:, 1], rows[:, 1] / SIGMA_C, SIGMA_C / kt_gross(rows[:, 0])],
           delimiter=",", header="R_mm,R_over_l,sigma_f_MPa,sigma_f_over_sigma_c,strength_criterion_MPa",
           comments="", fmt="%.5g")

fig, a = plt.subplots(figsize=(8.5, 5.6), constrained_layout=True)
Rs = np.logspace(-2, np.log10(4), 200)
a.plot(Rs, np.ones_like(Rs), "--", color="gray", label="Un-notched strength σ_c (tiny-hole limit)")
a.plot(Rs, 1 / kt_gross(Rs), "-.", color="#1f77b4", label="Strength criterion σ_c / K_t (no size effect)")
a.plot(rows[:, 0], rows[:, 1] / SIGMA_C, "o-", color="#d62728", lw=2.2, ms=8, label="Phase field (AT1)")
a.axvline((K_IC / SIGMA_C) ** 2, color="0.6", lw=1, ls=":")
a.set_xscale("log"), a.set_ylim(0, 1.1), a.grid(alpha=0.3, which="both"), a.legend(loc="lower left")
a.set_xlabel("Hole radius R (mm)"), a.set_ylabel("Failure stress / σ_c")
a.secondary_xaxis("top", functions=(lambda r: r / L, lambda q: q * L)).set_xlabel("R / l")
fig.savefig(os.path.join(out, "hole_size_effect_curve.png"), dpi=120)
for R, s in rows:
    print("R=%-5g R/l=%6.2f sigma_f=%6.1f MPa  = %.2f x strength criterion" % (R, R / L, s, s * kt_gross(R) / SIGMA_C))
