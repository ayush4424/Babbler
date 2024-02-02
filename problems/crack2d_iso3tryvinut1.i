#This input uses PhaseField-Nonconserved Action to add phase field fracture bulk rate kernels
[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 100
    ny = 100
    ymax = 1
  []
[]

[GlobalParams]
  displacements = 'disp_x disp_y'
[]

[Modules]
  [./PhaseField]
    [./Nonconserved]
      [./c]
        free_energy = F
        kappa = kappa_op
        mobility = L
      [../]
    [../]
  [../]
  [./TensorMechanics]
    [./Master]
      [./mech]
        add_variables = true
        strain = SMALL
        additional_generate_output = 'stress_yy'
        save_in = 'resid_x resid_y'
        planar_formulation = PLANE_STRAIN
      [../]
    [../]
  [../]
[]

[AuxVariables]
  [./resid_x]
  [../]
  [./resid_y]
  [../]
  [./bounds_dummy]
    order = FIRST
    family = LAGRANGE
  [../]
[]

[Kernels]
  [./solid_x]
    type = PhaseFieldFractureMechanicsOffDiag
    variable = disp_x
    component = 0
    c = c
  [../]
  [./solid_y]
    type = PhaseFieldFractureMechanicsOffDiag
    variable = disp_y
    component = 1
    c = c
  [../]
  [./off_disp]
    type = AllenCahnElasticEnergyOffDiag
    variable = c
    displacements = 'disp_x disp_y'
    mob_name = L
  [../]
[]

[ICs]
  [./u_ic]
    type = ConstantIC
    variable = disp_y
    value = 0
  [../]
[]

[Functions]
  [top_pull]
    type = PiecewiseLinear
    x = '  0   0.05   0.1'
    y = '0 -1   -1'
  []
[]

[BCs]
  [./yfixbottom]
    type = DirichletBC
    variable = disp_y
    boundary = bottom
    value = 0
  [../]
  [./xfixbottom]
    type = DirichletBC
    variable = disp_x
    boundary = bottom
    value = 0
  [../]
  [./xfixleft]
    type = DirichletBC
    variable = disp_x
    boundary = left
    value = 0
  [../]
  [./xfixright]
    type = DirichletBC
    variable = disp_x
    boundary = right
    value = 0
  [../]
  [u_top_pull]
    type = Pressure
    variable = disp_y
    boundary = top
    factor = 1
    function = top_pull
  []
[]

[Materials]
  [./pfbulkmat]
    type = GenericConstantMaterial
    prop_names = 'gc_prop l visco'
    prop_values = '25e-3 0.1 1e-20'
  [../]
  [./define_mobility]
    type = ParsedMaterial
    material_property_names = 'gc_prop visco'
    property_name = L
    expression = '1.0/(gc_prop * visco)'
  [../]
  [./define_kappa]
    type = ParsedMaterial
    material_property_names = 'gc_prop l'
    property_name = kappa_op
    expression = 'gc_prop * l'
  [../]
  [./elasticity_tensor]
    type = ComputeElasticityTensor
    C_ijkl = '576.9 384.6 0'
    fill_method = symmetric_isotropic
  [../]
  [./damage_stress]
    type = ComputeLinearElasticPFFractureStress
    c = c
    E_name = 'elastic_energy'
    D_name = 'degradation'
    F_name = 'local_fracture_energy'
    decomposition_type = strain_spectral
    #use_current_history_variable = true
    use_snes_vi_solver = true
  [../]
  [./degradation]
    type = DerivativeParsedMaterial
    property_name = degradation
    coupled_variables = 'c'
    expression = '(1.0-c)^2*(1.0 - eta) + eta'
    constant_names       = 'eta'
    constant_expressions = '0.0'
    derivative_order = 2
  [../]
  [./local_fracture_energy]
    type = DerivativeParsedMaterial
    property_name = local_fracture_energy
    coupled_variables = 'c'
    material_property_names = 'gc_prop l'
    expression = 'c^2 * gc_prop / 2 / l'
    derivative_order = 2
  [../]
  [./fracture_driving_energy]
    type = DerivativeSumMaterial
    coupled_variables = c
    sum_materials = 'elastic_energy local_fracture_energy'
    derivative_order = 2
    property_name = F
  [../]
  [./density]
    type = GenericConstantMaterial
    prop_names = 'density'
    prop_values = '1'
  [../]
[]

[Postprocessors]
  [./resid_x]
    type = NodalSum
    variable = resid_x
    boundary = 2
  [../]
  [./resid_y]
    type = NodalSum
    variable = resid_y
    boundary = 2
  [../]
[]

[Preconditioning]
  [./smp]
    type = SMP
    full = true
  [../]
[]

[Bounds]
  [./c_upper_bound]
    type = ConstantBoundsAux
    variable = bounds_dummy
    bounded_variable = c
    bound_type = upper
    bound_value = 1.0
  [../]
  [./c_lower_bound]
    type = VariableOldValueBoundsAux
    variable = bounds_dummy
    bounded_variable = c
    bound_type = lower
  [../]
[]

[Executioner]
  type = Transient

  solve_type = PJFNK
  petsc_options_iname = '-pc_type  -snes_type'
  petsc_options_value = 'lu vinewtonrsls'

  nl_rel_tol = 1e-8
  l_max_its = 10
  nl_max_its = 10

  dt = 1e-4
  dtmin = 1e-4
  num_steps = 1000
[]

[Outputs]
  exodus = true
[]
