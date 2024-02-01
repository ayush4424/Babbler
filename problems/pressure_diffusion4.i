[Mesh]
  type=GeneratedMesh
  dim=2
  nx=10
  ny=10
  xmax=1
  ymax=1
[]

[Variables]
  [Temperature]
  []
[]

[Kernels]
  [temp4]
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
    value = 0
  []
  [top]
    type = ADDirichletBC
    variable = Temperature
    boundary = top
    value = 1
  []
  [bottom]
    type = ADDirichletBC
    variable = Temperature
    boundary = bottom
    value = 0
  []
[]

[Executioner]
  type = Steady 
  solve_type = NEWTON 
  petsc_options_iname = '-pc_type -pc_hypre_type' 
  petsc_options_value = 'hypre    boomeramg'
[]

[Outputs]
  exodus = true
  [csv]
  type = CSV
  []
[]
