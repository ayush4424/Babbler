# Prebuilt MOOSE toolchain (March 2024)

This branch only stores a prebuilt MOOSE build. It shares no history with `main`;
the Babbler cloud-environment setup script downloads it.

- MOOSE commit `fec364fc89a8244f04ffe28e55101d418ae42383` (2024-03-06)
- PETSc 3.20.3 (+ SLEPc, HYPRE, SuperLU_DIST, STRUMPACK, ParMETIS, ScaLAPACK; no MUMPS/PT-Scotch), system HDF5 (MPICH)
- libMesh (opt method only), WASP
- MOOSE framework + heat_transfer, phase_field, solid_mechanics, ray_tracing modules (opt)
- Built on Ubuntu 24.04 x86_64; must be extracted to `/home/user/moose` (absolute rpaths)

Reassemble: `cat moose-prebuilt.tar.zst.part* > moose-prebuilt.tar.zst && sha256sum -c SHA256SUMS`
