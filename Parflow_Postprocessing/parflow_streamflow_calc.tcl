# THIS SCRIPT CALCULATES STREAMFLOW USING MANNING EQ.
# (Code adapted from parflow short course 2012 and parflow manual)
# Import the ParFlow TCL package
lappend   auto_path $env(PARFLOW_DIR)/bin
package   require parflow
namespace import Parflow::*

pfset     FileVersion    4

#------------------------------------------------------------
# Set up run info
#------------------------------------------------------------
set runname                               "pfclmwrf_DCEW_30m"
set rundir                                .
set starttime                             [lindex $argv 0]
set stoptime                              [lindex $argv 1]
set istep                                 1
set pfboutputs                           "./outputs_ESMF_pfclmwrf"
set geoinputs                            "./outputs_ESMF_pfclmwrf"
set dx                                    30.0
set dy                                    30.0

#------------------------------------------------------------
# Topo slopes in x-direction
# pfsetgrid {nx ny nz} {x0 y0 z0} {dx dy dz} dataset
#------------------------------------------------------------
set sx                [pfload $geoinputs/DCEW_30m.sx.pfb]
#------------------------------------------------------------
# Topo slopes in y-direction
#------------------------------------------------------------
set sy                [pfload $geoinputs/DCEW_30m.sy.pfb]
#------------------------------------------------------------
# Mannings coefficient
#------------------------------------------------------------
set n 0.000094
#------------------------------------------------------------
# Calculate Flow using Mannings equation on DCEW stations
# units = m3/s
#------------------------------------------------------------

set mask [pfload $geoinputs/$runname.out.mask.pfb]
set top [pfcomputetop $mask]

set fobsfile [open fobs_location.txt r 0600]
set calculated_obs_file [open DCEW_obs_out.csv w ]
set fnobs [gets $fobsfile]


for {set i 1} {$i <= $fnobs} {incr i 1} {

       gets $fobsfile flocation
       set Xloca($i) [lindex $flocation 0]
       set Yloca($i) [lindex $flocation 1]
       set sx1 [pfgetelt $sx $Xloca($i) $Yloca($i) 0]
       set sy1 [pfgetelt $sy $Xloca($i) $Yloca($i) 0]
       set S($i) [expr ($sx1**2+$sy1**2)**0.5]
       puts stdout "Slope at $Xloca($i) $Yloca($i) = $S($i)"

       for {set ii $starttime} {$ii <=$stoptime } {incr ii} {

       set press [pfload [format $pfboutputs/$runname.out.press.%05d.pfb $ii]]
       set P($i) [pfgetelt $press $Xloca($i) $Yloca($i) 19]
       set PP [expr $P($i)*1.0]

#------------------------------------------------------------      
# Clean up to avoid memory leaks...
#------------------------------------------------------------

       pfdelete $press
       unset press
       
# set P($i)=0 when $P($i)<=0
       if {$P($i) >= 0} {    
       }  else { 
          set P($i) 0
       }         

       set QT($i) [expr ($dx/$n)*($S($i)**0.5)*($P($i)**(5./3.))*(1000.0/3600.0)]
       set timestep [expr $ii*$istep] 
       puts stdout "Streamflow at Lower Gauge (P=$PP) : = $QT($i) (l/s) at time $timestep (hrs)"   
       puts $calculated_obs_file "$timestep,$QT($i)"  
}
       
}
       close $fobsfile
       close $calculated_obs_file

puts "...DONE."