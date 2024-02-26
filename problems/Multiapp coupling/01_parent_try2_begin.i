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
  end_time = 1
  dt = 1

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
    type = MultiAppPostprocessorInterpolationTransfer
    from_multi_app = micro1
    variable = vt
    postprocessor = average_v
  []
[]
