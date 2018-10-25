# THIS SCRIPT RETRIEVES SWE DATA FROM CLM FILES
# Import the ParFlow TCL package

lappend   auto_path $env(PARFLOW_DIR)/bin
package   require parflow
namespace import Parflow::*

pfset     FileVersion    4

#------------------------------------------------------------ 
# Set up run info
#------------------------------------------------------------ 
set runname				                        "pfclmwrf_DCEW_30m"
set starttime                             [lindex $argv 0]
set stoptime                              [lindex $argv 1]
set istep                                 1
set pfboutputs                           "/miguel/OSSEs/30m/met_res_1km_bilinear/clm_output"
set geoinputs                            "./geo_inputs"

#------------------------------------------------------------ 
# Get SWE at different stations
# units = mm
#------------------------------------------------------------ 

set fobsfile [open $geoinputs/fobs_location.txt r 0600]
set calculated_obs_file_swe [open DCEW_obs_swe_out.csv w ]
set fnobs [gets $fobsfile]
puts $calculated_obs_file_swe "ID,X,Y,Time,Value"

for {set i 1} {$i <= $fnobs} {incr i 1} {

       gets $fobsfile flocation
       set Xloca($i) [lindex $flocation 0]
       set Yloca($i) [lindex $flocation 1]

       for {set ii $starttime} {$ii <=$stoptime } {incr ii} {
       
       set swe [pfload [format $pfboutputs/$runname.out.clm_output.%05d.C.pfb $ii]]
       set S($i) [pfgetelt $swe $Xloca($i) $Yloca($i) 10]
       puts $calculated_obs_file_swe "$i,$Xloca($i),$Yloca($i),$ii,$S($i)" 
       puts "$i,$Xloca($i),$Yloca($i),$ii,$S($i)" 

#------------------------------------------------------------       
# Clean up to avoid memory leaks...
#------------------------------------------------------------ 
       pfdelete $swe
       unset swe
}
       
}
       close $fobsfile
       close $calculated_obs_file_swe

puts "...DONE."