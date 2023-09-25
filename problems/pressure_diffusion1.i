[Mesh]
  type=GeneratedMesh
  dim=2
  nx=1
  ny=1
  xmax=1
  ymax=1
[]

[Variables]
  [Temperature]
  []
[]

[Kernels]
  [temp1]
    type = Diffusion
    variable = Temperature 
  []
[]

[BCs]
  [left]
    type = ADDirichletBC 
    variable = Temperature 
    boundary = left 
    value = 0
  []
  [right]
    type = ADDirichletBC
    variable = Temperature
    boundary = right
    value = 100
  []
[]

[Executioner]
  type = Steady 
  solve_type = NEWTON 
  petsc_options_iname = '-pc_type -pc_hypre_type' 
  petsc_options_value = ' hypre    boomeramg'
[]

[Outputs]
  exodus = true
  [csv]
  type = CSV
  []
[]
