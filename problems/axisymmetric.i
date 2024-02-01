[Mesh]
	file="circle.msh"
[]

[Variables]
  [T]
  []
[]

[Kernels]
  [heat_conduction]
    type = HeatConduction
    variable = T
  []
  [time_derivative]
    type = HeatConductionTimeDerivative
    variable = T
  []
[]

[Materials]
  [thermal]
    type = HeatConductionMaterial
    thermal_conductivity = 50.0
    specific_heat = 18382
  []
  [density]
    type = GenericConstantMaterial
    prop_names = 'density'
    prop_values = 8000
  []
[]

[BCs]
  [t_outer]
    type = DirichletBC
    variable = T
    value = '100'
    boundary = 'outer_surface'
  []
[]

[Executioner]
  type = Transient
  end_time = 25000
  dt = 250
[]

[VectorPostprocessors]
  [t_sampler]
    type = LineValueSampler
    variable = T
    start_point = '0 0 0'
    end_point = '0.1 0 0'
    num_points = 20
    sort_by = x
  []
[]

[Outputs]
  exodus = true
  [csv]
    type = CSV
    file_base = axisymmetric_out
    execute_on = final
  []
[]
