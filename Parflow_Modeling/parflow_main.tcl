# SET PARAMETERS AND RUN PARFLOW-CLM IN DCEW DOMAIN USING TERRAIN-FOLLOWING GRID
# DETAILS:
# -- SPATIALLY DISTRIBUTED SOILS IN ALL DIMENSIONS
# -- 20M SUBSURFACE (1M: soil, 19M: bedrock)
# -- USES INITIAL CONDITION FILE FROM A DRAINAGE EXPERIMENT
# -- units: m/hr

# Import ParFlow TCL package
lappend   auto_path $env(PARFLOW_DIR)/bin
package   require parflow
namespace import Parflow::*

pfset     FileVersion    4

#------------------------------------------------------------
# Set up run outputs
#------------------------------------------------------------
exec mkdir "../outputs_01_pfclmwrf"
cd "../outputs_01_pfclmwrf"

#------------------------------------------------------------
# Set up run input paths
#------------------------------------------------------------
# Paths:
# path to initial condition file
set icdir			"../init_files"
# path to parflow_input
set pfindir		"../parflow_input"
# path to clm_input
set clmindir	"../clm_input"
# path to soil indicator 
set siindir 		"../parflow_input/geo_indi"
# path to forcing files  
set ffinidir	"../../../WRF-Data/DCEW-WY2009-300x315/1km-bilinear/"

#------------------------------------------------------------
# Set up run input file names
#------------------------------------------------------------
# Files:
# initial condition file from last drainage output
set pfif		 "pf_DCEW_30m.out.press.10950.pfb"
# initial file rename (from file.out.press.0----.pfb to file.out.press.init.pfb)
set ic0		  "pf_DCEW_30m.out.press.init.pfb"
# slope files
set sx		  "DCEW_30m.sx.pfb"
set sy 		  "DCEW_30m.sy.pfb"
# soil indicator file
set si			  "DCEW_30m.indi.pfb"
# clm input files
set vegp	  "drv_vegp.dat"
set clmin	  "drv_clmin.dat"
set vegm	  "drv_vegm.alluv.dat"
set narr	  "narr_1hr.txt"

#------------------------------------------------------------
# Set up run info
#------------------------------------------------------------
set runname                            "pfclmwrf_DCEW_30m"
set startcount                          0
set starttime                           0
set stoptime                            4368
set dmpinterval                         1
set tstep                               0.02
set istep                               0
set rc                                  50
set nmanning                            0.000094

set x0                                  0.0
set y0                                  0.0
set z0                                  -20.0

set nx                                  315
set ny                                  300 
set nz                                  20  

set dx                                  30.0
set dy                                  30.0
set dz                                  1.0

#------------------------------------------------------------
# Soil paramameters (Van Genuchten)
#------------------------------------------------------------

# ---------- Bed Rock (BR) ----------
set Perm_val_BR					  0.000001			
set Poros_val_BR			    0.0004
set RPerm_alpha_BR				3.5
set RPerm_n_BR					  2.0
set S_alpha_BR				    3.5
set S_n_BR							  2.0
set S_sres_BR						  0.126
set S_ssat_BR						  1.0

# ---------- Loamy sand (LS) ----------
set Perm_val_LS				    0.1459			
set Poros_val_LS			    0.41
set RPerm_alpha_LS			  12.4
set RPerm_n_LS				    2.28
set S_alpha_LS				    12.4
set S_n_LS				        2.28
set S_sres_LS				      0.057
set S_ssat_LS				      1.0
			
# ---------- Sandy loam (SL) ----------
set Perm_val_SL				    0.0442	
set Poros_val_SL			    0.41
set RPerm_alpha_SL			  7.5
set RPerm_n_SL			   	  1.89
set S_alpha_SL				    7.5
set S_n_SL				        1.89
set S_sres_SL				      0.065
set S_ssat_SL				      1.0		

