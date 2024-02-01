# Wave propogation in 1D using Newmark time integration
#
# The test is for an 1D bar element of length 4m  fixed on one end
# with a sinusoidal pulse dirichlet boundary condition applied to the other end.
# beta and gamma are Newmark time integration parameters
# The equation of motion in terms of matrices is:
#
# M*accel +  K*disp = 0
#
# Here M is the mass matrix, K is the stiffness matrix
#
# This equation is equivalent to:
#
# density*accel + Div Stress= 0
#
# The first term on the left is evaluated using the Inertial force kernel
# The last term on the left is evaluated using StressDivergenceTensors
#
# The displacement at the second, third and fourth node at t = 0.1 are
# -8.021501116638234119e-02, 2.073994362053969628e-02 and  -5.045094181261772920e-03, respectively

[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 10
  ny = 10
  #nz = 1
  xmin = 0.0
  xmax = 1
  ymin = 0.0
  ymax = 1
  #zmin = 0.0
  #zmax = 0.1
[]


[Variables]
  [./disp_x]
  [../]
  [./disp_y]
  [../]
 # [./disp_z]
  #[../]
[]

[AuxVariables]
  [./vel_x]
  [../]
  [./accel_x]
  [../]
  ###
 # [./vel_z]
 # [../]
 # [./accel_z]
 # [../]
  [./stress_xx]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./strain_xx]
    order = CONSTANT
    family = MONOMIAL
  [../]

[]

[Kernels]
  [./TensorMechanics]
    displacements = 'disp_x disp_y'
  [../]
  [./inertia_x]
    type = InertialForce
    variable = disp_x
    velocity = vel_x
    acceleration = accel_x
    beta = 0.25
    gamma = 0.5
    eta=0.0
  [../]
  ###
  #[./inertia_z]
  #  type = InertialForce
  #  variable = disp_z
  #  velocity = vel_z
  #  acceleration = accel_z
  #  beta = 0.3025
  #  gamma = 0.6
  #  eta = 0.0
  #[../]

[]

[AuxKernels]
  [./accel_x]
    type = NewmarkAccelAux
    variable = accel_x
    displacement = disp_x
    velocity = vel_x
    beta = 0.25
    execute_on = timestep_end
  [../]
  [./vel_x]
    type = NewmarkVelAux
    variable = vel_x
    acceleration = accel_x
    gamma = 0.5
    execute_on = timestep_end
  [../]
  ###
#del
  [./stress_xx]
    type = RankTwoAux
    rank_two_tensor = stress
    variable = stress_xx
    index_i = 0
    index_j = 1
  [../]
  [./strain_xx]
    type = RankTwoAux
    rank_two_tensor = total_strain
    variable = strain_xx
    index_i = 0
    index_j = 1
  [../]

[]


[BCs]
  [./bottom_y]
    type = DirichletBC
    variable = disp_y
    boundary = bottom
    value=0.0
  [../]
##
 #
  #[./right_x]
  #  type = DirichletBC
   # variable = disp_x
   # boundary = right
   # value=0.0
  #[../]
  #
  [./left_x]
    type = DirichletBC
    variable = disp_x
    boundary = left
    value=0.0
  [../]
  #
 #
  #
  #
  #
  ##
#
 [./right_x]
  type = NeumannBC
  variable = disp_x
  boundary = right
  value = 1
[../]
[]

[Materials]
  [./Elasticity_tensor]
    type = ComputeIsotropicElasticityTensor
    block = 0
    youngs_modulus = 1
    poissons_ratio= 0
  [../]

  [./strain]
    type = ComputeSmallStrain
    block = 0
    displacements = 'disp_x disp_y'
  [../]

  [./stress]
    type = ComputeLinearElasticStress
    block = 0
  [../]

  [./density]
    type = GenericConstantMaterial
    block = 0
    prop_names = 'density'
    prop_values = '1'
  [../]

[]

[Executioner]
  type = Transient
  start_time = 0
  end_time = 0.5
  l_tol = 1e-12
  nl_rel_tol = 1e-12
  dt = 0.05
[]


#[Functions]
#  [./displacement_bc]
#    type = PiecewiseLinear
#    data_file = 'sine_wave.csv'
#    format = columns
#  [../]
#[]

[Postprocessors]
  [./_dt]
    type = TimestepSize
  [../]
  [./disp_1]
    type = NodalVariableValue
    nodeid = 1
    variable = disp_x
  [../]
  [./disp_2]
    type = NodalVariableValue
    nodeid = 3
    variable = disp_x
  [../]
  #
  #
[]

[Outputs]
  exodus = true
  perf_graph = true
[]
