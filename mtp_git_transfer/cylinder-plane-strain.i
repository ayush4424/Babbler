# quarter cylinder | internal & external pressure | plane strain condition

[GlobalParams]
  displacements = 'disp_x disp_y'
[]

[Mesh]
  file = 27-02-struct.msh
[]

[AuxVariables]
  [./rad_disp]
  [../]
[]

[Modules/TensorMechanics/Master]
  [all]
    strain = SMALL
    incremental = true
    add_variables = true
    out_of_plane_direction = z
    generate_output = 'stress_xx stress_xy stress_yy stress_zz strain_xx strain_xy strain_yy strain_zz'
    planar_formulation = PLANE_STRAIN
  []
[]

[AuxVariables]
  [./stress_xx]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./stress_xy]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./stress_yy]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./strain_xx]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./strain_xy]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./strain_yy]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./stress_rr]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./stress_rt]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./stress_tt]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./strain_rr]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./strain_rt]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./strain_tt]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[AuxKernels]
  [./stress_xx]
    type = RankTwoAux
    rank_two_tensor = stress
    variable = stress_xx
    index_i = 0
    index_j = 0
  [../]
  [./stress_xy]
    type = RankTwoAux
    rank_two_tensor = stress
    variable = stress_xy
    index_i = 0
    index_j = 1
  [../]
  [./stress_yy]
    type = RankTwoAux
    rank_two_tensor = stress
    variable = stress_yy
    index_i = 1
    index_j = 1
  [../]
  [./strain_xx]
    type = RankTwoAux
    rank_two_tensor = total_strain
    variable = strain_xx
    index_i = 0
    index_j = 0
  [../]
  [./strain_xy]
    type = RankTwoAux
    rank_two_tensor = total_strain
    variable = strain_xy
    index_i = 0
    index_j = 1
  [../]
  [./strain_yy]
    type = RankTwoAux
    rank_two_tensor = total_strain
    variable = strain_yy
    index_i = 1
    index_j = 1
  [../]
  [./stress_rr]
    type = CylindricalRankTwoAux
    rank_two_tensor = stress
    variable = stress_rr
    index_i = 0
    index_j = 0
    center_point = '0 0 0'
  [../]
  [./stress_rt]
    type = CylindricalRankTwoAux
    rank_two_tensor = stress
    variable = stress_rt
    index_i = 0
    index_j = 1
    center_point = '0 0 0'
  [../]
  [./stress_tt]
    type = CylindricalRankTwoAux
    rank_two_tensor = stress
    variable = stress_tt
    index_i = 1
    index_j = 1
    center_point = '0 0 0'
  [../]
  [./strain_rr]
    type = CylindricalRankTwoAux
    rank_two_tensor = total_strain
    variable = strain_rr
    index_i = 0
    index_j = 0
    center_point = '0 0 0'
  [../]
  [./strain_rt]
    type = CylindricalRankTwoAux
    rank_two_tensor = total_strain
    variable = strain_rt
    index_i = 0
    index_j = 1
    center_point = '0 0 0'
  [../]
  [./strain_tt]
    type = CylindricalRankTwoAux
    rank_two_tensor = total_strain
    variable = strain_tt
    index_i = 1
    index_j = 1
    center_point = '0 0 0'
  [../]
  [./rad_disp_aux]
    type = RadialDisplacementCylinderAux
    variable = rad_disp
    origin = '0 0 0'
  [../]
[]

[BCs]
  [Pressure]
    [./inner]
      boundary = inner
      factor = 10
    [../]
    [./outer]
      boundary = outer
      factor = 20
    [../]
  []
  [./disp_y]
    type = DirichletBC
    variable = disp_y
    boundary = 'bottom-1 bottom-2'
    value = 0
  [../]
  [./disp_x]
    type = DirichletBC
    variable = disp_x
    boundary = 'left-1 left-2'
    value = 0
  [../]
[]

[Materials]
    [./elasticity_1]
      type = ComputeIsotropicElasticityTensor
      block = mat-1
      youngs_modulus = 1e6
      poissons_ratio = 0.3
    [../]
    [./elasticity_2]
      type = ComputeIsotropicElasticityTensor
      block = mat-2
      youngs_modulus = 2e6
      poissons_ratio = 0.3
    [../]
  [stress]
    type = ComputeStrainIncrementBasedStress
  []
[]

[Executioner]
  type = Steady
  solve_type = LINEAR
  petsc_options_iname = '-pc_hypre_type'
  petsc_options_value = 'boomeramg'
[]

[VectorPostprocessors]
  [./element_value_sampler-r]
    type = ElementValueSampler
    variable = stress_rr
    sort_by = id
  [../]
  [./element_value_sampler-t]
    type = ElementValueSampler
    variable = stress_tt
    sort_by = id
  [../]
[]
  
[Outputs]
  file_base = outputs/28-02/cylinder/cylinder-plane-strain
  csv = true
  exodus = true
  execute_on = 'final'
[]    
