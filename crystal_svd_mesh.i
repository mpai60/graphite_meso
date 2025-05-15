#This input file models a single graphite crysal surrounded by a binder. The crystal should have
#its expansion constrained by the binder. As a result, the 3 Mrozowski cracks inside the crystal
#should close. In the vertical direction, the crystal should initially shrink as the cracks close,
#and once they do, it should expand. 
#
#This model replicates work done by Dr. Marsden in ABAQUS.
#
#Notes on planned material properties. These are not entirely implemented yet:
#
#   Mechanical strains:
#      Orthtropic crystal, temperature-independent Young's moduli and Poisson Ratios 
#      Isotropic binder, no irradiation eigenstrain, isotropic thermal expansion.
#   Eigenstrain 1:
#     Temperature dependent CTE for both materials
#   Eigenstrain 2:
#     Irradiation-induced dimensional change, dependent on dose AND temperature

###################################################################################
[Mesh]

  type = MeshGeneratorMesh
  patch_update_strategy = iteration


#
# Binder
#
  
   [binder_block]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 16
    ny = 16
    xmin = 3e+2
    xmax = 4.00e+2
    ymin = 0
    ymax = 0.5e+2
    boundary_id_offset = 800
    subdomain_ids = 800
    boundary_name_prefix = 'binder'
    elem_type = QUAD4
  []

  [binder_rm]
    type = SubdomainBoundingBoxGenerator
    input = binder_block
    block_id = 200
    # bottom_left = '0.75e+2 0 0' 
    # top_right = '4.0e+2 0.375e+2 0'
    bottom_left = '3.5e+2 0 0' 
    top_right = '4.0e+2 0.375e+2 0'
  []

  [binder_rm_nodeset]
    type = BoundingBoxNodeSetGenerator
    input = binder_rm
    new_boundary = 807
    bottom_left = '3.5e+2 0 0' 
    top_right = '4.0e+2 0.375e+2 0'
  []

  [binder]
    type = BlockDeletionGenerator
    block = 200
    input = binder_rm_nodeset
    new_boundary = 815
  []  
  
  [binder_inner_top]
    type = SideSetsFromBoundingBoxGenerator
    input = binder
    included_boundaries = 815
    boundary_new = 812
    bottom_left = '0.65e2 0.35e+2 0'
    top_right = '4.2e+2 0.45e+2 0'
  []


  [binder_inner_left]
    type = SideSetsFromBoundingBoxGenerator
    input = binder
    included_boundaries = 815
    boundary_new = 813
    # bottom_left = '0.6e+2 0 0'
    # top_right = '0.76e+2 0.38e+2 0'
    bottom_left = '3.4e+2 0 0'
    top_right = '3.6e+2 0.38e+2 0'
  []


#
# Crystal
#

  [crystal_sd1]
    type = GeneratedMeshGenerator
    nx = 13
    ny = 15
    dim = 2
    xmin = 3.5e+2
    xmax = 4.0e+2
    ymin = 0
    ymax = 0.1875e+2
    boundary_id_offset = 100
    subdomain_ids = 100
    boundary_name_prefix = 'sd1'
  []

  [crystal_sd2]
    type = GeneratedMeshGenerator
    nx = 13
    ny = 15
    dim = 2
    xmin = 3.5e+2
    xmax = 4.0e+2
    ymin = 0.1875e+2
    ymax = 0.375e+2
    boundary_id_offset = 200
    subdomain_ids = 200
    boundary_name_prefix = 'sd2'
  []
  
  [crystal_stitch]
    type = StitchedMeshGenerator
    inputs = 'crystal_sd1 crystal_sd2'
    stitch_boundaries_pairs = 'sd1_top sd2_bottom' 
  []


  [crystal_subdomain]
    type = CombinerGenerator
    inputs = 'binder binder_inner_top binder_inner_left crystal_stitch' #binder binder_inner_right  crystal_sd3 crystal_sd4 binder_inner_bottom  
  []

