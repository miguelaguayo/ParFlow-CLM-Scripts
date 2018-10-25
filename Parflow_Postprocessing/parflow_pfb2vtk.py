# -*- coding: utf-8 -*-
"""
Created on Thu Sep 11 11:19:32 2014

@author: Miguel Aguayo
"""
import numpy as np
import struct

#------------------------------------------------------------
#  This loop creates 3D spatially distributed time series 
#  (.vtk maps)
#------------------------------------------------------------

nf1 = 3267 # initial filename
nf2 = 3267 # last filename

#----- open and read parflow outputs -----# 
for nf in range(nf1,nf2+1):   
    fn = '30m/pfclmwrf_DCEW_30m.out.clm_output.%05d.C.pfb' % nf
    fvtk = '30m/pfclmwrf_DCEW_30m.out.clm_output.%05d.C.vtk' % nf

    with open(fn,'r') as fid:
        x1 = np.fromfile(fid,dtype='>f8', count=1)
        y1 = np.fromfile(fid,dtype='>f8', count=1)
        z1 = np.fromfile(fid,dtype='>f8', count=1)
        nx = np.fromfile(fid,dtype='>i4', count=1)
        ny = np.fromfile(fid,dtype='>i4', count=1)
        nz = np.fromfile(fid,dtype='>i4', count=1)
        dx = np.fromfile(fid,dtype='>f8', count=1)
        dy = np.fromfile(fid,dtype='>f8', count=1)
        dz = np.fromfile(fid,dtype='>f8', count=1)
        ns = np.fromfile(fid,dtype='>i4', count=1)
        var = np.zeros((np.int64(ny),np.int64(nx),np.int64(nz)))
        
        for i0 in range(ns):
            ix = np.fromfile(fid,dtype='>i4', count=1)
            iy = np.fromfile(fid,dtype='>i4', count=1)
            iz = np.fromfile(fid,dtype='>i4', count=1)        
            nnx = np.fromfile(fid,dtype='>i4', count=1)
            nny = np.fromfile(fid,dtype='>i4', count=1)
            nnz = np.fromfile(fid,dtype='>i4', count=1)       
            rx = np.fromfile(fid,dtype='>i4', count=1) 
            ry = np.fromfile(fid,dtype='>i4', count=1)
            rz = np.fromfile(fid,dtype='>i4', count=1)
            
            for k in range(iz,iz+nnz):
                for i in range(iy,iy+nny):
                    for j in range(ix,ix+nnx):
                        var[i,j,k]=np.fromfile(fid,dtype='>f8', count=1)    

    P = var[:,:,10] # get the variable SWE from the CLM pfb file 
                
    Psize = P.shape
    Prows = Psize[0] 
    Pcols = Psize[1]

    dim1D = Prows*Pcols
    nn = np.zeros((dim1D,1))

    for i1 in range(Pcols):
        for j1 in range(Prows):
            k = j1 + Prows*(i1)
            nn[k]=P[j1,i1]
               
    #----- Open DEM -----#
    fi = "DCEW_30m.dem.asc"
    mr = np.loadtxt(fi)
    mrsize = mr.shape 
    mrrows = mrsize[0] 
    mrcols = mrsize[1]
    mrflip = (np.flipud(mr)) # flip DEM from bottom to top       
    
    #----- Write binary vtk file -----#
    CONV = '# vtk DataFile Version 2.0'
    NAME = 'Example'
    FORMAT = 'BINARY'
    DSTRUC = 'DATASET STRUCTURED_GRID'
    dimZ = 1
    points = Pcols*Prows*dimZ
    x0 = 565500.0 # Lon lower left corner
    y0 = 4837000.0 # Lat lower left corner
    dh = 30.0 # Distance between cells
    xc = np.zeros((Pcols))
    yc = np.zeros((Prows))
    a = np.zeros((points))
    b = np.zeros((points))
    c = np.zeros((points))
    var1 = np.zeros(points)
    var2 = np.zeros(points)
    var3 = np.zeros(points) 
    for ic in range(0,Pcols):
        xc[ic]=(ic*dh)+x0
    for jc in range(0,Prows):
        yc[jc]=(jc*dh)+y0
        
    with file(fvtk, 'wb') as outvtk:
        outvtk.write('%s\n%s\n%s\n%s\n' % (CONV,NAME,FORMAT,DSTRUC))
        outvtk.write('DIMENSIONS %d %d %d\n' % (Pcols,Prows,dimZ))
        outvtk.write('POINTS %d double\n' % points)
        for jc in range(Prows):
            for ic in range(Pcols):
                kc = ic + jc*Pcols
                a[kc] = np.double(xc[ic])
                b[kc] = np.double(yc[jc])
                c[kc] = np.double(mrflip[jc,ic])
                da = struct.pack('>d',a[kc])
                db = struct.pack('>d',b[kc])
                dc = struct.pack('>d',c[kc])
                outvtk.write(da)
                outvtk.write(db)
                outvtk.write(dc)
        outvtk.write('\n')
        outvtk.write('POINT_DATA %d\n' % points)
        outvtk.write('SCALARS Elevation double\n')
        outvtk.write('LOOKUP_TABLE default\n')
        for jc in range(Prows):
            for ic in range(Pcols):
                kc = ic + jc*Pcols
                var1[kc] = np.double(mrflip[jc,ic])
                dvar1 = struct.pack('>d',var1[kc])
                outvtk.write(dvar1)
        outvtk.write('\n')
        outvtk.write('SCALARS SWE double\n')
        outvtk.write('LOOKUP_TABLE default\n')
        for jc in range(Prows):
            for ic in range(Pcols):
                kc = ic + jc*Pcols
                var2[kc] = np.double(P[jc,ic])
                dvar2 = struct.pack('>d',var2[kc])
                outvtk.write(dvar2)