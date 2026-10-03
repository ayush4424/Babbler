E = 2.1e5
nu = 0.3
K = '${fparse E/3/(1-2*nu)}'
G = '${fparse E/2/(1+nu)}'

Gc = 2.7
l = 0.015

[MultiApps]
  [fracture]
    type = TransientMultiApp
    input_files = fracture_tensiontest.i
    cli_args = 'Gc=${Gc};l=${l}'
    execute_on = 'TIMESTEP_END'
  []
[]

[Transfers]
  [from_d]
    type = MultiAppCopyTransfer
    multi_app = fracture
    direction = from_multiapp
    variable = d
    source_variable = d
  []
  [to_psie_active]
    type = MultiAppCopyTransfer
    multi_app = fracture
    direction = to_multiapp
    variable = psie_active
    source_variable = psie_active
  []
[]

[GlobalParams]
 # order = FIRST
 # family = LAGRANGE
  displacements = 'disp_x disp_y'
  out_of_plane_strain = strain_zz
 # pspg = true
[]

[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 256
    ny = 256
    ymax = 1
    xmax = 1
  []
  #
  construct_side_list_from_node_list = true
[]

#


[Variables]
  [disp_x]
  []
  [disp_y]
  []
  
  [./strain_zz]
  [../]

[]

[AuxVariables]
  [fx]
  []
  [fy]
  []
  [d]
  []
[]

[ICs]
  [./d_ic]
    type = FunctionIC
    function = ic
    variable = d
  [../]
[]

[Functions]
  [./ic]
    type = ParsedFunction
    expression = 'if(x<0.5 & y < 0.5075 & y > 0.4925,1, 0)'
  [../]
[]

[Physics/SolidMechanics/QuasiStatic]
  [./plane_stress]
    planar_formulation = WEAK_PLANE_STRESS
    add_variables = true
    strain = SMALL
    generate_output = 'stress_xx stress_xy stress_yy stress_zz strain_xx strain_xy strain_yy'
    #eigenstrain_names = eigenstrain
    use_automatic_differentiation = true
    save_in = 'fx fy'
  [../]
[]

[BCs]
  [top_y]
    type = ADFunctionDirichletBC
    variable = disp_y
    boundary = top
    function = 't'
  []
  [top_x]
    type = ADDirichletBC
    variable = disp_x
    boundary = top
    value = 0
  []
  [bottom_y]
    type = ADDirichletBC
    variable = disp_y
    boundary = bottom
    value = 0
  []
  [right_x]
    type = ADDirichletBC
    variable = disp_x
    boundary = right
    value = 0
  []
  [left_x]
    type = ADDirichletBC
    variable = disp_x
    boundary = left
    value = 0
  []
[]

[Materials]
  [bulk]
    type = ADGenericConstantMaterial
    prop_names = 'K G'
    prop_values = '${K} ${G}'
  []
  [degradation]
    type = PowerDegradationFunction
    f_name = g
    function = (1-d)^p*(1-eta)+eta
    phase_field = d
    parameter_names = 'p eta '
    parameter_values = '2 1e-6'
  []
 # [strain]
 #   type = ADComputeSmallStrain
 # []
  [elasticity]
    type = SmallDeformationIsotropicElasticity
    bulk_modulus = K
    shear_modulus = G
    phase_field = d
    degradation_function = g
    decomposition = spectral
    output_properties = 'elastic_strain psie_active'
    outputs = exodus
  []
  [stress]
    type = ComputeSmallDeformationStress
    elasticity_model = elasticity
    output_properties = 'stress'
    outputs = exodus
  []
[]

[Postprocessors]
  [Fy]
    type = NodalSum
    variable = fy
    boundary = top
  []
  [./change_over_time1]
    type = ChangeOverFixedPointPostprocessor
    postprocessor = 'Fy'
    change_with_respect_to_initial = false
    execute_on = 'MULTIAPP_FIXED_POINT_END'
  [../]
[]

[Executioner]
  type = Transient

  solve_type = NEWTON
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = 'lu       superlu_dist                 '
  automatic_scaling = true

  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-8

  dt = 5e-6
  end_time = 8e-3

  fixed_point_max_its = 20
  fixed_point_min_its = 2
  accept_on_max_fixed_point_iteration = true
  fixed_point_rel_tol = 1e-6
  fixed_point_abs_tol = 1e-8
[]

[Outputs]
  exodus = true
  print_linear_residuals = false
[]
