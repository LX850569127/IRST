
function [HDR, CS]=Cryo_L2I_read(full_filename)

% Scope: Matlab Function to ingest CryoSat L2I (intermediate) data products to matlab workspace
% Data Level: 2I
% Supported Modes: LRM, SAR, SARin, FDM, SID
%
% Input Argument: <full_filename> is the full pathname (path + file) where the CryoSat .DBL
% file is stored in your local drive
%
% Output Arguments: the structures <HDR>, containing the header of the read file, and the structure <CS>,
% containing the read data fields
%
% Author: Salvatore Dinardo
% Date: 02/02/2015
% Version: 1.1
% Compliance to CryoSat L2 Product Specification: 4.2
% Debugging: for any issues, please write to salvatore.dinardo@esa.int
% Track Change Log:
%
%    - version 1.0: first pubblic issue
%    - version 1.1: add compatibility to Baseline C
%    - version 1.2:  nominal version for Baseline C

[pathname filename, ext]=fileparts(full_filename);

fid=fopen(fullfile(pathname,[filename ext ] ),'r','b');
s = dir(fullfile(pathname, [filename ext]  ));

%%%%%%%%%%%%%%%%%%%%%%%%  DATA HEADER READING %%%%%%%%%%%%%%%%%%%

MPH_size=1247;

i=0;
k=1;

I_1=[1,4,7,10,13,16,19,22,25,28,31,34,37,40,43,46,49,52,55,58,61];
I_2=I_1+2;

