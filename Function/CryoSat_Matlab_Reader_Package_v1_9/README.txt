CRYOSAT-2 MATLAB READING ROUTINES

This is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License, version 2, as published by the Free Software Foundation. 

The software is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

The readers have been developed by EOP-SER Team in ESA-ESRIN.

--------------------------------------------------------------------------------
 $Date: 2015/15/07 $
 $Revision: 1.9 $
 $Change Log: 
   - version 1.2 fixed a bug in the calculation of the total ocean geo-correction: now the IB correction has been ruled out of the    total sum of corrections $
   - version 1.3 fixed a mistake in the ice concentracion scale factor in L2 routine $
   - version 1.4 fixed a typo bug in L2 routine $
   - version 1.5 fixed a bug in correction flag reading for L2 routine $
   - version 1.6 added support to CryoSat-2 L2 Intermediate (L2I) data products
   - version 1.7 added support to CryoSat-2 Baseline-C
   - version 1.8 corrected minor bugs of version 1.7
   - version 1.9 corrected minor bugs of version 1.8 related to L2 SARIn reader
--------------------------------------------------------------------------------

PACKAGE CONTENT: 

Cryo_L1b_read.m
Cryo_L2_read.m
Cryo_L2I_read.m
README.txt

DESCRIPTION:

The enclosed routines read standard Cryosat FBR/L1b/L2I/L2 .DBL files in SAR/SARIN/LRM Mode 
Use: 
     - the routine Cryo_L1b_read.m to read FBR/L1b CRYOSAT-2 Data Products
     - the routine Cryo_L2I_read.m to read L2I CRYOSAT-2 Data Products 
     - the routine Cryo_L2_read.m to read  L2 CRYOSAT-2 Data Products 

The routines work also with FDM Data Products

USAGE:

In order to use the routines, pass in input as function argument and as string the full filename (path + file) where the CryoSat .DBL
file is stored in your local drive
The routine returns in output a structure <HDR>, containing the header of the read file, and the structure <CS>, containing the read data fields 

Cryo_L1b_read.m: 
Reads Cryosat-2 FBR and L1b products(LRM SAR SARin mode) located in the local drive. 

Cryo_L2I_read.m: 
Reads Cryosat-2 L2I products (LRM SAR SARin mode) located in the local drive. 

Cryo_L2_read.m: 
Reads Cryosat-2 L2 products (LRM SAR SARin mode) located in the local drive. 

Debugging: for any issues, please write to salvatore.dinardo@esa.int



