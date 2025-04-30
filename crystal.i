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
    nx = 33
    ny = 18
    xmin = 0
    xmax = 8.25e+2
    ymin = 0
    ymax = 2.25e+2
    boundary_id_offset = 800
    subdomain_ids = 800
    boundary_name_prefix = 'binder'
    elem_type = QUAD4
  []

  [binder_rm]
    type = SubdomainBoundingBoxGenerator
    input = binder_block
    block_id = 200
    bottom_left = '0.75e+2 0.75e+2 0' 
    top_right = '7.5e+2 1.5e+2 0'
  []

  [binder_rm_nodeset]
    type = BoundingBoxNodeSetGenerator
    input = binder_rm
    new_boundary = 807
    bottom_left = '0.75e+2 0.75e+2 0' 
    top_right = '7.5e+2 1.5e+2 0'
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
    bottom_left = '0.7e+2 1.499e+2 0'
    top_right = '7.55e+2 1.7e+2 0'
  []

  [binder_inner_bottom]
    type = SideSetsFromBoundingBoxGenerator
    input = binder
    included_boundaries = 815
    boundary_new = 810
    bottom_left = '0.7e+2 0.6e+2 0'
    top_right = '7.55e+2 0.9e+2 0'
  []

  [binder_inner_left]
    type = SideSetsFromBoundingBoxGenerator
    input = binder
    included_boundaries = 815
    boundary_new = 813
    bottom_left = '0.6e+2 0.7e+2 0'
    top_right = '0.76e+2 1.53e+2 0'
  []

   [binder_inner_right]
    type = SideSetsFromBoundingBoxGenerator
    input = binder
    included_boundaries = 815
    boundary_new = 811
    bottom_left = '7.49e+2 0.73e+2 0'
    top_right = '7.8e+2 1.52e+2 0'
  []




#
# Crystal
#

  [crystal_sd1]
    type = GeneratedMeshGenerator
    nx = 25
    ny = 15
    dim = 2
    xmin = 0.75e+2
    xmax = 7.5e+2
    ymin = 0.75e+2
    ymax = 0.9325e+2
    boundary_id_offset = 100
    subdomain_ids = 100
    boundary_name_prefix = 'sd1'
  []

  [crystal_sd2]
    type = GeneratedMeshGenerator
    nx = 25
    ny = 15
    dim = 2
    xmin = 0.75e+2
    xmax = 7.5e+2
    ymin = 0.9325e+2
    ymax = 1.125e+2
    boundary_id_offset = 200
    subdomain_ids = 200
    boundary_name_prefix = 'sd2'
  []
  
  [crystal_sd3]
    type = GeneratedMeshGenerator
    nx = 25
    ny = 15
    dim = 2
    xmin = 0.75e+2
    xmax = 7.5e+2
    ymin = 1.125e+2 
    ymax = 1.31875e+2
    boundary_id_offset = 300
    subdomain_ids = 300
    boundary_name_prefix = 'sd3'
  []

  [crystal_sd4]
    type = GeneratedMeshGenerator
    nx = 25
    ny = 15
    dim = 2
    xmin = 0.75e+2
    xmax = 7.5e+2
    ymin = 1.31875e+2
    ymax = 1.5e+2
    boundary_id_offset = 400
    subdomain_ids = 400
    boundary_name_prefix = 'sd4'
  []



  [crystal_subdomain]
    type = CombinerGenerator
    inputs = 'binder binder_inner_right binder_inner_left binder_inner_bottom binder_inner_top crystal_sd1 crystal_sd2 crystal_sd3 crystal_sd4'
  []


