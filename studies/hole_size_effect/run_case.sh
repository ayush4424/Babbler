#!/bin/bash
# Mesh and run one open-hole case:  run_case.sh R [n_procs] [workdir]
#   R        hole radius in mm
#   n_procs  MPI ranks (default 2)
#   workdir  where meshes and results go (default ./runs)
# Needs: python3 with gmsh, and RACCOON (set RACCOON=/path/to/raccoon-opt).
set -euo pipefail
R=$1; NP=${2:-2}; HERE=$(cd "$(dirname "$0")" && pwd); WORK=${3:-$HERE/runs}
RACCOON=${RACCOON:-raccoon-opt}
L=0.08278
mkdir -p "$WORK/R$R" && cd "$WORK/R$R"
cp "$HERE/elasticity.i" "$HERE/fracture.i" .
python3 "$HERE/make_mesh.py" "$R" "$L" "$PWD/hole.msh"
# Coarse steps while the plate is certainly still elastic (nominal stress < 0.29 sigma_c),
# then fine steps through damage initiation and failure.
start=$(date +%s)
mpiexec -n "$NP" "$RACCOON" -i elasticity.i mesh_file="$PWD/hole.msh" u_max=0.02 \
  Executioner/TimeStepper/type=FunctionDT "Executioner/TimeStepper/function=if(t<0.005,2.5e-4,5e-5)" \
  Outputs/file_base=out > run.log 2>&1
echo "R=$R finished in $(( $(date +%s) - start )) s"
