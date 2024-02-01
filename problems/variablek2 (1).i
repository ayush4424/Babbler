[Mesh]
  [generated]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 100
    ny = 10
  xmax=0.5
  ymax=0.0416667
  [../]
[]

[Variables]
  [./T]
    initial_condition=76
  [../]
[]

[Kernels]
  [./heat]
    type = HeatConduction
    variable = T
  [../]
  [time_derivative]
    type= HeatConductionTimeDerivative
    variable= T
  []
[]

[BCs]
  [./ui]
    type = DirichletBC
    boundary = left
    variable = T
    value = 600
  [../]
  [./uo]
    type = DirichletBC
    boundary = right
    variable = T
    value = 32
  [../]
  [t_top]
    type = NeumannBC
    variable = T
    value = 0
    boundary = 'top'
  []
  [t_bottom]
    type = NeumannBC
    variable = T
    value = 0
    boundary = 'bottom'
  []
[]

[Materials]
  [./property]
    type = GenericConstantMaterial
    prop_names = 'density specific_heat'
    prop_values = '523 0.1075'
  [../]
  [./thermal_conductivity]
    type = ParsedMaterial
    property_name = 'thermal_conductivity'
    coupled_variables = T
    expression ='9.5 * (1 + 0.00093* T)'
  [../]
[]

[Executioner]
  type = Transient
  end_time = 0.666667
  dt = 0.033333
[]

[Postprocessors]
  [h]
   type = AverageElementSize
  []
[]

[Outputs]
  exodus = true
  csv = true
[]
