# Elastoplastic open-hole tension: aluminium 6061-T6, quarter model, thin slab (plane stress).
# J2 (von Mises) plasticity with isotropic hardening, finite strain. Units: N, mm, MPa.
#
#   babbler-opt -i plate.i mesh_file=/abs/path/metal.msh
#
# Handbook values for 6061-T6 (e.g. ASM / MMPDS typical): E = 68.9 GPa, nu = 0.33,
# 0.2 % yield 276 MPa, ultimate 310 MPa, elongation about 12 %. The hardening curve below
# is a simple piecewise-linear fit through those numbers (true stress vs plastic strain).

mesh_file = metal.msh
E = 68.9e3
nu = 0.33
thickness = 2.0       # slab thickness [mm]; only the plane-stress condition matters
u_max = 0.6           # top displacement at the end [mm]
nsteps = 120

[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
[]

[Mesh]
  [file]
    type = FileMeshGenerator
    file = ${mesh_file}
  []
  [slab]
    type = AdvancedExtruderGenerator
    input = file
    direction = '0 0 1'
    heights = ${thickness}
    num_layers = 1
    bottom_boundary = 100
    top_boundary = 101
  []
  [names]
    type = RenameBoundaryGenerator
    input = slab
    old_boundary = '100 101'
    new_boundary = 'back front'
  []
  [nodesets]
    type = NodeSetsFromSideSetsGenerator
    input = names
  []
[]

[Physics/SolidMechanics/QuasiStatic]
  [all]
    strain = FINITE
    add_variables = true
    generate_output = 'vonmises_stress stress_yy'
  []
[]

[AuxVariables]
  [effective_plastic_strain]
    order = CONSTANT
    family = MONOMIAL
  []
[]

[AuxKernels]
  [effective_plastic_strain]
    type = MaterialRealAux
    variable = effective_plastic_strain
    property = effective_plastic_strain
  []
[]

[Functions]
  [hardening]
    # true stress [MPa] vs effective plastic strain
    type = PiecewiseLinear
    x = '0     0.01  0.03  0.06  0.10  0.20'
    y = '276   290   302   310   316   320'
  []
[]

[BCs]
  [pull]
    type = FunctionDirichletBC
    variable = disp_y
    boundary = top
    function = '${u_max} * t'
  []
  [sym_y]
    type = DirichletBC
    variable = disp_y
    boundary = bottom
    value = 0
  []
  [sym_x]
    type = DirichletBC
    variable = disp_x
    boundary = left
    value = 0
  []
  [no_rigid_z]
    # one face held in z; the slab is free to thin (plane stress)
    type = DirichletBC
    variable = disp_z
    boundary = back
    value = 0
  []
[]

[Materials]
  [elasticity]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = ${E}
    poissons_ratio = ${nu}
  []
  [plasticity]
    type = IsotropicPlasticityStressUpdate
    yield_stress = 276
    hardening_function = hardening
  []
  [stress]
    type = ComputeMultipleInelasticStress
    inelastic_models = plasticity
  []
[]

[Postprocessors]
  [force]
    type = SidesetReaction
    direction = '0 1 0'
    stress_tensor = stress
    boundary = top
  []
  [nominal_stress]
    # remote stress on the gross section: F / (W/2 * t)
    type = ParsedPostprocessor
    pp_names = force
    function = 'force / (20 * ${thickness})'
  []
  [max_plastic_strain]
    type = ElementExtremeValue
    variable = effective_plastic_strain
  []
  [max_von_mises]
    type = ElementExtremeValue
    variable = vonmises_stress
  []
  [top_disp]
    type = FunctionValuePostprocessor
    function = '${u_max} * t'
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = 'lu       superlu_dist'
  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-8
  l_max_its = 50
  start_time = 0
  end_time = 1
  dt = '${fparse 1 / nsteps}'
[]

[Outputs]
  exodus = true
  csv = true
[]
