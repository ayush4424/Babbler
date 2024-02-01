[Mesh]
    file="new.msh"
[]


[GlobalParams]
  displacements = 'disp_x disp_y'
  #out_of_plane_strain = strain_zz
[]

[Variables]
  [disp_x]
    order = FIRST
    family = LAGRANGE
  []
  [disp_y]
    order = FIRST
    family = LAGRANGE
  []
  #[strain_zz]
  #[]
[]

[Modules/TensorMechanics/Master]
  [all]
    planar_formulation= PLANE_STRAIN
    strain= SMALL
    add_variables = true
    #use_displaced_mesh = true
    generate_output='vonmises_stress stress_xx stress_yy stress_xy stress_zz strain_zz'
  []
[]

[BCs]
  [bottom_y]
    type = DirichletBC
    variable = disp_y
    boundary = bottom
    value = 0.0
  []
  [left_x]
    type = DirichletBC
    variable = disp_x
    boundary = left
    value = 0.0
  []
  [Pressure]
    [rightl]
     boundary = right
     function = -1
    []
    [up]
     boundary = top
     function = t
    []
  []
[]

[Materials]
  [Elasticity_tensor]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 1000
    poissons_ratio=0.3
  []
  [stress]
    type = ComputeLinearElasticStress
  []
[]

[Preconditioning]
    [SMP]
        type= SMP
        full=true
    []
[]

[Executioner]
  type = Steady # Steady state problem
  solve_type = NEWTON # Perform a Newton solve
  petsc_options_iname = '-pc_type -pc_hypre_type' 
  petsc_options_value = ' hypre    boomeramg'
[]

[Outputs]
  exodus = true
[]
