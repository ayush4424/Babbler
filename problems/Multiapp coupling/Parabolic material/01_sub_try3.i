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
    type = ADDiffusion
    variable = v
  []
  [source]
    type = ADBodyForce
    variable = v
    value = -1
    function = 1
  []
[]

[BCs]
  [left]
    type = DirichletBC
    variable = v
    boundary = left
    value = 0
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
  dt = 0.1
  
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
[]