#
# Mrozowski Cracks
#

  [crack1_subdomain]
    type = SubdomainBoundingBoxGenerator
    input = crystal_subdomain
    block_id = 510
    bottom_left = '3.75e+2 0.175e+2 0' 
    top_right = '4.0e+2 0.2e+2 0'
  []

  [crack1_nodeset]
    type = BoundingBoxNodeSetGenerator
    input = crack1_subdomain
    new_boundary = crack1_ns
    bottom_left = '3.75e+2 0.175e+2 0' 
    top_right = '4.0e+2 0.2e+2 0'
  []

  [crystal_c1]
    type = BlockDeletionGenerator
    block = 510
    input = crack1_nodeset
    new_boundary = 500
  []  

  [crack2_subdomain]
    type = SubdomainBoundingBoxGenerator
    input = crystal_c1
    block_id = 610
    bottom_left = '3.75e+2 0 0' 
    top_right = '4.0e+2 0.0125e+2 0'
  []

  [crack2_nodeset]
    type = BoundingBoxNodeSetGenerator
    input = crack2_subdomain
    new_boundary = crack2_ns
    # bottom_left = '1e+2 0 0' 
    # top_right = '4.0e+2 0.0125e+2 0'
    bottom_left = '3.75e+2 0 0' 
    top_right = '4.0e+2 0.0125e+2 0'
    
  []

  [crystal_c2]
    type = BlockDeletionGenerator
    block = 610
    input = crack2_nodeset
    new_boundary = 600
  [] 


#
# Defining crack boundaries for contact
#

  [crack1_lower]
    type = SideSetsFromBoundingBoxGenerator
    input = crystal_c2
    included_boundaries = 500
    boundary_new = 511
    bottom_left = '0.7e+2 0.165e+2 0'
    top_right = '4.1e+2 0.18e+2 0'
  []

  [crack1_upper]
    type = SideSetsFromBoundingBoxGenerator
    input = crystal_c2
    included_boundaries = 500
    boundary_new = 512
    bottom_left = '0.7e+2 0.195e+2 0'
    top_right = '4.1e+2 0.21e+2 0'
  []

  [crack2_upper]
    type = SideSetsFromBoundingBoxGenerator
    input = crystal_c2
    included_boundaries = 600
    boundary_new = 612
    bottom_left = '0.7e+2 0.012e+2 0'
    top_right = '4.1e+2 0.02e+2 0'
  []

  [rve_final]
    type = CombinerGenerator
    inputs = 'crystal_c2 crack1_upper crack1_lower crack2_upper' #crack3_lower crack3_upper crack2_lower 
  []
[]
##################################################################################
[Contact]

# #
# # Left side fixtures
# #

  # [bc_100_left]
  #   primary = 103
  #   secondary = 813
  #   penalty = 1e+8
  #   #formulation = mortar
  #   model = frictionless
  # []
  # [bc_200_left]
  #   primary = 203
  #   secondary = 813
  #   penalty = 1e+8
  #   #formulation = mortar
  #   model = frictionless
  # []


# #
# # Top Fixture 
# #
  [bc_top]
    primary = 202
    secondary = 812
    penalty = 1e+8
    #formulation = mortar
    model = frictionless
  []


# #
# # Mrozowski crack contact
# #

#   # [crack1_contact]
#   #   primary = 512
#   #   secondary = 511
#   #   penalty = 1e+8
#   #    #formulation = mortar
#   #   model = glued
#   # []

[]


##################################################################################
[GlobalParams]
  displacements = 'disp_x disp_y'
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
[]

###################################################################################
[AuxVariables]

  [temp]
    order = CONSTANT
    family = MONOMIAL
  []
  [irr]
    order = CONSTANT
    family = MONOMIAL
  []
  [initial_x]
    order = CONSTANT
    family = MONOMIAL
  []

  [strain_x]
    order = CONSTANT
    family = MONOMIAL
  []
  [strain_y]
    order = CONSTANT
    family = MONOMIAL
  []
 
[]


###################################################################################
[Functions]

  [temp_def]
    type = ConstantFunction
    value = 800
  []
  [irr_def]
    type = ConstantFunction
    value = 2
  []
  [initial_x_def]
    type = ConstantFunction
    value = 825
  []

[]

###################################################################################
[Kernels]
  [SolidMechanics]
    eigenstrain_names = 'thermal_strain irr_strain'
  []
[]

###################################################################################
[AuxKernels]

  [initial_x]
    type = FunctionAux
    variable = initial_x
    function = initial_x_def
    use_displaced_mesh = false
  []
  [tempfuncaux]
    type = FunctionAux
    variable = temp
    function = temp_def
    use_displaced_mesh = false
  []
  [irrfuncaux]
    type = FunctionAux
    variable = irr
    function = irr_def
    use_displaced_mesh = false
  []

[]


###################################################################################
[BCs]

  [right]
    type = DirichletBC
    boundary = 'binder_right sd1_right sd2_right'
    variable = disp_x
    value = 0.
  []
  [bottom]
    type = DirichletBC
    boundary = 'binder_bottom sd1_bottom'
    variable = disp_y
    value = 0.
  []
  # [top]
  #   type = DirichletBC
  #   boundary = 'binder_top'
  #   variable = disp_y
  #   value = 0.
  # []
  
[]