#
# Mrozowski Cracks
#

  [crack1_subdomain]
    type = SubdomainBoundingBoxGenerator
    input = crystal_subdomain
    block_id = 510
    bottom_left = '1e+2 0.91875e+2 0' 
    top_right = '7.25e+2 0.94375e+2 0'
  []

  [crack1_nodeset]
    type = BoundingBoxNodeSetGenerator
    input = crack1_subdomain
    new_boundary = crack1_ns
    bottom_left = '1e+2 0.91875e+2 0' 
    top_right = '7.25e+2 0.94375e+2 0'
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
    bottom_left = '1e+2 1.1125e+2 0' 
    top_right = '7.25e+2 1.1375e+2 0'
  []

  [crack2_nodeset]
    type = BoundingBoxNodeSetGenerator
    input = crack2_subdomain
    new_boundary = crack2_ns
    bottom_left = '1e+2 1.1125e+2 0' 
    top_right = '7.25e+2 1.1375e+2 0'
  []

  [crystal_c2]
    type = BlockDeletionGenerator
    block = 610
    input = crack2_nodeset
    new_boundary = 600
  [] 

  [crack3_subdomain]
    type = SubdomainBoundingBoxGenerator
    input = crystal_c2
    block_id = 710
    bottom_left = '1e+2 1.30625e+2 0' 
    top_right = '7.25e+2 1.33125e+2 0'
  []

  [crack3_nodeset]
    type = BoundingBoxNodeSetGenerator
    input = crack3_subdomain
    new_boundary = crack3_ns
    bottom_left = '1e+2 1.30625e+2 0' 
    top_right = '7.25e+2 1.33125e+2 0'
  []

  [rve_r1]
    type = BlockDeletionGenerator
    block = 710
    input = crack3_nodeset
    new_boundary = 700
  [] 
  

#
# Defining crack boundaries for contact
#

  [crack1_lower]
    type = SideSetsFromBoundingBoxGenerator
    input = rve_r1
    included_boundaries = 500
    boundary_new = 511
    bottom_left = '0.7e+2 0.8e+2 0'
    top_right = '7.7e+2 0.9188e+2 0'
  []

  [crack1_upper]
    type = SideSetsFromBoundingBoxGenerator
    input = rve_r1
    included_boundaries = 500
    boundary_new = 512
    bottom_left = '0.7e+2 0.95e+2 0'
    top_right = '7.7e+2 0.97e+2 0'
  []

  [crack2_lower]
    type = SideSetsFromBoundingBoxGenerator
    input = rve_r1
    included_boundaries = 600
    boundary_new = 611
    bottom_left = '0.7e+2 0.95e+2 0'
    top_right = '7.7e+2 1.113e+2 0'
  []

  [crack2_upper]
    type = SideSetsFromBoundingBoxGenerator
    input = rve_r1
    included_boundaries = 600
    boundary_new = 612
    bottom_left = '0.7e+2 1.137e+2 0'
    top_right = '7.7e+2 1.2e+2 0'
  []

  [crack3_lower]
    type = SideSetsFromBoundingBoxGenerator
    input = rve_r1
    included_boundaries = 700
    boundary_new = 711
    bottom_left = '0.7e+2 1.25e+2 0'
    top_right = '7.7e+2 1.310e+2 0'
  []

  [crack3_upper]
    type = SideSetsFromBoundingBoxGenerator
    input = rve_r1
    included_boundaries = 700
    boundary_new = 712
    bottom_left = '0.7e+2 1.3312e+2 0'
    top_right = '7.7e+2 1.34e+2 0'
  []
  
  [rve_final]
    type = CombinerGenerator
    inputs = 'rve_r1 crack1_lower crack1_upper crack2_lower crack2_upper crack3_lower crack3_upper'
  []
  
[]
##################################################################################
[Contact]

#
# Left side fixtures
#

  [bc_100_left]
    primary = 103
    secondary = 813
    penalty = 1e+8
    model = frictionless
  []
  [bc_200_left]
    primary = 203
    secondary = 813
    penalty = 1e+8
    model = frictionless
  []
  [bc_300_left]
    primary = 303
    secondary = 813
    penalty = 1e+8
    model = frictionless
  []
  [bc_400_left]
    primary = 403
    secondary = 813
    penalty = 1e+8
    model = frictionless
  []

#
# Right side fixtures
#

  [bc_100_right]
    primary = 101
    secondary = 811
    penalty = 1e+8
    model = frictionless
  []
  [bc_200_right]
    primary = 201
    secondary = 811
    penalty = 1e+8
    model = frictionless
  []
  [bc_300_right]
    primary = 301
    secondary = 811
    penalty = 1e+8
    model = frictionless
  []
  [bc_400_right]
    primary = 401
    secondary = 811
    penalty = 1e+8
    model = frictionless
  []

