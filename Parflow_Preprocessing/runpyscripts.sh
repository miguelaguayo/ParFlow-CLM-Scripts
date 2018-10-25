#!/bin/bash

## Set domain parameters

cname="DCEW_30m"
pfpath="parflow_input"
clmpath="clm_input"
dataset="NLCD"     # MODIS or NLCD
lh=5               # number of header lines to skip in the raster input files (Make sure header lines are same for each input file)
nsl=10            # number of soil layers (soil depth will be equal in all domain grid - terrain following grid)
nx=315		# number of columns (x)
ny=300		# number of rows (y)
nz=20		# number of soil and rock layers (z) (Add the number of bedrock layers to soil layers)
dx=30		# grid x-size
dy=30		# grid y-size
x0=0.0		# origin of the domain (x)
y0=0.0		# origin of the domain (y)
z0=-20.0	# origin of the domain (z)

## Run python scripts and save all the files generated in their corresponding directories
## i.e. parflow_input, geo_indi and clm_input

echo "Converting ASCII DEM data to Parflow .sa ..."
python -c "from pfclmConvert import asciiDEM2sa; asciiDEM2sa('$cname',$lh,'$pfpath')"
echo "Converting ASCII Soil data to Parflow .sa ..."
python -c "from pfclmConvert import asciiSoil2sa; asciiSoil2sa('$cname',$lh,$nsl,'$pfpath')"
echo "Converting ASCII Land Cover data to CLM .dat ..."
python -c "from pfclmConvert import asciiLCD2clmdat; asciiLCD2clmdat('$dataset','$cname',$lh,'$clmpath')"
echo "Generating a 3D indicator field for the domain"
python -c "from pfclmConvert import soilsa2indisa; soilsa2indisa('$cname',$nx,$ny,$nz,$nsl,'$pfpath')"
echo "Done..."

## Run tcl scripts (Make sure all variables are correct)

echo "Processing DEM for slopes ..."
echo "Generating .pfb files for slopes ..."
cd parflow_input
tclsh process_dem.tcl $cname $nx $ny $dx $dy
echo "Done..."
cd geo_indi
echo "Converting indicator field to .pfb file"
tclsh convert.tcl $cname $nx $ny $nz $x0 $y0 $z0 $dx $dy 1
echo "Done..."
