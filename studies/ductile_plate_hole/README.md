# Ductile phase-field fracture: aluminium 6061-T6 plate with a hole (RACCOON)

Same plate as `../metal_plate_hole` (quarter of 40 x 100 mm, 10 mm hole, thin slab in
plane stress), now with damage so the model predicts where and when it tears.

- Plasticity: J2 with power-law hardening sigma = sigma_y (1 + ep/ep0)^(1/n),
  sigma_y = 276 MPa, n = 27.98, ep0 = 0.00272 (fit to the 276 -> 320 MPa curve
  used in the plasticity study, within 1-2 MPa up to 20 % plastic strain).
- Fracture: PF-CZM (alpha = d, rational degradation), damage driven by elastic energy
  plus plastic work, as in RACCOON's `mode1_ductile_fracture` tutorial.
  Gc = K_IC^2 (1 - nu^2) / E = 10.88 N/mm (K_IC = 29 MPa sqrt(m));
  psic = 37.4 MPa = plastic work + elastic energy at 12 % plastic strain (typical
  elongation), so a uniaxial bar starts to damage at about 12 % (checked: 11.98 %);
  l = 0.05 mm (PF-CZM requires 3 Gc / (8 l psic) > ~2) with 0.025 mm elements along the crack path.
- Staggered solve (elastoplasticity.i + fracture.i), stops after the force drops
  below 20 % of its peak.

Mesh:  python3 ../metal_plate_hole/make_mesh.py $PWD/plate.msh --H 100 --h_hole 0.1 --band_h 0.025 --band_height 0.4
Run:   mpiexec -n 4 raccoon-opt -i elastoplasticity.i mesh_file=$PWD/plate.msh

Limitations: small-strain kinematics; the onset criterion is calibrated to uniaxial
elongation, so it does not account for stress triaxiality; the symmetric quarter model
forces a flat (mode I) crack on the symmetry plane.