# -------- Sandy clay loam (SCL) --------
set Perm_val_SCL			    0.0131	
set Poros_val_SCL			    0.39
set RPerm_alpha_SCL			  5.9
set RPerm_n_SCL			   	  1.48
set S_alpha_SCL				    5.9
set S_n_SCL				        1.48
set S_sres_SCL            0.1
set S_ssat_SCL				    1.0				

# ---------- Loam (L) ----------
set Perm_val_L				    0.0104	
set Poros_val_L			  	  0.43
set RPerm_alpha_L			    3.6
set RPerm_n_L			   	    1.56
set S_alpha_L				      3.6
set S_n_L				          1.56
set S_sres_L              0.078
set S_ssat_L				      1.0

# ---------- Clay (C) ----------
set Perm_val_C            0.002
set Poros_val_C           0.38
set RPerm_alpha_C         0.8
set RPerm_n_C             1.09
set S_alpha_C             0.8
set S_n_C                 1.09
set S_sres_C              0.068
set S_ssat_C              1.0

#------------------------------------------------------------
# Copy input files to run directory
#------------------------------------------------------------
# ParFlow Input
file copy -force    $pfindir/$sx            .
file copy -force    $pfindir/$sy            .
file copy -force    $siindir/$si            .
file copy -force    $icdir/$pfif          $ic0

# CLM Input
file copy -force    $clmindir/$vegp         .
file copy -force    $clmindir/$clmin        .
file copy -force    $clmindir/$vegm         .
file copy -force    $clmindir/$narr	        .

#------------------------------------------------------------
# Processor topology (P=x-direction,Q=y-direction,R=z-direction)
#------------------------------------------------------------
pfset Process.Topology.P                  21
pfset Process.Topology.Q                  16
pfset Process.Topology.R                  1

#------------------------------------------------------------
# Computational Grid
#------------------------------------------------------------
pfset ComputationalGrid.Lower.X           $x0
pfset ComputationalGrid.Lower.Y           $y0
pfset ComputationalGrid.Lower.Z           $z0 

pfset ComputationalGrid.NX                $nx 
pfset ComputationalGrid.NY                $ny 
pfset ComputationalGrid.NZ                $nz  

pfset ComputationalGrid.DX                $dx
pfset ComputationalGrid.DY                $dy
pfset ComputationalGrid.DZ                $dz

#------------------------------------------------------------

pfset Solver.Nonlinear.VariableDz       True
pfset dzScale.GeomNames                 domain
pfset dzScale.Type                      nzList
pfset dzScale.nzListNumber              20

pfset Cell.0.dzScale.Value              2.0
pfset Cell.1.dzScale.Value              2.0
pfset Cell.2.dzScale.Value              2.0
pfset Cell.3.dzScale.Value              2.0
pfset Cell.4.dzScale.Value              2.0
pfset Cell.5.dzScale.Value              2.0
pfset Cell.6.dzScale.Value              2.0
pfset Cell.7.dzScale.Value              2.0
pfset Cell.8.dzScale.Value              2.0
pfset Cell.9.dzScale.Value              1.0
pfset Cell.10.dzScale.Value             0.2
pfset Cell.11.dzScale.Value             0.1
pfset Cell.12.dzScale.Value             0.1
pfset Cell.13.dzScale.Value             0.1
pfset Cell.14.dzScale.Value             0.1
pfset Cell.15.dzScale.Value             0.1
pfset Cell.16.dzScale.Value             0.1
pfset Cell.17.dzScale.Value             0.1
pfset Cell.18.dzScale.Value             0.05
pfset Cell.19.dzScale.Value             0.05

#------------------------------------------------------------
# Timing (time units is set by units of permeability)
#------------------------------------------------------------
pfset TimingInfo.BaseUnit                 1.0
pfset TimingInfo.StartCount               $startcount
pfset TimingInfo.StartTime                $starttime
pfset TimingInfo.StopTime                 $stoptime
pfset TimingInfo.DumpInterval             $dmpinterval
pfset TimeStep.Type                       Constant
pfset TimeStep.Value                      $tstep

#------------------------------------------------------------
# Domain
#------------------------------------------------------------
pfset Domain.GeomName                     "domain"

