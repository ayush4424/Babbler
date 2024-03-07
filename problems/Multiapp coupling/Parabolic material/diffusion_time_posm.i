[Mesh]
  type = GeneratedMesh
  dim = 1
  xmax = 1
  nx = 10
[]

[Variables]
  [u]
  []
[]

[AuxVariables]
  [vt]
  []
[]

[Kernels]
  [diff]
    type = MatDiffusion
    variable = u
  []
  [td]
    type = TimeDerivative
    variable = u
  []
[]

[BCs]
  [left]
    type = DirichletBC
    variable = u
    boundary = left
    value = 0
  []
  [right]
    type = DirichletBC
    variable = u
    boundary = right
    value = 1
  []
[]

[ICs]
  [ic1]
    type = ConstantIC
	variable = u
	value = 0
  []
[]

[Functions]
  [matprop1]
    type = ParsedFunction
    expression = '0.5*x^2+9.5*x'
  []
[]

[Materials]
  [diff]
    type = GenericFunctionMaterial
    prop_names = D
	prop_values	= matprop1
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
