# quarter cylinder | internal & external pressure | plane strain condition

[GlobalParams]
  displacements = 'disp_x disp_y'
[]

[Mesh]
  [generated]
    type = AnnularMeshGenerator
    nr = 300
    nt = 60
    rmin = 1
    rmax = 2
    dmin = 0
    dmax = 90
  []
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
[]

[BCs]
  [Pressure]
    [./inner]
      boundary = rmin
      factor = 10
    [../]
    [./outer]
      boundary = rmax
      factor = 20
    [../]
  []
  [./disp_y]
    type = DirichletBC
    variable = disp_y
    boundary = dmin
    value = 0
  [../]
  [./disp_x]
    type = DirichletBC
    variable = disp_x
    boundary = dmax
    value = 0
  [../]
[]

[Materials]
  [./elasticity_tensor]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 1e9
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
  [./element_value_sampler]
    type = ElementValueSampler
    variable = 'stress_xx stress_yy stress_xy stress_rr stress_rt stress_tt strain_xx strain_yy strain_xy strain_rr strain_rt strain_tt'
    sort_by = id
    execute_on = 'final'
  [../]
  [./point_value_sampler]
    type = PointValueSampler
    variable = 'stress_xx stress_yy stress_xy stress_rr stress_rt stress_tt strain_xx strain_yy strain_xy strain_rr strain_rt strain_tt'
    points = '1.0 0.0 0.0  2.0 0.0 0.0  0.0 1.0 0.0  0.0 2.0 0.0'
    sort_by = id
    execute_on = 'final'
  [../]
[]

[Outputs]
  csv = true
  exodus = true
  execute_on = 'final'
[]    