#------------------------------------------------------------
# Names of the GeomInputs
#------------------------------------------------------------
pfset GeomInput.Names                     "box_input indi_input"

#------------------------------------------------------------
# SolidFile Geometry Input
#------------------------------------------------------------
pfset GeomInput.box_input.InputType      Box
pfset GeomInput.box_input.GeomName      "domain"

#------------------------------------------------------------
# Domain Geometry 
#------------------------------------------------------------
pfset Geom.domain.Lower.X                        $x0
pfset Geom.domain.Lower.Y                        $y0
pfset Geom.domain.Lower.Z                        $z0
 
pfset Geom.domain.Upper.X                        9450.0
pfset Geom.domain.Upper.Y                        9000.0
pfset Geom.domain.Upper.Z                        0.0
pfset Geom.domain.Patches                        "x-lower x-upper y-lower y-upper z-lower z-upper"

#------------------------------------------------------------
# Indicator Geometry Input
#------------------------------------------------------------

pfset GeomInput.indi_input.InputType      IndicatorField
pfset GeomInput.indi_input.GeomNames      "F1 F2 F3 F4 F5 F6"
pfset Geom.indi_input.FileName      $si

# Geometry input values
pfset GeomInput.F1.Value          0
pfset GeomInput.F2.Value          1
pfset GeomInput.F3.Value          3
pfset GeomInput.F4.Value          4
pfset GeomInput.F5.Value          5
pfset GeomInput.F6.Value          6

#------------------------------------------------------------
# Permeability (values in m/hr)
#------------------------------------------------------------

pfset Geom.Perm.Names          "domain F1 F2 F3 F4 F5 F6"
pfset Geom.domain.Perm.Type       Constant
pfset Geom.domain.Perm.Value      $Perm_val_LS

# Permeability input values
pfset Geom.F1.Perm.Type     Constant
pfset Geom.F1.Perm.Value    $Perm_val_BR	
pfset Geom.F2.Perm.Type     Constant
pfset Geom.F2.Perm.Value    $Perm_val_C
pfset Geom.F3.Perm.Type     Constant
pfset Geom.F3.Perm.Value    $Perm_val_L
pfset Geom.F4.Perm.Type     Constant
pfset Geom.F4.Perm.Value    $Perm_val_LS
pfset Geom.F5.Perm.Type     Constant
pfset Geom.F5.Perm.Value    $Perm_val_SCL
pfset Geom.F6.Perm.Type     Constant
pfset Geom.F6.Perm.Value    $Perm_val_SL

#------------------------------------------------------------
# Porosity
#------------------------------------------------------------

pfset Geom.Porosity.GeomNames          "domain F1 F2 F3 F4 F5 F6"
pfset Geom.domain.Porosity.Type       Constant
pfset Geom.domain.Porosity.Value      $Poros_val_LS

# Porosity input values
pfset Geom.F1.Porosity.Type     Constant
pfset Geom.F1.Porosity.Value    $Poros_val_BR
pfset Geom.F2.Porosity.Type     Constant
pfset Geom.F2.Porosity.Value    $Poros_val_C
pfset Geom.F3.Porosity.Type     Constant
pfset Geom.F3.Porosity.Value    $Poros_val_L
pfset Geom.F4.Porosity.Type     Constant
pfset Geom.F4.Porosity.Value    $Poros_val_LS
pfset Geom.F5.Porosity.Type     Constant
pfset Geom.F5.Porosity.Value    $Poros_val_SCL
pfset Geom.F6.Porosity.Type     Constant
pfset Geom.F6.Porosity.Value    $Poros_val_SL

#------------------------------------------------------------
# Relative Permeability 
#------------------------------------------------------------

pfset Phase.RelPerm.Type              VanGenuchten
pfset Phase.RelPerm.GeomNames          "domain F1 F2 F3 F4 F5 F6"
pfset Geom.domain.RelPerm.Alpha       $RPerm_alpha_LS
pfset Geom.domain.RelPerm.N           $RPerm_n_LS

