function [Output_TrackInfo] = NcFileRead(FolderPath)
%Function：读取同一个文件夹下所有nc文件里的坐标、高程、时间信息
%Input：folderPath(存储需要读取的所有nc文件的文件夹)
%Output：Output_TrackInfo(每行对应一个nc文件的信息，且从左往右依次是经度、纬度、高程、时间)
%说明：由于GDR数据一个而文件中除当前轨道号的数据还存在前后轨道号的部分数据，需要根据头文件中的观测时间对数据进行裁剪

filesPath = dir(fullfile(FolderPath,'*.nc'));  
fileNumber=size(filesPath);
Output_TrackInfo=[]; %定义输出坐标、高程以及时间信息的矩阵
%1)读取经纬度坐标、高程信息、时间并进行存储
    
    for i=1:fileNumber(1)
        Inpath=strcat(FolderPath,'\',filesPath(i,:).name);
        lat = ncread(Inpath,'lat_poca_20_ku'); 
        lon = ncread(Inpath,'lon_poca_20_ku');
        time =ncread(Inpath,'time_20_ku');
        height=ncread(Inpath,'height_1_20_ku');      
        Attribute=ncinfo(Inpath).Attributes;     %文件头信息   
     
        if string(Attribute(13).Name)=='abs_orbit_number'
            orbitNum=Attribute(13).Value;                     %absolute orbit number
            first_record_time=TAI2Sec(Attribute(27).Value);   
            last_record_time=TAI2Sec(Attribute(28).Value);    %读取数据记录时间用于数据裁剪
        else
            temp={Attribute(:).Name}.';                       %将结构体中的Name字段下的所有信息转为string数组
            attributeName=string(zeros(numel(temp),1));
            for j=1:numel(temp)
                 attributeName(j)=cell2mat(temp(j));
            end
              k=contains(attributeName,'abs_orbit_number');
              k1=contains(attributeName,'first_record_time');
              k2=contains(attributeName,'last_record_time');
              orbitNum=Attribute(k).Value;
              first_record_time=TAI2Sec(Attribute(k1).Value);   
              last_record_time=TAI2Sec(Attribute(k2).Value);                       
        end
      
        [value,fist_row]=min(abs(time-first_record_time));
        [value,last_row]=min(abs(time-last_record_time));
                                             
        %截取观测时间内的数据
        lat=lat(fist_row:last_row);    
        lon=lon(fist_row:last_row);
        time=time(fist_row:last_row);
        height=height(fist_row:last_row);
   
        trackInfo=struct('longitude',lon,'latitude',lat,'time',time,'height',height,'orbitNum',orbitNum);  %存储该轨道对应的所有坐标、高程以及时间信息
        Output_TrackInfo=[Output_TrackInfo;trackInfo];
    end
 
end

function [Sec] = TAI2Sec(TAI)
%Function：Transform TAI to the seconds since 2000-01-01 00:00:00.0 
%Input：TAI;TAI=yyyy-mm-ddThh:mm:ss.uuuuuu(char)
%Output：Sec;seconds since 2000-01-01 00:00:00.0(double)

    year=str2num(TAI(5:8));
    month=str2num(TAI(10:11));
    day=str2num(TAI(13:14));
    hour=str2num(TAI(16:17));
    minute=str2num(TAI(19:20));
    second=str2num(TAI(22:end));

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