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
  allow_renumbering = false
[]


[Variables]
  [./disp_x]
  [../]
  [./disp_y]
  [../]
[]

[AuxVariables]
  [./vel_x]
    [InitialCondition]
	  type=ConstantIC
	  value=2
    [../]
  []
  [./accel_x]
  [../]
  [./vel_y]
  [../]
  [./accel_y]
  [../]
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
	planar_formulation = PLANE_STRAIN
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
  [./inertia_y]
    type = InertialForce
    variable = disp_y
    velocity = vel_y
    acceleration = accel_y
    beta = 0.25
    gamma = 0.5
    eta=0.0
  [../]
  [./gravity]
    type = Gravity
    variable = disp_y
    value = 0
  [../]

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
  [./accel_y]
    type = NewmarkAccelAux
    variable = accel_y
    displacement = disp_y
    velocity = vel_y
    beta = 0.25
    execute_on = timestep_end
  [../]
  [./vel_y]
    type = NewmarkVelAux
    variable = vel_y
    acceleration = accel_y
    gamma = 0.5
    execute_on = timestep_end
  [../]
  [./stress_yy]
    type = RankTwoAux
    rank_two_tensor = stress
    variable = stress_xx
    index_i = 0
    index_j = 0
  [../]
  [./strain_yy]
    type = RankTwoAux
    rank_two_tensor = total_strain
    variable = strain_xx
    index_i = 0
    index_j = 0
  [../]

[]


[BCs]
  [./bottom_x]
    type = DirichletBC
    variable = disp_y
    boundary = bottom
    value=0.0
  [../]
  [./left_y]
    type = DirichletBC
    variable = disp_x
    boundary = left
    value=0.0
  [../]
  [./bottom_y]
    type = FunctionNeumannBC
	variable = disp_x
	boundary = right
	function = pressure
  [../]
[]

[Materials]
  [./Elasticity_tensor]
    youngs_modulus = 1000 
    poissons_ratio = 0.3
    type = ComputeIsotropicElasticityTensor
    block = 0
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

[Controls] # turns off inertial terms for the first time step
  [./period0]
    type = TimePeriod
    disable_objects = '*/vel_x */vel_y */accel_x */accel_y */inertia_x */inertia_y'
    start_time = 0.0
    end_time = 0.000625 # dt used in the simulation
  [../]
[../]

[Executioner]
  type = Transient
  start_time = 0
  end_time = 0.5
  l_tol = 1e-12
  nl_rel_tol = 1e-12
  dt = 0.000625
[]


[Functions]
  [./pressure]
    type = PiecewiseLinear
    x = '0.0 0.1 0.2 0.3 0.4 0.5'
    y = '0.0 0.0005 0.001 0.001 0.001 0.001'
    scale_factor = 1e3
  [../]
[]

[Postprocessors]
  [./_dt]
    type = TimestepSize
  [../]
  [./disp_1]
    type = NodalVariableValue
    nodeid = 1
    variable = disp_y
  [../]
  [./disp_2]
    type = NodalVariableValue
    nodeid = 3
    variable = disp_y
  [../]
  [./disp_3]
    type = NodalVariableValue
    nodeid = 10
    variable = disp_y
  [../]
  [./disp_4]
    type = NodalVariableValue
    nodeid = 14
    variable = disp_y
  [../]
[]

[Outputs]
  exodus = true
  perf_graph = true
[]
