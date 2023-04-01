
function [HDR, CS]=Cryo_L2_read(full_filename)

% Scope: Matlab Function to ingest CryoSat L2 data products to matlab workspace
% Data Level: 2
% Supported Modes: LRM, SAR, SARin, FDM, SID, GDR
%
% Input Argument: <full_filename> is the full pathname (path + file) where the CryoSat .DBL
% file is stored in your local drive
%
% Output Arguments: the structures <HDR>, containing the header of the read file, and the structure <CS>,
% containing the read data fields
%
% Author: Salvatore Dinardo
% Date: 15/07/2015
% Version: 3.2
% Compliance to CryoSat L2 Product Specification: 4.2
% Debugging: for any issues, please write to salvatore.dinardo@esa.int
% Track Change Log:
%
%    - version 2.6: fix for the fields:   CS.COR.total_ocean
%    - version 2.7: fix for the scaling factor for ice concentration
%    - version 2.8: fix a bug in byte positioning for correction flag extraction
%    - version 3.0: add compatibility to Baseline C
%    - version 3.1:  nominal version for Baseline C
%    - version 3.2: corrected a bug for Corr_Applic_flag_20Hz (flag reading skipped in Baseline B)

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
    
    if ftell(fid)>=MPH_size+HDR.SPH_SIZE 
    
        break;
    end
    if i>=50000  %error
        break;    
    end
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

%%%%%%%%%%%%%%%%%%%%%%%%  DATA STRUCTURE INFORMATION %%%%%%%%%%%%%%%%%%%%%%

if   strcmp(CS.GEO.Baseline_ID,'C')
    
    switch  CS.GEO.OPERATION_MODE
        
        case  {'SIR_LRM_L2','SIR_SAR_L2A','SIR_SAR_L2B','SIR_SIN_L2','SIR_SID_L2','SIR_GDR_2A','SIR_GDR_2B','SIR_SAR_L2','SIR_GDR_2_'}
            
            mispo_group=4+4+4;
            meas_group=4*6+2*10+4+4+4+4+4;
            
    end
    
else
    
    mispo_group=0;
    meas_group=4+4+4+4+2+2+2+2+2+2+2+2+4+8;
    
end


switch CS.GEO.OPERATION_MODE
    
    case {'SIR_LRM_L2','SIR_SAR_L2A','SIR_SAR_L2B','SIR_SIN_L2','SIR_SID_L2','SIR_GDR_2A','SIR_GDR_2B','SIR_SAR_L2','SIR_GDR_2_'}
        
        N_block=20;
        timestamp=4+4+4;
        time_group=timestamp+8+4+4+4+mispo_group+2+2; % time and orbit group 36 bytes
        ext_corr_group=2+2+2+2+2+2+2+2+2+2+2+2+8+4+4+2+2+2+2+4+2+2+8; % external corrections group 64 bytes
        record_size=time_group+ext_corr_group+meas_group.*N_block; % 980 byte
        
    case {'SIR_FDM_L2'}
        
        timestamp=4+4+4;
        time_group=timestamp+20.*4+4+20.*4+4+20.*4+4+4+4+20.*4+2+2;  % Time and orbit group
        range_group=4+20.*4+2+2+4+4+20.*4+2+2+4; % Measurement group
        geo_corr_group=2.*10;       % Geocorrection group
        SWH_Sigma0_group=4+2+2+20.*4+2+2+4+2+2+20.*2+2+2+4+2+2+20*2+2+2+4+4+4;
        geophysical_group=4+4+4+2+2+2+2+2+2+2+2+20.*2+4+2+2;
        record_size=geo_corr_group+time_group+range_group+SWH_Sigma0_group+geophysical_group;
        
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