# Relative Permeability input values
pfset Geom.F1.RelPerm.Alpha    $RPerm_alpha_BR
pfset Geom.F1.RelPerm.N        $RPerm_n_BR
pfset Geom.F2.RelPerm.Alpha    $RPerm_alpha_C
pfset Geom.F2.RelPerm.N        $RPerm_n_C
pfset Geom.F3.RelPerm.Alpha    $RPerm_alpha_L
pfset Geom.F3.RelPerm.N        $RPerm_n_L
pfset Geom.F4.RelPerm.Alpha    $RPerm_alpha_LS
pfset Geom.F4.RelPerm.N        $RPerm_n_LS
pfset Geom.F5.RelPerm.Alpha    $RPerm_alpha_SCL
pfset Geom.F5.RelPerm.N        $RPerm_n_SCL
pfset Geom.F6.RelPerm.Alpha    $RPerm_alpha_SL
pfset Geom.F6.RelPerm.N        $RPerm_n_SL

#------------------------------------------------------------
# Saturation 
#------------------------------------------------------------

pfset Phase.Saturation.Type               VanGenuchten
pfset Phase.Saturation.GeomNames          "domain F1 F2 F3 F4 F5 F6"
pfset Geom.domain.Saturation.Alpha       $S_alpha_LS
pfset Geom.domain.Saturation.N           $S_n_LS
pfset Geom.domain.Saturation.SRes        $S_sres_LS
pfset Geom.domain.Saturation.SSat        $S_ssat_LS

# Saturation input values
pfset Geom.F1.Saturation.Alpha    $S_alpha_BR
pfset Geom.F1.Saturation.N        $S_n_BR
pfset Geom.F1.Saturation.SRes     $S_sres_BR
pfset Geom.F1.Saturation.SSat     $S_ssat_BR
pfset Geom.F2.Saturation.Alpha    $S_alpha_C
pfset Geom.F2.Saturation.N        $S_n_C
pfset Geom.F2.Saturation.SRes     $S_sres_C
pfset Geom.F2.Saturation.SSat     $S_ssat_C
pfset Geom.F3.Saturation.Alpha    $S_alpha_L
pfset Geom.F3.Saturation.N        $S_n_L
pfset Geom.F3.Saturation.SRes     $S_sres_L
pfset Geom.F3.Saturation.SSat     $S_ssat_L
pfset Geom.F4.Saturation.Alpha    $S_alpha_LS
pfset Geom.F4.Saturation.N        $S_n_LS
pfset Geom.F4.Saturation.SRes     $S_sres_LS
pfset Geom.F4.Saturation.SSat     $S_ssat_LS
pfset Geom.F5.Saturation.Alpha    $S_alpha_SCL
pfset Geom.F5.Saturation.N        $S_n_SCL
pfset Geom.F5.Saturation.SRes     $S_sres_SCL
pfset Geom.F5.Saturation.SSat     $S_ssat_SCL
pfset Geom.F6.Saturation.Alpha    $S_alpha_SL
pfset Geom.F6.Saturation.N        $S_n_SL
pfset Geom.F6.Saturation.SRes     $S_sres_SL
pfset Geom.F6.Saturation.SSat     $S_ssat_SL

#------------------------------------------------------------
# Permeability Tensors
#------------------------------------------------------------
pfset Perm.TensorType                     TensorByGeom
pfset Geom.Perm.TensorByGeom.Names        "domain"
pfset Geom.domain.Perm.TensorValX         1.0d0
pfset Geom.domain.Perm.TensorValY         1.0d0
pfset Geom.domain.Perm.TensorValZ         1.0d0

#------------------------------------------------------------
# Specific Storage
#------------------------------------------------------------
pfset SpecificStorage.Type                Constant
pfset SpecificStorage.GeomNames           "domain"
pfset Geom.domain.SpecificStorage.Value   1.0e-4

#------------------------------------------------------------
# Phases
#------------------------------------------------------------
pfset Phase.Names                         "water"
pfset Phase.water.Density.Type            Constant
pfset Phase.water.Density.Value           1.0
pfset Phase.water.Viscosity.Type          Constant
pfset Phase.water.Viscosity.Value         1.0