###################################################################################
[Materials]

#
# Binder proerties
# 

  [binder_elasticity_tensor]
    block = '800'
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 10e9
    poissons_ratio = 0.01
  []

  [binder_therm_prefactor]
    type = DerivativeParsedMaterial
    block = '800'
    coupled_variables = 'temp'
    property_name = 'binder_therm_prefactor'
    constant_names = 'a T' 
    constant_expressions = '0 298'
    expression = '(a*(temp-T))'
  []

  [binder_thermal_strain]
      type = ComputeVariableEigenstrain
      block = '800'
      eigen_base = '1 0 0 0 1 0 0 0 1'
      args = 'temp'
      prefactor = 'binder_therm_prefactor'
      eigenstrain_name = 'thermal_strain'
  []

  [binder_irr_prefactor]
    type = DerivativeParsedMaterial
    block = '800'
    coupled_variables = 'irr initial_x'
    property_name = binder_irr_prefactor
    constant_names = 'm' 
    constant_expressions = '0'
    expression = '((m*irr)/100)'
[]

[binder_irr_strain]
    type = ComputeVariableEigenstrain
    block = '800'
    eigen_base = '1 0 0 0 1 0 0 0 1'
    args = 'irr'
    prefactor = 'binder_irr_prefactor'
    eigenstrain_name = 'irr_strain'
[]


#
# Crystal properties
#

#
# Mechanical strain
#
  [elasticity_tensor]
    type = ComputeElasticityTensor
    block = '100 200'
    fill_method = 'orthotropic'
    C_ijkl = '1.095e12 3.65e10 1.095e12 2.8568e8 9.549e6 9.549e6 0.01 0.01 0.3 0.3 0.01 0.01'
   []

#
# Thermal expansion eigenstrain
#

  [therm_prefactor]
    type = DerivativeParsedMaterial
    block = '100 200'
    coupled_variables = 'temp'
    property_name = 'therm_prefactor'
    constant_names = 'a T' 
    constant_expressions = '1.3e-5 298'
    expression = '(a*(temp-T))'
  []

  [thermal_strain]
      type = ComputeVariableEigenstrain
      block = '100 200'
      #eigen_base = '1 0 0 0 1 0 0 0 1'
      eigen_base = '-0.0577 0 0 0 1 0 0 0 1'
      args = 'temp'
      prefactor = 'therm_prefactor'
      eigenstrain_name = 'thermal_strain'
  []

#
#  Irradiation eigenstrain 
#

  [irr_prefactor]
      type = DerivativeParsedMaterial
      block = '100 200'
      coupled_variables = 'irr initial_x'
      property_name = irr_prefactor
      constant_names = 'm' 
      constant_expressions = '1.185'
      expression = '((m*irr)/100)'
  []

  [irr_strain]
      type = ComputeVariableEigenstrain
      block = '100 200'
      #eigen_base = '1 0 0 0 1 0 0 0 1'
      eigen_base = '-0.31 0 0 0 1 0 0 0 1'
      args = 'irr'
      prefactor = 'irr_prefactor'
      eigenstrain_name = 'irr_strain'
  []
 
#
# Overall strain and stress
#

  [strain]
    type = ComputeSmallStrain
    displacements = 'disp_x disp_y'
    eigenstrain_names = 'thermal_strain irr_strain'
  []

  [stress]
    type = ComputeLinearElasticStress
  []

[]

###################################################################################
[Preconditioning]
  [prec1]
    type = SMP
    full = true
  []
[]

[Executioner]
  type = Steady
  solve_type = 'Newton'
  #line_search = 'none'
  # petsc_options = '-snes_ksp_ew'
  # petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  # petsc_options_value = 'lu superlu_dist'
  petsc_options = '-snes_ksp_ew -pc_svd_monitor'
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package -pc_type'
  petsc_options_value = 'lu superlu_dist svd'
  #nl_abs_tol = 2.8313e+9
[]

[Outputs]
  exodus = true
[]

# [VectorPostprocessors]
#   [center_disp_y]
#     type = NodalValueSampler
#     execute_on = 'timestep_end'
#     variable = 'disp_y'
#     boundary = '102'
#     sort_by = x
#     unique_node_execute = 'True'
#   []  
#   [center_disp_x]
#     type = NodalValueSampler
#     execute_on = 'timestep_end'
#     variable = 'disp_x'
#     boundary = '103'
#     sort_by = y
#     unique_node_execute = 'True'
#   []  
# []  


[Outputs]
  [out]
      type = CSV
      execute_on = 'TIMESTEP_END FINAL'
      create_final_symlink = true
  []
[]

############################################################################# ######