switch CS.GEO.OPERATION_MODE
    
    case  {'SIR_LRM_L2','SIR_SAR_L2A','SIR_SAR_L2B','SIR_SIN_L2','SIR_SID_L2','SIR_GDR_2A','SIR_GDR_2B','SIR_SAR_L2','SIR_GDR_2_'}
        
        
        CS.GEO.MEAS_MODE_tab=zeros(N_block,n_recs);
        CS.COR.SURF_TYPE_tab=zeros(N_block,n_recs);
        
        if   strcmp(CS.GEO.Baseline_ID,'C')
            
            CS.MEA.delta_time_20Hz=zeros(N_block,n_recs);
            CS.MEA.LAT_20Hz=zeros(N_block,n_recs);
            CS.MEA.LON_20Hz=zeros(N_block,n_recs);
            CS.MEA.surf_height_r1_20Hz=zeros(N_block,n_recs);
            CS.MEA.surf_height_r2_20Hz=zeros(N_block,n_recs);
            CS.MEA.surf_height_r3_20Hz=zeros(N_block,n_recs);
            CS.MEA.backsc_sig_r1_20Hz=zeros(N_block,n_recs);
            CS.MEA.backsc_sig_r2_20Hz=zeros(N_block,n_recs);
            CS.MEA.backsc_sig_r3_20Hz=zeros(N_block,n_recs);
            CS.MEA.freeboard_20Hz=zeros(N_block,n_recs);
            CS.MEA.SLA_interp_20Hz=zeros(N_block,n_recs);
            CS.MEA.SLA_N_rec_20Hz=zeros(N_block,n_recs);
            CS.MEA.SLA_interp_qual_20Hz=zeros(N_block,n_recs);
            CS.MEA.peakiness_20Hz=zeros(N_block,n_recs);
            CS.MEA.beam_avg_N_20Hz=zeros(N_block,n_recs);
            CS.MEA.Qual_flag_20Hz=char(zeros(32,N_block,n_recs));
            CS.MEA.Corr_Applic_flag_20Hz=char(zeros(32,N_block,n_recs));
            CS.MEA.Qual_r1_Value_20Hz=zeros(N_block,n_recs);
            CS.MEA.Qual_r1_Value_20Hz=zeros(N_block,n_recs);
            CS.MEA.Qual_r1_Value_20Hz=zeros(N_block,n_recs);
            
            CS.MEA.Qual_flag_20Hz_tab.record_degraded=zeros(N_block,n_recs);
            CS.MEA.Qual_flag_20Hz_tab.orbit_err=zeros(N_block,n_recs);
            CS.MEA.Qual_flag_20Hz_tab.orbit_discont=zeros(N_block,n_recs);
            CS.MEA.Qual_flag_20Hz_tab.height_err_r1=zeros(N_block,n_recs);
            CS.MEA.Qual_flag_20Hz_tab.height_err_r2=zeros(N_block,n_recs);
            CS.MEA.Qual_flag_20Hz_tab.height_err_r3=zeros(N_block,n_recs);
            CS.MEA.Qual_flag_20Hz_tab.backsc_err_r1=zeros(N_block,n_recs);
            CS.MEA.Qual_flag_20Hz_tab.backsc_err_r2=zeros(N_block,n_recs);
            CS.MEA.Qual_flag_20Hz_tab.backsc_err_r3=zeros(N_block,n_recs);
            CS.MEA.Qual_flag_20Hz_tab.interp_SSHA_err=zeros(N_block,n_recs);
            CS.MEA.Qual_flag_20Hz_tab.peakiness_err=zeros(N_block,n_recs);
            CS.MEA.Qual_flag_20Hz_tab.freeboard_err=zeros(N_block,n_recs);
            CS.MEA.Qual_flag_20Hz_tab.SAR_discriminator_ocean=zeros(N_block,n_recs);
            CS.MEA.Qual_flag_20Hz_tab.SAR_discriminator_lead=zeros(N_block,n_recs);
            CS.MEA.Qual_flag_20Hz_tab.SAR_discriminator_ice=zeros(N_block,n_recs);
            CS.MEA.Qual_flag_20Hz_tab.SAR_discriminator_unknown=zeros(N_block,n_recs);
            CS.MEA.Qual_flag_20Hz_tab.SARin_Xtrack_angle_err=zeros(N_block,n_recs);
            CS.MEA.Qual_flag_20Hz_tab.SARin_ch1_err=zeros(N_block,n_recs);
            CS.MEA.Qual_flag_20Hz_tab.SARin_ch2_err=zeros(N_block,n_recs);
            CS.MEA.Qual_flag_20Hz_tab.SIRAL_id=zeros(N_block,n_recs);
            CS.MEA.Qual_flag_20Hz_tab.surf_mod_available=zeros(N_block,n_recs);
            CS.MEA.Qual_flag_20Hz_tab.misp_err=zeros(N_block,n_recs);
            CS.MEA.Qual_flag_20Hz_tab.delta_time_err=zeros(N_block,n_recs);
            CS.MEA.Qual_flag_20Hz_tab.LRM_Slope_Model_valid=zeros(N_block,n_recs);
            CS.MEA.Qual_flag_20Hz_tab.SIN_Baseline_bad=zeros(N_block,n_recs);
            CS.MEA.Qual_flag_20Hz_tab.SIN_Out_of_Range=zeros(N_block,n_recs);
            CS.MEA.Qual_flag_20Hz_tab.SIN_Velocity_bad=zeros(N_block,n_recs);
            CS.MEA.Qual_flag_20Hz_tab.cal_wrng=zeros(N_block,n_recs);
            
            CS.MEA.Corr_Applic_flag_20Hz_tab.corr_int_cal=zeros(N_block,n_recs);
            CS.MEA.Corr_Applic_flag_20Hz_tab.corr_rad_doppler=zeros(N_block,n_recs);
            CS.MEA.Corr_Applic_flag_20Hz_tab.corr_dry_tropo=zeros(N_block,n_recs);
            CS.MEA.Corr_Applic_flag_20Hz_tab.corr_wet_tropo=zeros(N_block,n_recs);
            CS.MEA.Corr_Applic_flag_20Hz_tab.corr_inv_bar=zeros(N_block,n_recs);
            CS.MEA.Corr_Applic_flag_20Hz_tab.corr_hf_atmo=zeros(N_block,n_recs);
            CS.MEA.Corr_Applic_flag_20Hz_tab.corr_iono_gim=zeros(N_block,n_recs);
            CS.MEA.Corr_Applic_flag_20Hz_tab.corr_iono_model=zeros(N_block,n_recs);
            CS.MEA.Corr_Applic_flag_20Hz_tab.corr_ocean_tide=zeros(N_block,n_recs);
            CS.MEA.Corr_Applic_flag_20Hz_tab.corr_lpe_tide=zeros(N_block,n_recs);
            CS.MEA.Corr_Applic_flag_20Hz_tab.corr_ocean_loading=zeros(N_block,n_recs);
            CS.MEA.Corr_Applic_flag_20Hz_tab.corr_se_tide=zeros(N_block,n_recs);
            CS.MEA.Corr_Applic_flag_20Hz_tab.corr_geo_polar_tide=zeros(N_block,n_recs);
            CS.MEA.Corr_Applic_flag_20Hz_tab.corr_doppler_slope_correction=zeros(N_block,n_recs);
            CS.MEA.Corr_Applic_flag_20Hz_tab.mode_window_offset_applied=zeros(N_block,n_recs);
            CS.MEA.Corr_Applic_flag_20Hz_tab.SAR_retrack_applied=zeros(N_block,n_recs);
            CS.MEA.Corr_Applic_flag_20Hz_tab.SIN_retrack_applied=zeros(N_block,n_recs);
            CS.MEA.Corr_Applic_flag_20Hz_tab.LRM_retrack_applied=zeros(N_block,n_recs);
            CS.MEA.Corr_Applic_flag_20Hz_tab.LRM_ocean_bias_applied=zeros(N_block,n_recs);
            CS.MEA.Corr_Applic_flag_20Hz_tab.LRM_ice_bias_applied=zeros(N_block,n_recs);
            CS.MEA.Corr_Applic_flag_20Hz_tab.SAR_ocean_bias_applied=zeros(N_block,n_recs);
            CS.MEA.Corr_Applic_flag_20Hz_tab.SAR_ice_bias_applied=zeros(N_block,n_recs);
            CS.MEA.Corr_Applic_flag_20Hz_tab.SIN_ocean_bias_applied=zeros(N_block,n_recs);
            CS.MEA.Corr_Applic_flag_20Hz_tab.SIN_ice_bias_applied=zeros(N_block,n_recs);
            CS.MEA.Corr_Applic_flag_20Hz_tab.corr_slope=zeros(N_block,n_recs);
            CS.MEA.Corr_Applic_flag_20Hz_tab.corr_ssb=zeros(N_block,n_recs);
            CS.MEA.Corr_Applic_flag_20Hz_tab.master_failure=zeros(N_block,n_recs);
            
        else
            
            CS.MEA.delta_time_20Hz=zeros(N_block,n_recs);
            CS.MEA.LAT_20Hz=zeros(N_block,n_recs);
            CS.MEA.LON_20Hz=zeros(N_block,n_recs);
            CS.MEA.surf_height_20Hz=zeros(N_block,n_recs);
            CS.MEA.SLA_interp_20Hz=zeros(N_block,n_recs);
            CS.MEA.SLA_N_rec_20Hz=zeros(N_block,n_recs);
            CS.MEA.SLA_interp_qual_20Hz=zeros(N_block,n_recs);
            CS.MEA.backsc_sig_20Hz=zeros(N_block,n_recs);
            CS.MEA.peakiness_20Hz=zeros(N_block,n_recs);
            CS.MEA.freeboard_20Hz=zeros(N_block,n_recs);
            CS.MEA.beam_avg_N_20Hz=zeros(N_block,n_recs);
            CS.MEA.Qual_flag_20Hz=char(zeros(32,N_block,n_recs));
            CS.MEA.Qual_flag_20Hz_tab.block_degraded=zeros(N_block,n_recs);
            CS.MEA.Qual_flag_20Hz_tab.orbit_err=zeros(N_block,n_recs);
            CS.MEA.Qual_flag_20Hz_tab.orbit_discont=zeros(N_block,n_recs);
            CS.MEA.Qual_flag_20Hz_tab.height_err=zeros(N_block,n_recs);
            CS.MEA.Qual_flag_20Hz_tab.interp_SSH_err=zeros(N_block,n_recs);
            CS.MEA.Qual_flag_20Hz_tab.cal_wrng=zeros(N_block,n_recs);
            CS.MEA.Qual_flag_20Hz_tab.backsc_err=zeros(N_block,n_recs);
            CS.MEA.Qual_flag_20Hz_tab.peakiness_err=zeros(N_block,n_recs);
            CS.MEA.Qual_flag_20Hz_tab.freeboard_err=zeros(N_block,n_recs);
            CS.MEA.Qual_flag_20Hz_tab.SAR_discriminator_ocean=zeros(N_block,n_recs);
            CS.MEA.Qual_flag_20Hz_tab.SAR_discriminator_lead=zeros(N_block,n_recs);
            CS.MEA.Qual_flag_20Hz_tab.SAR_discriminator_ice=zeros(N_block,n_recs);
            CS.MEA.Qual_flag_20Hz_tab.SAR_discriminator_unknown=zeros(N_block,n_recs);
            CS.MEA.Qual_flag_20Hz_tab.SARin_Xtrack_angle_err=zeros(N_block,n_recs);
            CS.MEA.Qual_flag_20Hz_tab.SARin_ch1_err=zeros(N_block,n_recs);
            CS.MEA.Qual_flag_20Hz_tab.SARin_ch2_err=zeros(N_block,n_recs);
            CS.MEA.Qual_flag_20Hz_tab.SIRAL_id=zeros(N_block,n_recs);
            CS.MEA.Qual_flag_20Hz_tab.surf_mod_available=zeros(N_block,n_recs);
            CS.MEA.Qual_flag_20Hz_tab.misp_err=zeros(N_block,n_recs);
            CS.MEA.Qual_flag_20Hz_tab.d_time_err=zeros(N_block,n_recs);
            
        end
        
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Reading the product

