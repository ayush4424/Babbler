#This input uses PhaseField-Nonconserved Action to add phase field fracture bulk rate kernels
[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 100
    ny = 100
    xmax = 1
    ymax = 1
  []
[]

[GlobalParams]
  displacements = 'disp_x disp_y'
[]

[AuxVariables]
  [./strain_yy]
    family = MONOMIAL
    order = CONSTANT
  [../]
  [./resid_x]
  [../]
  [./resid_y]
  [../]
  [./bounds_dummy]
    order = FIRST
    family = LAGRANGE
  [../]
[]

[Modules]
  [./TensorMechanics]
    [./Master]
      [./All]
        add_variables = true
        strain = SMALL
        planar_formulation = PLANE_STRAIN
        additional_generate_output = 'stress_yy'
        strain_base_name = uncracked
        save_in = 'resid_x resid_y'
      [../]
    [../]
  [../]
  [./PhaseField]
    [./Nonconserved]
      [./c]
        free_energy = E_el
        kappa = kappa_op
        mobility = L
      [../]
    [../]
  [../]
[]

[ICs]
  [./c_ic]
    type = FunctionIC
    function = ic
    variable = c
  [../]
[]

[Functions]
  [./ic]
    type = ParsedFunction
    expression = 'if(x>0.5 & y < 0.5075 & y > 0.4925,1,0)'
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

[AuxKernels]
  [./strain_yy]
    type = RankTwoAux
    variable = strain_yy
    rank_two_tensor = uncracked_mechanical_strain
    index_i = 1
    index_j = 1
  [../]
[]

[BCs]
  [./ydisp]
    type = FunctionDirichletBC
    variable = disp_y
    boundary = top
    function = 't'
  [../]
  [./yfix]
    type = DirichletBC
    variable = disp_y
    boundary = bottom
    value = 0
  [../]
  [./xfix]
    type = DirichletBC
    variable = disp_x
    boundary = 'top bottom'
    value = 0
  [../]
[]

[Materials]
  [./pfbulkmat]
    type = GenericConstantMaterial
    prop_names = 'gc_prop l visco'
    prop_values = '2.7e-3 0.015 1e-8'
  [../]
  [./elasticity_tensor]
    type = ComputeElasticityTensor
    C_ijkl = '121.2 80.77 0'
    fill_method = symmetric_isotropic
    base_name = uncracked
  [../]
  [./elastic]
    type = ComputeLinearElasticStress
    base_name = uncracked
  [../]
  [./cracked_stress]
    type = ComputeCrackedStress
    c = c
    kdamage = 1e-6
    F_name = E_el
    use_current_history_variable = true
    uncracked_base_name = uncracked
  [../]
[]

[Postprocessors]
  [./av_stress_yy]
    type = ElementAverageValue
    variable = stress_yy
  [../]
  [./av_strain_yy]
    type = SideAverageValue
    variable = disp_y
    boundary = top
  [../]
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
  [./react_y]
    type = SidesetReaction
    direction = '0 1 0'
    stress_tensor = stress
    boundary = top
  [../]
[]

[Preconditioning]
  [./smp]
    type = SMP
    full = true
  [../]
[]

[Executioner]
  type = Transient

  solve_type = PJFNK
  petsc_options_iname = '-pc_type -pc_factor_mat_solving_package'
  petsc_options_value = 'lu superlu_dist'

  nl_rel_tol = 1e-8
  l_tol = 1e-4
  l_max_its = 100
  nl_max_its = 10

  dt = 125e-6
  dtmin = 1e-8
  num_steps = 64
[]

[Outputs]
  exodus = true
[]
