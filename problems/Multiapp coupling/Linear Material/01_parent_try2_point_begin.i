[Mesh]
  type = GeneratedMesh
  dim = 1
  xmax = 1
  nx = 20
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
    type = NeumannBC
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

[Materials]
  [diff]
    type = ParsedMaterial
    property_name = D
    coupled_variables = 'vt'
	expression = 'vt'
  []
[]

[Executioner]
  type = Transient
  end_time = 0.001
  dt = 0.0001

  solve_type = 'PJFNK'

  petsc_options_iname = '-pc_type -pc_hypre_type'
  petsc_options_value = 'hypre boomeramg'
[]

[Outputs]
  exodus = true
[]

[MultiApps]
  [micro1]
    type = TransientMultiApp
    positions = '0 0 0'
    input_files = '01_sub_try2.i'
    execute_on = timestep_begin
    output_in_position = true
	sub_cycling = true
  []
[]

[Transfers]
  [push_u]
    type = MultiAppVariableValueSampleTransfer
    to_multi_app = micro1
    source_variable = u
    variable = ut
  []

  [pull_v]
    type = MultiAppGeneralFieldShapeEvaluationTransfer
    from_multi_app = micro1
    source_variable = v
	variable = vt
  []
[]
