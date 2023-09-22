[Mesh]
  type=GeneratedMesh
  dim=2
  nx=100
  ny=10
  xmax=0.304
  ymax=0.0257
  coord_type=RZ
  rz_coord_axis=X
[]

[Problem]
  type=FEProblem
  #coord_type=RZ
  #rz_coord_axis=X
[]

[Variables]
  [pressure]
  []
[]

[Kernels]
  [diffusion]
    type = DarcyPressure
    variable = pressure 
    permeability = 0.8451e-09
  []
[]

[BCs]
  [inlet]
    type = ADDirichletBC # Simple u=value BC
    variable = pressure # Variable to be set
    boundary = left # Name of a sideset in the mesh
    value = 4000 # (Pa) From Figure 2 from paper. First data point for 1mm spheres.
  []
  [outlet]
    type = ADDirichletBC
    variable = pressure
    boundary = right
    value = 0 # (Pa) Gives the correct pressure drop from Figure 2 for 1mm spheres
  []
[]

[Executioner]
  type = Steady # Steady state problem
  solve_type = NEWTON # Perform a Newton solve

  # Set PETSc parameters to optimize solver efficiency
  petsc_options_iname = '-pc_type -pc_hypre_type' # PETSc option pairs with values below
  petsc_options_value = ' hypre    boomeramg'
[]

[Outputs]
  exodus = true # Output Exodus format
[]
