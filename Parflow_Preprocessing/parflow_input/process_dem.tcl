# Process DEM for ParFlow inputs (modified from LW example, Parflow short course 2012) 
# (0) Read raw DEM, set grid info (pfsetgrid)
# (1) Process flat areas 
# (2) Pit-fill to remove local minima/pits
# (3) Compute slopes 
# (4) Save to txt, silo, and pfb

lappend   auto_path $env(PARFLOW_DIR)/bin
package   require parflow
namespace import Parflow::*

set demName [lindex $argv 0]
set nx [lindex $argv 1]
set ny [lindex $argv 2]
set dx [lindex $argv 3]
set dy [lindex $argv 4]
# Read raw dem 
# Set grid info -- pfsetgrid {nx ny nz} {x0 y0 z0} {dx dy dz} $dem
# NOTE: for slopes, nz should be 1, z0 and dz are arbitrary, but all else needs to be set correctly

#puts "$demName -- $inx"
set dem [pfload $demName.dem.sa]

eval [format "pfsetgrid { %d %d 1} {0.0 0.0 0.0} {%f %f 1.0} %s " $nx $ny $dx $dx {$dem}]
# Example: pfsetgrid {315 300 1} {0.0 0.0 0.0} {30.0 30.0 1.0} $dem
pfsave $dem -silo $demName.dem.silo
puts "*******************************************************"
puts "SUMMARY: pfsetgrid" 
puts "*******************************************************"
pfprintgrid $dem
puts stdout "pfsetgrid ... Done!"

# Fill flat areas (if any)
# (if there are large contiguous areas with identical elevations, they result in sx=sy=0.0...
#  this routine just interpolates across the bounds of flat areas to ensure nonzero slopes)
set flatfill    [pffillflats $dem]
puts stdout "flatfill... Done!"

# Pitfill
# (this routine uses a standard pit-fill method to remove local minima and cells with non-zero slope...
#  syntax is: pfpitfilldem <input dem> <amount added to local mins at each iteration> <max iterations> )
set pitfill [pfpitfilldem $flatfill 0.01 10000]
puts stdout "pitfill... Done!"

# Fill dem sinks with moving average routine
set demSmooth [pfmovingavgdem $pitfill 8 150]
pfsave $demSmooth -pfb   $demName.dem-mav.pfb

# Calculate slopes
# (uses 1st-order upwind differences, consistent with PF overland flow scheme)
# If you want to compute slopes with moving average routine, use this:
#set       slope_x     [pfslopex $demSmooth]
#set       slope_y     [pfslopey $demSmooth]

# If you want to compute slopes with Pitfill routine, use this:
set       slope_x     [pfslopex $pitfill]
set       slope_y     [pfslopey $pitfill]

# Write to outputs

pfsave $pitfill -silo   $demName.pitfill.silo
pfsave $flatfill -silo   $demName.flatfill.silo
pfsave $demSmooth -silo   $demName.dem-mav.silo

pfsave $slope_x  -pfb  $demName.sx.pfb
pfsave $slope_x  -silo  $demName.sx.silo
pfsave $slope_y  -pfb  $demName.sy.pfb
pfsave $slope_y  -silo  $demName.sy.silo

puts stdout "slopes... Done!"