#------------------------------------------------------------
# Contaminants
#------------------------------------------------------------
pfset Contaminants.Names                  ""

#------------------------------------------------------------
# Retardation
#------------------------------------------------------------
pfset Geom.Retardation.GeomNames          ""

#------------------------------------------------------------
# Gravity
#------------------------------------------------------------
pfset Gravity                             1.0

#------------------------------------------------------------
# Wells
#------------------------------------------------------------
pfset Wells.Names                         ""

#------------------------------------------------------------
# Mobility
#------------------------------------------------------------
pfset Phase.water.Mobility.Type        Constant
pfset Phase.water.Mobility.Value       1.0

#------------------------------------------------------------
# Time Cycles
#------------------------------------------------------------

pfset Cycle.Names                         "constant"
pfset Cycle.constant.Names                "alltime"
pfset Cycle.constant.alltime.Length        1
pfset Cycle.constant.Repeat               -1

#------------------------------------------------------------
# Boundary Conditions: Pressure
#------------------------------------------------------------
pfset BCPressure.PatchNames                 [pfget Geom.domain.Patches]

pfset Patch.x-lower.BCPressure.Type		              FluxConst
pfset Patch.x-lower.BCPressure.Cycle		            "constant"
pfset Patch.x-lower.BCPressure.alltime.Value	      0.0

pfset Patch.y-lower.BCPressure.Type		              FluxConst
pfset Patch.y-lower.BCPressure.Cycle		            "constant"
pfset Patch.y-lower.BCPressure.alltime.Value	      0.0

pfset Patch.z-lower.BCPressure.Type		              FluxConst
pfset Patch.z-lower.BCPressure.Cycle		            "constant"
pfset Patch.z-lower.BCPressure.alltime.Value	      0.0

pfset Patch.x-upper.BCPressure.Type		              FluxConst
pfset Patch.x-upper.BCPressure.Cycle		            "constant"
pfset Patch.x-upper.BCPressure.alltime.Value	      0.0

pfset Patch.y-upper.BCPressure.Type		              FluxConst
pfset Patch.y-upper.BCPressure.Cycle		            "constant"
pfset Patch.y-upper.BCPressure.alltime.Value	      0.0

pfset Patch.z-upper.BCPressure.Type		              OverlandFlow
pfset Patch.z-upper.BCPressure.Cycle		            "constant"
pfset Patch.z-upper.BCPressure.alltime.Value	      0.0

#------------------------------------------------------------
# Topo slopes in x-direction
#------------------------------------------------------------

pfset TopoSlopesX.Type                                "PFBFile"
pfset TopoSlopesX.GeomNames                           "domain"
pfset TopoSlopesX.FileName                            $sx

#------------------------------------------------------------
# Topo slopes in y-direction
#------------------------------------------------------------

pfset TopoSlopesY.Type                                "PFBFile"
pfset TopoSlopesY.GeomNames                           "domain"
pfset TopoSlopesY.FileName                            $sy

#------------------------------------------------------------
# Mannings coefficient
#------------------------------------------------------------
pfset Mannings.Type                                   "Constant"
pfset Mannings.GeomNames                              "domain"
pfset Mannings.Geom.domain.Value                      $nmanning

#------------------------------------------------------------
# Phase sources:
#------------------------------------------------------------
pfset PhaseSources.water.Type                         "Constant"
pfset PhaseSources.water.GeomNames                    "domain"
pfset PhaseSources.water.Geom.domain.Value            0.0

#------------------------------------------------------------
# Exact solution specification for error calculations
#------------------------------------------------------------
pfset KnownSolution                                   NoKnownSolution

#---------------------------------------------------------
# Initial conditions: water pressure
#---------------------------------------------------------
pfset ICPressure.Type                                 PFBFile
pfset ICPressure.GeomNames                            domain
pfset Geom.domain.ICPressure.RefPatch                 z-upper
pfset Geom.domain.ICPressure.FileName                 $ic0

