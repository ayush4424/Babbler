# Open-hole tension, quarter model, plane strain: mechanics (parent) app.
# Damage d comes from fracture.i (staggered MultiApp, as in RACCOON's tutorials).
# Units: N, mm, MPa. Alumina: E = 380 GPa, nu = 0.26, K_IC = 5.2 MPa sqrt(m), sigma_c = 350 MPa.
#
#   raccoon-opt -i elasticity.i mesh_file=/abs/path/hole_R0.2.msh u_max=0.02 dt=5e-5

mesh_file = hole.msh
E = 380e3
nu = 0.26
K = '${fparse E/3/(1-2*nu)}'
G = '${fparse E/2/(1+nu)}'
Gc = 0.06635          # K_IC^2 (1 - nu^2) / E
l = 0.08278           # AT1: sigma_c = sqrt(3 Gc E' / (8 l)) = 350 MPa, E' = E / (1 - nu^2)
u_max = 0.02          # top displacement at which to stop if the plate has not failed
dt = 5e-5

[MultiApps]
  [fracture]
    type = TransientMultiApp
    input_files = fracture.i
    cli_args = 'Gc=${Gc};l=${l};mesh_file=${mesh_file}'
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
[]

[GlobalParams]
  displacements = 'disp_x disp_y'
[]

[Mesh]
  [file]
    type = FileMeshGenerator
    file = ${mesh_file}
  []
  [nodesets]
    # gmsh meshes only carry side sets; the reaction-force sum needs node sets
    type = NodeSetsFromSideSetsGenerator
    input = file
  []
[]

[Variables]
  [disp_x]
  []
  [disp_y]
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
[]

[Materials]
  [bulk]
    type = ADGenericConstantMaterial
    prop_names = 'K G'
    prop_values = '${K} ${G}'
  []
  [degradation]
    type = PowerDegradationFunction
    f_name = g
    function = (1-d)^p*(1-eta)+eta
    phase_field = d
    parameter_names = 'p eta '
    parameter_values = '2 1e-6'
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
  [stress]
    type = ComputeSmallDeformationStress
    elasticity_model = elasticity
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
  [Fmax]
    type = TimeExtremeValue
    postprocessor = Fy
  []
  [d_max]
    type = NodalExtremeValue
    variable = d
  []
[]

[UserObjects]
  # Stop once the plate has failed (force below half of its peak)
  [failed]
    type = Terminator
    expression = 'Fmax > 0 & Fy < 0.5 * Fmax'
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = 'lu       superlu_dist'
  automatic_scaling = true
  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-10
  dt = ${dt}
  end_time = ${u_max}
  fixed_point_max_its = 50
  accept_on_max_fixed_point_iteration = true
  fixed_point_rel_tol = 1e-8
  fixed_point_abs_tol = 1e-10
[]

[Outputs]
  exodus = true
  csv = true
  print_linear_residuals = false
[]
