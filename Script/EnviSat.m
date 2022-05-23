                             
Region='Amery';                                       % 区域
DataPath='Y:\EnviSatElevationChange\读取数据\';               % 数据路径
load(strcat(Region,'Boundary.mat'));                          % 边界数据
StoragePath=strcat('E:\Sync\Master\Project\Crossover\Variate\',Region,'\');   % 存储路径

%% 一、读取N1文件中的坐标和高程数据并保存成变量形式，裁剪特定冰架区域
% year=2003;     % 年份      
% for i=9:12    % 月份     
%    
%     folderPath=strcat(DataPath,num2str(year),'\',num2str(i),'\结果');       % 文件路径
%     variate_cut=strcat('Cut',num2str(year), zerosFill(i));
%     filesPath = dir(fullfile(folderPath,'*.N1'));                           % 统计N1文件  
%     fileNumber=size(filesPath);                                             % 文件个数
%     raw=[];         % 定义输出坐标、高程以及时间信息的矩阵  
% 
%     %1)读取经纬度坐标、高程信息、时间并进行存储
%     parfor j=1:fileNumber(1)
%         Inpath=strcat(folderPath,'\',filesPath(j,:).name);
%         fileName= filesPath(j,:).name;
%         absOrbit=str2num(fileName(50:54));
%         tempData=load(Inpath);
%         if ~isempty(tempData)
%             lon=tempData(:,1);
%             lat=tempData(:,2);
%             height=tempData(:,3);
%             time=tempData(:,5);
%             trackInfo=struct('longitude',lon,'latitude',lat,'height',height, ...
%                 'time',time,'orbitNum',absOrbit);  %存储该轨道对应的所有坐标、高程以及时间信息
%             raw=[raw;trackInfo];
%         end
%     end
%    
%     %2) 对raw中每一段轨迹进行裁切，注意有的轨迹裁切后仍有两个弧段的情况
%     orbitalInfo= struct('coordinate',[],'orbitNum',[]);       
%     orbitalInfo=repmat(orbitalInfo,[size(raw,1) 1]);
%     ind=1;
%    
%     for j=1:size(raw)                   
%         temp=raw(j);     
%         longitude=getfield(temp,'longitude');
%         latitude=getfield(temp,'latitude');
%         height=getfield(temp,'height');
%         time=getfield(temp,'time');
%         orbitNum=getfield(temp,'orbitNum');
%         coor=[longitude,latitude,height,time];
% 
%         % 需要根据具体的实验区域来调整拟合区域，在第一步曲线拟合的过程中可以得到更好的拟合结果
%          switch Region
%             case 'Ronne' 
%                 intraArea=ScreenCoordinatasRegularly(coor,[min(Boundary(:,1))-2,max(Boundary(:,1)+2)],... 
%                 [min(Boundary(:,2))-1.1,max(Boundary(:,2)+1.25)]);     %Ronne ice shelf 
%             case 'Ross' 
%                 intraArea=ScreenCoordinatasRegularly(coor,[min(Boundary(:,1))-1.5,max(Boundary(:,1)+1.5)],... 
%                 [min(Boundary(:,2))-1,max(Boundary(:,2)+1)]);          %Ross ice shelf 
%             case 'Amery'
%                   intraArea=ScreenCoordinatasRegularly(coor,[min(Boundary(:,1))-1.5,max(Boundary(:,1)+1.5)],... 
%                 [min(Boundary(:,2))-1,max(Boundary(:,2)+1)]);          %Amery ice shelf 
%                 %罗斯冰架左下方区需进行的裁剪
%                  if (size(intraArea)~=0)
%                   for k=1:size(intraArea)
%                      if  intraArea(k,2)<-83                        %根据该直线对数据左下方数据区域进行裁切
%                           y=intraArea(k,1)*(-0.06717)-72.3805;     %Line function for clipping
%                           if intraArea(k,2)<y
%                               intraArea(k,:)=0;
%                           end
%                      end
%                   end
%                  index=find(intraArea(:,1)==0);
%                  intraArea(index,:)=[];
%                  end
%              otherwise
%                  warning('Unexpected Region');
%          end
%          
%         if (size(intraArea,1)>9)       
%             tempOrbitalInfo = struct('coordinate',intraArea,'orbitNum',orbitNum);
%             orbitalInfo(ind)=tempOrbitalInfo;                     
%             ind=ind+1;
%         end
%     end    
% 
%     orbitalInfo=orbitalInfo(1:ind-1);
%     eval([variate_cut '=orbitalInfo']);
%     
%     %Save
%     fileName=strcat(variate_cut,'.mat');
%     filePath=strcat(StoragePath,num2str(year),'\Cut\');
%     if ~exist(filePath,'dir')
%         mkdir(filePath)
%     end
%     save([filePath,fileName],variate_cut);
%     clear raw;         %清除原始数据变量
% end

%% 二、升降轨数据分离

% year=2002;
% for i=7:12   %Month 
%     
%     Ascend=[];
%     Descend=[];
% 
%     variate_cut=strcat('Cut',num2str(year),zerosFill(i));
%     variate_A=strcat(Region,'_A',num2str(year),zerosFill(i));
%     variate_D=strcat(Region,'_D',num2str(year),zerosFill(i));
%    
% %     load(variate_cut);
%     Cut=eval(variate_cut);
%     
%     for j=1:size(Cut,1)
%         cor=Cut(j).coordinate;
% 
%         orbitNum=Cut(j).orbitNum;
%         if size(cor,1)>15          %剔除点数较少的轨迹
%         cor=preprocess(cor);       %数据预处理，剔除偏离较大的轨迹点 
% 
% %   判断轨道的升降轨(第一点的纬度与最后一点的纬度进行比较)
%             if(cor(1,2)<cor(end,2))
%                 flag_AD='A';
%                 trackInfo = struct('coordinate',cor,'flag_AD',{flag_AD},'orbitNum',orbitNum);
%                 Ascend=[Ascend;trackInfo];
%             else 
%                 flag_AD='D';
%                 trackInfo = struct('coordinate',cor,'flag_AD',{flag_AD},'orbitNum',orbitNum);
%                 Descend=[Descend;trackInfo]; 
%             end
%         end
%     end
%     
%    eval(strcat(variate_A ,'=Ascend'));
%    eval(strcat(variate_D ,'=Descend'));
%    
%    fileNameA=strcat(variate_A,'.mat');
%    fileNameD=strcat(variate_D,'.mat');
%    storagePathA=strcat(StoragePath,num2str(year),'\Ascend\');
%    storagePathD=strcat(StoragePath,num2str(year),'\Descend\');
%    if ~exist(storagePathA,'dir')|| ~exist(storagePathD,'dir')
%        mkdir(storagePathA); 
%        mkdir(storagePathD); 
%    end
% 
%    save([char(storagePathA),char(fileNameA)],variate_A);
%    save([char(storagePathD),char(fileNameD)],variate_D);
% end

%% 三、交叉点求解
  
% Continuous period of data

year_A=2003;    % 升轨年份
year_D=2004;    % 降轨年份

startMonth=7;
endMonth=12;
   
Ascend=strings([endMonth-startMonth+1,1]);
Descend=strings([endMonth-startMonth+1,1]);

for i=startMonth:endMonth
    if i<10
        month=strcat('0',num2str(i));    
    else 
        month=num2str(i);  
    end
    ym_A=strcat(num2str(year_A),month);
    ym_D=strcat(num2str(year_D),month);
    Ascend(i-startMonth+1)=ym_A;
    Descend(i-startMonth+1)=ym_D;
end

% Custom period of data
% Descend=["200207"];
% Ascend=["200208"];

for i=1:endMonth-startMonth+1
 
    % Load and name 
    name_A=strcat(Region,'_A',Ascend(i));
    name_D=strcat(Region,'_D',Descend(i));
    name_CP=strcat(Region,'_A',Ascend(i),'_D',Descend(i));
    load(name_A);  
    load(name_D);  
    % Solve crossovers 
    couple=JudgeCrossPoint(eval(name_A),eval(name_D));
    sizeOfCouple=size(couple,1);
    corssOver= struct('coordinate',[], 'orbitNum_A',[], 'orbitNum_D',[],...
        'altitude_A',[],'altitude_D',[], 'time_A',[],'time_D',[],'PDOP',[]); 
    CP=repmat(corssOver,[sizeOfCouple 1]);
    
    ind=1;
   for j=1:sizeOfCouple
%     figure;
%     plot(Boundary(:,1),Boundary(:,2));
%     hold on;
        out= MyCrossOver(couple(j,1),couple(j,2),Boundary);
        if ~isempty(out)
            CP(ind)=out;
            ind = ind+1;
        end
%         close all;
    end
    CP=CP(1:ind-1);

    % Save 
    eval(strcat(name_CP,'=CP')); 
    fileName=strcat(name_CP,'.mat');
    storagePath=strcat('.\Variate\',Region,'\CP\');   %CurrentPath is "..\Crossover"
    save(strcat(storagePath,fileName),name_CP); 
%   clear -regexp ^Ross
end

%% 结果处理
year1='2002';    % 升轨年份
year2='2003';    % 降轨年份

month='12';
name_cp1=strcat(Region,'_A',year1,month,'_D',year2,month);
name_cp2=strcat(Region,'_A',year2,month,'_D',year1,month);
CP=[eval(name_cp1);eval(name_cp1)];



 Bias=zeros(size(CP,1),3);
for i=1:size(CP,1)
    cor=CP(i).coordinate;
    altitude_A=CP(i).altitude_A;
    altitude_D=CP(i).altitude_D;
    orbitNum_A=CP(i).orbitNum_A;
    orbitNum_D=CP(i).orbitNum_D;          
    if orbitNum_A<orbitNum_D   
        Bias(i,:)=[cor,altitude_D-altitude_A];       
    else 
        Bias(i,:)=[cor,altitude_A-altitude_D];
    end      
end
  Bias(abs(Bias(:,3))>4,:)=[];     

fileName=strcat(Region,year1,month,year2,month,'.txt');
fid = fopen(fileName,'a+');
fprintf(fid,'%15.7f%15.7f%10.4f\n',Bias');

%% calibrate the crossovers in FilchnerRonne 
coordinate=cell2mat({Ronne_A200208_D200207(:).coordinate}).';
longitude=coordinate(1:2:size(coordinate,1)-1);
latitude=coordinate(2:2:size(coordinate,1));
figure('color','w');
hold on;
scatter(longitude,latitude,10,'filled');
plot(Boundary(:,1),Boundary(:,2),'k','MarkerSize',0.01,'HandleVisibility','off'); 

for i=1:size(Ronne_A200208,1)
    cor_A=Ronne_A200208(i).coordinate;
    scatter(cor_A(:,1),cor_A(:,2),1,[127 140 141]/255,'filled','HandleVisibility','off');  
end

for i=1:size(Ronne_D200207,1)
    cor_D=Ronne_D200207(i).coordinate;
    scatter(cor_D(:,1),cor_D(:,2),1,[127 140 141]/255,'filled');  %color [0 140 141]/255  
end



