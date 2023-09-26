[Mesh]
  type=GeneratedMesh
  dim=2
  nx=1
  ny=1
  xmax=1
  ymax=1
[]

#[Problem]
#  type=FEProblem
#[]

[Variables]
  [Temperature]
  []
[]

[Kernels]
  [temp5]
    type = Temptry1
    variable = Temperature
    thermal_conductivity = 1
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
