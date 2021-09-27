%一、数据读取
% bar=waitbar(0,'正在读取数据');
% for i=1:12
%     if i<10
%       folderPath = strcat('D:\CryoSat_2\GDR\2013\0', num2str(i));
%       variate=strcat('Raw20130', num2str(i));
%     else
%       folderPath = strcat('D:\CryoSat_2\GDR\2013\', num2str(i));
%       variate=strcat('Raw2013', num2str(i));
%     end
%     Output_TrackInfo=NcFileRead(folderPath);   %输出该路径下所有文件的坐标信息
%     eval([variate '=Output_TrackInfo']);
%     waitbar(i/12,bar);
% end
% close(bar);

%%
%二、数据处理 数据读取以及数据裁剪

%  批量裁剪 
% % clear;
% % load('AdjustBoundary.mat');
% year=2013;
% for i=3:3   %月份
%     trackInfoGather=[];
%     
%     if i<10
%        folderPath = strcat('X:\CryoSat-2 Data\Baseline D\SIR_GDR\', num2str(year),'\0', num2str(i));
%         variate_cut=strcat('Cut20130', num2str(i));
%     else 
%         folderPath = strcat('X:\CryoSat-2 Data\Baseline D\SIR_GDR\', num2str(year),'\', num2str(i));
%         variate_cut=strcat('Cut2013', num2str(i));
%     end 
%     
% %     raw=NcFileRead(folderPath);   %输出该路径下所有文件的坐标信息
% 
%     %%
%     for j=1:size(raw)    %对raw中每一段轨迹进行裁切，注意有的轨迹裁切后仍有两个弧段的情况
%       temp=raw(j);
%       longtitude=getfield(temp,'longtitude');
%       latitude=getfield(temp,'latitude');
%       height=getfield(temp,'height');
%       time=getfield(temp,'time');
%       orbitNum=getfield(temp,'orbitNum');
%    
%       coor=[longtitude,latitude,height,time];
%       range_Coordinate=ScreenCoordinatasRegularly(coor,[min(adjustBoundary(:,1)),max(adjustBoundary(:,1))],...
%           [min(adjustBoundary(:,2)),max(adjustBoundary(:,2)+1.5)]);
%       
% %          figure;    %调试 查看满足条件时是否存在两条轨迹
% %          plot(adjustBoundary(:,1),adjustBoundary(:,2),'k','MarkerSize',0.01,'HandleVisibility','off'); 
% %          hold on;
% %          scatter(range_Coordinate(:,1),range_Coordinate(:,2));    
%          
%       if (size(range_Coordinate)~=0)
%           for k=1:size(range_Coordinate)
%              if  range_Coordinate(k,2)<-83 %根据该直线对数据左下方数据区域进行裁切
%                   y=range_Coordinate(k,1)*(-0.06717)-72.3805;  
%                   if range_Coordinate(k,2)<y
%                       range_Coordinate(k,:)=0;
%                   end
%              end
%           end
%          index=find(range_Coordinate(:,1)==0);
%          range_Coordinate(index,:)=[];
%            trackInfo = struct('coordinate',range_Coordinate,'orbitNum',orbitNum);
%               trackInfoGather=[trackInfoGather;trackInfo];                                %粗筛后的坐标数据
%     end 
%    eval([variate_cut '=trackInfoGather']);
%     end
%     clear raw;         %清除原始数据变量
% %         for q=1:size(coor,2)
% %             range_Coordinate=coor(q).coordinate;
% %             if (size(range_Coordinate)~=0)
% %                 for k=1:size(range_Coordinate)
% %                    if  range_Coordinate(k,2)<-83 %根据该直线对数据左下方数据区域进行裁切
% %                         y=range_Coordinate(k,1)*(-0.06717)-72.3805;  
% %                         if range_Coordinate(k,2)<y
% %                             range_Coordinate(k,:)=0;
% %                         end
% %                    end
% %                 end
% %              index=find(range_Coordinate(:,1)==0);
% %              range_Coordinate(index,:)=[];
% %              trackInfo = struct('coordinate',range_Coordinate,'orbitNum',orbitNum);
% %              trackInfoGather=[trackInfoGather;trackInfo];                                %粗筛后的坐标数据
% %             end 
% %         end   
% %     end
% %     %%
% %     eval([variate_cut '=trackInfoGather']);
% %     clear raw;         %清除原始数据变量
%     fileName=strcat(variate_cut,'.mat');
%     filePath=strcat('Y:\LiXiao\新验证方法试验区\变量\数据\',num2str(year),'\Cut\');
%     save([filePath,fileName],variate_cut);
%     clear -regexp ^Cut;  %清除已经保存的裁剪数据变量
% end

% 批量保存
% for i=1:12
%     if i<10
%       variate=strcat('Cut20160', num2str(i));
%     else
%       variate=strcat('Cut2016', num2str(i));
%     enda
%      fileName=strcat(variate,'.mat');
%     save(fileName,variate);
% end

% 三、升降轨数据分离
% for i=3:3  %月
%     RIS_A=[];
%     RIS_D=[];
%     if i<10
%         variate_cut=strcat('Cut20130', num2str(i));
%         variate_RISA=strcat('RIS_A20130', num2str(i));
%         variate_RISD=strcat('RIS_D20130', num2str(i));
%     else 
%         variate_cut=strcat('Cut2013', num2str(i));
%         variate_RISA=strcat('RIS_A2013', num2str(i));
%         variate_RISD=strcat('RIS_D2013', num2str(i));
%     end  
%     Cut=eval(variate_cut);
%     for j=1:size(Cut,1)
%         cor=Cut(j).coordinate;
%         orbitNum=Cut(j).orbitNum;
%         if size(cor,1)>5   %剔除点数较少的轨迹
%     %     判断轨道的升降轨(第一点的纬度与最后一点的纬度进行比较)
%             if(cor(1,2)<cor(end,2))
%                 ascending_flag='A';
%                 trackInfo = struct('coordinate',cor,'ascending_flag',{ascending_flag},'orbitNum',orbitNum);
%                 RIS_A=[RIS_A;trackInfo];
%             else 
%                 ascending_flag='D';
%                 trackInfo = struct('coordinate',cor,'ascending_flag',{ascending_flag},'orbitNum',orbitNum);
%                 RIS_D=[RIS_D;trackInfo]; 
%             end
%         end
%     end
%    eval([variate_RISA '=RIS_A']);
%    eval([variate_RISD '=RIS_D']);
%    
%    fileNameA=strcat(variate_RISA,'.mat');
%    save(['Y:\LiXiao\新验证方法试验区\变量\数据\2013\Ascend\', fileNameA],variate_RISA);
%    fileNameD=strcat(variate_RISD,'.mat');
%    save(['Y:\LiXiao\新验证方法试验区\变量\数据\2013\Descend\', fileNameD],variate_RISD);
% end
%% 四、求交叉点的精确位置
load('以35为间隔稀释后的边界数据.mat');
load('原始边界数据')
figure;
plot(adjustBoundary(:,1),adjustBoundary(:,2),'k','MarkerSize',0.01,'HandleVisibility','off'); 
hold on;

year=2013;
% bar=waitbar(0,'正在计算交叉点');    %进度条
for k=3:3  %月份

str=['正在计算交叉点',num2str(k),'月'];
% waitbar(k/12,bar,str);

    if k<10
        month=strcat('0',num2str(k));
    else 
         month=num2str(k);
    end 
    for i=1:1
        AllCrossOverPoint=[];        

        if i==1       %前一年升轨，后一年降轨
        AscendPeriod=strcat('13',month);
        DescendPeriod=strcat('13',month);
        else         %后一年升轨，前一年降轨
         AscendPeriod=strcat('13',month);
        DescendPeriod=strcat('13',month);
        end
        variate_RIS_A=strcat('RIS_A20',AscendPeriod);
        variate_RIS_D=strcat('RIS_D20',DescendPeriod);
        foldPath=('Y:\LiXiao\新验证方法试验区\变量\数据\2013\');
        
        load(strcat(foldPath,'Ascend\',variate_RIS_A));
        load(strcat(foldPath,'Descend\',variate_RIS_D));    %加载对应的升降轨数据
        
        % 1判断是否存在交叉点,得到所有轨道的交叉点组合
%         Combine=JudgeCrossPoint(eval(variate_RIS_A),eval(variate_RIS_D));
        variateName=strcat('CP2', '_A',AscendPeriod,'_D',DescendPeriod);  %最后生成的交叉点集合的命名
%         bar=waitbar(0,'正在计算交叉点');
        sizeOfCrossCombinations=size(Combine,1);
       % 2求交叉点的位置及两个不同时间的高程
        for j=1618:1618
%             str=[month,'正在计算交叉点',num2str(j/sizeOfCrossCombinations*100),'%'];
%             waitbar(j/sizeOfCrossCombinations,bar,str);
            CrossOverPoint= MyCrossOver(Combine(j,1),Combine(j,2),boundary);
            AllCrossOverPoint=[AllCrossOverPoint;CrossOverPoint];
        end
        
% coor=zeros(size(AllCrossOverPoint,1),4);
% for t=1:size(AllCrossOverPoint,1)
%     coordinate=AllCrossOverPoint(t).coordinate;
%     orbitNum=double(AllCrossOverPoint(t).orbitNum);
%     coor(t,:)=[coordinate,orbitNum];
% end
% 
% A=inross(coor(:,1),coor(:,2),boundary);
% CP2_A1301_D1301=AllCrossOverPoint(find(A==1),:);
%          
        eval([variateName '=AllCrossOverPoint']);
%         close(bar);
        fileName=strcat(variateName,'.mat');
        save(['G:\新验证方法试验区\变量\AMT优化后\', ...
            fileName],variateName);
    end
end

% 找到AMT方法能计算出来但是自己写的跨立交叉法计算不出来的情况
% orbitNum1=zeros(size(CP_AMT_Line,1),2);
% for i=1:size(CP_AMT_Line,1)
%     Num=CP_AMT_Line(i).orbitNum; 
%     orbitNum1(i,:)=Num;
% end
% 
% orbitNum2=zeros(size(CP,1),2);
% for i=1:size(CP,1)
%     Num=CP(i).orbitNum; 
%     orbitNum2(i,:)=Num;
% end
% 
% C=unique([orbitNum1;orbitNum2],'rows'); 
% 
% Lia = ismember(C,orbitNum2,'rows');
% d=C(find(Lia==0),:);

% % 将combine组合的轨道号提取出来，便于查找
% sizeOfCombine=size(Combine,1);
% orbitNumCom=zeros(sizeOfCombine,2);
% for i=1:sizeOfCombine
%     orbitNumCom(i,1)=Combine(i,1).orbitNum;
%     orbitNumCom(i,2)=Combine(i,2).orbitNum;
% end

