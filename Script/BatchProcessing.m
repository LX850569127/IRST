% clear;

%% Preferences
CurrentPath='E:\Sync\Master\Project\Crossover';                % 使用相对路径需要注意当前路径
Region='Ross';                                                 % Input experimental region
DataPath='Y:\CryoSat-2 Data\Baseline D\SIR_GDR\';              % Data Path
StoragePath=strcat('E:\Sync\Master\Project\Crossover\Variate\',Region,'\');   
load(strcat(Region,'Boundary.mat'));

%% 一、数据读取及裁剪
% year=2016;
% for i=1:12  %月份
%    
%     if i<10
%         folderPath = strcat(DataPath, num2str(year),'\0', num2str(i));
%         variate_cut=strcat('Cut',num2str(year),'0', num2str(i));
%     else 
%         folderPath = strcat(DataPath, num2str(year),'\', num2str(i));
%        variate_cut=strcat('Cut',num2str(year), num2str(i));
%     end 
%     
%    raw=NcFileRead(folderPath);   %输出该路径下所有文件的坐标信息
%    
%    orbitalInfo= struct('coordinate',[],'orbitNum',[]);       
%    orbitalInfo=repmat(orbitalInfo,[size(raw,1) 1]);
%    ind=1;
%    
%    for j=1:size(raw)             %对raw中每一段轨迹进行裁切，注意有的轨迹裁切后仍有两个弧段的情况
%         temp=raw(j);
%         longitude=getfield(temp,'longtitude');
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
% 
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
%    end    
%     clear raw;         %清除原始数据变量
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
%     
% %   clear -regexp ^Cut;  %清除已经保存的裁剪数据变量
% end
 
%% 二、升降轨数据分离

% year=2016;
% for i=1:12   %Month 
%     
%     Ascend=[];
%     Descend=[];
%     
%     if i<10
%         variate_cut=strcat('Cut',num2str(year),'0',num2str(i));
%         variate_A=strcat(Region,'_A',num2str(year),'0',num2str(i));
%         variate_D=strcat(Region,'_D',num2str(year),'0',num2str(i));
%     else 
%        variate_cut=strcat('Cut',num2str(year),num2str(i));
%        variate_A=strcat(Region,'_A',num2str(year),num2str(i));
%        variate_D=strcat(Region,'_D',num2str(year),num2str(i));
%     end  
%     
%     load(variate_cut);
%     Cut=eval(variate_cut);
%     
%     for j=1:size(Cut,1)
%         cor=Cut(j).coordinate;
% %           对数据进行预处理
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

%% 三、求交叉点的精确位置  Ross冰架

Region='Ross';     

% Continuous period of data
year_A=2016;
year_D=2016;    

startMonth=1;
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
% Descend=["201101";"201102";"201103";"201104";"201105";"201106"];
% Ascend=["201201";"201202";"201203";"201204";"201205";"201206"];

for i=1:12
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
        out= MyCrossOver(couple(j,1),couple(j,2),Boundary);
        if ~isempty(out)
            CP(ind)=out;
            ind = ind+1;
        end
           close all;
    end
    CP=CP(1:ind-1);
 
    % Save 
    eval(strcat(name_CP,'=CP'));
    fileName=strcat(name_CP,'.mat');
    storagePath=strcat('.\Variate\',Region,'\CP\');   %CurrentPath is "..\Crossover"
    save(strcat(storagePath,fileName),name_CP); 
  clear -regexp ^Ross
  clear couple
end

%% 寻找5km*5km格网中每个格网中的交叉点
% Region='Ross';     
% 
% % Continuous period of data
% year_A=2011;
% year_D=2015;    
% 
% startMonth=1;
% endMonth=12;
%    
% Ascend=strings([endMonth-startMonth+1,1]);
% Descend=strings([endMonth-startMonth+1,1]);
% 
% for i=startMonth:endMonth
%     if i<10
%         month=strcat('0',num2str(i));    
%     else 
%         month=num2str(i);  
%     end
%     ym_A=strcat(num2str(year_A),month);
%     ym_D=strcat(num2str(year_D),month);
%     Ascend(i-startMonth+1)=ym_A;
%     Descend(i-startMonth+1)=ym_D;
% end
% 
% total_CP=[];
% for i=startMonth:endMonth
%      name_CP=strcat(Region,'_A',Ascend(i),'_D',Descend(i));
%      CP=eval(name_CP);
%      total_CP=[total_CP;CP]
% end