while 1
    
    i=i+1;
    
    if ftell(fid)>MPH_size, break,   end
    tline = fgetl(fid);
    
    field=tline(1:strfind(tline,'=')-1);
    
    I=strfind(tline,'=')+1;
    
    if  i>2 && isfield(HDR,field)
        
        
        if strcmp(field,['DS_NAME'])
            
            k=k+1;
            
        end
        
        field=[field num2str(k)];
        
    end
    
    if strcmp(tline(I),'"')
        
        value=tline(I+1:end-1);
        eval([ 'HDR.' field '='' ' value ''';']);
        
    else
        
        J=strfind(tline,'<')-1;
        if isempty(J) J=length(tline); end
        
        if  not(isempty(tline(I:J)))&& not(isnan(str2double(tline(I:J))))
            
            value=str2double(tline(I:J));
            eval([ 'HDR.' field '= ' num2str(value, '%10.5f') ';']);
            
        elseif not(isempty(tline(I:J)))&& (isnan(str2double(tline(I:J))))
            
            value=(tline(I:J));
            eval([ 'HDR.' field '= ''' value ''';']);
        end
        
    end
    
end

i=0;
k=1;

while 1
    
    i=i+1;
    
    if ftell(fid)>=MPH_size+HDR.SPH_SIZE break,   end
    
    tline = fgetl(fid);
    field=tline(1:strfind(tline,'=')-1);
    
    I=strfind(tline,'=')+1;
    
    if  i>2 && isfield(HDR,field)
        
        
        if strcmp(field,['DS_NAME'])
            
            k=k+1;
            
        end
        
        field=[field num2str(k)];
        
    end
    
    if strcmp(tline(I),'"')
        
        value=tline(I+1:end-1);
        eval([ 'HDR.' field '='' ' value ''';']);
        
    else
        
        J=strfind(tline,'<')-1;
        if isempty(J) J=length(tline); end
        
        if  not(isempty(tline(I:J)))&& not(isnan(str2double(tline(I:J))))
            
            value=str2double(tline(I:J));
            eval([ 'HDR.' field '= ' num2str(value, '%10.5f') ';']);
            
        elseif not(isempty(tline(I:J)))&& (isnan(str2double(tline(I:J))))
            
            value=(tline(I:J));
            eval([ 'HDR.' field '= ''' value ''';']);
            
        end
    end
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%% OPERATIVE MODE IDENTIFICATION  %%%%%%%%%%%%%%%%%%

CS.GEO.OPERATION_MODE=strtrim(HDR.DS_NAME);
CS.GEO.Start_Time=(datenum(HDR.START_RECORD_TAI_TIME)-datenum('01-Jan-2000 00:00:00')).*24.*60.*60;
tmp=deblank(HDR.PRODUCT);
CS.GEO.Baseline_ID=tmp(end-3);

switch  CS.GEO.Baseline_ID
    
    case  'C'
        
        time_group=100;    % time and orbit group
        meas_group=332; % measurement group
        aux_meas_group=120; % auxiliary measurement group
        aux_slope_field=4;
        
    otherwise
        
        aux_slope_field=0;
        time_group=84;    % time and orbit group
        meas_group=244; % measurement group
        aux_meas_group=116; % auxiliary measurement group
        
end

%%%%%%%%%%%%%%%%%%%%%%%%  DATA STRUCTURE INFORMATION %%%%%%%%%%%%%%%%%%%%%%


switch CS.GEO.OPERATION_MODE
    
    case {'SIR_LRM_L2_I','SIR_SAR_L2A_I','SIR_SAR_L2B_I','SIR_SIN_L2_I','SIR_SID_L2_I','SIR_SAR_L2_I'}

        ext_corr_group=68; % external corrections group
        int_corr_group=44; % external corrections group
        record_size=time_group+meas_group+aux_meas_group+ext_corr_group+int_corr_group;
        
    otherwise
        
        disp('Mode not Supported or File Product not recognized');
        CS=[];HDR=[];return;
        
end

n_recs=(s.bytes-(MPH_size+HDR.SPH_SIZE))./record_size;

if ~~(mod(n_recs,1))
    
    disp('File Product corrupt');
    HDR=[];CS=[];
    return
end

CS.MEA.beam_param=zeros(50,n_recs);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Reading the product  %%%

%%% Time and Orbit Group

fseek(fid,MPH_size+HDR.SPH_SIZE,'bof');
CS.GEO.TAI.days=fread(fid,n_recs,'int32',record_size-4);

fseek(fid,MPH_size+HDR.SPH_SIZE+4,'bof');
CS.GEO.TAI.secs=fread(fid,n_recs,'uint32',record_size-4);

fseek(fid,MPH_size+HDR.SPH_SIZE+4+4,'bof');
CS.GEO.TAI.microsecs=fread(fid,n_recs,'uint32',record_size-4);

fseek(fid,MPH_size+HDR.SPH_SIZE+4+4+4,'bof');
CS.GEO.USO_Correction=fread(fid,n_recs,'int32',record_size-4)*1e-15;

fseek(fid,MPH_size+HDR.SPH_SIZE+4+4+4+4,'bof');
CS.GEO.MODE_ID=dec2bin(fread(fid,n_recs,'uint16',record_size-2),16);

fseek(fid,MPH_size+HDR.SPH_SIZE+4+4+4+4+2,'bof');
CS.GEO.Source_Sequence_Counter=fread(fid,n_recs,'uint16',record_size-2);

fseek(fid,MPH_size+HDR.SPH_SIZE+4+4+4+4+2+2,'bof');
CS.GEO.Instrument_Config=dec2bin(fread(fid,n_recs,'uint32',record_size-4),32);

fseek(fid,MPH_size+HDR.SPH_SIZE+4+4+4+4+2+2+4,'bof');
CS.GEO.Record_Counter=fread(fid,n_recs,'uint32',record_size-4);

fseek(fid,MPH_size+HDR.SPH_SIZE+4+4+4+4+2+2+4+4,'bof');
CS.GEO.LAT=fread(fid,n_recs,'int32',record_size-4).*1e-7; %%decimal degree

fseek(fid,MPH_size+HDR.SPH_SIZE+4+4+4+4+2+2+4+4+4,'bof');
CS.GEO.LON=fread(fid,n_recs,'int32',record_size-4).*1e-7; %% decimal degree

fseek(fid,MPH_size+HDR.SPH_SIZE+4+4+4+4+2+2+4+4+4+4,'bof');
CS.GEO.H=fread(fid,n_recs,'int32',record_size-4).*1e-3; % meter

fseek(fid,MPH_size+HDR.SPH_SIZE+4+4+4+4+2+2+4+4+4+4+4,'bof');
CS.GEO.H_rate=fread(fid,n_recs,'int32',record_size-4).*1e-3; % meter/sec

fseek(fid,MPH_size+HDR.SPH_SIZE+4+4+4+4+2+2+4+4+4+4+4+4,'bof');
CS.GEO.V.Vx=fread(fid,n_recs,'int32',record_size-4)./1e3; % meter/sec

fseek(fid, MPH_size+HDR.SPH_SIZE+4+4+4+4+2+2+4+4+4+4+4+4+4,'bof');
CS.GEO.V.Vy=fread(fid,n_recs,'int32',record_size-4)./1e3; % meter/sec

fseek(fid,MPH_size+HDR.SPH_SIZE+4+4+4+4+2+2+4+4+4+4+4+4+4+4,'bof');
CS.GEO.V.Vz=fread(fid,n_recs,'int32',record_size-4)./1e3; % meter/sec

fseek(fid,MPH_size+HDR.SPH_SIZE+4+4+4+4+2+2+4+4+4+4+4+4+4+4+4,'bof');
CS.GEO.Beam.X=fread(fid,n_recs,'int32',record_size-4)./1e6;

fseek(fid,MPH_size+HDR.SPH_SIZE+4+4+4+4+2+2+4+4+4+4+4+4+4+4+4+4,'bof');
CS.GEO.Beam.Y=fread(fid,n_recs,'int32',record_size-4)./1e6;

fseek(fid,MPH_size+HDR.SPH_SIZE+4+4+4+4+2+2+4+4+4+4+4+4+4+4+4+4+4,'bof');
CS.GEO.Beam.Z=fread(fid,n_recs,'int32',record_size-4)./1e6;

fseek(fid,MPH_size+HDR.SPH_SIZE+4+4+4+4+2+2+4+4+4+4+4+4+4+4+4+4+4+4,'bof');
CS.GEO.Baseline.X=fread(fid,n_recs,'int32',record_size-4)./1e6;

fseek(fid,MPH_size+HDR.SPH_SIZE+4+4+4+4+2+2+4+4+4+4+4+4+4+4+4+4+4+4+4,'bof');
CS.GEO.Baseline.Y=fread(fid,n_recs,'int32',record_size-4)./1e6;

fseek(fid,MPH_size+HDR.SPH_SIZE+4+4+4+4+2+2+6*4+3*4+3*4+2*4,'bof');
CS.GEO.Baseline.Z=fread(fid,n_recs,'int32',record_size-4)./1e6;

if  strcmp( CS.GEO.Baseline_ID, 'C')
    
    fseek(fid,MPH_size+HDR.SPH_SIZE+4+4+4+4+2+2+6*4+3*4+3*4+3*4,'bof');
    CS.GEO.Star_Tracker_ID=fread(fid,n_recs,'uint16',record_size-2);
    
    fseek(fid,MPH_size+HDR.SPH_SIZE+4+4+4+4+2+2+6*4+3*4+3*4+3*4+2+2,'bof');
    CS.GEO.Spacecraft_Roll=fread(fid,n_recs,'int32',record_size-4).*1e-7;
    
    fseek(fid,MPH_size+HDR.SPH_SIZE+4+4+4+4+2+2+6*4+3*4+3*4+3*4+2+2+4,'bof');
    CS.GEO.Spacecraft_Pitch=fread(fid,n_recs,'int32',record_size-4).*1e-7;
    
    fseek(fid,MPH_size+HDR.SPH_SIZE+4+4+4+4+2+2+6*4+3*4+3*4+3*4+2+2+4+4,'bof');
    CS.GEO.Spacecraft_Yaw=fread(fid,n_recs,'int32',record_size-4).*1e-7;
    
end

fseek(fid,MPH_size+HDR.SPH_SIZE+time_group-4,'bof');
CS.GEO.MCD_FLAG=dec2bin(fread(fid,n_recs,'uint32',record_size-4),32);

CS.GEO.MODE_ID_Tab.Ins_Oper_Mode=bin2dec(CS.GEO.MODE_ID(:,1:6));
CS.GEO.MODE_ID_Tab.Sarin_Degr_Case=bin2dec(CS.GEO.MODE_ID(:,7));
CS.GEO.MODE_ID_Tab.Reserved_1=bin2dec(CS.GEO.MODE_ID(:,8));
CS.GEO.MODE_ID_Tab.Cal4_Flag=bin2dec(CS.GEO.MODE_ID(:,9));
CS.GEO.MODE_ID_Tab.Plat_Att_Ctrl=bin2dec(CS.GEO.MODE_ID(:,10:11));
CS.GEO.MODE_ID_Tab.Reserved_2=bin2dec(CS.GEO.MODE_ID(:,12:16));

CS.GEO.Instrument_Config_Tab.Rx_Chain_Use=bin2dec(CS.GEO.Instrument_Config(:,1:2));
CS.GEO.Instrument_Config_Tab.SIRAL_ID=bin2dec(CS.GEO.Instrument_Config(:,3));
CS.GEO.Instrument_Config_Tab.Reserved_1=bin2dec(CS.GEO.Instrument_Config(:,4));
CS.GEO.Instrument_Config_Tab.Band_FLAG=bin2dec(CS.GEO.Instrument_Config(:,5:6));
CS.GEO.Instrument_Config_Tab.Reserved_2=bin2dec(CS.GEO.Instrument_Config(:,7:8));
CS.GEO.Instrument_Config_Tab.Tracking_Mode=bin2dec(CS.GEO.Instrument_Config(:,9:10));
CS.GEO.Instrument_Config_Tab.Ext_Cal=bin2dec(CS.GEO.Instrument_Config(:,11));
CS.GEO.Instrument_Config_Tab.Reserved_3=bin2dec(CS.GEO.Instrument_Config(:,12));
CS.GEO.Instrument_Config_Tab.Loop_Status=bin2dec(CS.GEO.Instrument_Config(:,13));
CS.GEO.Instrument_Config_Tab.Echo_Loss=bin2dec(CS.GEO.Instrument_Config(:,14));
CS.GEO.Instrument_Config_Tab.Real_Time_Err=bin2dec(CS.GEO.Instrument_Config(:,15));
CS.GEO.Instrument_Config_Tab.Echo_Satur_Err=bin2dec(CS.GEO.Instrument_Config(:,16));
CS.GEO.Instrument_Config_Tab.Rx_Band_Atten=bin2dec(CS.GEO.Instrument_Config(:,17));
CS.GEO.Instrument_Config_Tab.Cycle_Report_Err=bin2dec(CS.GEO.Instrument_Config(:,18));

if  strcmp( CS.GEO.Baseline_ID, 'C')
    
    CS.GEO.Instrument_Config_Tab.Reserved_4=bin2dec(CS.GEO.Instrument_Config(:,19));
    CS.GEO.Instrument_Config_Tab.Reserved_5=bin2dec(CS.GEO.Instrument_Config(:,20));
    CS.GEO.Instrument_Config_Tab.Reserved_6=bin2dec(CS.GEO.Instrument_Config(:,21));
    CS.GEO.Instrument_Config_Tab.STR_ATTREF_used=bin2dec(CS.GEO.Instrument_Config(:,22));
    CS.GEO.Instrument_Config_Tab.Reserved_7=bin2dec(CS.GEO.Instrument_Config(:,23:32));
    
else
    
    CS.GEO.Instrument_Config_Tab.Star_Trk_1=bin2dec(CS.GEO.Instrument_Config(:,19));
    CS.GEO.Instrument_Config_Tab.Star_Trk_2=bin2dec(CS.GEO.Instrument_Config(:,20));
    CS.GEO.Instrument_Config_Tab.Star_Trk_3=bin2dec(CS.GEO.Instrument_Config(:,21));
    CS.GEO.Instrument_Config_Tab.Reserved_4=bin2dec(CS.GEO.Instrument_Config(:,22:32));
    
end

CS.GEO.MCD_FLAG_Tab.Block_Degraded=bin2dec(CS.GEO.MCD_FLAG(:,1));
CS.GEO.MCD_FLAG_Tab.Blank_Block=bin2dec(CS.GEO.MCD_FLAG(:,2));
CS.GEO.MCD_FLAG_Tab.Datation_Degraded=bin2dec(CS.GEO.MCD_FLAG(:,3));
CS.GEO.MCD_FLAG_Tab.Orbit_Propag_Err=bin2dec(CS.GEO.MCD_FLAG(:,4));
CS.GEO.MCD_FLAG_Tab.Orbit_File_Change=bin2dec(CS.GEO.MCD_FLAG(:,5));
CS.GEO.MCD_FLAG_Tab.Orbit_Discontinuity=bin2dec(CS.GEO.MCD_FLAG(:,6));
CS.GEO.MCD_FLAG_Tab.Echo_Saturation=bin2dec(CS.GEO.MCD_FLAG(:,7));
CS.GEO.MCD_FLAG_Tab.Other_Echo_Err=bin2dec(CS.GEO.MCD_FLAG(:,8));
CS.GEO.MCD_FLAG_Tab.Rx1_Err_SARin=bin2dec(CS.GEO.MCD_FLAG(:,9));
CS.GEO.MCD_FLAG_Tab.Rx2_Err_SARin=bin2dec(CS.GEO.MCD_FLAG(:,10));
CS.GEO.MCD_FLAG_Tab.Wind_Delay_Incon=bin2dec(CS.GEO.MCD_FLAG(:,11));
CS.GEO.MCD_FLAG_Tab.AGC_Incon=bin2dec(CS.GEO.MCD_FLAG(:,12));
CS.GEO.MCD_FLAG_Tab.CAL1_Corr_Miss=bin2dec(CS.GEO.MCD_FLAG(:,13));
CS.GEO.MCD_FLAG_Tab.CAL1_Corr_IPF=bin2dec(CS.GEO.MCD_FLAG(:,14));
CS.GEO.MCD_FLAG_Tab.DORIS_USO_Corr=bin2dec(CS.GEO.MCD_FLAG(:,15));
CS.GEO.MCD_FLAG_Tab.Complex_CAL1_Corr_IPF=bin2dec(CS.GEO.MCD_FLAG(:,16));
CS.GEO.MCD_FLAG_Tab.TRK_ECHO_Err=bin2dec(CS.GEO.MCD_FLAG(:,17));
CS.GEO.MCD_FLAG_Tab.RX1_ECHO_Err=bin2dec(CS.GEO.MCD_FLAG(:,18));
CS.GEO.MCD_FLAG_Tab.RX2_ECHO_Err=bin2dec(CS.GEO.MCD_FLAG(:,19));
CS.GEO.MCD_FLAG_Tab.NPM_Incon=bin2dec(CS.GEO.MCD_FLAG(:,20));

if  strcmp( CS.GEO.Baseline_ID, 'C')
    
    CS.GEO.MCD_FLAG_Tab.Azimuth_Cal_missing=bin2dec(CS.GEO.MCD_FLAG(:,21));
    CS.GEO.MCD_FLAG_Tab.Antenna_Bending_Corr=bin2dec(CS.GEO.MCD_FLAG(:,22));
    CS.GEO.MCD_FLAG_Tab.Reserved_1=bin2dec(CS.GEO.MCD_FLAG(:,23));
    CS.GEO.MCD_FLAG_Tab.Reserved_2=bin2dec(CS.GEO.MCD_FLAG(:,24));
    CS.GEO.MCD_FLAG_Tab.Phase_Pertubation_Corr=bin2dec(CS.GEO.MCD_FLAG(:,25));
    CS.GEO.MCD_FLAG_Tab.CAL2_Corr_Miss=bin2dec(CS.GEO.MCD_FLAG(:,26));
    CS.GEO.MCD_FLAG_Tab.CAL2_Corr_IPF=bin2dec(CS.GEO.MCD_FLAG(:,27));
    CS.GEO.MCD_FLAG_Tab.Power_Scaling_Err=bin2dec(CS.GEO.MCD_FLAG(:,28));
    CS.GEO.MCD_FLAG_Tab.Att_Corr_Miss=bin2dec(CS.GEO.MCD_FLAG(:,29));
    CS.GEO.MCD_FLAG_Tab.Reserved_3=bin2dec(CS.GEO.MCD_FLAG(:,30));
    CS.GEO.MCD_FLAG_Tab.Reserved_4=bin2dec(CS.GEO.MCD_FLAG(:,31));
    CS.GEO.MCD_FLAG_Tab.Phase_Pertubation_Mode=bin2dec(CS.GEO.MCD_FLAG(:,32));
    
else
    
    CS.GEO.MCD_FLAG_Tab.Reserved_1=bin2dec(CS.GEO.MCD_FLAG(:,21));
    CS.GEO.MCD_FLAG_Tab.Reserved_2=bin2dec(CS.GEO.MCD_FLAG(:,22));
    CS.GEO.MCD_FLAG_Tab.Reserved_3=bin2dec(CS.GEO.MCD_FLAG(:,23));
    CS.GEO.MCD_FLAG_Tab.Reserved_4=bin2dec(CS.GEO.MCD_FLAG(:,24));
    CS.GEO.MCD_FLAG_Tab.Phase_Pertubation_Corr=bin2dec(CS.GEO.MCD_FLAG(:,25));
    CS.GEO.MCD_FLAG_Tab.CAL2_Corr_Miss=bin2dec(CS.GEO.MCD_FLAG(:,26));
    CS.GEO.MCD_FLAG_Tab.CAL2_Corr_IPF=bin2dec(CS.GEO.MCD_FLAG(:,27));
    CS.GEO.MCD_FLAG_Tab.Power_Scaling_Err=bin2dec(CS.GEO.MCD_FLAG(:,28));
    CS.GEO.MCD_FLAG_Tab.Att_Corr_Miss=bin2dec(CS.GEO.MCD_FLAG(:,29));
    CS.GEO.MCD_FLAG_Tab.Reserved_5=bin2dec(CS.GEO.MCD_FLAG(:,30));
    CS.GEO.MCD_FLAG_Tab.Reserved_6=bin2dec(CS.GEO.MCD_FLAG(:,31));
    CS.GEO.MCD_FLAG_Tab.Phase_Pertubation_Mode=bin2dec(CS.GEO.MCD_FLAG(:,32));
  
end

CS.GEO.MODE_ID=CS.GEO.MODE_ID_Tab;
CS.GEO=rmfield(CS.GEO,'MODE_ID_Tab');

CS.GEO.Instrument_Config=CS.GEO.Instrument_Config_Tab;
CS.GEO=rmfield(CS.GEO,'Instrument_Config_Tab');

CS.GEO.MCD_FLAG=CS.GEO.MCD_FLAG_Tab;
CS.GEO=rmfield(CS.GEO,'MCD_FLAG_Tab');

%%%Measurements Group   %%%%%%%

if  strcmp( CS.GEO.Baseline_ID, 'C')
    
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group,'bof');
    CS.MEA.Height_over_surface_r1=fread(fid,n_recs,'int32',record_size-4).*1e-3;
   
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4,'bof');
    CS.MEA.Height_over_surface_r2=fread(fid,n_recs,'int32',record_size-4).*1e-3;
    
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*2,'bof');
    CS.MEA.Height_over_surface_r3=fread(fid,n_recs,'int32',record_size-4).*1e-3;
    
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*3,'bof');
    CS.MEA.Sigma0_r1=fread(fid,n_recs,'int32',record_size-4)/100;
    
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*4,'bof');
    CS.MEA.Sigma0_r2=fread(fid,n_recs,'int32',record_size-4)/100;
    
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*5,'bof');
    CS.MEA.Sigma0_r3=fread(fid,n_recs,'int32',record_size-4)/100;
    
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*6,'bof');
    CS.MEA.SWH=fread(fid,n_recs,'int32',record_size-4).*1e-3;
    
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*7,'bof');
    CS.MEA.Peakiness=fread(fid,n_recs,'int32',record_size-4).*1e-2;
    
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*8,'bof');
    CS.MEA.Retracked_Range_r1=fread(fid,n_recs,'int32',record_size-4).*1e-3;
    
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*9,'bof');
    CS.MEA.Retracked_Range_r2=fread(fid,n_recs,'int32',record_size-4).*1e-3;
    
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*10,'bof');
    CS.MEA.Retracked_Range_r3=fread(fid,n_recs,'int32',record_size-4).*1e-3;
    
    switch CS.GEO.OPERATION_MODE
        
        case {'SIR_LRM_L2_I'}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*14,'bof');
            CS.MEA.LRM_MQE_r1=fread(fid,n_recs,'int32',record_size-4).*1e-6;
            
        case  {'SIR_SAR_L2A_I','SIR_SAR_L2B_I','SIR_SAR_L2_I',}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*14,'bof');
            CS.MEA.SAR_CHI_square_r1=fread(fid,n_recs,'int32',record_size-4).*1e-6;

        case  {'SIR_SIN_L2_I','SIR_SID_L2_I'}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*14,'bof');
            CS.MEA.SIN_CHI_square_r1=fread(fid,n_recs,'int32',record_size-4).*1e-6;
            
    end
    
    switch CS.GEO.OPERATION_MODE
        
        case {'SIR_LRM_L2_I'}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*15,'bof');
            CS.MEA.LRM_MQE_r2=fread(fid,n_recs,'int32',record_size-4)*1e-6;
            
            
        case  {'SIR_SAR_L2A_I','SIR_SAR_L2B_I','SIR_SAR_L2_I',}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*15,'bof');
            CS.MEA.SAR_Retracker_Output_2=fread(fid,n_recs,'int32',record_size-4);
            
            
        case  {'SIR_SIN_L2_I','SIR_SID_L2_I'}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*15,'bof');
            CS.MEA.SIN_Retracker_Output_2=fread(fid,n_recs,'int32',record_size-4);
            
            
    end
    
    switch CS.GEO.OPERATION_MODE
        
        case {'SIR_LRM_L2_I'}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*16,'bof');
            CS.MEA.LRM_Retracker_Output_3=fread(fid,n_recs,'int32',record_size-4);
            
            
        case  {'SIR_SAR_L2A_I','SIR_SAR_L2B_I','SIR_SAR_L2_I',}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*16,'bof');
            CS.MEA.SAR_Retracker_Output_3=fread(fid,n_recs,'int32',record_size-4);
            
            
        case  {'SIR_SIN_L2_I','SIR_SID_L2_I'}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*16,'bof');
            CS.MEA.SIN_Retracker_Output_3=fread(fid,n_recs,'int32',record_size-4);
            
            
    end
    
    
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*17,'bof');
    CS.MEA.Power_Amplitude_r1=fread(fid,n_recs,'int32',record_size-4)*1e-15;
    
    
    switch CS.GEO.OPERATION_MODE
        
        case {'SIR_LRM_L2_I'}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*18,'bof');
            CS.MEA.LRM_Leading_Edge_Width_r1=fread(fid,n_recs,'int32',record_size-4)*1e-3;
            
        case  {'SIR_SAR_L2A_I','SIR_SAR_L2B_I','SIR_SAR_L2_I',}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*18,'bof');
            CS.MEA.SAR_Retracked_Output_5=fread(fid,n_recs,'int32',record_size-4);
            
        case  {'SIR_SIN_L2_I','SIR_SID_L2_I'}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*18,'bof');
            CS.MEA.SIN_Echo_Width_r1=fread(fid,n_recs,'int32',record_size-4)*1e-3;
            
    end
    
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*19,'bof');
    CS.MEA.Retracked_Output_6=fread(fid,n_recs,'int32',record_size-4);
    
    
    switch CS.GEO.OPERATION_MODE
        
        case {'SIR_LRM_L2_I'}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*20,'bof');
            CS.MEA.LRM_Ocean_Retracked_Thermal_Noise_r1=fread(fid,n_recs,'int32',record_size-4)*1e-15;
            
        case  {'SIR_SAR_L2A_I','SIR_SAR_L2B_I','SIR_SAR_L2_I',}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*20,'bof');
            CS.MEA.SAR_Retracked_Output_7=fread(fid,n_recs,'int32',record_size-4);
            
        case  {'SIR_SIN_L2_I','SIR_SID_L2_I'}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*20,'bof');
            CS.MEA.SIN_Chi_square_r1=fread(fid,n_recs,'int32',record_size-4)*1e-6;
            
    end
    
    
    
    switch CS.GEO.OPERATION_MODE
        
        case {'SIR_LRM_L2_I'}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*21,'bof');
            CS.MEA.LRM_Retracked_Output_8=fread(fid,n_recs,'int32',record_size-4);
            
        case  {'SIR_SAR_L2A_I','SIR_SAR_L2B_I','SIR_SAR_L2_I',}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*21,'bof');
            CS.MEA.SAR_Sigma_Fit_r1=fread(fid,n_recs,'int32',record_size-4).*1-6;
            
        case  {'SIR_SIN_L2_I','SIR_SID_L2_I'}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*21,'bof');
            CS.MEA.SIN_Phase_r1=fread(fid,n_recs,'int32',record_size-4)*1e-6;
            
    end
    
    
    
    switch CS.GEO.OPERATION_MODE
        
        case {'SIR_LRM_L2_I'}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*22,'bof');
            CS.MEA.LRM_Retracked_Output_9=fread(fid,n_recs,'int32',record_size-4);
            
        case  {'SIR_SAR_L2A_I','SIR_SAR_L2B_I','SIR_SAR_L2_I',}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*22,'bof');
            CS.MEA.SAR_Expon_Fit_r1=fread(fid,n_recs,'int32',record_size-4).*1-6;
            
        case  {'SIR_SIN_L2_I','SIR_SID_L2_I'}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*22,'bof');
            CS.MEA.SIN_Phase_Slope_r1=fread(fid,n_recs,'int32',record_size-4)*1e-6;
            
    end
    
    
    switch CS.GEO.OPERATION_MODE
        
        case {'SIR_LRM_L2_I'}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*23,'bof');
            CS.MEA.LRM_Retracked_Output_10=fread(fid,n_recs,'int32',record_size-4);
            
        case  {'SIR_SAR_L2A_I','SIR_SAR_L2B_I','SIR_SAR_L2_I',}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*23,'bof');
            CS.MEA.SAR_Retracked_Output_10=fread(fid,n_recs,'int32',record_size-4);
            
        case  {'SIR_SIN_L2_I','SIR_SID_L2_I'}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*23,'bof');
            CS.MEA.SIN_Leading_Edge_Slope_r1=fread(fid,n_recs,'int32',record_size-4)*1e-3;
            
    end
    
    
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*24,'bof');
    CS.MEA.OCOG_Position=fread(fid,n_recs,'int32',record_size-4)*1e-3;
    
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*25,'bof');
    CS.MEA.OCOG_Amplitude=fread(fid,n_recs,'int32',record_size-4)*1e-15;
    
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*26,'bof');
    CS.MEA.OCOG_Width=fread(fid,n_recs,'int32',record_size-4)*1e-3;
    
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*27,'bof');
    CS.MEA.Window_Delay=fread(fid,n_recs,'int32',record_size-4)*1e-3;
    
    switch CS.GEO.OPERATION_MODE
        
        case {'SIR_LRM_L2_I'}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*28,'bof');
            CS.MEA.LRM_Retracked_Output_15=fread(fid,n_recs,'int32',record_size-4);
            
        case  {'SIR_SAR_L2A_I','SIR_SAR_L2B_I','SIR_SAR_L2_I',}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*28,'bof');
            CS.MEA.SAR_Retracked_Output_15=fread(fid,n_recs,'int32',record_size-4);
            
        case  {'SIR_SIN_L2_I','SIR_SID_L2_I'}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*28,'bof');
            CS.MEA.SIN_Tail_Slope_r1=fread(fid,n_recs,'int32',record_size-4)*1e-18;
            
    end
    
    
    switch CS.GEO.OPERATION_MODE
        
        case {'SIR_LRM_L2_I'}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*29,'bof');
            CS.MEA.LRM_Retracked_Output_16=fread(fid,n_recs,'int32',record_size-4);
            
        case  {'SIR_SAR_L2A_I','SIR_SAR_L2B_I','SIR_SAR_L2_I',}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*29,'bof');
            CS.MEA.SAR_Retracked_Output_16=fread(fid,n_recs,'int32',record_size-4);
            
        case  {'SIR_SIN_L2_I','SIR_SID_L2_I'}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*29,'bof');
            CS.MEA.SIN_Tail_Decay_r1=fread(fid,n_recs,'int32',record_size-4)*1e-6;
            
    end
    
    
    
    switch CS.GEO.OPERATION_MODE
        
        case {'SIR_LRM_L2_I'}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*30,'bof');
            CS.MEA.LRM_Retracked_Output_17=fread(fid,n_recs,'int32',record_size-4);
            
        case  {'SIR_SAR_L2A_I','SIR_SAR_L2B_I','SIR_SAR_L2_I',}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*30,'bof');
            CS.MEA.SAR_Retracked_Output_17=fread(fid,n_recs,'int32',record_size-4);
            
        case  {'SIR_SIN_L2_I','SIR_SID_L2_I'}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*30,'bof');
            CS.MEA.SIN_Retracked_Output_17=fread(fid,n_recs,'int32',record_size-4);
            
    end
    
    
    
    switch CS.GEO.OPERATION_MODE
        
        case {'SIR_LRM_L2_I'}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*31,'bof');
            CS.MEA.LRM_Retracked_Output_18=fread(fid,n_recs,'int32',record_size-4);
            
        case  {'SIR_SAR_L2A_I','SIR_SAR_L2B_I','SIR_SAR_L2_I',}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*31,'bof');
            CS.MEA.SAR_Retracked_Output_18=fread(fid,n_recs,'int32',record_size-4);
            
        case  {'SIR_SIN_L2_I','SIR_SID_L2_I'}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*31,'bof');
            CS.MEA.SIN_Retracked_Output_18=fread(fid,n_recs,'int32',record_size-4);
            
    end
    
    
    
    switch CS.GEO.OPERATION_MODE
        
        case {'SIR_LRM_L2_I'}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*32,'bof');
            CS.MEA.LRM_Retracked_Output_19=fread(fid,n_recs,'int32',record_size-4);
            
        case  {'SIR_SAR_L2A_I','SIR_SAR_L2B_I','SIR_SAR_L2_I',}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*32,'bof');
            CS.MEA.SAR_Retracked_Output_19=fread(fid,n_recs,'int32',record_size-4);
            
        case  {'SIR_SIN_L2_I','SIR_SID_L2_I'}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*32,'bof');
            CS.MEA.SIN_Retracked_Output_19=fread(fid,n_recs,'int32',record_size-4);
            
    end
    
    
    switch CS.GEO.OPERATION_MODE
        
        case {'SIR_LRM_L2_I'}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*33,'bof');
            CS.MEA.LRM_Retracked_Output_20=fread(fid,n_recs,'int32',record_size-4);
            
        case  {'SIR_SAR_L2A_I','SIR_SAR_L2B_I','SIR_SAR_L2_I',}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*33,'bof');
            CS.MEA.SAR_Retracked_Output_20=fread(fid,n_recs,'int32',record_size-4);
            
        case  {'SIR_SIN_L2_I','SIR_SID_L2_I'}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*33,'bof');
            CS.MEA.SIN_Retracked_Output_20=fread(fid,n_recs,'int32',record_size-4);
            
    end
    
    switch CS.GEO.OPERATION_MODE
        
        case {'SIR_LRM_L2_I'}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*34,'bof');
            CS.MEA.LRM_OCOG_Amplitude=fread(fid,n_recs,'int32',record_size-4);
            
        case  {'SIR_SAR_L2A_I','SIR_SAR_L2B_I','SIR_SAR_L2_I',}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*34,'bof');
            CS.MEA.SAR_Retracked_Output_21=fread(fid,n_recs,'int32',record_size-4);
            
        case  {'SIR_SIN_L2_I','SIR_SID_L2_I'}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*34,'bof');
            CS.MEA.SIN_Retracked_Output_21=fread(fid,n_recs,'int32',record_size-4);
            
    end
    
    
    switch CS.GEO.OPERATION_MODE
        
        case {'SIR_LRM_L2_I'}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*35,'bof');
            CS.MEA.LRM_25_OCOG_Range_Corr=fread(fid,n_recs,'int32',record_size-4).*1e-3;
            
        case  {'SIR_SAR_L2A_I','SIR_SAR_L2B_I','SIR_SAR_L2_I',}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*35,'bof');
            CS.MEA.SAR_Retracked_Output_22=fread(fid,n_recs,'int32',record_size-4);
            
        case  {'SIR_SIN_L2_I','SIR_SID_L2_I'}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*35,'bof');
            CS.MEA.SIN_Retracked_Output_22=fread(fid,n_recs,'int32',record_size-4);
            
    end
    
    switch CS.GEO.OPERATION_MODE
        
        case {'SIR_LRM_L2_I'}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*36,'bof');
            CS.MEA.LRM_Retracked_Output_23=fread(fid,n_recs,'int32',record_size-4);
            
        case  {'SIR_SAR_L2A_I','SIR_SAR_L2B_I','SIR_SAR_L2_I',}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*36,'bof');
            CS.MEA.SAR_Retracked_Output_23=fread(fid,n_recs,'int32',record_size-4);
            
        case  {'SIR_SIN_L2_I','SIR_SID_L2_I'}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*36,'bof');
            CS.MEA.SIN_Retracked_Output_23=fread(fid,n_recs,'int32',record_size-4);
            
    end
    
    
    switch CS.GEO.OPERATION_MODE
        
        case {'SIR_LRM_L2_I'}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*37,'bof');
            CS.MEA.LRM_Retracked_Output_24=fread(fid,n_recs,'int32',record_size-4);
            
        case  {'SIR_SAR_L2A_I','SIR_SAR_L2B_I','SIR_SAR_L2_I',}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*37,'bof');
            CS.MEA.SAR_Retracked_Output_24=fread(fid,n_recs,'int32',record_size-4);
            
        case  {'SIR_SIN_L2_I','SIR_SID_L2_I'}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*37,'bof');
            CS.MEA.SIN_Retracked_Output_24=fread(fid,n_recs,'int32',record_size-4);
            
    end
    
    
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*38,'bof');
    CS.MEA.Power_Echo_Shape_Parameter=fread(fid,n_recs,'int32',record_size-4);
    
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*39,'bof');
    CS.MEA.beam_param(1,:)=fread(fid,n_recs,'uint16',record_size-2)./100;
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*39+2,'bof');
    CS.MEA.beam_param(2,:)=fread(fid,n_recs,'uint16',record_size-2)./100;  
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*39+2*2,'bof');
    CS.MEA.beam_param(3,:)=fread(fid,n_recs,'int16',record_size-2)./100;
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*39+2*3,'bof');
    CS.MEA.beam_param(4,:)=fread(fid,n_recs,'int16',record_size-2)./100;
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*39+2*4,'bof');
    CS.MEA.beam_param(5,:)=fread(fid,n_recs,'int16',record_size-2)./100;
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*39+2*5,'bof');
    CS.MEA.beam_param(6,:)=fread(fid,n_recs,'uint16',record_size-2).*1e-6;
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*39+2*6,'bof');
    CS.MEA.beam_param(7,:)=fread(fid,n_recs,'int16',record_size-2).*1e-6;
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*39+2*7,'bof');
    CS.MEA.beam_param(8,:)=fread(fid,n_recs,'int32',record_size-4).*1e-7;
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*39+2*7+4,'bof');
    CS.MEA.beam_param(9,:)=fread(fid,n_recs,'int32',record_size-4).*1e-7;
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*39+2*7+4*2,'bof');
    CS.MEA.beam_param(10,:)=fread(fid,n_recs,'int32',record_size-4).*1e-7;
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*39+2*7+4*3,'bof');
    CS.MEA.beam_param(11,:)=fread(fid,n_recs,'int32',record_size-4).*1e-7;
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*39+2*7+4*4,'bof');
    CS.MEA.beam_param(12,:)=fread(fid,n_recs,'uint16',record_size-2);
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*39+2*7+4*4+2,'bof');
    CS.MEA.beam_param(13,:)=fread(fid,n_recs,'uint16',record_size-2);
    
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*39+50*2,'bof');
    CS.MEA.Cross_Track_Angle=fread(fid,n_recs,'int32',record_size-4)*1e-6;
    
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*40+50*2,'bof');
    CS.MEA.Cross_Track_Angle_Corr=fread(fid,n_recs,'int32',record_size-4)*1e-6;
    
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*41+50*2,'bof');
    CS.MEA.Coherence=fread(fid,n_recs,'int32',record_size-4)*1e-3;
    
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*42+50*2,'bof');
    CS.MEA.Interpolated_Ocean_Height=fread(fid,n_recs,'int32',record_size-4)*1e-3;
    
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*43+50*2,'bof');
    CS.MEA.Freeboard=fread(fid,n_recs,'int32',record_size-4)*1e-3;
    
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*44+50*2,'bof');
    CS.MEA.Surface_Height_Anomaly=fread(fid,n_recs,'int32',record_size-4)*1e-3;
    
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*45+50*2,'bof');
    CS.MEA.Interpolated_Sea_Surface_Height_Anomaly=fread(fid,n_recs,'int32',record_size-4)*1e-3;
    
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*46+50*2,'bof');
    CS.MEA.Ocean_Height_Interpolation_Error=fread(fid,n_recs,'uint16',record_size-2)*1e-3;
    
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*46+50*2+2,'bof');
    CS.MEA.Number_Interpolation_Point_Forward=fread(fid,n_recs,'uint16',record_size-2);
    
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*46+50*2+2*2,'bof');
    CS.MEA.Number_Interpolation_Point_Backward=fread(fid,n_recs,'uint16',record_size-2);
    
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*46+50*2+2*3,'bof');
    CS.MEA.Radius_Interpolation_Backward=fread(fid,n_recs,'uint16',record_size-2).*1e-3;
    
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*46+50*2+2*4,'bof');
    CS.MEA.Radius_Interpolation_Forward=fread(fid,n_recs,'uint16',record_size-2).*1e-3;
    
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*46+50*2+2*5,'bof');
    CS.MEA.Interpolation_Error_Flag=dec2bin(fread(fid,n_recs,'uint16',record_size-2),16);
    
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*46+50*2+2*6,'bof');
    CS.MEA.MEA_Mode=fread(fid,n_recs,'uint32',record_size-4);
    
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*46+50*2+2*6+4,'bof');
    CS.MEA.MEA_Quality_Flag=dec2bin(fread(fid,n_recs,'uint32',record_size-4),32);
    
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*46+50*2+2*6+4*2,'bof');
    CS.MEA.Retracker_Flag=dec2bin(fread(fid,n_recs,'uint32',record_size-4),32);
    
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*46+50*2+2*6+4*3,'bof');
    CS.MEA.Height_Status_Flag=dec2bin(fread(fid,n_recs,'uint32',record_size-4),32);
    
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*46+50*2+2*6+4*4,'bof');
    CS.MEA.SAR_Freeboard_Status_Flag=dec2bin(fread(fid,n_recs,'uint32',record_size-4),32);
    
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*46+50*2+2*6+4*5,'bof');
    CS.MEA.Number_Looks_Averaged=fread(fid,n_recs,'uint16',record_size-2);
    
else
    
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group,'bof');
    CS.MEA.Height_over_surface=fread(fid,n_recs,'int32',record_size-4).*1e-3;
    
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4,'bof');
    CS.MEA.Sigma0=fread(fid,n_recs,'int32',record_size-4)/100;
    
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*2,'bof');
    CS.MEA.SWH=fread(fid,n_recs,'int32',record_size-4).*1e-3;
    
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*3,'bof');
    CS.MEA.Peakiness=fread(fid,n_recs,'int32',record_size-4).*1e-2;
    
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*4,'bof');
    CS.MEA.Retracked_Range=fread(fid,n_recs,'int32',record_size-4).*1e-3;
    
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*5,'bof');
    CS.MEA.Retracked_Sigma0_Corr=fread(fid,n_recs,'int32',record_size-4).*1e-2;
    
    switch CS.GEO.OPERATION_MODE
        
        case {'SIR_LRM_L2_I'}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*6,'bof');
            CS.MEA.LRM_Power_Amplitude=fread(fid,n_recs,'int32',record_size-4)*1e-15;
            
        case  {'SIR_SAR_L2A_I','SIR_SAR_L2B_I'}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*6,'bof');
            CS.MEA.SAR_Retracked_Output_3=fread(fid,n_recs,'int32',record_size-4);
            
        case  {'SIR_SIN_L2_I','SIR_SID_L2_I'}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*6,'bof');
            CS.MEA.SIN_Power=fread(fid,n_recs,'int32',record_size-4)*1e-18;
            
    end
    
    switch CS.GEO.OPERATION_MODE
        
        case {'SIR_LRM_L2_I'}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*7,'bof');
            CS.MEA.LRM_Leading_Edge_Width=fread(fid,n_recs,'int32',record_size-4)*1e-3;
            
        case  {'SIR_SAR_L2A_I','SIR_SAR_L2B_I'}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*7,'bof');
            CS.MEA.SAR_Retracked_Output_4=fread(fid,n_recs,'int32',record_size-4);
            
        case  {'SIR_SIN_L2_I','SIR_SID_L2_I'}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*7,'bof');
            CS.MEA.SIN_Echo_Width=fread(fid,n_recs,'int32',record_size-4).*1e-3;
            
    end
    
    switch CS.GEO.OPERATION_MODE
        
        case {'SIR_LRM_L2_I'}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*8,'bof');
            CS.MEA.LRM_Initialization_Value=fread(fid,n_recs,'int32',record_size-4).*1e-3;
            
        case  {'SIR_SAR_L2A_I','SIR_SAR_L2B_I'}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*8,'bof');
            CS.MEA.SAR_Retracked_Output_5=fread(fid,n_recs,'int32',record_size-4);
            
        case  {'SIR_SIN_L2_I','SIR_SID_L2_I'}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*8,'bof');
            CS.MEA.SIN_Retracked_Bin=fread(fid,n_recs,'int32',record_size-4).*1e-3;
            
    end
    
    switch CS.GEO.OPERATION_MODE
        
        case {'SIR_LRM_L2_I'}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*9,'bof');
            CS.MEA.LRM_U10=fread(fid,n_recs,'int32',record_size-4);
            
        case  {'SIR_SAR_L2A_I','SIR_SAR_L2B_I'}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*9,'bof');
            CS.MEA.SAR_Retracked_Output_6=fread(fid,n_recs,'int32',record_size-4);
            
        case  {'SIR_SIN_L2_I','SIR_SID_L2_I'}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*9,'bof');
            CS.MEA.SIN_Tail_Slope=fread(fid,n_recs,'int32',record_size-4)*1e-18;
            
    end
    
    switch CS.GEO.OPERATION_MODE
        
        case {'SIR_LRM_L2_I'}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*10,'bof');
            CS.MEA.LRM_OCOG_Retracked_Bin=fread(fid,n_recs,'int32',record_size-4).*1e-3;
            
        case  {'SIR_SAR_L2A_I','SIR_SAR_L2B_I'}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*10,'bof');
            CS.MEA.SAR_Retracked_Output_7=fread(fid,n_recs,'int32',record_size-4);
            
        case  {'SIR_SIN_L2_I','SIR_SID_L2_I'}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*10,'bof');
            CS.MEA.SIN_Tail_Delay=fread(fid,n_recs,'int32',record_size-4)*1e3;
            
    end
    
    
    switch CS.GEO.OPERATION_MODE
        
        case {'SIR_LRM_L2_I'}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*11,'bof');
            CS.MEA.LRM_Ocean_Retracked_Amplitude=fread(fid,n_recs,'int32',record_size-4)*1e-15;
            
        case  {'SIR_SAR_L2A_I','SIR_SAR_L2B_I'}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*11,'bof');
            CS.MEA.SAR_Retracked_Output_8=fread(fid,n_recs,'int32',record_size-4);
            
        case  {'SIR_SIN_L2_I','SIR_SID_L2_I'}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*11,'bof');
            CS.MEA.SIN_Leading_Edge_Slope=fread(fid,n_recs,'int32',record_size-4)*1e-3;
            
    end
    
    
    switch CS.GEO.OPERATION_MODE
        
        case {'SIR_LRM_L2_I'}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*12,'bof');
            CS.MEA.LRM_Ocean_Retracked_Thermal_Noise=fread(fid,n_recs,'int32',record_size-4).*1e-15;
            
        case  {'SIR_SAR_L2A_I','SIR_SAR_L2B_I'}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*12,'bof');
            CS.MEA.SAR_Retracked_Output_9=fread(fid,n_recs,'int32',record_size-4);
            
        case  {'SIR_SIN_L2_I','SIR_SID_L2_I'}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*12,'bof');
            CS.MEA.SIN_Chi_square=fread(fid,n_recs,'int32',record_size-4).*1e-6;
            
    end
    
    
    switch CS.GEO.OPERATION_MODE
        
        case {'SIR_LRM_L2_I'}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*13,'bof');
            CS.MEA.LRM_OCOG_Width=fread(fid,n_recs,'int32',record_size-4).*1e-3;
            
        case  {'SIR_SAR_L2A_I','SIR_SAR_L2B_I'}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*13,'bof');
            CS.MEA.SAR_Retracked_Output_10=fread(fid,n_recs,'int32',record_size-4);
            
        case  {'SIR_SIN_L2_I','SIR_SID_L2_I'}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*13,'bof');
            CS.MEA.SIN_Minimum_Chi_Square=fread(fid,n_recs,'int32',record_size-4).*1e-6;
            
    end
    
    switch CS.GEO.OPERATION_MODE
        
        case {'SIR_LRM_L2_I'}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*14,'bof');
            CS.MEA.LRM_Ocean_Retracked_Range_Correction=fread(fid,n_recs,'int32',record_size-4).*1e-3;
            
        case  {'SIR_SAR_L2A_I','SIR_SAR_L2B_I'}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*14,'bof');
            CS.MEA.SAR_Retracked_Output_11=fread(fid,n_recs,'int32',record_size-4);
            
        case  {'SIR_SIN_L2_I','SIR_SID_L2_I'}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*14,'bof');
            CS.MEA.SIN_Phase_Fit_Constant=fread(fid,n_recs,'int32',record_size-4).*1e-6;
            
    end
    
    switch CS.GEO.OPERATION_MODE
        
        case {'SIR_LRM_L2_I'}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*15,'bof');
            CS.MEA.LRM_OCOG_Retracked_Bin=fread(fid,n_recs,'int32',record_size-4).*1e-3;
            
        case  {'SIR_SAR_L2A_I','SIR_SAR_L2B_I'}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*15,'bof');
            CS.MEA.SAR_Retracked_Output_12=fread(fid,n_recs,'int32',record_size-4);
            
        case  {'SIR_SIN_L2_I','SIR_SID_L2_I'}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*15,'bof');
            CS.MEA.SIN_Phase_Fit_Slope=fread(fid,n_recs,'int32',record_size-4)*1e-6;
            
    end
    
    switch CS.GEO.OPERATION_MODE
        
        case {'SIR_LRM_L2_I'}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*16,'bof');
            CS.MEA.LRM_Retracked_Point=fread(fid,n_recs,'int32',record_size-4).*1e-3;
            
        case  {'SIR_SAR_L2A_I','SIR_SAR_L2B_I'}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*16,'bof');
            CS.MEA.SAR_Retracked_Point=fread(fid,n_recs,'int32',record_size-4).*1e-3;
            
        case  {'SIR_SIN_L2_I','SIR_SID_L2_I'}
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*16,'bof');
            CS.MEA.SIN_Retracked_Range=fread(fid,n_recs,'int32',record_size-4).*1e-3;
            
    end
    
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*17,'bof');
    CS.MEA.Power_Echo_Shape_Parameter=fread(fid,n_recs,'int32',record_size-4)*1e-2;
   
     fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*18,'bof');
    CS.MEA.beam_param(1,:)=fread(fid,n_recs,'uint16',record_size-2)./100;
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*18+2,'bof');
    CS.MEA.beam_param(2,:)=fread(fid,n_recs,'uint16',record_size-2)./100;  
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*18+2*2,'bof');
    CS.MEA.beam_param(3,:)=fread(fid,n_recs,'int16',record_size-2)./100;
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*18+2*3,'bof');
    CS.MEA.beam_param(4,:)=fread(fid,n_recs,'int16',record_size-2)./100;
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*18+2*4,'bof');
    CS.MEA.beam_param(5,:)=fread(fid,n_recs,'int16',record_size-2)./100;
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*18+2*5,'bof');
    CS.MEA.beam_param(6,:)=fread(fid,n_recs,'uint16',record_size-2).*1e-6;
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*18+2*6,'bof');
    CS.MEA.beam_param(7,:)=fread(fid,n_recs,'int16',record_size-2).*1e-6;
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*18+2*7,'bof');
    CS.MEA.beam_param(8,:)=fread(fid,n_recs,'int32',record_size-4).*1e-7;
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*18+2*7+4,'bof');
    CS.MEA.beam_param(9,:)=fread(fid,n_recs,'int32',record_size-4).*1e-7;
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*18+2*7+4*2,'bof');
    CS.MEA.beam_param(10,:)=fread(fid,n_recs,'int32',record_size-4).*1e-7;
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*18+2*7+4*3,'bof');
    CS.MEA.beam_param(11,:)=fread(fid,n_recs,'int32',record_size-4).*1e-7;
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*18+2*7+4*4,'bof');
    CS.MEA.beam_param(12,:)=fread(fid,n_recs,'uint16',record_size-2);
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*18+2*7+4*4+2,'bof');
    CS.MEA.beam_param(13,:)=fread(fid,n_recs,'uint16',record_size-2); 
    
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*18+50*2,'bof');
    CS.MEA.Cross_Track_Angle=fread(fid,n_recs,'int32',record_size-4)*1e-6;
    
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*18+50*2+4,'bof');
    CS.MEA.Coherence=fread(fid,n_recs,'int32',record_size-4)*1e-3;
    
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*18+50*2+4*2,'bof');
    CS.MEA.Interpolated_Ocean_Height=fread(fid,n_recs,'int32',record_size-4)*1e-3;
    
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*18+50*2+4*3,'bof');
    CS.MEA.Freeboard=fread(fid,n_recs,'int32',record_size-4)*1e-3;
    
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*18+50*2+4*4,'bof');
    CS.MEA.Surface_Height_Anomaly=fread(fid,n_recs,'int32',record_size-4)*1e-3;
    
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*18+50*2+4*5,'bof');
    CS.MEA.Interpolated_Sea_Surface_Height_Anomaly=fread(fid,n_recs,'int32',record_size-4)*1e-3;
    
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*18+50*2+4*6,'bof');
    CS.MEA.Ocean_Height_Interpolation_Error=fread(fid,n_recs,'uint16',record_size-2)*1e-3;
    
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*18+50*2+4*6+2,'bof');
    CS.MEA.Number_Interpolation_Point_Forward=fread(fid,n_recs,'uint16',record_size-2);
    
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*18+50*2+4*6+2*2,'bof');
    CS.MEA.Number_Interpolation_Point_Backward=fread(fid,n_recs,'uint16',record_size-2);
    
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*18+50*2+4*6+2*3,'bof');
    CS.MEA.Radius_Interpolation_Backward=fread(fid,n_recs,'uint16',record_size-2).*1e-3;
    
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*18+50*2+4*6+2*4,'bof');
    CS.MEA.Radius_Interpolation_Forward=fread(fid,n_recs,'uint16',record_size-2).*1e-3;
    
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*18+50*2+4*6+2*5,'bof');
    CS.MEA.Interpolation_Error_Flag=dec2bin(fread(fid,n_recs,'uint16',record_size-2),16);
    
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*18+50*2+4*6+2*6,'bof');
    CS.MEA.MEA_Mode=fread(fid,n_recs,'uint32',record_size-4);
    
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*18+50*2+4*6+2*6+4,'bof');
    CS.MEA.MEA_Quality_Flag=dec2bin(fread(fid,n_recs,'uint32',record_size-4),32);
    
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*18+50*2+4*6+2*6+4*2,'bof');
    CS.MEA.Retracker_Flag=dec2bin(fread(fid,n_recs,'uint32',record_size-4),32);
    
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*18+50*2+4*6+2*6+4*3,'bof');
    CS.MEA.Height_Status_Flag=dec2bin(fread(fid,n_recs,'uint32',record_size-4),32);
    
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*18+50*2+4*6+2*6+4*4,'bof');
    CS.MEA.SAR_Freeboard_Status_Flag=dec2bin(fread(fid,n_recs,'uint32',record_size-4),32);
    
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4*18+50*2+4*6+2*6+4*5,'bof');
    CS.MEA.Number_Looks_Averaged=fread(fid,n_recs,'uint16',record_size-2);
    
end

CS.MEA.Interpolation_Error_Flag_Tab.Result_Unreliable=bin2dec(CS.MEA.Interpolation_Error_Flag(:,1));
CS.MEA.Interpolation_Error_Flag_Tab.Interpolation_One_Sided=bin2dec(CS.MEA.Interpolation_Error_Flag(:,2));
CS.MEA.Interpolation_Error_Flag_Tab.No_Values_Available_for_interpolation=bin2dec(CS.MEA.Interpolation_Error_Flag(:,3));


if  strcmp( CS.GEO.Baseline_ID, 'C')
    
    CS.MEA.MEA_Quality_Flag_Tab.Height_err_r1=bin2dec(CS.MEA.MEA_Quality_Flag(:,1));
    CS.MEA.MEA_Quality_Flag_Tab.Height_err_r2=bin2dec(CS.MEA.MEA_Quality_Flag(:,2));
    CS.MEA.MEA_Quality_Flag_Tab.Height_err_r3=bin2dec(CS.MEA.MEA_Quality_Flag(:,3));
    CS.MEA.MEA_Quality_Flag_Tab.Sigma0_err_r1=bin2dec(CS.MEA.MEA_Quality_Flag(:,4));
    CS.MEA.MEA_Quality_Flag_Tab.Sigma0_err_r2=bin2dec(CS.MEA.MEA_Quality_Flag(:,5));
    CS.MEA.MEA_Quality_Flag_Tab.Sigma0_err_r3=bin2dec(CS.MEA.MEA_Quality_Flag(:,6));
    CS.MEA.MEA_Quality_Flag_Tab.Peakiness_err=bin2dec(CS.MEA.MEA_Quality_Flag(:,7));
    CS.MEA.MEA_Quality_Flag_Tab.Echo_Shape_Factor_err=bin2dec(CS.MEA.MEA_Quality_Flag(:,8));
    CS.MEA.MEA_Quality_Flag_Tab.X_Track_Angle_err=bin2dec(CS.MEA.MEA_Quality_Flag(:,9));
    CS.MEA.MEA_Quality_Flag_Tab.Coherence_err=bin2dec(CS.MEA.MEA_Quality_Flag(:,10));
    CS.MEA.MEA_Quality_Flag_Tab.Arithmetic_err=bin2dec(CS.MEA.MEA_Quality_Flag(:,11));
    CS.MEA.MEA_Quality_Flag_Tab.Wind_Speed_err=bin2dec(CS.MEA.MEA_Quality_Flag(:,12));
    CS.MEA.MEA_Quality_Flag_Tab.SWH_err=bin2dec(CS.MEA.MEA_Quality_Flag(:,13));
    
else
    
    CS.MEA.MEA_Quality_Flag_Tab.Height_err=bin2dec(CS.MEA.MEA_Quality_Flag(:,1));
    CS.MEA.MEA_Quality_Flag_Tab.Sigma0_err=bin2dec(CS.MEA.MEA_Quality_Flag(:,2));
    CS.MEA.MEA_Quality_Flag_Tab.Reserved_1=bin2dec(CS.MEA.MEA_Quality_Flag(:,3));
    CS.MEA.MEA_Quality_Flag_Tab.Peakiness_err=bin2dec(CS.MEA.MEA_Quality_Flag(:,4));
    CS.MEA.MEA_Quality_Flag_Tab.Echo_Shape_Factor_err=bin2dec(CS.MEA.MEA_Quality_Flag(:,5));
    CS.MEA.MEA_Quality_Flag_Tab.X_Track_Angle_err=bin2dec(CS.MEA.MEA_Quality_Flag(:,6));
    CS.MEA.MEA_Quality_Flag_Tab.Coherence_err=bin2dec(CS.MEA.MEA_Quality_Flag(:,7));
    CS.MEA.MEA_Quality_Flag_Tab.Arithmetic_err=bin2dec(CS.MEA.MEA_Quality_Flag(:,8));
    CS.MEA.MEA_Quality_Flag_Tab.Wind_Speed_err=bin2dec(CS.MEA.MEA_Quality_Flag(:,9));
    CS.MEA.MEA_Quality_Flag_Tab.SWH_err=bin2dec(CS.MEA.MEA_Quality_Flag(:,10));
    
end

if  strcmp( CS.GEO.Baseline_ID, 'C')
    
    CS.MEA.Retracker_Flag_Tab.Reserved_1=bin2dec(CS.MEA.Retracker_Flag(:,1));
    CS.MEA.Retracker_Flag_Tab.Low_Power_in_waveform=bin2dec(CS.MEA.Retracker_Flag(:,2));
    CS.MEA.Retracker_Flag_Tab.Low_Peakiness=bin2dec(CS.MEA.Retracker_Flag(:,3));
    CS.MEA.Retracker_Flag_Tab.High_Peakiness=bin2dec(CS.MEA.Retracker_Flag(:,4));
    CS.MEA.Retracker_Flag_Tab.High_Noise=bin2dec(CS.MEA.Retracker_Flag(:,5));
    CS.MEA.Retracker_Flag_Tab.Low_Variance=bin2dec(CS.MEA.Retracker_Flag(:,6));
    CS.MEA.Retracker_Flag_Tab.Bad_Leading_Edge=bin2dec(CS.MEA.Retracker_Flag(:,7));
    CS.MEA.Retracker_Flag_Tab.Reserved_2=bin2dec(CS.MEA.Retracker_Flag(:,8));
    CS.MEA.Retracker_Flag_Tab.Abnormal_beam_parameters=bin2dec(CS.MEA.Retracker_Flag(:,9));
    CS.MEA.Retracker_Flag_Tab.Reserved_3=bin2dec(CS.MEA.Retracker_Flag(:,10));
    CS.MEA.Retracker_Flag_Tab.Reserved_4=bin2dec(CS.MEA.Retracker_Flag(:,11));
    CS.MEA.Retracker_Flag_Tab.U10_Flag=bin2dec(CS.MEA.Retracker_Flag(:,12));
    CS.MEA.Retracker_Flag_Tab.Reserved_5=bin2dec(CS.MEA.Retracker_Flag(:,13));
    CS.MEA.Retracker_Flag_Tab.Reserved_6=bin2dec(CS.MEA.Retracker_Flag(:,14));
    CS.MEA.Retracker_Flag_Tab.SIN_Retrack_Interpolation_Failure=bin2dec(CS.MEA.Retracker_Flag(:,15));
    CS.MEA.Retracker_Flag_Tab.SIN_Low_Coherence=bin2dec(CS.MEA.Retracker_Flag(:,16));
    CS.MEA.Retracker_Flag_Tab.Fit_Failed=bin2dec(CS.MEA.Retracker_Flag(:,17));
    CS.MEA.Retracker_Flag_Tab.FDM_OCOG_Failed=bin2dec(CS.MEA.Retracker_Flag(:,18));
    CS.MEA.Retracker_Flag_Tab.Poor_Power_Fit=bin2dec(CS.MEA.Retracker_Flag(:,19));
    CS.MEA.Retracker_Flag_Tab.SIN_Poor_Phase_Fit=bin2dec(CS.MEA.Retracker_Flag(:,20));
    CS.MEA.Retracker_Flag_Tab.Retracker_Failure_r1=bin2dec(CS.MEA.Retracker_Flag(:,21));
    CS.MEA.Retracker_Flag_Tab.Retracker_Failure_r2=bin2dec(CS.MEA.Retracker_Flag(:,22));
    CS.MEA.Retracker_Flag_Tab.Retracker_Failure_r3=bin2dec(CS.MEA.Retracker_Flag(:,23));
    CS.MEA.Retracker_Flag_Tab.Reserved_7=bin2dec(CS.MEA.Retracker_Flag(:,24:32));
    
else
    
    CS.MEA.Retracker_Flag_Tab.Overall_Retracker_Failure=bin2dec(CS.MEA.Retracker_Flag(:,1));
    CS.MEA.Retracker_Flag_Tab.Low_Power_in_waveform=bin2dec(CS.MEA.Retracker_Flag(:,2));
    CS.MEA.Retracker_Flag_Tab.Low_Peakiness=bin2dec(CS.MEA.Retracker_Flag(:,3));
    CS.MEA.Retracker_Flag_Tab.High_Peakiness=bin2dec(CS.MEA.Retracker_Flag(:,4));
    CS.MEA.Retracker_Flag_Tab.High_Noise=bin2dec(CS.MEA.Retracker_Flag(:,5));
    CS.MEA.Retracker_Flag_Tab.Low_Variance=bin2dec(CS.MEA.Retracker_Flag(:,6));
    CS.MEA.Retracker_Flag_Tab.Bad_Leading_Edge=bin2dec(CS.MEA.Retracker_Flag(:,7));
    CS.MEA.Retracker_Flag_Tab.Retrack_Position_out_of_range=bin2dec(CS.MEA.Retracker_Flag(:,8));
    CS.MEA.Retracker_Flag_Tab.Abnormal_beam_parameters=bin2dec(CS.MEA.Retracker_Flag(:,9));
    CS.MEA.Retracker_Flag_Tab.Reserved_1=bin2dec(CS.MEA.Retracker_Flag(:,10));
    CS.MEA.Retracker_Flag_Tab.Reserved_2=bin2dec(CS.MEA.Retracker_Flag(:,11));
    CS.MEA.Retracker_Flag_Tab.Reserved_3=bin2dec(CS.MEA.Retracker_Flag(:,12));
    CS.MEA.Retracker_Flag_Tab.Reserved_4=bin2dec(CS.MEA.Retracker_Flag(:,13));
    CS.MEA.Retracker_Flag_Tab.Reserved_5=bin2dec(CS.MEA.Retracker_Flag(:,14));
    CS.MEA.Retracker_Flag_Tab.SIN_Retrack_Interpolation_Failure=bin2dec(CS.MEA.Retracker_Flag(:,15));
    CS.MEA.Retracker_Flag_Tab.SIN_Low_Coherence=bin2dec(CS.MEA.Retracker_Flag(:,16));
    CS.MEA.Retracker_Flag_Tab.Fit_Failed=bin2dec(CS.MEA.Retracker_Flag(:,17));
    CS.MEA.Retracker_Flag_Tab.FDM_OCOG_Failed=bin2dec(CS.MEA.Retracker_Flag(:,18));
    CS.MEA.Retracker_Flag_Tab.Poor_Power_Fit=bin2dec(CS.MEA.Retracker_Flag(:,19));
    CS.MEA.Retracker_Flag_Tab.SIN_Poor_Phase_Fit=bin2dec(CS.MEA.Retracker_Flag(:,20));
    CS.MEA.Retracker_Flag_Tab.Reserved_6=bin2dec(CS.MEA.Retracker_Flag(:,21:30));
    CS.MEA.Retracker_Flag_Tab.CFI_LRM_Retracker=bin2dec(CS.MEA.Retracker_Flag(:,31));
    CS.MEA.Retracker_Flag_Tab.OCOG_LRM_Retracker=bin2dec(CS.MEA.Retracker_Flag(:,32));
    
end

CS.MEA.Height_Status_Flag_Tab.Corrected_for_Internal_Calibration=bin2dec(CS.MEA.Height_Status_Flag(:,1));
CS.MEA.Height_Status_Flag_Tab.Corrected_for_Radial_Doppler=bin2dec(CS.MEA.Height_Status_Flag(:,2));
CS.MEA.Height_Status_Flag_Tab.Corrected_for_Dry_Troposphere=bin2dec(CS.MEA.Height_Status_Flag(:,3));
CS.MEA.Height_Status_Flag_Tab.Corrected_for_Wet_Troposphere=bin2dec(CS.MEA.Height_Status_Flag(:,4));
CS.MEA.Height_Status_Flag_Tab.Corrected_for_Inverse_Barometer=bin2dec(CS.MEA.Height_Status_Flag(:,5));
CS.MEA.Height_Status_Flag_Tab.Corrected_for_DAC=bin2dec(CS.MEA.Height_Status_Flag(:,6));
CS.MEA.Height_Status_Flag_Tab.Corrected_for_Iono_GIM=bin2dec(CS.MEA.Height_Status_Flag(:,7));
CS.MEA.Height_Status_Flag_Tab.Corrected_for_Iono_Model=bin2dec(CS.MEA.Height_Status_Flag(:,8));
CS.MEA.Height_Status_Flag_Tab.Corrected_for_Ocean_Tide=bin2dec(CS.MEA.Height_Status_Flag(:,9));
CS.MEA.Height_Status_Flag_Tab.Corrected_for_Ocean_Tide_Long_Period=bin2dec(CS.MEA.Height_Status_Flag(:,10));
CS.MEA.Height_Status_Flag_Tab.Corrected_for_Ocean_Tide_Loading=bin2dec(CS.MEA.Height_Status_Flag(:,11));
CS.MEA.Height_Status_Flag_Tab.Corrected_for_Solid_Earth_Tide=bin2dec(CS.MEA.Height_Status_Flag(:,12));
CS.MEA.Height_Status_Flag_Tab.Corrected_for_Geocentric_Polar_Tide=bin2dec(CS.MEA.Height_Status_Flag(:,13));
CS.MEA.Height_Status_Flag_Tab.Corrected_for_Slope_Doppler_Corr=bin2dec(CS.MEA.Height_Status_Flag(:,14));
CS.MEA.Height_Status_Flag_Tab.Applied_Mode_Specific_Window_Offset=bin2dec(CS.MEA.Height_Status_Flag(:,15));
CS.MEA.Height_Status_Flag_Tab.Applied_SAR_Retracker=bin2dec(CS.MEA.Height_Status_Flag(:,16));
CS.MEA.Height_Status_Flag_Tab.Applied_SIN_Retracker=bin2dec(CS.MEA.Height_Status_Flag(:,17));
CS.MEA.Height_Status_Flag_Tab.Applied_LRM_Retracker=bin2dec(CS.MEA.Height_Status_Flag(:,18));
CS.MEA.Height_Status_Flag_Tab.Applied_LRM_Ocean_Bias=bin2dec(CS.MEA.Height_Status_Flag(:,19));
CS.MEA.Height_Status_Flag_Tab.Applied_LRM_Ice_Bias=bin2dec(CS.MEA.Height_Status_Flag(:,20));
CS.MEA.Height_Status_Flag_Tab.Applied_SAR_Ocean_Bias=bin2dec(CS.MEA.Height_Status_Flag(:,21));
CS.MEA.Height_Status_Flag_Tab.Applied_SAR_Ice_Bias=bin2dec(CS.MEA.Height_Status_Flag(:,22));
CS.MEA.Height_Status_Flag_Tab.Applied_SIN_Ocean_Bias=bin2dec(CS.MEA.Height_Status_Flag(:,23));
CS.MEA.Height_Status_Flag_Tab.Applied_SIN_Ice_Bias=bin2dec(CS.MEA.Height_Status_Flag(:,24));
CS.MEA.Height_Status_Flag_Tab.LRM_Slope_Model_Valid=bin2dec(CS.MEA.Height_Status_Flag(:,25));
CS.MEA.Height_Status_Flag_Tab.SIN_Baseline_Bad=bin2dec(CS.MEA.Height_Status_Flag(:,26));
CS.MEA.Height_Status_Flag_Tab.SIN_out_of_range=bin2dec(CS.MEA.Height_Status_Flag(:,27));
CS.MEA.Height_Status_Flag_Tab.SIN_Velocity_Bad=bin2dec(CS.MEA.Height_Status_Flag(:,28));
CS.MEA.Height_Status_Flag_Tab.Applied_Sea_State_Bias=bin2dec(CS.MEA.Height_Status_Flag(:,29));
CS.MEA.Height_Status_Flag_Tab.Reserved=bin2dec(CS.MEA.Height_Status_Flag(:,30:31));
CS.MEA.Height_Status_Flag_Tab.Master_Failure=bin2dec(CS.MEA.Height_Status_Flag(:,32));


CS.MEA.SAR_Freeboard_Status_Flag_Tab.Unavailable_Freeboard_Measurement=bin2dec(CS.MEA.SAR_Freeboard_Status_Flag(:,1));
CS.MEA.SAR_Freeboard_Status_Flag_Tab.Unreliable_Freeboard_Measurement=bin2dec(CS.MEA.SAR_Freeboard_Status_Flag(:,2));
CS.MEA.SAR_Freeboard_Status_Flag_Tab.Northern_Geographical_Boundary_Freeboard_Measurement=bin2dec(CS.MEA.SAR_Freeboard_Status_Flag(:,3));
CS.MEA.SAR_Freeboard_Status_Flag_Tab.Southern_Geographical_Boundary_Freeboard_Measurement=bin2dec(CS.MEA.SAR_Freeboard_Status_Flag(:,4));


CS.MEA.Interpolation_Error_Flag=CS.MEA.Interpolation_Error_Flag_Tab;
CS.MEA=rmfield(CS.MEA,'Interpolation_Error_Flag_Tab');

CS.MEA.MEA_Quality_Flag=CS.MEA.MEA_Quality_Flag_Tab;
CS.MEA=rmfield(CS.MEA,'MEA_Quality_Flag_Tab');

CS.MEA.Retracker_Flag=CS.MEA.Retracker_Flag_Tab;
CS.MEA=rmfield(CS.MEA,'Retracker_Flag_Tab');

CS.MEA.Height_Status_Flag=CS.MEA.Height_Status_Flag_Tab;
CS.MEA=rmfield(CS.MEA,'Height_Status_Flag_Tab');

CS.MEA.SAR_Freeboard_Status_Flag=CS.MEA.SAR_Freeboard_Status_Flag_Tab;
CS.MEA=rmfield(CS.MEA,'SAR_Freeboard_Status_Flag_Tab');


%%% Auxiliary Measurements Group

fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+meas_group,'bof');
CS.AUX.Ice_Concentration=fread(fid,n_recs,'int32',record_size-4)./1000;

fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+meas_group+4,'bof');
CS.AUX.Snow_Depth=fread(fid,n_recs,'int32',record_size-4).*1e-3;

fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+meas_group+4.*2,'bof');
CS.AUX.Snow_Density=fread(fid,n_recs,'int32',record_size-4);

fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+meas_group+4.*3,'bof');
CS.AUX.Discriminator_Result=fread(fid,n_recs,'int32',record_size-4);

fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+meas_group+4.*4,'bof');
CS.AUX.SIN_Discriminator_Total_Power=fread(fid,n_recs,'int32',record_size-4).*1e-18;

fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+meas_group+4.*5,'bof');
CS.AUX.SIN_Discriminator_Max_Power=fread(fid,n_recs,'int32',record_size-4).*1e-18;

fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+meas_group+4.*6,'bof');
CS.AUX.SIN_Discriminator_Mean_Power=fread(fid,n_recs,'int32',record_size-4).*1e-18;

fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+meas_group+4.*7,'bof');
CS.AUX.SIN_Discriminator_Bin_with_Max_Power=fread(fid,n_recs,'int32',record_size-4).*1e-3;

fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+meas_group+4.*8,'bof');
CS.AUX.SIN_Discriminator_Bin_of_Half_Max_Power=fread(fid,n_recs,'int32',record_size-4).*1e-3;

fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+meas_group+4.*9,'bof');
CS.AUX.SIN_Discriminator_Max_Coherence=fread(fid,n_recs,'int32',record_size-4).*1e-3;

fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+meas_group+4.*10,'bof');
CS.AUX.SIN_Discriminator_Bin_with_Max_Coherence=fread(fid,n_recs,'int32',record_size-4).*1e-3;

fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+meas_group+4.*11,'bof');
CS.AUX.SIN_Discriminator_First_Power_Bin=fread(fid,n_recs,'int32',record_size-4).*1e-3;

fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+meas_group+4.*12,'bof');
CS.AUX.SIN_Discriminator_Last_Power_Bin=fread(fid,n_recs,'int32',record_size-4).*1e-3;

fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+meas_group+4.*13,'bof');
CS.AUX.SIN_Discriminator_Reserved=fread(fid,n_recs,'int32',record_size-4);

fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+meas_group+4.*14,'bof');
CS.AUX.SIN_Discriminator_Status_Flag=dec2bin(fread(fid,n_recs,'uint32',record_size-4),32);

CS.AUX.SIN_Discriminator_Status_Flag_Tab.Overall_Discriminator_Failure=bin2dec(CS.AUX.SIN_Discriminator_Status_Flag(:,1));
CS.AUX.SIN_Discriminator_Status_Flag_Tab.LRM_Discriminator=bin2dec(CS.AUX.SIN_Discriminator_Status_Flag(:,2));
CS.AUX.SIN_Discriminator_Status_Flag_Tab.LRM_Reserved=bin2dec(CS.AUX.SIN_Discriminator_Status_Flag(:,3:10));
CS.AUX.SIN_Discriminator_Status_Flag_Tab.SIN_Low_Variance=bin2dec(CS.AUX.SIN_Discriminator_Status_Flag(:,11));
CS.AUX.SIN_Discriminator_Status_Flag_Tab.SIN_Bad_Leading_Edge=bin2dec(CS.AUX.SIN_Discriminator_Status_Flag(:,12));
CS.AUX.SIN_Discriminator_Status_Flag_Tab.SIN_High_Noise=bin2dec(CS.AUX.SIN_Discriminator_Status_Flag(:,13));
CS.AUX.SIN_Discriminator_Status_Flag_Tab.SIN_Low_Peakiness=bin2dec(CS.AUX.SIN_Discriminator_Status_Flag(:,14));
CS.AUX.SIN_Discriminator_Status_Flag_Tab.SIN_Low_Power=bin2dec(CS.AUX.SIN_Discriminator_Status_Flag(:,15));
CS.AUX.SIN_Discriminator_Status_Flag_Tab.SIN_High_Peakiness=bin2dec(CS.AUX.SIN_Discriminator_Status_Flag(:,16));
CS.AUX.SIN_Discriminator_Status_Flag_Tab.SIN_Reserved=bin2dec(CS.AUX.SIN_Discriminator_Status_Flag(:,17:20));
CS.AUX.SIN_Discriminator_Status_Flag_Tab.SAR_Very_High_Peakiness=bin2dec(CS.AUX.SIN_Discriminator_Status_Flag(:,21));
CS.AUX.SIN_Discriminator_Status_Flag_Tab.SAR_Very_Low_Peakiness=bin2dec(CS.AUX.SIN_Discriminator_Status_Flag(:,22));
CS.AUX.SIN_Discriminator_Status_Flag_Tab.SAR_Low_Power=bin2dec(CS.AUX.SIN_Discriminator_Status_Flag(:,23));
CS.AUX.SIN_Discriminator_Status_Flag_Tab.SAR_abnormal_beam_params=bin2dec(CS.AUX.SIN_Discriminator_Status_Flag(:,24));
CS.AUX.SIN_Discriminator_Status_Flag_Tab.Unavailable_SAR_Ice_Concentration=bin2dec(CS.AUX.SIN_Discriminator_Status_Flag(:,25));
CS.AUX.SIN_Discriminator_Status_Flag_Tab.Unreliable_SAR_Ice_Concentration=bin2dec(CS.AUX.SIN_Discriminator_Status_Flag(:,26));
CS.AUX.SIN_Discriminator_Status_Flag_Tab.SAR_SNR_Low=bin2dec(CS.AUX.SIN_Discriminator_Status_Flag(:,27));
CS.AUX.SIN_Discriminator_Status_Flag_Tab.Waveform_Wide=bin2dec(CS.AUX.SIN_Discriminator_Status_Flag(:,28));

fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+meas_group+4.*15,'bof');
CS.AUX.Slope_Model_Correction_Attitude=fread(fid,n_recs,'int32',record_size-4)*1e-6;

fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+meas_group+4.*16,'bof');
CS.AUX.Slope_Model_Correction_Azimuth=fread(fid,n_recs,'int32',record_size-4)*1e-6;


if  strcmp( CS.GEO.Baseline_ID, 'C')
    
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+meas_group+4.*17,'bof');
    CS.AUX.Slope_Doppler_Correction=fread(fid,n_recs,'int32',record_size-4)*1e-3;
    
end


fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+meas_group+aux_slope_field+4.*17,'bof');
CS.AUX.Uncorrected_Lat=fread(fid,n_recs,'int32',record_size-4)*1e-7;

fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+meas_group+aux_slope_field+4.*18,'bof');
CS.AUX.Uncorrected_Lon=fread(fid,n_recs,'int32',record_size-4)*1e-7;

fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+meas_group+aux_slope_field+4.*19,'bof');
CS.AUX.Ambiguity_Indicator_Flag=dec2bin(fread(fid,n_recs,'uint32',record_size-4),32);

CS.AUX.Ambiguity_Indicator_Flag_Tab.Overall_Ambiguity=bin2dec(CS.AUX.Ambiguity_Indicator_Flag(:,1));
CS.AUX.Ambiguity_Indicator_Flag_Tab.Reserved=bin2dec(CS.AUX.Ambiguity_Indicator_Flag(:,2:10));
CS.AUX.Ambiguity_Indicator_Flag_Tab.Unavailable_DEM=bin2dec(CS.AUX.Ambiguity_Indicator_Flag(:,11));
CS.AUX.Ambiguity_Indicator_Flag_Tab.Different_Elevations=bin2dec(CS.AUX.Ambiguity_Indicator_Flag(:,12));
CS.AUX.Ambiguity_Indicator_Flag_Tab.Retracker_Failed=bin2dec(CS.AUX.Ambiguity_Indicator_Flag(:,13));
CS.AUX.Ambiguity_Indicator_Flag_Tab.Maths_err=bin2dec(CS.AUX.Ambiguity_Indicator_Flag(:,14));

fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+meas_group+aux_slope_field+4.*20,'bof');
CS.AUX.MSS=fread(fid,n_recs,'int32',record_size-4)*1e-3;

fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+meas_group+aux_slope_field+4.*21,'bof');
CS.AUX.Geoid=fread(fid,n_recs,'int32',record_size-4)*1e-3;

fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+meas_group+aux_slope_field+4.*22,'bof');
CS.AUX.ODLE=fread(fid,n_recs,'int32',record_size-4)*1e-3;

fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+meas_group+aux_slope_field+4.*23,'bof');
CS.AUX.DEM=fread(fid,n_recs,'int32',record_size-4)*1e-3;

fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+meas_group+aux_slope_field+4.*24,'bof');
CS.AUX.DEM_ID=fread(fid,n_recs,'uint32',record_size-4);


CS.AUX.SIN_Discriminator_Status_Flag=CS.AUX.SIN_Discriminator_Status_Flag_Tab;
CS.AUX=rmfield(CS.AUX,'SIN_Discriminator_Status_Flag_Tab');

CS.AUX.Ambiguity_Indicator_Flag=CS.AUX.Ambiguity_Indicator_Flag_Tab;
CS.AUX=rmfield(CS.AUX,'Ambiguity_Indicator_Flag_Tab');

%%% External Corrections Group

fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+meas_group+aux_meas_group,'bof');
CS.COR.Dry_Tropo=fread(fid,n_recs,'int32',record_size-4)*1e-3; % meter

fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+meas_group+aux_meas_group+4.*1,'bof');
CS.COR.Wet_Tropo=fread(fid,n_recs,'int32',record_size-4)*1e-3; % meter

fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+meas_group+aux_meas_group+4.*2,'bof');
CS.COR.Inv_Baro=fread(fid,n_recs,'int32',record_size-4)*1e-3; % meter

fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+meas_group+aux_meas_group+4.*3,'bof');
CS.COR.DAC=fread(fid,n_recs,'int32',record_size-4)*1e-3; % meter

fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+meas_group+aux_meas_group+4.*4,'bof');
CS.COR.GIM_Iono=fread(fid,n_recs,'int32',record_size-4)*1e-3; % meter

fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+meas_group+aux_meas_group+4.*5,'bof');
CS.COR.Model_Iono=fread(fid,n_recs,'int32',record_size-4)*1e-3; % meter

fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+meas_group+aux_meas_group+4.*6,'bof');
CS.COR.Ocean_Tide=fread(fid,n_recs,'int32',record_size-4)*1e-3; % meter

fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+meas_group+aux_meas_group+4.*7,'bof');
CS.COR.LPE_Ocean_Tide=fread(fid,n_recs,'int32',record_size-4)*1e-3; % meter

fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+meas_group+aux_meas_group+4.*8,'bof');
CS.COR.Ocean_Loading_Tide=fread(fid,n_recs,'int32',record_size-4)*1e-3; % meter

fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+meas_group+aux_meas_group+4.*9,'bof');
CS.COR.Solid_Earth_Tide=fread(fid,n_recs,'int32',record_size-4)*1e-3; % meter

fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+meas_group+aux_meas_group+4.*10,'bof');
CS.COR.Geoc_Polar_Tide=fread(fid,n_recs,'int32',record_size-4)*1e-3; % meter

fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+meas_group+aux_meas_group+4.*11,'bof');
CS.COR.SURF_TYPE=fread(fid,n_recs,'uint32',record_size-4);

fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+meas_group+aux_meas_group+4.*12,'bof');
CS.COR.COR_Status_Flag=dec2bin(fread(fid,n_recs,'uint32',record_size-4),32);

CS.COR.COR_Status_Flag_tab.Called_Dry_Tropo=bin2dec(CS.COR.COR_Status_Flag(:,1));
CS.COR.COR_Status_Flag_tab.Called_Wet_Tropo=bin2dec(CS.COR.COR_Status_Flag(:,2));
CS.COR.COR_Status_Flag_tab.Called_Inverse_Barometric=bin2dec(CS.COR.COR_Status_Flag(:,3));
CS.COR.COR_Status_Flag_tab.Called_DAC=bin2dec(CS.COR.COR_Status_Flag(:,4));
CS.COR.COR_Status_Flag_tab.Called_GIM_Iono=bin2dec(CS.COR.COR_Status_Flag(:,5));
CS.COR.COR_Status_Flag_tab.Called_Model_Iono=bin2dec(CS.COR.COR_Status_Flag(:,6));
CS.COR.COR_Status_Flag_tab.Called_Ocean_Tide=bin2dec(CS.COR.COR_Status_Flag(:,7));
CS.COR.COR_Status_Flag_tab.Called_Ocean_LongPeriod_Tide=bin2dec(CS.COR.COR_Status_Flag(:,8));
CS.COR.COR_Status_Flag_tab.Called_Ocean_Loading_Tide=bin2dec(CS.COR.COR_Status_Flag(:,9));
CS.COR.COR_Status_Flag_tab.Called_Solid_Earth_Tide=bin2dec(CS.COR.COR_Status_Flag(:,10));
CS.COR.COR_Status_Flag_tab.Called_Geocentric_Polar_Tide=bin2dec(CS.COR.COR_Status_Flag(:,11));
CS.COR.COR_Status_Flag_tab.Called_Surface_Type=bin2dec(CS.COR.COR_Status_Flag(:,12));
CS.COR.COR_Status_Flag_tab.Called_Ice_Concentration_Model=bin2dec(CS.COR.COR_Status_Flag(:,13));
CS.COR.COR_Status_Flag_tab.Called_Snow_Depth_Model=bin2dec(CS.COR.COR_Status_Flag(:,14));
CS.COR.COR_Status_Flag_tab.Called_Snow_Density_Model=bin2dec(CS.COR.COR_Status_Flag(:,15));
CS.COR.COR_Status_Flag_tab.Called_MSS=bin2dec(CS.COR.COR_Status_Flag(:,16));
CS.COR.COR_Status_Flag_tab.Called_Geoid=bin2dec(CS.COR.COR_Status_Flag(:,17));
CS.COR.COR_Status_Flag_tab.Called_ODLE=bin2dec(CS.COR.COR_Status_Flag(:,18));
CS.COR.COR_Status_Flag_tab.Called_DEM=bin2dec(CS.COR.COR_Status_Flag(:,19));
CS.COR.COR_Status_Flag_tab.Called_Slope_Model=bin2dec(CS.COR.COR_Status_Flag(:,20));
CS.COR.COR_Status_Flag_tab.Called_SSB_Model=bin2dec(CS.COR.COR_Status_Flag(:,21));

fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+meas_group+aux_meas_group+4.*13,'bof');
CS.COR.COR_Error_Flag=dec2bin(fread(fid,n_recs,'uint32',record_size-4),32);

CS.COR.COR_Error_Flag_tab.Dry_Tropo_err=bin2dec(CS.COR.COR_Error_Flag(:,1));
CS.COR.COR_Error_Flag_tab.Wet_Tropo_err=bin2dec(CS.COR.COR_Error_Flag(:,2));
CS.COR.COR_Error_Flag_tab.Inverse_Barometric_err=bin2dec(CS.COR.COR_Error_Flag(:,3));
CS.COR.COR_Error_Flag_tab.DAC_err=bin2dec(CS.COR.COR_Error_Flag(:,4));
CS.COR.COR_Error_Flag_tab.GIM_Iono_err=bin2dec(CS.COR.COR_Error_Flag(:,5));
CS.COR.COR_Error_Flag_tab.Model_Iono_err=bin2dec(CS.COR.COR_Error_Flag(:,6));
CS.COR.COR_Error_Flag_tab.Ocean_Tide_err=bin2dec(CS.COR.COR_Error_Flag(:,7));
CS.COR.COR_Error_Flag_tab.Ocean_LongPeriod_Tide_err=bin2dec(CS.COR.COR_Error_Flag(:,8));
CS.COR.COR_Error_Flag_tab.Ocean_Loading_Tide_err=bin2dec(CS.COR.COR_Error_Flag(:,9));
CS.COR.COR_Error_Flag_tab.Solid_Earth_Tide_err=bin2dec(CS.COR.COR_Error_Flag(:,10));
CS.COR.COR_Error_Flag_tab.Geocentric_Polar_Tide_err=bin2dec(CS.COR.COR_Error_Flag(:,11));
CS.COR.COR_Error_Flag_tab.Surface_Type_err=bin2dec(CS.COR.COR_Error_Flag(:,12));
CS.COR.COR_Error_Flag_tab.Ice_Concentration_Model_err=bin2dec(CS.COR.COR_Error_Flag(:,13));
CS.COR.COR_Error_Flag_tab.Snow_Depth_Model_err=bin2dec(CS.COR.COR_Error_Flag(:,14));
CS.COR.COR_Error_Flag_tab.Snow_Density_Model_err=bin2dec(CS.COR.COR_Error_Flag(:,15));
CS.COR.COR_Error_Flag_tab.MSS_err=bin2dec(CS.COR.COR_Error_Flag(:,16));
CS.COR.COR_Error_Flag_tab.Geoid_err=bin2dec(CS.COR.COR_Error_Flag(:,17));
CS.COR.COR_Error_Flag_tab.ODLE_err=bin2dec(CS.COR.COR_Error_Flag(:,18));
CS.COR.COR_Error_Flag_tab.DEM_err=bin2dec(CS.COR.COR_Error_Flag(:,19));
CS.COR.COR_Error_Flag_tab.Slope_Model_err=bin2dec(CS.COR.COR_Error_Flag(:,20));
CS.COR.COR_Error_Flag_tab.SSB_Model_err=bin2dec(CS.COR.COR_Error_Flag(:,21));

fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+meas_group+aux_meas_group+4.*14,'bof');
CS.COR.SSB=fread(fid,n_recs,'int32',record_size-4).*1e-3;

CS.COR.COR_Status_Flag=CS.COR.COR_Status_Flag_tab;
CS.COR=rmfield(CS.COR,'COR_Status_Flag_tab');

CS.COR.COR_Error_Flag=CS.COR.COR_Error_Flag_tab;
CS.COR=rmfield(CS.COR,'COR_Error_Flag_tab');

%%% Internal Corrections Group

fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+meas_group+aux_meas_group+ext_corr_group,'bof');
CS.CAL.Doppler_Range_Correction=fread(fid,n_recs,'int32',record_size-4).*1e-3;

fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+meas_group+aux_meas_group+ext_corr_group+4,'bof');
CS.CAL.Tx_Rx_Instrument_Range_Correction=fread(fid,n_recs,'int32',record_size-4).*1e-3;

fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+meas_group+aux_meas_group+ext_corr_group+4.*2,'bof');
CS.CAL.Rx_Instrument_Range_Correction=fread(fid,n_recs,'int32',record_size-4).*1e-3;

fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+meas_group+aux_meas_group+ext_corr_group+4.*3,'bof');
CS.CAL.Tx_Rx_Instrument_Sigma0_Correction=fread(fid,n_recs,'int32',record_size-4).*1e-2;

fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+meas_group+aux_meas_group+ext_corr_group+4.*4,'bof');
CS.CAL.Rx_Instrument_Sigma0_Correction=fread(fid,n_recs,'int32',record_size-4).*1e-2;

fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+meas_group+aux_meas_group+ext_corr_group+4.*5,'bof');
CS.CAL.Internal_Phase_Correction=fread(fid,n_recs,'int32',record_size-4).*1e-3;

fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+meas_group+aux_meas_group+ext_corr_group+4.*6,'bof');
CS.CAL.External_Phase_Correction=fread(fid,n_recs,'int32',record_size-4).*1e-3;

fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+meas_group+aux_meas_group+ext_corr_group+4.*7,'bof');
CS.CAL.Noise_Power_Measurement=fread(fid,n_recs,'int32',record_size-4).*1e-2;

if  strcmp( CS.GEO.Baseline_ID, 'C')
    
    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+meas_group+aux_meas_group+ext_corr_group+4.*8,'bof');
    CS.CAL.Phase_Slope_Correction=fread(fid,n_recs,'int32',record_size-4).*1e-3;
    
end

%%% Reading End %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


CS.GEO.Serial_Sec_Num=CS.GEO.TAI.days.*24.*60.*60+CS.GEO.TAI.secs+CS.GEO.TAI.microsecs./1e6;
CS.GEO.Elapsed_Time=zeros(size(CS.GEO.Serial_Sec_Num));
CS.GEO.Elapsed_Time(CS.GEO.Serial_Sec_Num~=0)=CS.GEO.Serial_Sec_Num(CS.GEO.Serial_Sec_Num~=0)-CS.GEO.Start_Time;
CS.GEO.V.V=sqrt(CS.GEO.V.Vx.^2+CS.GEO.V.Vy.^2+CS.GEO.V.Vz.^2);

fclose(fid);
