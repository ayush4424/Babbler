# Open-hole strength of alumina vs hole size (phase-field, AT1)

Does a plate with a hole fail when the peak stress at the hole reaches the tensile
strength (sigma_nom = sigma_c / K_t), or when the net section does? Classical theory
picks one; the phase-field model should give a smooth transition with hole radius R,
governed by R / l (Tanné et al., JMPS 2018).

- Material (Al2O3, from the MTP): E = 380 GPa, nu = 0.26, K_IC = 5.2 MPa sqrt(m),
  sigma_c = 350 MPa  ->  Gc = K_IC^2 (1 - nu^2) / E = 0.06635 N/mm.
- AT1 model: elastic until sigma_c; l = 3 Gc E' / (8 sigma_c^2) = 0.08278 mm, E' = E / (1 - nu^2).
  Checked on an un-notched strip: peak 352.6 MPa (target 350; the excess is the load step).
- Quarter model of a 40 x 40 mm plate, plane strain, displacement-controlled pull on `top`;
  symmetry on `left` (x = 0) and `bottom` (y = 0, where the crack grows).
- Element size l/4 in a band along the crack path (`make_mesh.py`), staggered
  RACCOON solve (`elasticity.i` + `fracture.i`), stops automatically after failure.

Run one case (hole radius in mm, MPI ranks):

    RACCOON=/path/to/raccoon-opt ./run_case.sh 0.2 2

Nominal (far-field) stress = reaction force on `top` / 20 mm (per unit thickness).
