#!/usr/bin/env python3
"""Coupled stress-energy criterion (Finite Fracture Mechanics) for a circular hole.

Leguillon (2002, Eur. J. Mech. A/Solids 21:61-72); applied to open holes by Martin,
Leguillon & Carrere (2012, IJSS 49:3915-3922). A crack of finite length a nucleates
at the hole edge when BOTH
  stress:  sigma_yy(x) >= sigma_c on the whole path R <= x <= R + a      (Kirsch field)
  energy:  G_inc(a) = (1/a) int_0^a G(s) ds >= Gc                         (Tada handbook)
The failure stress is the smallest remote stress for which some a satisfies both.

Infinite plate, uniaxial remote stress sigma, two symmetric cracks at the hole edges:
  Kirsch:   sigma_yy(x, 0) = sigma [1 + R^2/(2 x^2) + 3 R^4/(2 x^4)]
  Tada:     K = sigma sqrt(pi a) F(s),  s = a / (R + a),
            F(s) = 0.5 (3 - s) [1 + 1.243 (1 - s)^3]     (F -> 3.36 for a << R, -> 1 for a >> R)
  plane strain: G = K^2 (1 - nu^2) / E
"""
import numpy as np
from scipy.integrate import cumulative_trapezoid
from scipy.optimize import brentq

E, NU, SIGMA_C, K_IC = 380e3, 0.26, 350.0, 5.2 * np.sqrt(1000.0)  # MPa, -, MPa, MPa sqrt(mm)
GC = K_IC**2 * (1 - NU**2) / E


def kirsch(R, x):
    return 1 + R**2 / (2 * x**2) + 3 * R**4 / (2 * x**4)


def g_inc_unit(R, a_max, n=4000):
    """Average energy release rate over crack length a, for unit remote stress."""
    a = np.geomspace(1e-7 * a_max, a_max, n)  # log grid: resolves short cracks at large holes
    s = a / (R + a)
    F = 0.5 * (3 - s) * (1 + 1.243 * (1 - s) ** 3)
    G = np.pi * a * F**2 * (1 - NU**2) / E
    # G ~ a near a = 0, so the integral from 0 to a[0] is G[0] a[0] / 2
    Ginc = (G[0] * a[0] / 2 + cumulative_trapezoid(G, a, initial=0.0)) / a
    return a, Ginc


def failure_stress(R):
    a, ginc = g_inc_unit(R, a_max=50 * max(R, (K_IC / SIGMA_C) ** 2))
    # stress-admissible remote stress for length a, and energy-admissible remote stress
    s_stress = SIGMA_C / kirsch(R, R + a)
    s_energy = np.sqrt(GC / ginc)
    f = s_energy - s_stress            # > 0 for short cracks (energy limits), < 0 for long ones
    i = np.argmax(f < 0)
    a_star = brentq(lambda t: np.interp(t, a, f), a[i - 1], a[i])
    return float(np.interp(a_star, a, s_stress)), a_star


if __name__ == "__main__":
    print("Gc = %.5f N/mm, Irwin length = %.3f mm" % (GC, (K_IC / SIGMA_C) ** 2))
    for R in [0.01, 0.02, 0.06, 0.2, 0.6, 2.0, 6.0, 20.0]:
        s, a = failure_stress(R)
        print("R=%6g mm  sigma_f=%6.1f MPa  (%.3f sigma_c, %.2f x sigma_c/3)  nucleated crack length a*=%.4f mm"
              % (R, s, s / SIGMA_C, 3 * s / SIGMA_C, a))
