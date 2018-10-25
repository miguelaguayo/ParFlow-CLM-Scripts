# THIS SCRIPT DISTRIBUTES WRF-OUTPUTS DATA

# Import ParFlow TCL package
lappend   auto_path $env(PARFLOW_DIR)/bin
package   require parflow
namespace import Parflow::*

pfset     FileVersion    4

#------------------------------------------------------------
# Set up run info
#------------------------------------------------------------

set metdir				  "../clm_dist_input"
set starttime                             0.0
set stoptime                              4368

#------------------------------------------------------------
# Processor topology (P=x-direction,Q=y-direction,R=z-direction)
#------------------------------------------------------------
pfset Process.Topology.P                  21
pfset Process.Topology.Q                  16
pfset Process.Topology.R                  1

#------------------------------------------------------------
# Run pfdist
#------------------------------------------------------------
puts " "
puts "Distributing input files..."
pfset ComputationalGrid.NX                315 
pfset ComputationalGrid.NY                300 
pfset ComputationalGrid.NZ                1

# distribute 2D Met input files
array set vars {
     v1	NLDAS.DSWR. 
     v2 NLDAS.DLWR.
     v3 NLDAS.APCP.
     v4 NLDAS.Temp.
     v5 NLDAS.UGRD.
     v6 NLDAS.VGRD.
     v7 NLDAS.Press.
     v8 NLDAS.SPFH.
}
foreach name [array names vars] {
	for {set i 0} {$i < $stoptime+1} {incr i} {
    	pfdist [format "$metdir/$vars($name)%06d.pfb" $i]
	puts "Creating $vars($name) at t: $i"
	}	
}