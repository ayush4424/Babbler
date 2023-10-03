[Mesh]
  type=GeneratedMesh
  dim=2
  nx=10
  ny=10
  xmax=1
  ymax=1
[]

[Problem]
  type=FEProblem
[]

[Variables]
  [Temperature]
  []
[]

[Kernels]
  [temp3]
    type = Temptry1
    variable = Temperature
    thermal_conductivity = 1
    heatsource = 1
  []
[]

[BCs]
  [top]
    type = ADDirichletBC
    variable = Temperature
    boundary = top
    value = 15
  []
  [bottom]
    type = ADDirichletBC
    variable = Temperature
    boundary = bottom
    value = 10
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
