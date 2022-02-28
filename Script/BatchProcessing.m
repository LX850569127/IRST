% clear;

%% Preferences
Region='Ross';                                                 % Input experimental region
DataPath='Y:\CryoSat-2 Data\Baseline D\SIR_GDR\';              % Data Path
StoragePath=strcat('E:\Sync\Master\Project\Crossover\Variate\',Region,'\');   
load(strcat(Region,'Boundary.mat'));

%% 一、数据读取及裁剪
year=2011;
for i=1:12  %月份
    trackInfoGather=[];
    if i<10
        folderPath = strcat(DataPath, num2str(year),'\0', num2str(i));
        variate_cut=strcat('Cut',num2str(year),'0', num2str(i));
    else 
        folderPath = strcat(DataPath, num2str(year),'\', num2str(i));
       variate_cut=strcat('Cut',num2str(year), num2str(i));
    end 
    
    raw=NcFileRead(folderPath);   %输出该路径下所有文件的坐标信息

    for j=1:size(raw)             %对raw中每一段轨迹进行裁切，注意有的轨迹裁切后仍有两个弧段的情况
        temp=raw(j);
        longitude=getfield(temp,'longtitude');
        latitude=getfield(temp,'latitude');
        height=getfield(temp,'height');
        time=getfield(temp,'time');
        orbitNum=getfield(temp,'orbitNum');
        
        coor=[longitude,latitude,height,time];

        % 需要根据具体的实验区域来调整拟合区域，在第一步曲线拟合的过程中可以得到更好的拟合结果
         switch Region
            case 'Ronne' 
                intraArea=ScreenCoordinatasRegularly(coor,[min(Boundary(:,1))-2,max(Boundary(:,1)+2)],... 
                [min(Boundary(:,2))-1.1,max(Boundary(:,2)+1.25)]);     %Ronne ice shelf 
            case 'Ross' 
                intraArea=ScreenCoordinatasRegularly(coor,[min(Boundary(:,1))-1.5,max(Boundary(:,1)+1.5)],... 
                [min(Boundary(:,2))-1,max(Boundary(:,2)+1)]);          %Ross ice shelf 

                %罗斯冰架左下方区需进行的裁剪
                 if (size(intraArea)~=0)
                  for k=1:size(intraArea)
                     if  intraArea(k,2)<-83                        %根据该直线对数据左下方数据区域进行裁切
                          y=intraArea(k,1)*(-0.06717)-72.3805;     %Line function for clipping
                          if intraArea(k,2)<y
                              intraArea(k,:)=0;
                          end
                     end
                  end
                 index=find(intraArea(:,1)==0);
                 intraArea(index,:)=[];
                 end
             otherwise
                 warning('Unexpected Region');
         end
         
        if (size(intraArea,1)>9)       
            trackInfo = struct('coordinate',intraArea(:,1:2),'height',intraArea(:,3),'time',intraArea(:,4),'orbitNum',orbitNum);
            trackInfoGather=[trackInfoGather;trackInfo];                                %粗筛后的坐标数据
        end
        eval([variate_cut '=trackInfoGather']);
    end    
    
%   clear raw;         %清除原始数据变量
    fileName=strcat(variate_cut,'.mat');
    filePath=strcat(StoragePath,num2str(year),'\Cut\');
    if ~exist(filePath,'dir')
        mkdir(filePath)
    end
    save([filePath,fileName],variate_cut);
    
%   clear -regexp ^Cut;  %清除已经保存的裁剪数据变量
 end

%% 二、升降轨数据分离
% year=2011;
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
%     for j=47:size(Cut,1)
%         coor=Cut(j).coordinate;
%         height=Cut(j).height;
%         time=Cut(j).time;
%         orbitNum=Cut(j).orbitNum;
%         
%         if size(coor,1)>15          %剔除点数较少的轨迹
%         coor=preprocess(coor);       %数据预处理，剔除偏离较大的轨迹点 
% 
% %   判断轨道的升降轨(第一点的纬度与最后一点的纬度进行比较)
%        trackInfo = struct('coordinate',coor,'height',height,'time',time,'orbitNum',orbitNum);
%             if(coor(1,2)<coor(end,2))
%                 ascending_flag='A';
%                 trackInfo.flag_AD={ascending_flag};
%                 Ascend=[Ascend;trackInfo];
%             else 
%                 ascending_flag='D';
%                 trackInfo.flag_AD={ascending_flag};
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
year_A=2011;
startMonth_A=1;
endMonth_A=1;

year_D=2011;
startMonth_D=1;
endMonth_D=1;

Ascend=strings([endMonth_A-startMonth_A+1,1]);
Descend=strings([endMonth_A-startMonth_A+1,1]);
for i=startMonth_A:endMonth_A
    if i<10
        month=strcat('0',num2str(i));    
    else 
        month=num2str(i);  
    end
    ym_A=strcat(num2str(year_A),month);
    ym_D=strcat(num2str(year_D),month);
    Ascend(i-startMonth_A+1)=ym_A;
    Descend(i-startMonth_A+1)=ym_D;
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
    corssOvers=repmat(corssOver,[sizeOfCouple 1]);
    ind=1;
    for j=1:sizeOfCouple
        out= MyCrossOver(couple(j,1),couple(j,2),Boundary);
        if ~isempty(out)
            corssOvers(ind)=out;
            ind = ind+1;
        end
    end
    corssOvers=corssOvers(1:ind-1);
    % Save 
    eval(strcat(name_CP,'=corssOvers'));
    fileName=strcat(name_CP,'.mat');
    storagePath=strcat('.\Variate\',Region,'\CP\');   %CurrentPath is "..\Crossover"
    save(strcat(storagePath,fileName),name_CP); 
    clear -regexp ^Ross; 
end

year=2011;
% bar=waitbar(0,'正在计算交叉点');    %进度条
for k=1:1 %月份
    
% str=['正在计算交叉点',num2str(k),'月'];
% waitbar(k/12,bar,str);

    if k<10
        month=strcat('0',num2str(k));
    else 
         month=num2str(k);
    end 
    for i=1:1
        AllCrossOverPoint=[];        
        if i==1       %前一年升轨，后一年降轨
        AscendPeriod=strcat(num2str(year),month);
        DescendPeriod=strcat(num2str(year),month);
        else         %后一年升轨，前一年降轨
         AscendPeriod=strcat(num2str(year),month);
        DescendPeriod=strcat(num2str(year),month);
        end
        
        variate_A=strcat(Region,'_A',AscendPeriod);
        variate_D=strcat(Region,'_D',AscendPeriod);
        
        foldPath=strcat(StoragePath,num2str(year),'\');
        load(strcat(foldPath,'Ascend\',variate_A));
        load(strcat(foldPath,'Descend\',variate_D));    %加载对应的升降轨数据
        
        % 1判断是否存在交叉点,得到所有轨道的交叉点组合
        Combine=JudgeCrossPoint(eval(variate_A),eval(variate_D));
        variateName=strcat('CP', '_A',AscendPeriod(3:6),'_D',DescendPeriod(3:6));  %最后生成的交叉点集合的命名
        sizeOfCrossCombinations=size(Combine,1);
        
%         orbitNum=[];
%         for j=1:size(Combine,1)
%             orbitNum=[orbitNum;Combine(j,1).orbitNum,Combine(j,2).orbitNum];
%         end
%        bar=waitbar(0,'正在计算交叉点');
       % 2求交叉点的位置及两个不同时间的高程
        for j=1:sizeOfCrossCombinations
%             str=[month,'正在计算交叉点',num2str(j/sizeOfCrossCombinations*100),'%'];
%             waitbar(j/sizeOfCrossCombinations,bar,str);
            CrossOverPoint= MyCrossOver(Combine(j,1),Combine(j,2),Boundary);
            AllCrossOverPoint=[AllCrossOverPoint;CrossOverPoint];
        end
        eval([variateName '=AllCrossOverPoint']);
        fileName=strcat(variateName,'.mat');
        save([StoragePath,num2str(year),'\CP\',fileName],variateName); 
    end
end
% close(bar)
%% 五、求交叉点的精确位置  Ronne冰架
% region='RIS';
% load('RossBoundary')
% load('RossBoundary gap 35.mat');
% figure;
% plot(boundary(:,1),boundary(:,2),'k','MarkerSize',0.01,'HandleVisibility','off'); 
% set(gca,'fontsize',16);
% xlabel('经度/(°)','FontSize',16);
% ylabel('纬度/(°)','FontSize',16);
% hold on;
% year=2013;
% 
% % bar=waitbar(0,'正在计算交叉点');    %进度条
% for k=1:1 %月份
%     
% % str=['正在计算交叉点',num2str(k),'月'];
% % waitbar(k/12,bar,str);
% 
%     if k<10
%         month=strcat('0',num2str(k));
%     else 
%          month=num2str(k);
%     end 
%     for i=1:1
%         AllCrossOverPoint=[];        
%         if i==1       %前一年升轨，后一年降轨
%         AscendPeriod=strcat(num2str(year),month);
%         DescendPeriod=strcat(num2str(year),month);
%         else         %后一年升轨，前一年降轨
%          AscendPeriod=strcat(num2str(year),month);
%         DescendPeriod=strcat(num2str(year),month);
%         end
%         
%         variate_A=strcat(region,'_A',AscendPeriod);
%         variate_D=strcat(region,'_D',DescendPeriod);
%         foldPath=strcat('X:\Xiao\Master\Project\Crossover\Variate\',region,'\2013\');
%         load(strcat(foldPath,'Ascend\',variate_A));
%         load(strcat(foldPath,'Descend\',variate_D));    %加载对应的升降轨数据
%         
%         % 1判断是否存在交叉点,得到所有轨道的交叉点组合
% %         Combine=JudgeCrossPoint(eval(variate_RIS_A),eval(variate_RIS_D));
% %         variateName=strcat('CP2', '_A',AscendPeriod(3:6),'_D',DescendPeriod(3:6));  %最后生成的交叉点集合的命名
% %         sizeOfCrossCombinations=size(Combine,1);
% %       
% %         orbitNum=[];
% %         for j=1:sizeOfCrossCombinations
% %             orbitNum=[orbitNum;Combine(j,1).orbitNum,Combine(j,2).orbitNum];
% %         end
% %        bar=waitbar(0,'正在计算交叉点');
%        % 2求交叉点的位置及两个不同时间的高程
%         for j=199:199
% %             str=[month,'正在计算交叉点',num2str(j/sizeOfCrossCombinations*100),'%'];
% %             waitbar(j/sizeOfCrossCombinations,bar,str);
%             CrossOverPoint= MyCrossOver(Combine(j,1),Combine(j,2),AdjustBoundary);
%             AllCrossOverPoint=[AllCrossOverPoint;CrossOverPoint];
%         end
%         eval([variateName '=AllCrossOverPoint']);
%         fileName=strcat(variateName,'.mat');
%         save([StoragePath,'2013\CP\',fileName],variateName); 
%     end
% end
% % close(bar)
