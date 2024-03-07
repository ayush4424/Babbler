[Mesh]
  type = GeneratedMesh
  dim = 1
  xmax= 1
  nx = 10
[]

[Variables]
  [v]
  []
[]

[AuxVariables]
  [ut]
  []
[]

[Kernels]
  [diff]
    type = Diffusion
    variable = v
  []
[]

[BCs]
  [left]
    type = DirichletBC
    variable = v
    boundary = left
    value = 10
  []
  [right]
    type = DirichletBC
    variable = v
    boundary = right
    value = 10
  []
[]

[Executioner]
  type = Transient
  end_time = 0.1
  dt = 0.001
  
  solve_type = 'PJFNK'

  petsc_options_iname = '-pc_type -pc_hypre_type'
  petsc_options_value = 'hypre boomeramg'
[]

[Outputs]
  exodus = true
[]

[Postprocessors]
  [average_v]
    type = ElementAverageValue
    variable = v
  []
  [average_ut]
    type = ElementAverageValue
    variable = ut
  []
[]