#------------------------------------------------------------
# Set solver parameters
#------------------------------------------------------------
# ParFlow Solution
pfset Solver                                          Richards
pfset Solver.TerrainFollowingGrid                     True
pfset Solver.Nonlinear.VariableDz                     True
pfset Solver.MaxIter                                  5000000 
pfset Solver.Drop                                     1E-6
pfset Solver.AbsTol                                   1E-5
pfset Solver.MaxConvergenceFailures                   8

# New solver settings for Terrain Following Grid
pfset Solver.Nonlinear.EtaChoice                         EtaConstant
pfset Solver.Nonlinear.EtaValue                          0.001
pfset Solver.Nonlinear.UseJacobian                       True 
pfset Solver.Nonlinear.DerivativeEpsilon                 1e-16
pfset Solver.Nonlinear.StepTol				                   1e-30
pfset Solver.Nonlinear.Globalization                     LineSearch
pfset Solver.Nonlinear.MaxIter				                   50
pfset Solver.Nonlinear.ResidualTol			                 1E-5

pfset Solver.Linear.KrylovDimension                      50
pfset Solver.Linear.MaxRestarts                          2
pfset Solver.Linear.Preconditioner                       PFMG
pfset Solver.Linear.Preconditioner.PCMatrixType          FullJacobian
pfset Solver.Linear.Preconditioner.SymmetricMat          Nonsymmetric

# CLM:
pfset Solver.LSM                                      CLM
pfset Solver.CLM.CLMFileDir                           "clm_output/"
pfset Solver.CLM.Print1dOut                           False
pfset Solver.BinaryOutDir                             False
pfset Solver.CLM.CLMDumpInterval                      1

pfset Solver.CLM.EvapBeta                             Linear
pfset Solver.CLM.VegWaterStress                       Pressure
pfset Solver.CLM.ResSat                               0.1
pfset Solver.CLM.WiltingPoint                         0.12
pfset Solver.CLM.FieldCapacity                        0.98
pfset Solver.CLM.IrrigationType                       none

pfset Solver.CLM.MetForcing                           2D
pfset Solver.CLM.MetFileName                          "NLDAS"
pfset Solver.CLM.MetFilePath                          $ffinidir
pfset Solver.CLM.IstepStart                           $istep
pfset Solver.CLM.ReuseCount				                     $rc

#Writing output (no binary except Pressure, all silo):
pfset Solver.PrintSubsurfData                         True
pfset Solver.PrintPressure                            True
pfset Solver.PrintSaturation                          True
pfset Solver.PrintCLM				                          True
pfset Solver.PrintMask				                        True
pfset Solver.PrintLSMSink			                        True
pfset Solver.WriteCLMBinary                           False

pfset Solver.WriteSiloSpecificStorage                 True
pfset Solver.WriteSiloMannings                        False
pfset Solver.WriteSiloMask                            False
pfset Solver.WriteSiloSlopes                          False
pfset Solver.WriteSiloSubsurfData                     False
pfset Solver.WriteSiloPressure                        False
pfset Solver.WriteSiloSaturation                      False
pfset Solver.WriteSiloEvapTrans                       False
pfset Solver.WriteSiloEvapTransSum                    False
pfset Solver.WriteSiloOverlandSum                     False
pfset Solver.WriteSiloCLM                             False

#------------------------------------------------------------
# Run simulation
#------------------------------------------------------------
puts " "
puts "Distributing input files..."
pfset ComputationalGrid.NX                $nx 
pfset ComputationalGrid.NY                $ny 
pfset ComputationalGrid.NZ                1
pfdist $sx
pfdist $sy

pfset ComputationalGrid.NX                $nx 
pfset ComputationalGrid.NY                $ny 
pfset ComputationalGrid.NZ                $nz 
pfdist $si
pfdist $ic0
puts " "
puts "Executing pfrun..."

pfrun    $runname
puts " "

#------------------------------------------------------------
# Undistribute files
#------------------------------------------------------------
puts "Undistributing files"
pfundist $runname
pfundist $sx
pfundist $sy
pfundist $si
pfundist $ic0

puts "...DONE."