#
# Bottom and top fixtures
#

  [bc_bottom]
    primary = 100
    secondary = 810
    #penalty = 1e+8
    model = frictionless
  []

  [bc_top]
    primary = 812
    secondary = 402
    #penalty = 1e+8
    model = frictionless
  []

#
# Contact within crystal subdomains
#
  [sd1_sd2]
    primary = 102
    secondary = 200
    #penalty = 1e+8
    model = frictionless
  []

  [sd2_sd3]
    primary = 202
    secondary = 300
    #penalty = 1e+8
    model = frictionless
  []

  [sd3_sd4]
    primary = 302
    secondary = 400
    #penalty = 1e+8
    model = frictionless
  []

#
# Mrozowski crack contact
#

  # [crack1_contact]
  #   primary = 512
  #   secondary = 511
  #   penalty = 1e+8
  #   model = frictionless
  # []
  # [crack2_contact]
  #   primary = 612
  #   secondary = 611
  #   penalty = 1e+8
  #   model = frictionless
  # []
  # [crack3_contact]
  #   primary = 712
  #   secondary = 711
  #   penalty = 1e+8
  #   model = frictionless
  # []

  [crack1_contact_bottom]
    primary = 511
    secondary = 512
    #formulation = 'penalty'
    #penalty = 1e+8
    model = frictionless
  []
  [crack2_contact_bottom]
    primary = 611
    secondary = 612
    #formulation = 'penalty'
    #penalty = 1e+8
    model = frictionless 
  []
  [crack3_contact_bottom]
    primary = 711
    secondary = 712
    #formulation = 'penalty'
    #penalty = 1e+8
    model = frictionless
  []
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

#irr_value = 9
###################################################################################
[Functions]

  [temp_def]
    type = ConstantFunction
    value = 800
  []
  [irr_def]
    type = ConstantFunction
    #value = ${irr_value}
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

  [left]
    type = DirichletBC
    boundary = 'binder_left'
    variable = disp_x
    value = 0.
  []
  [bottom]
    type = DirichletBC
    boundary = 'binder_bottom'
    variable = disp_y
    value = 0.
  []
  
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
    block = '100 200 300 400'
    fill_method = 'orthotropic'
    C_ijkl = '1.095e12 3.65e10 1.095e12 2.8568e8 9.549e6 9.549e6 0.01 0.01 0.3 0.3 0.01 0.01'
   []

#
# Thermal expansion eigenstrain
#

  [therm_prefactor]
    type = DerivativeParsedMaterial
    block = '100 200 300 400'
    coupled_variables = 'temp'
    property_name = 'therm_prefactor'
    constant_names = 'a T' 
    constant_expressions = '1.3e-5 298'
    expression = '(a*(temp-T))'
  []

  [thermal_strain]
      type = ComputeVariableEigenstrain
      block = '100 200 300 400'
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
      block = '100 200 300 400'
      coupled_variables = 'irr initial_x'
      property_name = irr_prefactor
      constant_names = 'm' 
      constant_expressions = '1.185'
      expression = '((m*irr)/100)'
  []

  [irr_strain]
      type = ComputeVariableEigenstrain
      block = '100 200 300 400'
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
  petsc_options = '-snes_ksp_ew'
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = 'lu superlu_dist'
  #line_search = 'none'
[]

[Outputs]
  exodus = true
[]

[VectorPostprocessors]
  [center_disp_y]
    type = NodalValueSampler
    execute_on = 'timestep_end'
    variable = 'disp_y'
    boundary = '402'
    sort_by = x
    unique_node_execute = 'True'
  []  
  [center_disp_x]
    type = NodalValueSampler
    execute_on = 'timestep_end'
    variable = 'disp_x'
    boundary = '303'
    sort_by = y
    unique_node_execute = 'True'
  []  
[]  


[Outputs]
  [out]
      type = CSV
      execute_on = 'TIMESTEP_END FINAL'
      create_final_symlink = true
  []
[]

###################################################################################
