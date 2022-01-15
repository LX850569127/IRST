% clear;
Region='Ross';                                                 % Input experimental region
DataPath='Y:\CryoSat-2 Data\Baseline D\SIR_GDR\';              % Data Path
StoragePath=strcat('E:\Sync\Master\Project\Crossover\Variate\',Region,'\');   
load(strcat(Region,'Boundary.mat'));


%% 一、数据读取及裁剪
% year=2011;
% for i=3:12  %月份
%     trackInfoGather=[];
%     if i<10
%         folderPath = strcat(DataPath, num2str(year),'\0', num2str(i));
%         variate_cut=strcat('Cut',num2str(year),'0', num2str(i));
%     else 
%         folderPath = strcat(DataPath, num2str(year),'\', num2str(i));
%        variate_cut=strcat('Cut',num2str(year), num2str(i));
%     end 
%     
%     raw=NcFileRead(folderPath);   %输出该路径下所有文件的坐标信息
% 
%     for j=1:size(raw)             %对raw中每一段轨迹进行裁切，注意有的轨迹裁切后仍有两个弧段的情况
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
%                 range_Coordinate=ScreenCoordinatasRegularly(coor,[min(Boundary(:,1))-2,max(Boundary(:,1)+2)],... 
%                 [min(Boundary(:,2))-1.1,max(Boundary(:,2)+1.25)]);     %Ronne ice shelf 
%             case 'Ross' 
%                 range_Coordinate=ScreenCoordinatasRegularly(coor,[min(Boundary(:,1))-1.5,max(Boundary(:,1)+1.5)],... 
%                 [min(Boundary(:,2))-1,max(Boundary(:,2)+1)]);          %Ross ice shelf 
% 
%                 %罗斯冰架左下方区需进行的裁剪
%                  if (size(range_Coordinate)~=0)
%                   for k=1:size(range_Coordinate)
%                      if  range_Coordinate(k,2)<-83    %根据该直线对数据左下方数据区域进行裁切,仅
%                           y=range_Coordinate(k,1)*(-0.06717)-72.3805;  
%                           if range_Coordinate(k,2)<y
%                               range_Coordinate(k,:)=0;
%                           end
%                      end
%                   end
%                  index=find(range_Coordinate(:,1)==0);
%                  range_Coordinate(index,:)=[];
%                  end
%              otherwise
%                  warning('Unexpected Region');
%          end
%          
%         if (size(range_Coordinate,1)>9)
%             trackInfo = struct('coordinate',range_Coordinate,'orbitNum',orbitNum);
%             trackInfoGather=[trackInfoGather;trackInfo];                                %粗筛后的坐标数据
%         end
%         eval([variate_cut '=trackInfoGather']);
%    
%     end
% %     clear raw;         %清除原始数据变量
%   
%     fileName=strcat(variate_cut,'.mat');
%     filePath=strcat(StoragePath,num2str(year),'\Cut\');
%     save([filePath,fileName],variate_cut);
%     
% %   clear -regexp ^Cut;  %清除已经保存的裁剪数据变量
% end
% 
% % 二、升降轨数据分离
% year=2011;
% for i=12:12   %Month 
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
%         if size(cor,1)>12          %剔除点数较少的轨迹
%         cor=preprocess(cor);       %数据预处理，剔除偏离较大的轨迹点 
% 
% %   判断轨道的升降轨(第一点的纬度与最后一点的纬度进行比较)
%             if(cor(1,2)<cor(end,2))
%                 ascending_flag='A';
%                 trackInfo = struct('coordinate',cor,'ascending_flag',{ascending_flag},'orbitNum',orbitNum);
%                 Ascend=[Ascend;trackInfo];
%             else 
%                 ascending_flag='D';
%                 trackInfo = struct('coordinate',cor,'ascending_flag',{ascending_flag},'orbitNum',orbitNum);
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

year=2011;
% bar=waitbar(0,'正在计算交叉点');    %进度条
for k=3:12 %月份
    
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
