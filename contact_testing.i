#Toy Geometries to test contact
#TG1 is two square blocks stacked on top of each other, binder on top of crystal
#
#TG2 and 3 are the same - a square of crystal surrounded on 2 sides by binder and 2 sides by Dirichlett BC.
#3 differs from 2 because it has an added Dirchlett BC at the top.
#
#For TG1:
#
#Use the binder_block_tg1
#Use the mesh combiner with tg1
#Use the first contact block, the one with 800 and 102
#Make sure the bottom BC DOES NOT INCLUDE binder_bottom
#
#For TG2 and 3:
#
#Use binder_block_tg23 and all the included block remover and sideset blocks
#Use the mesh combiner that includes the binder and all the new boundaries
#Use the second contact block, the one with 812 and 102
#Use the relevant BCs: 
#  The bottom should include sd1_bottom AND binder_bottom
#  The top should be included depending on whether TG2 or 3 is being tested   
#
#The relevant blocks are marked in the code as well.
#


[Mesh]

  type = MeshGeneratorMesh
  patch_update_strategy = iteration


###################################################################################
#Binder geometry for TG1
###################################################################################
  #  [binder_block_tg1]
  #   type = GeneratedMeshGenerator
  #   dim = 2
  #   nx = 10
  #   ny = 10
  #   xmin = 1e+2
  #   xmax = 2e+2
  #   ymin = 1e+2
  #   ymax = 2e+2
  #   boundary_id_offset = 800
  #   subdomain_ids = 800
  #   boundary_name_prefix = 'binder'
  #   elem_type = QUAD4
  # []  

###################################################################################
#Binder geometry for TG2 and 3
###################################################################################

 [binder_block_tg23]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 10
    ny = 10
    xmin = 0
    xmax = 2e+2
    ymin = 0
    ymax = 2e+2
    boundary_id_offset = 800
    subdomain_ids = 800
    boundary_name_prefix = 'binder'
    elem_type = QUAD4
  []

  [./binder_rm]
    type = SubdomainBoundingBoxGenerator
    input = binder_block_tg23
    block_id = 200
    bottom_left = '1e+2 0 0' 
    top_right = '2e+2 1e+2 0'
  []

  [./binder_rm_nodeset]
    type = BoundingBoxNodeSetGenerator
    input = binder_rm
    new_boundary = 801
    bottom_left = '1e+2 0 0' 
    top_right = '2e+2 1e+2 0'
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
    bottom_left = '0.95e+2 0.9e+2 0'
    top_right = '2.1e+2 1.1e+2 0'
  []

  [binder_inner_left]
    type = SideSetsFromBoundingBoxGenerator
    input = binder
    included_boundaries = 815
    boundary_new = 813
    bottom_left = '0.9e+2 0 0'
    top_right = '1.1e+2 1.05e+2 0'
  []


#
#Crystal geometry, constant across all toy geometries.
#

  [crystal]
    type = GeneratedMeshGenerator
    nx = 21
    ny = 9
    dim = 2
    xmin = 1e+2
    xmax = 2e+2
    ymin = 0
    ymax = 1e+2
    boundary_id_offset = 100
    subdomain_ids = 100
    boundary_name_prefix = 'sd1'
  []

###################################################################################
#Mesh Combiner for TG1
###################################################################################


  # [crystal_subdomain]
  #   type = CombinerGenerator
  #   inputs = 'binder_block_tg1 crystal' #binder_inner_right binder_inner_left binder_inner_bottom binder_inner_top 
  # []

###################################################################################
#Mesh Combiner for TG2 and 3
###################################################################################
  
  [crystal_subdomain]
    type = CombinerGenerator
    inputs = 'binder binder_inner_top binder_inner_left crystal' #binder_inner_right binder_inner_left binder_inner_bottom binder_inner_top 
  []
  
  
[]


[Contact]

###################################################################################
#Contact for TG1
###################################################################################

  # [bc_inner_top]
  #   primary = 800
  #   secondary = 102
  #   #formulation = mortar
  #   penalty = 1e+8
  #   model = frictionless
  # []

###################################################################################
#Contact for TG2 and 3
###################################################################################
  
  [bc_inner_top]
    primary = 812
    secondary = 102
    #formulation = mortar
    penalty = 1e+8
    model = frictionless
  []

[]  


[GlobalParams]
  displacements = 'disp_x disp_y'
[]

[Variables]
  [./disp_x]
    order = FIRST
    family = LAGRANGE
  [../]
  [./disp_y]
    order = FIRST
    family = LAGRANGE
  [../]
[]


[AuxVariables]

#Initialize independent variables

  [./temp]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./irr]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./initial_x]
    order = CONSTANT
    family = MONOMIAL
  [../]

#Initialize dependent variables

  [./strain_x]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./strain_y]
    order = CONSTANT
    family = MONOMIAL
  [../]
 
[]



[Functions]

  [./temp_def]
    type = ConstantFunction
    value = 800
  [../]
  [./irr_def]
    type = ConstantFunction
    value = ${irr_value}
  [../]
  [./initial_x_def]
    type = ConstantFunction
    value = 700
  [../]

[]


[Kernels]
  [./SolidMechanics]
    eigenstrain_names = 'thermal_strain irr_strain'
  [../]
