# Linear elastic static analysis of a meshed STEP part (from step2mesh.py).
#
# Defaults: steel in N and mm (E in MPa), faces named `fixed` fully clamped, uniform
# traction on faces named `load` (positive = pulls outward, i.e. tension).
# Override anything on the command line, e.g.
#   babbler-opt -i static_structural.i mesh_file=bracket.msh traction=50 E=70e3 nu=0.33
#
# Stress output is a linear (FIRST order) field so peak stresses at notches are not
# averaged away over each element.

mesh_file = part.msh
order = SECOND        # SECOND for TET10 meshes (step2mesh default), FIRST for TET4
E = 210e3             # Young's modulus [MPa]
nu = 0.3              # Poisson's ratio
traction = 100        # traction on the `load` faces [MPa]; positive = tension

[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
[]

[Mesh]
  [file]
    type = FileMeshGenerator
    file = ${mesh_file}
  []
[]

[Variables]
  [disp_x]
    order = ${order}
  []
  [disp_y]
    order = ${order}
  []
  [disp_z]
    order = ${order}
  []
[]

[Physics/SolidMechanics/QuasiStatic]
  [all]
    strain = SMALL
    add_variables = false
    generate_output = 'vonmises_stress stress_xx stress_yy stress_zz stress_xy stress_yz stress_zx max_principal_stress'
    material_output_order = FIRST
    material_output_family = MONOMIAL
  []
[]

[BCs]
  [fixed_x]
    type = DirichletBC
    variable = disp_x
    boundary = fixed
    value = 0
  []
  [fixed_y]
    type = DirichletBC
    variable = disp_y
    boundary = fixed
    value = 0
  []
  [fixed_z]
    type = DirichletBC
    variable = disp_z
    boundary = fixed
    value = 0
  []
  [Pressure]
    [load]
      boundary = load
      # MOOSE pressure pushes into the surface, so tension is a negative pressure
      factor = ${fparse -traction}
    []
  []
[]

[Materials]
  [elasticity]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = ${E}
    poissons_ratio = ${nu}
  []
  [stress]
    type = ComputeLinearElasticStress
  []
[]

[Postprocessors]
  [max_von_mises]
    type = ElementExtremeValue
    variable = vonmises_stress
  []
  [max_principal]
    type = ElementExtremeValue
    variable = max_principal_stress
  []
  [max_disp_x]
    type = NodalExtremeValue
    variable = disp_x
  []
  [volume]
    type = VolumePostprocessor
  []
[]

[Executioner]
  type = Steady
  solve_type = NEWTON
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = 'lu       superlu_dist'
[]

[Outputs]
  exodus = true
  csv = true
[]
