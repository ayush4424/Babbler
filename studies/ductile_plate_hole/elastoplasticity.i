# Ductile phase-field fracture of an aluminium 6061-T6 plate with a hole (RACCOON).
# Quarter model of a 40 x 100 mm plate, 10 mm hole, thin slab (plane stress), pulled along y.
# J2 plasticity with power-law hardening; damage is driven by elastic energy + plastic work
# (PF-CZM rational degradation, Wu 2017 / RACCOON tutorial mode1_ductile_fracture).
# Units: N, mm, MPa.
#
#   mpiexec -n 4 raccoon-opt -i elastoplasticity.i mesh_file=/abs/path/plate.msh

mesh_file = plate.msh
thickness = 2.0
E = 68.9e3
nu = 0.33
K = '${fparse E/3/(1-2*nu)}'
G = '${fparse E/2/(1+nu)}'
sigma_y = 276        # 0.2 % yield [MPa]
n = 27.98            # power law sigma = sigma_y (1 + ep/ep0)^(1/n), fitted to 276 -> 320 MPa
ep0 = 0.00272
Gc = 10.88           # K_IC^2 (1 - nu^2) / E with K_IC = 29 MPa sqrt(m)
psic = 37.4          # damage onset: elastic + plastic work at ~12 % plastic strain (uniaxial)
l = 0.05             # regularization length [mm]. PF-CZM needs m = 3 Gc / (8 l psic) > ~2, i.e.
                     # l < ~0.055 mm here; l = 0.4 (m = 0.27) gave an unstable snap-back and the
                     # damage solve never converged. Mesh: 0.025 mm along the crack path.

[MultiApps]
  [fracture]
    type = TransientMultiApp
    input_files = fracture.i
    cli_args = 'Gc=${Gc};psic=${psic};l=${l};mesh_file=${mesh_file};thickness=${thickness}'
    execute_on = 'TIMESTEP_END'
  []
[]

[Transfers]
  [from_d]
    type = MultiAppCopyTransfer
    from_multi_app = fracture
    variable = d
    source_variable = d
  []
  [to_psie_active]
    type = MultiAppCopyTransfer
    to_multi_app = fracture
    variable = psie_active
    source_variable = psie_active
  []
  [to_psip_active]
    type = MultiAppCopyTransfer
    to_multi_app = fracture
    variable = psip_active
    source_variable = psip_active
  []
[]

[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
  volumetric_locking_correction = true
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

[Variables]
  [disp_x]
  []
  [disp_y]
  []
  [disp_z]
  []
[]

[AuxVariables]
  [fy]
  []
  [d]
  []
[]

[Kernels]
  [solid_x]
    type = ADStressDivergenceTensors
    variable = disp_x
    component = 0
  []
  [solid_y]
    type = ADStressDivergenceTensors
    variable = disp_y
    component = 1
    save_in = fy
  []
  [solid_z]
    type = ADStressDivergenceTensors
    variable = disp_z
    component = 2
  []
[]

[BCs]
  [pull]
    type = FunctionDirichletBC
    variable = disp_y
    boundary = top
    function = 't'
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
    type = DirichletBC
    variable = disp_z
    boundary = back
    value = 0
  []
[]

[Materials]
  [bulk_properties]
    type = ADGenericConstantMaterial
    prop_names = 'K G l Gc psic'
    prop_values = '${K} ${G} ${l} ${Gc} ${psic}'
  []
  [crack_geometric]
    type = CrackGeometricFunction
    f_name = alpha
    function = 'd'
    phase_field = d
  []
  [degradation]
    type = RationalDegradationFunction
    f_name = g
    function = (1-d)^p/((1-d)^p+(Gc/psic*xi/c0/l)*d*(1+a2*d+a2*a3*d^2))*(1-eta)+eta
    phase_field = d
    material_property_names = 'Gc psic xi c0 l '
    parameter_names = 'p a2 a3 eta '
    parameter_values = '2 -0.5 0 1e-6'
  []
  [strain]
    type = ADComputeSmallStrain
  []
  [elasticity]
    type = SmallDeformationIsotropicElasticity
    bulk_modulus = K
    shear_modulus = G
    phase_field = d
    degradation_function = g
    decomposition = NONE
    output_properties = 'psie_active'
    outputs = exodus
  []
  [plasticity]
    type = SmallDeformationJ2Plasticity
    hardening_model = power_law_hardening
    output_properties = 'effective_plastic_strain'
    outputs = exodus
  []
  [power_law_hardening]
    type = PowerLawHardening
    degradation_function = g
    yield_stress = ${sigma_y}
    exponent = ${n}
    reference_plastic_strain = ${ep0}
    phase_field = d
    output_properties = 'psip_active'
    outputs = exodus
  []
  [stress]
    type = ComputeSmallDeformationStress
    elasticity_model = elasticity
    plasticity_model = plasticity
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
  [nominal_stress]
    type = ParsedPostprocessor
    pp_names = Fy
    function = 'Fy / (20 * ${thickness})'
  []
  [Fmax]
    type = TimeExtremeValue
    postprocessor = Fy
  []
  [d_max]
    type = NodalExtremeValue
    variable = d
  []
  [max_plastic_strain]
    type = ADElementExtremeMaterialProperty
    mat_prop = effective_plastic_strain
    value_type = max
  []
[]

[UserObjects]
  [broken]
    type = Terminator
    expression = 'Fmax > 0 & Fy < 0.2 * Fmax'
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = 'lu       superlu_dist'
  automatic_scaling = true
  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-8
  end_time = 1.0
  [TimeStepper]
    type = FunctionDT
    # elastic-plastic part in large steps, fine steps from just before damage onset (~0.35 mm)
    function = 'if(t < 0.33, 1e-2, 1e-3)'
  []
  fixed_point_max_its = 20
  accept_on_max_fixed_point_iteration = true
  fixed_point_rel_tol = 1e-6
  fixed_point_abs_tol = 1e-8
[]

[Outputs]
  exodus = true
  csv = true
  print_linear_residuals = false
[]