[]


[AuxKernels]

  [./initial_x]
    type = FunctionAux
    variable = initial_x
    function = initial_x_def
    use_displaced_mesh = false
  [../]
  [./tempfuncaux]
    type = FunctionAux
    variable = temp
    function = temp_def
    use_displaced_mesh = false
  [../]
  [./irrfuncaux]
    type = FunctionAux
    variable = irr
    function = irr_def
    use_displaced_mesh = false
  [../]

[]



[BCs]

  [./right]
    type = DirichletBC
    boundary = 'binder_right sd1_right'
    variable = disp_x
    value = 0.
  [../]
###################################################################################
#For TG1, use the boundary line with only sd1_bottom
#For TG2 and 3, use sd1_bottom AND binder_bottom
###################################################################################
  [./bottom]
    type = DirichletBC
    boundary = 'sd1_bottom binder_bottom'
    #boundary = 'sd1_bottom'
    variable = disp_y
    value = 0.
  [../]

###################################################################################
#Dectivate the BC below only for TG2.
###################################################################################

  # [./top]
  #   type = DirichletBC
  #   boundary = 'binder_top'
  #   variable = disp_y
  #   value = 0.
  # [../]

  
[]


[Materials]

#
#  Binder proerties
# 

  [./binder_elasticity_tensor]
    block = '800'
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 10e6
    poissons_ratio = 0.01
  [../]


  [./binder_therm_prefactor]
    type = DerivativeParsedMaterial
    block = '800'
    coupled_variables = 'temp'
    property_name = binder_therm_prefactor
    constant_names = 'a T' 
    constant_expressions = '1.3e-5 298'
    expression = '(a*(temp-T))'
  [../]
  [./binder_thermal_strain]
      type = ComputeVariableEigenstrain
      block = '800'
      eigen_base = '1 0 0 0 1 0 0 0 1'
      args = 'temp'
      prefactor = binder_therm_prefactor
      eigenstrain_name = thermal_strain
  [../]

  [./binder_irr_prefactor]
    type = DerivativeParsedMaterial
    block = '800'
    coupled_variables = 'irr initial_x'
    property_name = binder_irr_prefactor
    constant_names = 'm' 
    constant_expressions = '0'
    expression = '((m*irr)/100)'
[../]
[./binder_irr_strain]
    type = ComputeVariableEigenstrain
    block = '800'
    eigen_base = '1 0 0 0 1 0 0 0 1'
    args = 'irr'
    prefactor = binder_irr_prefactor
    eigenstrain_name = irr_strain
[../]


#
#  Crystal properties
#

#
#  Mechanical strain
#
  [./elasticity_tensor]
    type = ComputeElasticityTensor
    block = '100'
    fill_method = orthotropic
    C_ijkl = '1.095e12 3.65e10 1.095e12 2.8568e8 9.549e6 9.549e6 0.01 0.01 0.3 0.3 0.01 0.01'
   [../]
#
#  Thermal expansion eigenstrain
#
  [./therm_prefactor]
    type = DerivativeParsedMaterial
    block = '100'
    coupled_variables = 'temp'
    property_name = therm_prefactor
    constant_names = 'a T' 
    constant_expressions = '1.3e-5 298'
    expression = '(a*(temp-T))'
  [../]
  [./thermal_strain]
      type = ComputeVariableEigenstrain
      block = '100'
      #eigen_base = '1 0 0 0 1 0 0 0 1'
      eigen_base = '-0.0577 0 0 0 1 0 0 0 1'
      args = 'temp'
      prefactor = therm_prefactor
      eigenstrain_name = thermal_strain
  [../]

#
#   Irradiation eigenstrain 
#

  [./irr_prefactor]
      type = DerivativeParsedMaterial
      block = '100'
      coupled_variables = 'irr initial_x'
      property_name = irr_prefactor
      constant_names = 'm' 
      constant_expressions = '1.185'
      #constant_expressions = '11.85'
      expression = '((m*irr)/100)'
#        expression = '((m*irr)/100) *initial_x'
  [../]
  [./irr_strain]
      type = ComputeVariableEigenstrain
      block = '100'
      #eigen_base = '1 0 0 0 1 0 0 0 1'
      eigen_base = '-0.31 0 0 0 1 0 0 0 1'
      args = 'irr'
      prefactor = irr_prefactor
      eigenstrain_name = irr_strain
  [../]
 
  [./strain]
    type = ComputeSmallStrain
    displacements = 'disp_x disp_y'
    eigenstrain_names = 'thermal_strain irr_strain'
  [../]

  [./stress]
    type = ComputeLinearElasticStress
  [../]

[]


[Preconditioning]
  [./prec1]
    type = SMP
    full = true
  [../]
[]
[Executioner]
  type = Steady
  solve_type = 'Newton'
  petsc_options = '-snes_ksp_ew'
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = 'lu superlu_dist'
[]

[Outputs]
  exodus = true
[]

[VectorPostprocessors]
  [center_disp_y]
    type = NodalValueSampler
    execute_on = 'timestep_end'
    variable = 'disp_y'
    boundary = '802'
    sort_by = x
    #unique_node_execute = 'True'
  []
[]  