switch CS.GEO.OPERATION_MODE
    
    case  {'SIR_LRM_L2','SIR_SAR_L2A','SIR_SAR_L2B','SIR_SIN_L2','SIR_SID_L2','SIR_GDR_2A','SIR_GDR_2B','SIR_SAR_L2','SIR_GDR_2_'}
        
        % Time and Orbit Group
        fseek(fid,MPH_size+HDR.SPH_SIZE,'bof');
        CS.GEO.TAI.days=fread(fid,n_recs,'int32',record_size-4);
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+4,'bof');
        CS.GEO.TAI.secs=fread(fid,n_recs,'uint32',record_size-4);
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+4+4,'bof');
        CS.GEO.TAI.microsecs=fread(fid,n_recs,'uint32',record_size-4);
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+timestamp,'bof');
        dummy_1=dec2bin(fread(fid,n_recs,'uint32',record_size-4),32).';
        fseek(fid,MPH_size+HDR.SPH_SIZE+timestamp+4,'bof');
        dummy_2=dec2bin(fread(fid,n_recs,'uint32',record_size-4),32).';
        CS.GEO.MEAS_MODE=[dummy_1 ; dummy_2];
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+timestamp+8,'bof');
        CS.GEO.LAT=fread(fid,n_recs,'int32',record_size-4).*1e-7; %%decimal degree
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+timestamp+8+4,'bof');
        CS.GEO.LON=fread(fid,n_recs,'int32',record_size-4).*1e-7; %% decimal degree
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+timestamp+8+4+4,'bof');
        CS.GEO.H=fread(fid,n_recs,'int32',record_size-4).*1e-3; % meter
        
        switch  CS.GEO.Baseline_ID
            
            case  'C'
                
                fseek(fid,MPH_size+HDR.SPH_SIZE+timestamp+8+4+4+4,'bof');
                CS.GEO.Spacecraft_Roll_Angle=fread(fid,n_recs,'int32',record_size-4).*1e-7; % degree
                fseek(fid,MPH_size+HDR.SPH_SIZE+timestamp+8+4+4+4+4,'bof');
                CS.GEO.Spacecraft_Pitch_Angle=fread(fid,n_recs,'int32',record_size-4).*1e-7; % degree
                fseek(fid,MPH_size+HDR.SPH_SIZE+timestamp+8+4+4+4+4+4,'bof');
                CS.GEO.Spacecraft_Yaw_Angle=fread(fid,n_recs,'int32',record_size-4).*1e-7; % degree
                fseek(fid,MPH_size+HDR.SPH_SIZE+timestamp+8+4+4+4+4+4+4+2,'bof');
                CS.GEO.valid_meas=fread(fid,n_recs,'uint16',record_size-2); % number of valid measurements (0-20)
                
            otherwise
                
                fseek(fid,MPH_size+HDR.SPH_SIZE+timestamp+8+4+4+4,'bof');
                CS.GEO.misp_angle=fread(fid,n_recs,'int16',record_size-2).*1e-3; % degree
                fseek(fid,MPH_size+HDR.SPH_SIZE+timestamp+8+4+4+4+2,'bof');
                CS.GEO.valid_meas=fread(fid,n_recs,'int16',record_size-2); % number of valid measurements (0-20)
                
        end
        
        
        CS.GEO.MEAS_MODE_Siral_id=bin2decimal(CS.GEO.MEAS_MODE(61,:).'); % 0=nominal 1=redundant
        
        %External Correction Group
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+time_group,'bof');
        CS.COR.dry_tropo=fread(fid,n_recs,'int16',record_size-2)*1e-3; % meter
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+2.*1,'bof');
        CS.COR.wet_tropo=fread(fid,n_recs,'int16',record_size-2)*1e-3; % meter
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+2.*2,'bof');
        CS.COR.inv_baro=fread(fid,n_recs,'int16',record_size-2)*1e-3; % meter
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+2.*3,'bof');
        CS.COR.dac=fread(fid,n_recs,'int16',record_size-2)*1e-3; % meter
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+2.*4,'bof');
        CS.COR.iono=fread(fid,n_recs,'int16',record_size-2)*1e-3; % meter
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+2.*5,'bof');
        CS.COR.ssb=fread(fid,n_recs,'int16',record_size-2)*1e-3; % meter
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+2.*6,'bof');
        CS.COR.ocean_tide=fread(fid,n_recs,'int16',record_size-2)*1e-3; % meter
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+2.*7,'bof');
        CS.COR.lpe_ocean=fread(fid,n_recs,'int16',record_size-2)*1e-3; % meter
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+2.*8,'bof');
        CS.COR.ocean_loading=fread(fid,n_recs,'int16',record_size-2)*1e-3; % meter
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+2.*9,'bof');
        CS.COR.solid_earth=fread(fid,n_recs,'int16',record_size-2)*1e-3; % meter
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+2.*10,'bof');
        CS.COR.geoc_polar=fread(fid,n_recs,'int16',record_size-2)*1e-3; % meter
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+2.*12,'bof');
        dummy_1=dec2bin(fread(fid,n_recs,'uint32',record_size-4),32).';
        fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+2.*12+4,'bof');
        dummy_2=dec2bin(fread(fid,n_recs,'uint32',record_size-4),32).';
        CS.COR.SURF_TYPE=[dummy_1 ; dummy_2];
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+2.*12+8,'bof');
        CS.COR.mss_geoid=fread(fid,n_recs,'int32',record_size-4).*1e-3; % meter
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+2.*12+8+4,'bof');
        CS.COR.odle=fread(fid,n_recs,'int32',record_size-4).*1e-3; % meter
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+2.*12+8+4+4,'bof');
        CS.COR.ice_concentration=fread(fid,n_recs,'int16',record_size-2).*1e-2; %(percentage)
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+2.*12+8+4+4+2,'bof');
        CS.COR.snow_depth=fread(fid,n_recs,'int16',record_size-2).*1e-3; % meter
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+2.*12+8+4+4+2+2,'bof');
        CS.COR.snow_density=fread(fid,n_recs,'int16',record_size-2); % kg/m^3
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+2.*12+8+4+4+2+2+2+2,'bof');
        CS.COR.corr_status=dec2bin(fread(fid,n_recs,'uint32',record_size-4),32).';
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+2.*12+8+4+4+2+2+2+2+4,'bof');
        CS.COR.SWH=fread(fid,n_recs,'int16',record_size-2).*1e-3; % meter
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+2.*12+8+4+4+2+2+2+2+4+2,'bof');
        CS.COR.wind_speed=fread(fid,n_recs,'int16',record_size-2).*1e-3; % m/s  (meter/second)
        
        CS.COR.corr_status_tab.dry_tropo=bin2decimal(CS.COR.corr_status(1,:).'); % 0=OK 1=invalid
        CS.COR.corr_status_tab.wet_tropo=bin2decimal(CS.COR.corr_status(2,:).'); % 0=OK 1=invalid
        CS.COR.corr_status_tab.inv_baro=bin2decimal(CS.COR.corr_status(3,:).'); % 0=OK 1=invalid
        CS.COR.corr_status_tab.dac=bin2decimal(CS.COR.corr_status(4,:).'); % 0=OK 1=invalid
        CS.COR.corr_status_tab.iono=bin2decimal(CS.COR.corr_status(5,:).'); % 0=OK 1=invalid
        CS.COR.corr_status_tab.ssb=bin2decimal(CS.COR.corr_status(6,:).'); % 0=OK 1=invalid
        CS.COR.corr_status_tab.ocean_tide=bin2decimal(CS.COR.corr_status(7,:).'); % 0=OK 1=invalid
        CS.COR.corr_status_tab.lpe_ocean=bin2decimal(CS.COR.corr_status(8,:).'); % 0=OK 1=invalid
        CS.COR.corr_status_tab.ocean_loading=bin2decimal(CS.COR.corr_status(9,:).'); % 0=OK 1=invalid
        CS.COR.corr_status_tab.solid_earth=bin2decimal(CS.COR.corr_status(10,:).'); % 0=OK 1=invalid
        CS.COR.corr_status_tab.geoc_polar=bin2decimal(CS.COR.corr_status(11,:).'); % 0=OK 1=invalid
        CS.COR.corr_status_tab.surf_type=bin2decimal(CS.COR.corr_status(12,:).'); % 0=OK 1=invalid
        CS.COR.corr_status_tab.mss_geoid=bin2decimal(CS.COR.corr_status(13,:).'); % 0=OK 1=invalid
        CS.COR.corr_status_tab.odle_model=bin2decimal(CS.COR.corr_status(14,:).'); % 0=OK 1=invalid
        CS.COR.corr_status_tab.ice_conc=bin2decimal(CS.COR.corr_status(15,:).'); % 0=OK 1=invalid
        CS.COR.corr_status_tab.snow_depth=bin2decimal(CS.COR.corr_status(16,:).'); % 0=OK 1=invalid
        CS.COR.corr_status_tab.snow_dens=bin2decimal(CS.COR.corr_status(17,:).'); % 0=OK 1=invalid
        CS.COR.corr_status_tab.swh=bin2decimal(CS.COR.corr_status(18,:).'); % 0=OK 1=invalid
        CS.COR.corr_status_tab.wind_spd=bin2decimal(CS.COR.corr_status(19,:).'); % 0=OK 1=invalid
        
        CS.COR.total_ocean=CS.COR.dry_tropo+CS.COR.wet_tropo+CS.COR.dac+CS.COR.iono+...
            CS.COR.ssb+CS.COR.ocean_tide+CS.COR.lpe_ocean+CS.COR.ocean_loading+CS.COR.solid_earth+CS.COR.geoc_polar;
        
        for i=1:N_block
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+ext_corr_group+(i-1).*meas_group,'bof');
            CS.MEA.delta_time_20Hz(i,:)=fread(fid,n_recs,'int32',record_size-4).*1e-6;
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+ext_corr_group+4+(i-1).*meas_group,'bof');
            CS.MEA.LAT_20Hz(i,:)=fread(fid,n_recs,'int32',record_size-4).*1e-7; % decimal degree
            
            fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+ext_corr_group+4+4+(i-1).*meas_group,'bof');
            CS.MEA.LON_20Hz(i,:)=fread(fid,n_recs,'int32',record_size-4).*1e-7; % decimal degree
            
            
            switch  CS.GEO.Baseline_ID
                
                case  'C'
                    
                    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+ext_corr_group+4+4+4+(i-1).*meas_group,'bof');
                    CS.MEA.surf_height_r1_20Hz(i,:)=fread(fid,n_recs,'int32',record_size-4).*1e-3; % meter
                    
                    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+ext_corr_group+4+4+4+4+(i-1).*meas_group,'bof');
                    CS.MEA.surf_height_r2_20Hz(i,:)=fread(fid,n_recs,'int32',record_size-4).*1e-3; % meter
                    
                    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+ext_corr_group+4+4+4+4+4+(i-1).*meas_group,'bof');
                    CS.MEA.surf_height_r3_20Hz(i,:)=fread(fid,n_recs,'int32',record_size-4).*1e-3; % meter
                    
                    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+ext_corr_group+4+4+4+4+4+4+(i-1).*meas_group,'bof');
                    CS.MEA.backsc_sig_r1_20Hz(i,:)=fread(fid,n_recs,'int16',record_size-2).*1e-2; % dB
                    
                    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+ext_corr_group+4+4+4+4+4+4+2+(i-1).*meas_group,'bof');
                    CS.MEA.backsc_sig_r2_20Hz(i,:)=fread(fid,n_recs,'int16',record_size-2).*1e-2; % dB
                    
                    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+ext_corr_group+4+4+4+4+4+4+2+2+(i-1).*meas_group,'bof');
                    CS.MEA.backsc_sig_r3_20Hz(i,:)=fread(fid,n_recs,'int16',record_size-2).*1e-2; % dB
                    
                    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+ext_corr_group+4+4+4+4+4+4+2+2+2+(i-1).*meas_group,'bof');
                    CS.MEA.freeboard_20Hz(i,:)=fread(fid,n_recs,'int16',record_size-2).*1e-3; % meter (set to -9.999 as flag value where not applicable)
                    
                    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+ext_corr_group+4+4+4+4+4+4+2+2+2+2+(i-1).*meas_group,'bof');
                    CS.MEA.SLA_interp_20Hz(i,:)=fread(fid,n_recs,'int16',record_size-2).*1e-3; % meter
                    
                    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+ext_corr_group+4+4+4+4+4+4+2+2+2+2+2+(i-1).*meas_group,'bof');
                    CS.MEA.SLA_N_rec_20Hz(i,:)=fread(fid,n_recs,'int16',record_size-2); % count
                    
                    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+ext_corr_group+4*6+2*6+(i-1).*meas_group,'bof');
                    CS.MEA.SLA_interp_qual_20Hz(i,:)=fread(fid,n_recs,'int16',record_size-2).*1e-3; % meter
                    
                    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+ext_corr_group+4*6+2*7+(i-1).*meas_group,'bof');
                    CS.MEA.peakiness_20Hz(i,:)=fread(fid,n_recs,'uint16',record_size-2).*1e-2; %
                    
                    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+ext_corr_group+4*6+2*8+(i-1).*meas_group,'bof');
                    CS.MEA.beam_avg_N_20Hz(i,:)=fread(fid,n_recs,'uint16',record_size-2); % count
                    
                    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+ext_corr_group+4*6+2*10+(i-1).*meas_group,'bof');
                    CS.MEA.Qual_flag_20Hz(:,i,:)=dec2bin(fread(fid,n_recs,'uint32',record_size-4).',32).'; % count
                    
                    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+ext_corr_group+4*6+2*10+4+(i-1).*meas_group,'bof');
                    CS.MEA.Corr_Applic_flag_20Hz(:,i,:)=dec2bin(fread(fid,n_recs,'uint32',record_size-4).',32).'; % count
                    
                    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+ext_corr_group+4*6+2*10+4+4+(i-1).*meas_group,'bof');
                    CS.MEA.Qual_r1_Value_20Hz(i,:)=fread(fid,n_recs,'uint32',record_size-4); % count
                    
                    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+ext_corr_group+4*6+2*10+4+4+4+(i-1).*meas_group,'bof');
                    CS.MEA.Qual_r2_Value_20Hz(i,:)=fread(fid,n_recs,'uint32',record_size-4); % count
                    
                    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+ext_corr_group+4*6+2*10+4+4+4+4+(i-1).*meas_group,'bof');
                    CS.MEA.Qual_r3_Value_20Hz(i,:)=fread(fid,n_recs,'uint32',record_size-4); % count
                    
                    CS.GEO.MEAS_MODE_tab(i,:)=bin2decimal(CS.GEO.MEAS_MODE(I_1(i):I_2(i),:).'); % 001=1=LRM 010=2=SAR 011=3=SARin 100=4=SID
                    CS.COR.SURF_TYPE_tab(i,:)=bin2decimal(CS.COR.SURF_TYPE(I_1(i):I_2(i),:).'); % 000=0=open ocean 001=1=closed sea 010=2=continental_ice 011=3=land
                    
                    
                otherwise
                    
                    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+ext_corr_group+4+4+4+(i-1).*meas_group,'bof');
                    CS.MEA.surf_height_20Hz(i,:)=fread(fid,n_recs,'int32',record_size-4).*1e-3; % meter
                    
                    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+ext_corr_group+4+4+4+4+(i-1).*meas_group,'bof');
                    CS.MEA.SLA_interp_20Hz(i,:)=fread(fid,n_recs,'int16',record_size-2).*1e-3; % meter
                    
                    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+ext_corr_group+4+4+4+4+2+(i-1).*meas_group,'bof');
                    CS.MEA.SLA_N_rec_20Hz(i,:)=fread(fid,n_recs,'int16',record_size-2); % count
                    
                    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+ext_corr_group+4+4+4+4+2+2+(i-1).*meas_group,'bof');
                    CS.MEA.SLA_interp_qual_20Hz(i,:)=fread(fid,n_recs,'int16',record_size-2).*1e-3; % meter
                    
                    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+ext_corr_group+4+4+4+4+2+2+2+(i-1).*meas_group,'bof');
                    CS.MEA.backsc_sig_20Hz(i,:)=fread(fid,n_recs,'int16',record_size-2).*1e-2; % dB
                    
                    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+ext_corr_group+4+4+4+4+2+2+2+2+(i-1).*meas_group,'bof');
                    CS.MEA.peakiness_20Hz(i,:)=fread(fid,n_recs,'uint16',record_size-2).*1e-2; %
                    
                    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+ext_corr_group+4+4+4+4+2+2+2+2+2+(i-1).*meas_group,'bof');
                    CS.MEA.freeboard_20Hz(i,:)=fread(fid,n_recs,'int16',record_size-2).*1e-3; % meter (set to -9.999 as flag value where not applicable)
                    
                    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+ext_corr_group+4+4+4+4+2+2+2+2+2+2+(i-1).*meas_group,'bof');
                    CS.MEA.beam_avg_N_20Hz(i,:)=fread(fid,n_recs,'uint16',record_size-2); % count
                    
                    fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+ext_corr_group+4+4+4+4+2+2+2+2+2+2+2+2+(i-1).*meas_group,'bof');
                    CS.MEA.Qual_flag_20Hz(:,i,:)=dec2bin(fread(fid,n_recs,'uint32',record_size-4).',32).'; % count
                    
                    CS.GEO.MEAS_MODE_tab(i,:)=bin2decimal(CS.GEO.MEAS_MODE(I_1(i):I_2(i),:).'); % 001=1=LRM 010=2=SAR 011=3=SARin 100=4=SID
                    CS.COR.SURF_TYPE_tab(i,:)=bin2decimal(CS.COR.SURF_TYPE(I_1(i):I_2(i),:).'); % 000=0=open ocean 001=1=closed sea 010=2=continental_ice 011=3=land
                    
                    
            end
            
            CS.MEA.Qual_flag_20Hz_tab.block_degraded(i,:)=bin2decimal(squeeze(CS.MEA.Qual_flag_20Hz(1,i,:))).'; % 0=OK 1=block should not be processed
            CS.MEA.Qual_flag_20Hz_tab.orbit_err(i,:)=bin2decimal(squeeze(CS.MEA.Qual_flag_20Hz(2,i,:))).'; % 0=OK 1=error detected
            CS.MEA.Qual_flag_20Hz_tab.orbit_discont(i,:)=bin2decimal(squeeze(CS.MEA.Qual_flag_20Hz(3,i,:))).'; % 0=OK 1=orbit discontinuity occureg (e.g. gap)
            
            
            switch  CS.GEO.Baseline_ID
                
                case  'C'
                    
                    CS.MEA.Qual_flag_20Hz_tab.height_err_r1(i,:)=bin2decimal(squeeze(CS.MEA.Qual_flag_20Hz(4,i,:))).'; % 0=no 1=error in height derivation
                    CS.MEA.Qual_flag_20Hz_tab.height_err_r2(i,:)=bin2decimal(squeeze(CS.MEA.Qual_flag_20Hz(5,i,:))).'; % 0=no 1=error in height derivation
                    CS.MEA.Qual_flag_20Hz_tab.height_err_r2(i,:)=bin2decimal(squeeze(CS.MEA.Qual_flag_20Hz(6,i,:))).'; % 0=no 1=error in height derivation
                    CS.MEA.Qual_flag_20Hz_tab.backsc_err_r1(i,:)=bin2decimal(squeeze(CS.MEA.Qual_flag_20Hz(7,i,:))).'; % 0=no 1=error
                    CS.MEA.Qual_flag_20Hz_tab.backsc_err_r2(i,:)=bin2decimal(squeeze(CS.MEA.Qual_flag_20Hz(8,i,:))).'; % 0=no 1=error
                    CS.MEA.Qual_flag_20Hz_tab.backsc_err_r3(i,:)=bin2decimal(squeeze(CS.MEA.Qual_flag_20Hz(9,i,:))).'; % 0=no 1=error
                    CS.MEA.Qual_flag_20Hz_tab.interp_SSH_err(i,:)=bin2decimal(squeeze(CS.MEA.Qual_flag_20Hz(10,i,:))).'; % 0=no 1=error
                    CS.MEA.Qual_flag_20Hz_tab.peakiness_err(i,:)=bin2decimal(squeeze(CS.MEA.Qual_flag_20Hz(11,i,:))).'; % 0=no 1=error detected
                    CS.MEA.Qual_flag_20Hz_tab.freeboard_err(i,:)=bin2decimal(squeeze(CS.MEA.Qual_flag_20Hz(12,i,:))).'; % 0=OK 1=invalid
                    CS.MEA.Qual_flag_20Hz_tab.SAR_discriminator_ocean(i,:)=bin2decimal(squeeze(CS.MEA.Qual_flag_20Hz(13,i,:))).'; % 0=no 1=yes
                    CS.MEA.Qual_flag_20Hz_tab.SAR_discriminator_lead(i,:)=bin2decimal(squeeze(CS.MEA.Qual_flag_20Hz(14,i,:))).'; % 0=no 1=yes
                    CS.MEA.Qual_flag_20Hz_tab.SAR_discriminator_ice(i,:)=bin2decimal(squeeze(CS.MEA.Qual_flag_20Hz(15,i,:))).'; % 0=no 1=yes
                    CS.MEA.Qual_flag_20Hz_tab.SAR_discriminator_unknown(i,:)=bin2decimal(squeeze(CS.MEA.Qual_flag_20Hz(16,i,:))).'; % 0=no 1=yes
                    CS.MEA.Qual_flag_20Hz_tab.SARin_Xtrack_angle_err(i,:)=bin2decimal(squeeze(CS.MEA.Qual_flag_20Hz(17,i,:))).'; % 0=no 1=ambiguous angle
                    CS.MEA.Qual_flag_20Hz_tab.SARin_ch1_err(i,:)=bin2decimal(squeeze(CS.MEA.Qual_flag_20Hz(18,i,:))).'; % 0=OK 1=degraded or missing
                    CS.MEA.Qual_flag_20Hz_tab.SARin_ch2_err(i,:)=bin2decimal(squeeze(CS.MEA.Qual_flag_20Hz(19,i,:))).'; % 0=OK 1=degraded or missing
                    CS.MEA.Qual_flag_20Hz_tab.SIRAL_id(i,:)=bin2decimal(squeeze(CS.MEA.Qual_flag_20Hz(20,i,:))).'; % 0=nominal 1=redundant
                    CS.MEA.Qual_flag_20Hz_tab.surf_mod_available(i,:)=bin2decimal(squeeze(CS.MEA.Qual_flag_20Hz(21,i,:))).'; % 0=OK 1=no DEM/SLOPE model for location
                    CS.MEA.Qual_flag_20Hz_tab.misp_err(i,:)=bin2decimal(squeeze(CS.MEA.Qual_flag_20Hz(22,i,:))).'; % 0=OK 1=error during calculation
                    CS.MEA.Qual_flag_20Hz_tab.delta_time_err(i,:)=bin2decimal(squeeze(CS.MEA.Qual_flag_20Hz(23,i,:))).'; % 0=OK 1=error during calculation
                    CS.MEA.Qual_flag_20Hz_tab.LRM_Slope_Model_valid(i,:)=bin2decimal(squeeze(CS.MEA.Qual_flag_20Hz(24,i,:))).'; % 0=OK 1=error during calculation
                    CS.MEA.Qual_flag_20Hz_tab.SIN_Baseline_bad(i,:)=bin2decimal(squeeze(CS.MEA.Qual_flag_20Hz(25,i,:))).'; % 0=OK 1=error during calculation
                    CS.MEA.Qual_flag_20Hz_tab.SIN_Out_of_Range(i,:)=bin2decimal(squeeze(CS.MEA.Qual_flag_20Hz(26,i,:))).'; % 0=OK 1=error during calculation
                    CS.MEA.Qual_flag_20Hz_tab.SIN_Velocity_bad(i,:)=bin2decimal(squeeze(CS.MEA.Qual_flag_20Hz(27,i,:))).'; % 0=OK 1=error during calculation
                    CS.MEA.Qual_flag_20Hz_tab.cal_wrng(i,:)=bin2decimal(squeeze(CS.MEA.Qual_flag_20Hz(28,i,:))).'; % 0=no 1=non-nominal calibration correction
                    
                    
                    CS.MEA.Corr_Applic_flag_20Hz_tab.corr_int_cal(i,:)=bin2decimal(squeeze(CS.MEA.Corr_Applic_flag_20Hz(1,i,:))).';
                    CS.MEA.Corr_Applic_flag_20Hz_tab.corr_rad_doppler(i,:)=bin2decimal(squeeze(CS.MEA.Corr_Applic_flag_20Hz(2,i,:))).';
                    CS.MEA.Corr_Applic_flag_20Hz_tab.corr_dry_tropo(i,:)=bin2decimal(squeeze(CS.MEA.Corr_Applic_flag_20Hz(3,i,:))).';
                    CS.MEA.Corr_Applic_flag_20Hz_tab.corr_wet_tropo(i,:)=bin2decimal(squeeze(CS.MEA.Corr_Applic_flag_20Hz(4,i,:))).';
                    CS.MEA.Corr_Applic_flag_20Hz_tab.corr_inv_bar(i,:)=bin2decimal(squeeze(CS.MEA.Corr_Applic_flag_20Hz(5,i,:))).';
                    CS.MEA.Corr_Applic_flag_20Hz_tab.corr_hf_atmo(i,:)=bin2decimal(squeeze(CS.MEA.Corr_Applic_flag_20Hz(6,i,:))).';
                    CS.MEA.Corr_Applic_flag_20Hz_tab.corr_iono_gim(i,:)=bin2decimal(squeeze(CS.MEA.Corr_Applic_flag_20Hz(7,i,:))).';
                    CS.MEA.Corr_Applic_flag_20Hz_tab.corr_iono_model(i,:)=bin2decimal(squeeze(CS.MEA.Corr_Applic_flag_20Hz(8,i,:))).';
                    CS.MEA.Corr_Applic_flag_20Hz_tab.corr_ocean_tide(i,:)=bin2decimal(squeeze(CS.MEA.Corr_Applic_flag_20Hz(9,i,:))).';
                    CS.MEA.Corr_Applic_flag_20Hz_tab.corr_lpe_tide(i,:)=bin2decimal(squeeze(CS.MEA.Corr_Applic_flag_20Hz(10,i,:))).';
                    CS.MEA.Corr_Applic_flag_20Hz_tab.corr_ocean_loading(i,:)=bin2decimal(squeeze(CS.MEA.Corr_Applic_flag_20Hz(11,i,:))).';
                    CS.MEA.Corr_Applic_flag_20Hz_tab.corr_se_tide(i,:)=bin2decimal(squeeze(CS.MEA.Corr_Applic_flag_20Hz(12,i,:))).';
                    CS.MEA.Corr_Applic_flag_20Hz_tab.corr_geo_polar_tide(i,:)=bin2decimal(squeeze(CS.MEA.Corr_Applic_flag_20Hz(13,i,:))).';
                    CS.MEA.Corr_Applic_flag_20Hz_tab.corr_doppler_slope_correction(i,:)=bin2decimal(squeeze(CS.MEA.Corr_Applic_flag_20Hz(14,i,:))).';
                    CS.MEA.Corr_Applic_flag_20Hz_tab.mode_window_offset_applied(i,:)=bin2decimal(squeeze(CS.MEA.Corr_Applic_flag_20Hz(15,i,:))).';
                    CS.MEA.Corr_Applic_flag_20Hz_tab.SAR_retrack_applied(i,:)=bin2decimal(squeeze(CS.MEA.Corr_Applic_flag_20Hz(16,i,:))).';
                    CS.MEA.Corr_Applic_flag_20Hz_tab.SIN_retrack_applied(i,:)=bin2decimal(squeeze(CS.MEA.Corr_Applic_flag_20Hz(17,i,:))).';
                    CS.MEA.Corr_Applic_flag_20Hz_tab.LRM_retrack_applied(i,:)=bin2decimal(squeeze(CS.MEA.Corr_Applic_flag_20Hz(18,i,:))).';
                    CS.MEA.Corr_Applic_flag_20Hz_tab.LRM_ocean_bias_applied(i,:)=bin2decimal(squeeze(CS.MEA.Corr_Applic_flag_20Hz(19,i,:))).';
                    CS.MEA.Corr_Applic_flag_20Hz_tab.LRM_ice_bias_applied(i,:)=bin2decimal(squeeze(CS.MEA.Corr_Applic_flag_20Hz(20,i,:))).';
                    CS.MEA.Corr_Applic_flag_20Hz_tab.SAR_ocean_bias_applied(i,:)=bin2decimal(squeeze(CS.MEA.Corr_Applic_flag_20Hz(21,i,:))).';
                    CS.MEA.Corr_Applic_flag_20Hz_tab.SAR_ice_bias_applied(i,:)=bin2decimal(squeeze(CS.MEA.Corr_Applic_flag_20Hz(22,i,:))).';
                    CS.MEA.Corr_Applic_flag_20Hz_tab.SIN_ocean_bias_applied(i,:)=bin2decimal(squeeze(CS.MEA.Corr_Applic_flag_20Hz(23,i,:))).';
                    CS.MEA.Corr_Applic_flag_20Hz_tab.SIN_ice_bias_applied(i,:)=bin2decimal(squeeze(CS.MEA.Corr_Applic_flag_20Hz(24,i,:))).';
                    CS.MEA.Corr_Applic_flag_20Hz_tab.corr_slope(i,:)=bin2decimal(squeeze(CS.MEA.Corr_Applic_flag_20Hz(25,i,:))).';
                    CS.MEA.Corr_Applic_flag_20Hz_tab.corr_ssb(i,:)=bin2decimal(squeeze(CS.MEA.Corr_Applic_flag_20Hz(26,i,:))).';
                    CS.MEA.Corr_Applic_flag_20Hz_tab.master_failure(i,:)=bin2decimal(squeeze(CS.MEA.Corr_Applic_flag_20Hz(32,i,:))).';
                    
                otherwise
                    
                    CS.MEA.Qual_flag_20Hz_tab.height_err(i,:)=bin2decimal(squeeze(CS.MEA.Qual_flag_20Hz(4,i,:))).'; % 0=no 1=error in height derivation
                    CS.MEA.Qual_flag_20Hz_tab.interp_SSH_err(i,:)=bin2decimal(squeeze(CS.MEA.Qual_flag_20Hz(5,i,:))).'; % 0=no 1=error
                    CS.MEA.Qual_flag_20Hz_tab.cal_wrng(i,:)=bin2decimal(squeeze(CS.MEA.Qual_flag_20Hz(6,i,:))).'; % 0=no 1=non-nominal calibration correction
                    CS.MEA.Qual_flag_20Hz_tab.backsc_err(i,:)=bin2decimal(squeeze(CS.MEA.Qual_flag_20Hz(7,i,:))).'; % 0=no 1=error
                    CS.MEA.Qual_flag_20Hz_tab.peakiness_err(i,:)=bin2decimal(squeeze(CS.MEA.Qual_flag_20Hz(8,i,:))).'; % 0=no 1=error detected
                    CS.MEA.Qual_flag_20Hz_tab.freeboard_err(i,:)=bin2decimal(squeeze(CS.MEA.Qual_flag_20Hz(9,i,:))).'; % 0=OK 1=invalid
                    CS.MEA.Qual_flag_20Hz_tab.SAR_discriminator_ocean(i,:)=bin2decimal(squeeze(CS.MEA.Qual_flag_20Hz(10,i,:))).'; % 0=no 1=yes
                    CS.MEA.Qual_flag_20Hz_tab.SAR_discriminator_lead(i,:)=bin2decimal(squeeze(CS.MEA.Qual_flag_20Hz(11,i,:))).'; % 0=no 1=yes
                    CS.MEA.Qual_flag_20Hz_tab.SAR_discriminator_ice(i,:)=bin2decimal(squeeze(CS.MEA.Qual_flag_20Hz(12,i,:))).'; % 0=no 1=yes
                    CS.MEA.Qual_flag_20Hz_tab.SAR_discriminator_unknown(i,:)=bin2decimal(squeeze(CS.MEA.Qual_flag_20Hz(13,i,:))).'; % 0=no 1=yes
                    CS.MEA.Qual_flag_20Hz_tab.SARin_Xtrack_angle_err(i,:)=bin2decimal(squeeze(CS.MEA.Qual_flag_20Hz(14,i,:))).'; % 0=no 1=ambiguous angle
                    CS.MEA.Qual_flag_20Hz_tab.SARin_ch1_err(i,:)=bin2decimal(squeeze(CS.MEA.Qual_flag_20Hz(15,i,:))).'; % 0=OK 1=degraded or missing
                    CS.MEA.Qual_flag_20Hz_tab.SARin_ch2_err(i,:)=bin2decimal(squeeze(CS.MEA.Qual_flag_20Hz(16,i,:))).'; % 0=OK 1=degraded or missing
                    CS.MEA.Qual_flag_20Hz_tab.SIRAL_id(i,:)=bin2decimal(squeeze(CS.MEA.Qual_flag_20Hz(17,i,:))).'; % 0=nominal 1=redundant
                    CS.MEA.Qual_flag_20Hz_tab.surf_mod_available(i,:)=bin2decimal(squeeze(CS.MEA.Qual_flag_20Hz(18,i,:))).'; % 0=OK 1=no DEM/SLOPE model for location
                    CS.MEA.Qual_flag_20Hz_tab.misp_err(i,:)=bin2decimal(squeeze(CS.MEA.Qual_flag_20Hz(19,i,:))).'; % 0=OK 1=error during calculation
                    CS.MEA.Qual_flag_20Hz_tab.d_time_err(i,:)=bin2decimal(squeeze(CS.MEA.Qual_flag_20Hz(20,i,:))).'; % 0=OK 1=error during calculation
                    
                    
            end
            
        end
        
        
        CS.GEO.MEAS_MODE=CS.GEO.MEAS_MODE_tab;
        CS.GEO=rmfield(CS.GEO,'MEAS_MODE_tab');
        
        CS.COR.SURF_TYPE=CS.COR.SURF_TYPE_tab;
        CS.COR=rmfield(CS.COR,'SURF_TYPE_tab');
        
        CS.MEA.Qual_flag_20Hz=CS.MEA.Qual_flag_20Hz_tab;
        CS.MEA=rmfield(CS.MEA,'Qual_flag_20Hz_tab');
        
        if   strcmp(CS.GEO.Baseline_ID,'C')
            
            CS.MEA.Corr_Applic_flag_20Hz=CS.MEA.Corr_Applic_flag_20Hz_tab;
            CS.MEA=rmfield(CS.MEA,'Corr_Applic_flag_20Hz_tab');
            
        end
        
        CS.COR.corr_status=CS.COR.corr_status_tab;
        CS.COR=rmfield(CS.COR,'corr_status_tab');
        
    case {'SIR_FDM_L2'}
        
        %%%%%%%%% Time and Orbit Group Reading %%%%%%%%%%%%%%%%%%%%%%%%
        
        fseek(fid,MPH_size+HDR.SPH_SIZE,'bof');
        CS.GEO.TAI.days=fread(fid,n_recs,'int32',record_size-4);
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+4,'bof');
        CS.GEO.TAI.secs=fread(fid,n_recs,'uint32',record_size-4);
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+4+4,'bof');
        CS.GEO.TAI.microsecs=fread(fid,n_recs,'uint32',record_size-4);
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+timestamp,'bof');
        CS.GEO.Time_Diff=reshape(fread(fid,20.*n_recs,'20*int32',record_size-4.*20).*1e-6,20,[]);
        
        fseek(fid, MPH_size+HDR.SPH_SIZE+timestamp+20.*4,'bof');
        CS.GEO.LAT_1Hz=fread(fid,n_recs,'int32',record_size-4).*1e-7;
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+timestamp+20.*4+4,'bof');
        CS.GEO.LAT_20Hz=reshape(fread(fid,20.*n_recs,'20*int32',record_size-4.*20).*1e-7,20,[]);
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+ timestamp+20.*4+4+20.*4,'bof');
        CS.GEO.LON_1Hz=fread(fid,n_recs,'int32',record_size-4).*1e-7;
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+timestamp+20.*4+4+20.*4+4,'bof');
        CS.GEO.LON_20Hz=reshape(fread(fid,20.*n_recs,'20*int32',record_size-4.*20).*1e-7,20,[]);
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+timestamp+20.*4+4+20.*4+4+20*4,'bof');
        CS.GEO.CNT=fread(fid,n_recs,'uint32',record_size-4);
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+timestamp+20.*4+4+20.*4+4+20.*4+4,'bof');
        CS.GEO.MCD_FLAG=dec2bin(fread(fid,n_recs,'uint32',record_size-4),32).';
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+timestamp+20.*4+4+20.*4+4+20*4+4+4,'bof');
        CS.GEO.Height_1Hz=fread(fid,n_recs,'int32',record_size-4)./1000;
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+timestamp+20.*4+4+20.*4+4+20*4+4+4+4,'bof');
        CS.GEO.Height_20Hz=reshape(fread(fid,20.*n_recs,'20*int32',record_size-4.*20).*1e-3,20,[]);
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+timestamp+20.*4+4+20.*4+4+20*4+4+4+4+20*4,'bof');
        CS.GEO.Height_Rate=fread(fid,n_recs,'int16',record_size-2)*1e-3;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%% Range Group Reading %%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+time_group,'bof');
        CS.RNG.Brown_Range_1Hz=fread(fid,n_recs,'uint32',record_size-4).*1e-3;
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4,'bof');
        CS.RNG.Brown_Range_20Hz=reshape(fread(fid,20.*n_recs,'20*uint32',record_size-4.*20).*1e-3,20,[]);
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4+80,'bof');
        CS.RNG.Std_Brown_Range_20Hz=fread(fid,n_recs,'uint16',record_size-2).*1e-3;
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4+80+2,'bof');
        CS.RNG.Valid_Points_Brown_Range_20Hz=fread(fid,n_recs,'uint16',record_size-2);
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4+80+2+2,'bof');
        CS.RNG.Ocean_Flag_Brown_Range=dec2bin(fread(fid,n_recs,'uint32',record_size-4),32).';
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4+80+2+2+4,'bof');
        CS.RNG.OCOG_Range_1Hz=fread(fid,n_recs,'uint32',record_size-4).*1e-3;
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4+80+2+2+4+4,'bof');
        CS.RNG.OCOG_Range_20Hz=reshape(fread(fid,20.*n_recs,'20*uint32',record_size-4.*20).*1e-3,20,[]);
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4+80+2+2+4+4+80,'bof');
        CS.RNG.Std_OCOG_Range_20Hz=fread(fid,n_recs,'uint16',record_size-2).*1e-3;
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4+80+2+2+4+4+80+2,'bof');
        CS.RNG.Valid_Points_OCOG_Range_20Hz=fread(fid,n_recs,'uint16',record_size-2);
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+4+80+2+2+4+4+80+2+2,'bof');
        CS.RNG.Ocean_Flag_OCOG_Range=dec2bin(fread(fid,n_recs,'uint32',record_size-4),32).';
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%% Corrections Group Reading %%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+range_group,'bof');
        CS.COR.Doppler_Corr=fread(fid,n_recs,'int16',record_size-2).*1e-3;
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+range_group+2,'bof');
        CS.COR.Dry_Corr=fread(fid,n_recs,'int16',record_size-2).*1e-3;
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+range_group+2+2,'bof');
        CS.COR.Wet_Corr=fread(fid,n_recs,'int16',record_size-2).*1e-3;
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+range_group+2+2+2,'bof');
        CS.COR.IB_Corr=fread(fid,n_recs,'int16',record_size-2).*1e-3;
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+range_group+2+2+2+2,'bof');
        CS.COR.DAC_Corr=fread(fid,n_recs,'int16',record_size-2).*1e-3;
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+range_group+2+2+2+2+2,'bof');
        CS.COR.Iono_Corr=fread(fid,n_recs,'int16',record_size-2).*1e-3;
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+range_group+2+2+2+2+2+2,'bof');
        CS.COR.SSB_Corr=fread(fid,n_recs,'int16',record_size-2).*1e-3;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%% SWH & Sigma0 Group Reading %%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+range_group+ geo_corr_group,'bof');
        CS.SWH_BS.SWH_Squared_1Hz=fread(fid,n_recs,'int32',record_size-4).*1e-6;
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+range_group+ geo_corr_group+4,'bof');
        CS.SWH_BS.SWH_1Hz=fread(fid,n_recs,'int16',record_size-2).*1e-3;
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+range_group+ geo_corr_group+4+2+2,'bof');
        CS.SWH_BS.SWH_Squared_20Hz=reshape(fread(fid,20.*n_recs,'20*int32',record_size-4.*20).*1e-3,20,[]);
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+range_group+ geo_corr_group+4+2+2+20*4,'bof');
        CS.SWH_BS.Std_SWH_Squared=fread(fid,n_recs,'uint16',record_size-2);
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+range_group+ geo_corr_group+4+2+2+20*4+2,'bof');
        CS.SWH_BS.Valid_Points_SWH_squared=fread(fid,n_recs,'uint16',record_size-2);
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+range_group+geo_corr_group+4+2+2+20*4+2+2,'bof');
        CS.SWH_BS.Flag_SWH_squared=dec2bin(fread(fid,n_recs,'uint32',record_size-4),32).';
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+range_group+geo_corr_group+4+2+2+20*4+2+2+4+2,'bof');
        CS.SWH_BS.Brown_Backscattering_Coefficient_1Hz=fread(fid,n_recs,'int16',record_size-2)./100;
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+range_group+geo_corr_group+4+2+2+20*4+2+2+4+2+2,'bof');
        CS.SWH_BS.Brown_Backscattering_Coefficient_20Hz=reshape(fread(fid,20.*n_recs,'20*int16',record_size-2.*20)./100,20,[]);
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+range_group+geo_corr_group+4+2+2+20*4+2+2+4+2+2+20*2,'bof');
        CS.SWH_BS.Brown_Std_Backscattering_Coefficient_20Hz=fread(fid,n_recs,'uint16',record_size-2)./100;
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+range_group+geo_corr_group+4+2+2+20*4+2+2+4+2+2+20*2+2,'bof');
        CS.SWH_BS.Brown_Valid_Points_Backscattering_Coefficient_20Hz=fread(fid,n_recs,'uint16',record_size-2);
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+range_group+geo_corr_group+4+2+2+20*4+2+2+4+2+2+20*2+2+2,'bof');
        CS.SWH_BS.Brown_Flag_Backscattering_Coefficient_20Hz=dec2bin(fread(fid,n_recs,'uint32',record_size-4),32).';
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+range_group+geo_corr_group+4+2+2+20*4+2+2+4+2+2+20*2+2+2+4+2,'bof');
        CS.SWH_BS.OCOG_Backscattering_Coefficient_1Hz=fread(fid,n_recs,'int16',record_size-2)./100;
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+range_group+geo_corr_group+4+2+2+20*4+2+2+4+2+2+20*2+2+2+4+2+2,'bof');
        CS.SWH_BS.OCOG_Backscattering_Coefficient_20Hz=reshape(fread(fid,20.*n_recs,'20*int16',record_size-2.*20)./100,20,[]);
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+range_group+geo_corr_group+4+2+2+20*4+2+2+4+2+2+20*2+2+2+4+2+2+2*20,'bof');
        CS.SWH_BS.OCOG_Std_Backscattering_Coefficient_20Hz=fread(fid,n_recs,'uint16',record_size-2)./100;
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+range_group+geo_corr_group+4+2+2+20*4+2+2+4+2+2+20*2+2+2+4+2+2+2*20+2,'bof');
        CS.SWH_BS.OCOG_Valid_Points_Backscattering_Coefficient_20Hz=fread(fid,n_recs,'uint16',record_size-2);
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+range_group+geo_corr_group+4+2+2+20*4+2+2+4+2+2+20*2+2+2+4+2+2+2*20+2+2,'bof');
        CS.SWH_BS.OCOG_Flag_Backscattering_Coefficient_20Hz=dec2bin(fread(fid,n_recs,'uint32',record_size-4),32).';
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+range_group+geo_corr_group+4+2+2+20*4+2+2+4+2+2+20*2+2+2+4+2+2+2*20+2+2+4,'bof');
        CS.SWH_BS.Brown_Mispointing=fread(fid,n_recs,'int32',record_size-4).*1e-4;
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%% Geophysical Group Reading %%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+range_group+geo_corr_group+SWH_Sigma0_group,'bof');
        CS.GPH.MSS=fread(fid,n_recs,'int32',record_size-4).*1e-3;
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+range_group+geo_corr_group+SWH_Sigma0_group+4,'bof');
        CS.GPH.Geoid=fread(fid,n_recs,'int32',record_size-4).*1e-3;
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+range_group+geo_corr_group+SWH_Sigma0_group+4+4,'bof');
        CS.GPH.ODLE=fread(fid,n_recs,'int32',record_size-4).*1e-3;
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+range_group+geo_corr_group+SWH_Sigma0_group+4+4+4,'bof');
        CS.GPH.Total_Geocentric_Ocean_Tide=fread(fid,n_recs,'int16',record_size-2).*1e-3;
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+range_group+geo_corr_group+SWH_Sigma0_group+4+4+4+2*1,'bof');
        CS.GPH.Long_Period_Tide=fread(fid,n_recs,'int16',record_size-2).*1e-3;
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+range_group+geo_corr_group+SWH_Sigma0_group+4+4+4+2*2,'bof');
        CS.GPH.Tide_Loading_Tide=fread(fid,n_recs,'int16',record_size-2).*1e-3;
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+range_group+geo_corr_group+SWH_Sigma0_group+4+4+4+2*3,'bof');
        CS.GPH.Solid_Earth_Tide=fread(fid,n_recs,'int16',record_size-2).*1e-3;
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+range_group+geo_corr_group+SWH_Sigma0_group+4+4+4+2*4,'bof');
        CS.GPH.Geocentric_Polar_Tide=fread(fid,n_recs,'int16',record_size-2).*1e-3;
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+range_group+geo_corr_group+SWH_Sigma0_group+4+4+4+2*5,'bof');
        CS.GPH.Altimeter_Wind_Speed=fread(fid,n_recs,'int16',record_size-2).*1e-3;

        fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+range_group+geo_corr_group+SWH_Sigma0_group+4+4+4+2*6,'bof');
        CS.GPH.Model_Wind_Speed_U=fread(fid,n_recs,'int16',record_size-2).*1e-3;
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+range_group+geo_corr_group+SWH_Sigma0_group+4+4+4+2*7,'bof');
        CS.GPH.Model_Wind_Speed_V=fread(fid,n_recs,'int16',record_size-2).*1e-3;
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+range_group+geo_corr_group++SWH_Sigma0_group+4+4+4+2*8,'bof');
        CS.GPH.Peakness_20Hz=reshape(fread(fid,20.*n_recs,'20*uint16',record_size-2.*20),20,[]);
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+range_group+geo_corr_group+SWH_Sigma0_group+4+4+4+2*8+2.*20,'bof');
        CS.GPH.Retracking_Quality=dec2bin(fread(fid,n_recs,'uint32',record_size-4),32).';
        
        fseek(fid,MPH_size+HDR.SPH_SIZE+time_group+range_group+geo_corr_group+SWH_Sigma0_group+4+4+4+2*8+2.*20+4,'bof');
        CS.GPH.Flag_Type_Surface=dec2bin(fread(fid,n_recs,'uint16',record_size-2),16).';
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        CS.RNG.Brown_Range_1Hz((CS.RNG.Brown_Range_1Hz.*1000)==(2^(32)-1))=nan;
        
        CS.RNG.Brown_Range_20Hz((CS.RNG.Brown_Range_20Hz.*1000)==(2^(32)-1))=nan;
        
        CS.RNG.Std_Brown_Range_20Hz((CS.RNG.Std_Brown_Range_20Hz.*1000)==(2^(32/2)-1))=nan;
        
        CS.RNG.OCOG_Range_1Hz((CS.RNG.OCOG_Range_1Hz.*1000)==(2^(32)-1))=nan;
        
        CS.RNG.OCOG_Range_20Hz((CS.RNG.OCOG_Range_20Hz.*1000)==(2^(32)-1))=nan;
        
        CS.RNG.Std_OCOG_Range_20Hz((CS.RNG.Std_OCOG_Range_20Hz.*1000)==(2^(32/2)-1))=nan;
        
        CS.COR.Doppler_Corr(int16(CS.COR.Doppler_Corr.*1000)==(2^(16)/2-1))=nan;
        
        CS.COR.Dry_Corr(int16(CS.COR.Dry_Corr.*1000)==(2^(16)/2-1))=nan;
        
        CS.COR.Wet_Corr(int16(CS.COR.Wet_Corr.*1000)==(2^(16)/2-1))=nan;
        
        CS.COR.IB_Corr(int16(CS.COR.IB_Corr.*1000)==(2^(16)/2-1))=nan;
        
        CS.COR.DAC_Corr(int16(CS.COR.DAC_Corr.*1000)==(2^(16)/2-1))=nan;
        
        CS.COR.Iono_Corr(int16(CS.COR.Iono_Corr.*1000)==(2^(16)/2-1))=nan;
        
        CS.COR.SSB_Corr(int16(CS.COR.SSB_Corr.*1000)==(2^(16)/2-1))=nan;
        
        CS.GPH.Total_Geocentric_Ocean_Tide(int16(CS.GPH.Total_Geocentric_Ocean_Tide.*1000)==(2^(16)/2-1))=nan;
        
        CS.GPH.Long_Period_Tide(int16(CS.GPH.Long_Period_Tide.*1000)==(2^(16)/2-1))=nan;
        
        CS.GPH.Long_Period_Tide(int16(CS.GPH.Tide_Loading_Tide.*1000)==(2^(16)/2-1))=nan;
        
        CS.GPH.Solid_Earth_Tide(int16(CS.GPH.Solid_Earth_Tide.*1000)==(2^(16)/2-1))=nan;
        
        CS.GPH.Geocentric_Polar_Tide(int16(CS.GPH.Geocentric_Polar_Tide.*1000)==(2^(16)/2-1))=nan;
        
        CS.GPH.Model_Wind_Speed_U(int16(CS.GPH.Model_Wind_Speed_U.*1000)==(2^(16)/2-1))=nan;
        CS.GPH.Model_Wind_Speed_V(int16(CS.GPH.Model_Wind_Speed_V.*1000)==(2^(16)/2-1))=nan;
        
        CS.SWH_BS.SWH_Squared_1Hz(int32( CS.SWH_BS.SWH_Squared_1Hz.*(1000.^2))==(2^(32)/2-1))=nan;
        
        CS.SWH_BS.SWH_Squared_20Hz(int32(CS.SWH_BS.SWH_Squared_20Hz.*(1000.^2))==(2^(32)/2-1))=nan;
        
        CS.SWH_BS.Std_SWH_Squared(int16(CS.SWH_BS.Std_SWH_Squared)==(2^(16)/2-1))=nan;
        
        CS.SWH_BS.SWH_1Hz(int16(CS.SWH_BS.SWH_1Hz.*1000)==(2^(16)/2-1))=nan;
        
        CS.SWH_BS.Brown_Backscattering_Coefficient_1Hz(int16(CS.SWH_BS.Brown_Backscattering_Coefficient_1Hz.*(100))==(2^(16)/2-1))=nan;
        
        CS.SWH_BS.Brown_Backscattering_Coefficient_20Hz(int16(CS.SWH_BS.Brown_Backscattering_Coefficient_20Hz.*(100))==(2^(16)/2-1))=nan;
        
        CS.SWH_BS.Brown_Std_Backscattering_Coefficient_20Hz(int16(CS.SWH_BS.Brown_Std_Backscattering_Coefficient_20Hz.*(100))==(2^(16)/2-1))=nan;
        
        CS.SWH_BS.OCOG_Backscattering_Coefficient_1Hz(int16(CS.SWH_BS.OCOG_Backscattering_Coefficient_1Hz.*(100))==(2^(16)/2-1))=nan;
        
        CS.SWH_BS.OCOG_Backscattering_Coefficient_20Hz(int16(CS.SWH_BS.OCOG_Backscattering_Coefficient_20Hz.*(100))==(2^(16)/2-1))=nan;
        
        CS.SWH_BS.OCOG_Std_Backscattering_Coefficient_20Hz(int16(CS.SWH_BS.OCOG_Std_Backscattering_Coefficient_20Hz.*100)==(2^(16)/2-1))=nan;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        CS.COR.total_ocean=CS.COR.Dry_Corr+CS.COR.Wet_Corr+CS.COR.DAC_Corr+CS.COR.Iono_Corr+CS.COR.SSB_Corr+...
            CS.GPH.Total_Geocentric_Ocean_Tide+CS.GPH.Solid_Earth_Tide+ CS.GPH.Geocentric_Polar_Tide;
        
        CS.GPH.SSH_Brown_1Hz=CS.GEO.Height_1Hz-CS.RNG.Brown_Range_1Hz-CS.COR.total_ocean;
        CS.GPH.SLA_Brown_1Hz=CS.GPH.SSH_Brown_1Hz-CS.GPH.MSS;
        
        CS.GPH.SSH_OCOG_1Hz=CS.GEO.Height_1Hz-CS.RNG.OCOG_Range_1Hz-CS.COR.total_ocean;
        CS.GPH.SLA_OCOG_1Hz=CS.GPH.SSH_OCOG_1Hz-CS.GPH.MSS;
        
        CS.GEO.MCD_FLAG_Tab.Block_Degraded=bin2decimal(CS.GEO.MCD_FLAG(1,:).');
        CS.GEO.MCD_FLAG_Tab.Blank_Block=bin2decimal(CS.GEO.MCD_FLAG(2,:).');
        CS.GEO.MCD_FLAG_Tab.Datation_Degraded=bin2decimal(CS.GEO.MCD_FLAG(3,:).');
        CS.GEO.MCD_FLAG_Tab.Orbit_Propag_Err=bin2decimal(CS.GEO.MCD_FLAG(4,:).');
        CS.GEO.MCD_FLAG_Tab.Orbit_File_Change=bin2decimal(CS.GEO.MCD_FLAG(5,:).');
        CS.GEO.MCD_FLAG_Tab.Orbit_Discontinuity=bin2decimal(CS.GEO.MCD_FLAG(6,:).');
        CS.GEO.MCD_FLAG_Tab.Echo_Saturation=bin2decimal(CS.GEO.MCD_FLAG(7,:).');
        CS.GEO.MCD_FLAG_Tab.Other_Echo_Err=bin2decimal(CS.GEO.MCD_FLAG(8,:).');
        CS.GEO.MCD_FLAG_Tab.Rx1_Err_SARin=bin2decimal(CS.GEO.MCD_FLAG(9,:).');
        CS.GEO.MCD_FLAG_Tab.Rx2_Err_SARin=bin2decimal(CS.GEO.MCD_FLAG(10,:).');
        CS.GEO.MCD_FLAG_Tab.Wind_Delay_Incon=bin2decimal(CS.GEO.MCD_FLAG(11,:).');
        CS.GEO.MCD_FLAG_Tab.AGC_Incon=bin2decimal(CS.GEO.MCD_FLAG(12,:).');
        CS.GEO.MCD_FLAG_Tab.CAL1_Corr_Miss=bin2decimal(CS.GEO.MCD_FLAG(13,:).');
        CS.GEO.MCD_FLAG_Tab.CAL1_Corr_IPF=bin2decimal(CS.GEO.MCD_FLAG(14,:).');
        CS.GEO.MCD_FLAG_Tab.DORIS_USO_Corr=bin2decimal(CS.GEO.MCD_FLAG(15,:).');
        CS.GEO.MCD_FLAG_Tab.Complex_CAL1_Corr_IPF=bin2decimal(CS.GEO.MCD_FLAG(16,:).');
        CS.GEO.MCD_FLAG_Tab.TRK_ECHO_Err=bin2decimal(CS.GEO.MCD_FLAG(17,:).');
        CS.GEO.MCD_FLAG_Tab.RX1_ECHO_Err=bin2decimal(CS.GEO.MCD_FLAG(18,:).');
        CS.GEO.MCD_FLAG_Tab.RX2_ECHO_Err=bin2decimal(CS.GEO.MCD_FLAG(19,:).');
        CS.GEO.MCD_FLAG_Tab.NPM_Incon=bin2decimal(CS.GEO.MCD_FLAG(20,:).');
        CS.GEO.MCD_FLAG_Tab.Azi_Cal_Miss=bin2decimal(CS.GEO.MCD_FLAG(21,:).');
        CS.GEO.MCD_FLAG_Tab.Azi_Cal_DB=bin2decimal(CS.GEO.MCD_FLAG(22,:).');
        CS.GEO.MCD_FLAG_Tab.Range_Wind_Cal_Miss=bin2decimal(CS.GEO.MCD_FLAG(23,:).');
        CS.GEO.MCD_FLAG_Tab.Range_Wind_Cal_DB=bin2decimal(CS.GEO.MCD_FLAG(24,:).');
        CS.GEO.MCD_FLAG_Tab.Phase_Pertubation_Corr=bin2decimal(CS.GEO.MCD_FLAG(25,:).');
        CS.GEO.MCD_FLAG_Tab.CAL2_Corr_Miss=bin2decimal(CS.GEO.MCD_FLAG(26,:).');
        CS.GEO.MCD_FLAG_Tab.CAL2_Corr_IPF=bin2decimal(CS.GEO.MCD_FLAG(27,:).');
        CS.GEO.MCD_FLAG_Tab.Power_Scaling_Err=bin2decimal(CS.GEO.MCD_FLAG(28,:).');
        CS.GEO.MCD_FLAG_Tab.Att_Corr_Miss=bin2decimal(CS.GEO.MCD_FLAG(29,:).');
        CS.GEO.MCD_FLAG_Tab.Att_Inter_Err=bin2decimal(CS.GEO.MCD_FLAG(30,:).');
        CS.GEO.MCD_FLAG_Tab.SIRAL_Side=bin2decimal(CS.GEO.MCD_FLAG(31,:).');
        CS.GEO.MCD_FLAG_Tab.Phase_Pertubation_Mode=bin2decimal(CS.GEO.MCD_FLAG(32,:).');
        
        CS.GEO.MCD_FLAG=CS.GEO.MCD_FLAG_Tab;
        CS.GEO=rmfield(CS.GEO,'MCD_FLAG_Tab');
        
        
end

CS.GEO.Serial_Sec_Num=CS.GEO.TAI.days.*24.*60.*60+CS.GEO.TAI.secs+CS.GEO.TAI.microsecs./1e6;
CS.GEO.Elapsed_Time=zeros(size(CS.GEO.Serial_Sec_Num));
CS.GEO.Elapsed_Time(CS.GEO.Serial_Sec_Num~=0)=CS.GEO.Serial_Sec_Num(CS.GEO.Serial_Sec_Num~=0)-CS.GEO.Start_Time;

clear dummy_1 dummy_2
fclose(fid);


function x=bin2decimal(s)

[m,n] = size(s);
v = s - '0';
twos = pow2(n-1:-1:0);
x = sum(v .* twos(ones(m,1),:),2);

