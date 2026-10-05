# Elastoplastic plate with a hole: aluminium 6061-T6

Quarter model of a 40 x 100 mm plate with a 10 mm hole (d/W = 0.25), extruded to a thin
slab so the plate is in plane stress. J2 (von Mises) plasticity with isotropic hardening,
finite strain, automatic differentiation for an exact Jacobian (`plate.i`).

Material (handbook values for 6061-T6): E = 68.9 GPa, nu = 0.33, yield 276 MPa,
ultimate 310 MPa, about 12 % elongation; hardening as a piecewise-linear true-stress vs
plastic-strain curve rising to 320 MPa.

    python3 make_mesh.py $PWD/metal.msh --H 100 --h_hole 0.1
    mpiexec -n 4 babbler-opt -i plate.i mesh_file=$PWD/metal.msh u_max=1.0 nsteps=200

## Results (`results/`)

| Check | Analytical | MOOSE |
|---|---|---|
| Elastic K_t (von Mises at hole / nominal) | 3.23 (Peterson) | 3.13 (element-averaged stress) |
| First yield at the hole | sigma_y / K_t = 85 MPa | between 84 and 91 MPa |
| Plastic collapse (net section) | 207 MPa at sigma_y, 240 MPa at 320 MPa flow stress | plateau at 228 MPa |
| Local plastic strain at the hole | Neuber's rule | same trend, 20-50 % lower while yielding is local; Neuber no longer applies once the net section yields |

The hole edge yields at about 30 % of the yield stress; the plastic zone then spreads
from the hole across the net section and the load levels off at the collapse load. The
local strain passes the typical 12 % elongation near 225 MPa, so a real plate would start
to tear around there; this model has plasticity only, no fracture.

The run was stopped by the 2-hour job limit at u = 0.88 mm (88 % of the planned
displacement), well into the collapse plateau.
