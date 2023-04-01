function [DBL] = DBL_read(FolderPath)

% Scope: Matlab Function to ingest CryoSat L2 data products to matlab workspace


filesPath = dir(fullfile(FolderPath,'*.DBL'));  
fileNumber=size(filesPath);
DBL=struct('longitude',[], 'latitude',[], 'height',[],'time',[],'orbitNum',[]);
DBL=repmat(DBL,[fileNumber(1) 1]);

    parfor i=1:fileNumber(1)
        disp(i);
        Inpath=strcat(FolderPath,'\',filesPath(i,:).name);
        [HDR, CS]=Cryo_L2_read(Inpath);
        if isempty(CS)
            continue;
        end
        lat = CS.MEA.LAT_20Hz;
        lon = CS.MEA.LON_20Hz;  
        height = CS.MEA.surf_height_r1_20Hz ;
        delta_time = CS.MEA.delta_time_20Hz ;
        orbitNum=HDR.ABS_ORBIT;  
        lon = reshape(lon, size(lon,1)*size(lon,2), 1);
        lat = reshape(lat, size(lat,1)*size(lat,2), 1);
        height = reshape(height, size(height,1)*size(height,2), 1);
        delta_time = reshape(delta_time, size(delta_time,1)*size(delta_time,2), 1);     
        time = sort(repmat(CS.GEO.TAI.days*24*60*60+CS.GEO.TAI.secs,20,1)) ;
        time=time+delta_time;
                      
        start_record_tai_time=TAI2Sec(HDR.START_RECORD_TAI_TIME);  
        stop_record_tai_time=TAI2Sec(HDR.STOP_RECORD_TAI_TIME);  
        
        [~,fist_row]=min(abs(time-start_record_tai_time));
        [~,last_row]=min(abs(time-stop_record_tai_time));
        
        lat=lat(fist_row:last_row);    
        lon=lon(fist_row:last_row);
        time=time(fist_row:last_row);
        height=height(fist_row:last_row);
          
        DBL(i).longitude=lon;
        DBL(i).latitude=lat;
        DBL(i).height=height;
        DBL(i).time=time;
        DBL(i).orbitNum=orbitNum;        
    end  
    
end


function [Sec] = TAI2Sec(TAI)
%Function：Transform TAI to the seconds since 2000-01-01 00:00:00.0 
%Input：TAI;TAI=
%Output：Sec;seconds since 2000-01-01 00:00:00.0(double)

    year=str2double(TAI(9:12));
    str_month=string(TAI(5:7));
    day=str2double(TAI(2:3));
    hour=str2double(TAI(14:15));
    minute=str2double(TAI(17:18));
    second=str2double(TAI(20:end));

    switch  str_month
        case 'JAN' , month=1;
        case 'FEB' , month=2;   
        case 'MAR' , month=3;                
        case 'APR' , month=4;       
        case 'MAY' , month=5;              
        case 'JUN' , month=6;
        case 'JUL' , month=7;
        case 'AUG' , month=8;
        case 'SEP' , month=9;
        case 'OCT' , month=10;
        case 'NOV' , month=11;
        case 'DEC' , month=12;     
    end
    
    if rem((year-2000)/4 ,1)==0   %判断该年份是否为闰年
    %% 1)闰年
         if  month>2  %判断月份是否超过2月
             leaps=(year-2000)/4+1;   %闰年数
         else
             leaps=(year-2000)/4;
         end
    else
     %% 2)平年 
         leaps=ceil((year-2000)/4);
    end
    
    days=0;
    %计算该年已经过去了多少天
    if month>1
        for i=1:month-1
            if i ==2
                dd=28;
            elseif i==4||i==6||i==9||i ==11
                dd=30;
            else
                dd=31;
            end
            days=days+dd;
        end
    end
    
    days=days+day-1;
    d=(year-2000)*365+leaps+days;
    Sec=d*24*60*60+hour*60*60+minute*60+second;
end
