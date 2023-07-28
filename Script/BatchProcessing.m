% clear;
%% Preferences
Baseline='D';
Region='Amery'; 
CurrentPath='E:\Sync\BaiduSyncdisk\Master\Project\Crossover';                                      
DataPath=strcat('Z:\CryoSat-2 Data\Baseline_',Baseline, '\SIR_GDR\');
StoragePath=strcat('.\Variate\',Region,'\','baseline_',Baseline,'\');   
load(strcat(strcat('.\Variate\',Region,'\'),Region,'Boundary.mat'));


%% 1.Reanding and clipping data  
% year=2019;
% for i=1:12  %Month
%    
%     if i<10
%         folderPath = strcat(DataPath, num2str(year),'\0', num2str(i));
%         variate_cut=strcat('Cut',num2str(year),'0', num2str(i));
%     else 
%         folderPath = strcat(DataPath, num2str(year),'\', num2str(i));
%         variate_cut=strcat('Cut',num2str(year), num2str(i));
%     end 
%     
%     if strcmp(Baseline,'D')
%        raw=NcFileRead(folderPath); 
%     elseif strcmp(Baseline,'C')
%        raw=DBL_read(folderPath);
%     end
% 
%    orbitalInfo= struct('coordinate',[],'orbitNum',[]);       
%    orbitalInfo=repmat(orbitalInfo,[size(raw,1) 1]);
%    ind=1;
%    
%    for j=1:size(raw)             %对raw中每一段轨迹进行裁切，注意有的轨迹裁切后仍有两个弧段的情况
%         temp=raw(j);
%         longitude=getfield(temp,'longitude');
%         latitude=getfield(temp,'latitude');
%         height=getfield(temp,'height');
%         time=getfield(temp,'time');
%         orbitNum=getfield(temp,'orbitNum');
%         coor=[longitude,latitude,height,time];
%         
%         if isempty(coor)
%             continue;
%         end
%         
%         % 需要根据具体的实验区域来调整拟合区域，在第一步曲线拟合的过程中可以得到更好的拟合结果
%          switch Region
%             case 'Ronne' 
%                 intraArea=ScreenCoordinatasRegularly(coor,[min(Boundary(:,1))-2,max(Boundary(:,1)+2)],... 
%                 [min(Boundary(:,2))-1.1,max(Boundary(:,2)+1.25)]);     %Ronne ice shelf 
%             case 'Ross' 
%                 intraArea=ScreenCoordinatasRegularly(coor,[min(Boundary(:,1))-1.5,max(Boundary(:,1)+1.5)],... 
%                 [min(Boundary(:,2))-1,max(Boundary(:,2)+1)]);          %Ross ice shelf 
%              case 'Amery' 
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
% 
%     orbitalInfo=orbitalInfo(1:ind-1);
%      
%     %Save
% 
%     eval([variate_cut '=orbitalInfo']);
%     fileName=strcat(variate_cut,'.mat');
%     filePath=strcat(StoragePath,num2str(year),'\Cut\');
%     if ~exist(filePath,'dir')
%         mkdir(filePath)
%     end
%     save([filePath,fileName],variate_cut);
%     clear raw;         %清除原始数据变量  
%   clear -regexp ^Cut;  %清除已经保存的裁剪数据变量
% end

%% 2.Remove redundant orbital data that the orbital number is identical.   
% year=2011;
% for i=1:12  
%     name_cut=strcat('Cut',num2str(year),num2str(i,'%02d'));
%     load(strcat(StoragePath,num2str(year),'\Cut\',name_cut));
%     cut=eval(strcat(name_cut,';'));
%     on=cell2mat({cut(:).orbitNum}).';
%     don=getDuplicates(on);
%     for ii=1:size(don,1)
%        on=cell2mat({cut(:).orbitNum}).';
%        b=find(on==don(ii));  
%        cut(b(2:end))=[];
%     end
%     eval([name_cut '=cut']);
%     fileName=strcat(name_cut,'.mat');
%     filePath=strcat(StoragePath,num2str(year),'\Cut\');
%     if ~exist(filePath,'dir')
%         mkdir(filePath)
%     end
%     save([filePath,fileName],name_cut);
%     clear -regexp ^Cut;  %清除已经保存的裁剪数据变量
% end

%% 3.Dividing data into ascending and descending tracks

% for i=1:12   %Month 
%     Ascend=[];
%     
%     Descend=[];
%     variate_cut=strcat('Cut',num2str(year),num2str(i,'%02d'));
%     variate_A=strcat(Region,'_A',num2str(year),num2str(i,'%02d'));
%     variate_D=strcat(Region,'_D',num2str(year),num2str(i,'%02d'));
%     
%     load(strcat(StoragePath,num2str(year),'\Cut\',variate_cut));
%     Cut=eval(variate_cut);
%     
%     for j=1:size(Cut,1)
%         cor=Cut(j).coordinate;
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

% clear;
%% 4. determine the crossover error in the same period (in one month)
bof_flag='BA'; % 'BA' means 'before adjustment' 'AA' mean 'after adjustment'

for k=1:10
    year=2010+k;   
    startMonth=1;
    endMonth=12  ;

    Ascend=strings([endMonth-startMonth+1,1]);
    Descend=strings([endMonth-startMonth+1,1]);

    for i=startMonth:endMonth
        month=num2str(i,'%02d');    
        ym=strcat(num2str(year),month);
        Ascend(i-startMonth+1)=ym;
        Descend(i-startMonth+1)=ym;
    end

    for i=1:size(Ascend,1)
        % Load and name 
        name_A=strcat(Region,'_A',Ascend(i));
        name_D=strcat(Region,'_D',Descend(i));
        name_CP=strcat(Region,'_A',Ascend(i),'_D',Descend(i));

        load(strcat(StoragePath,num2str(year),'\Ascend\',name_A));  
        load(strcat(StoragePath,num2str(year),'\Descend\',name_D));  
        % Solve crossovers 
        couple=JudgeCrossPoint(eval(name_A),eval(name_D));
        sizeOfCouple=size(couple,1);
        corssOver= struct('coordinate',[], 'orbitNum_A',[], 'orbitNum_D',[],...
            'altitude_A',[],'altitude_D',[], 'time_A',[],'time_D',[],'PDOP',[]); 
        CP=repmat(corssOver,[sizeOfCouple 1]);

        ind=1;  
        for j=1:sizeOfCouple
            out= MyCrossOver(couple(j,1),couple(j,2),Boundary,bof_flag);
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
        
        % CurrentPath is "..\Crossover" 
        % 'BA' means 'before adjustment'
        
        path=strcat(StoragePath,num2str(year),'\CP\',bof_flag,'\');   
      
        if ~exist(path,'dir')
           mkdir(path);
        end
        save(strcat(path,fileName),name_CP); 
        clear -regexp ^Ross
        clear couple
    end
end

