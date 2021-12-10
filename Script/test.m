%% useful for debugging        

% figure;
% plot(adjustBoundary(:,1),adjustBoundary(:,2),'k','MarkerSize',0.01,'HandleVisibility','off'); 
% 
% A1=[166.539,-78.719];
% A2=[166.539,-82.755];
% A3=[199.961,-82.755];
% A4=[199.961,-78.719];
% rectangleA=[A1;A2;A3;A4;A1];
% 
% B1=[175.206,-82.755];
% B2=[175.206,-83.866];
% B3=[185.619,-83.866];
% B4=[185.619,-82.755];
% rectangleB=[B1;B2;B3;B4;B1];
% 
% C1=[199.961,-81.050];
% C2=[208.970,-81.050];

% C3=[208.970,-79.474];
% C4=[199.961,-79.474];
% rectangleC=[C1;C2;C3;C4;C1];
% 
% polygon=[A1;A2;B1;B2;B3;B4;A3;A4;A1];
% hold on;
% plot(polygon(:,1),polygon(:,2),'k','MarkerSize',0.02); 
% plot(rectangleB(:,1),rectangleB(:,2),'k','MarkerSize',0.02); 
% plot(rectangleC(:,1),rectangleC(:,2),'k','MarkerSize',0.02); 

%% 对共同存在的点进行比较

%1)提取出轨道号的集合
% AMTNum=zeros(size(CP_AMT_Line,1),2);
% Fixed5Num=zeros(size(Fixed5_Line,1),2);
% Fixed35Num=zeros(size(Fixed35_Line,1),2);
% DynamicNum=zeros(size(Dynamic,1),2);
% 
% for i=1:size(AMTNum,1)
%     AMTNum(i,:)=CP_AMT_Line(i).orbitNum;
% end
% for i=1:size(Fixed5Num,1)
%     Fixed5Num(i,:)=Fixed5_Line(i).orbitNum;
% end
% for i=1:size(Fixed35Num,1)
%     Fixed35Num(i,:)=Fixed35_Line(i).orbitNum;
% end
% for i=1:size(DynamicNum,1)
%     DynamicNum(i,:)=Dynamic(i).orbitNum;
% end
% 
% %把共同点的轨道号提取出来
% A=ismember(AMTNum,Fixed5Num,'rows');    
% mutual1=AMTNum(find(A==1),:);
% 
% A=ismember(mutual1,Fixed35Num,'rows');
% mutual2=mutual1(find(A==1),:);
% 
% A=ismember(mutual2,DynamicNum,'rows');
% mutual=mutual2(find(A==1),:);
% 
% %根据轨道号提取出每种计算方法共有点的位置精度
% commonAMT=[];
% A=ismember(AMTNum,mutual,'rows');
% for i=1:size(A,1)
%      if A(i)
%            commonAMT=[commonAMT;CP_AMT_Line(i)];
%      end
% end
% 
% commonFixed5=[];
% A=ismember(Fixed5Num,mutual,'rows');
% for i=1:size(A,1)
%      if A(i)
%            commonFixed5=[commonFixed5;Fixed5_Line(i)];
%      end
% end
% 
% commonFixed35=[];
% A=ismember(Fixed35Num,mutual,'rows');
% for i=1:size(A,1)
%      if A(i)
%            commonFixed35=[commonFixed35;Fixed35_Line(i)];
%      end
% end
% 
% commonDynamic=[];
% A=ismember(DynamicNum,mutual,'rows');
% for i=1:size(A,1)
%      if A(i)
%            commonDynamic=[commonDynamic;Dynamic(i)];
%      end
% end

%% 测试先计算出所有点再根据边界进行剔除

% 计算过程未进行边界剔除的点
% CP2_A1301_D1301=AllCrossOverPoint;
% coor=zeros(size(CP2_A1301_D1301,1),4);
% for i=1:size(CP2_A1301_D1301,1)
%     coordinate=CP2_A1301_D1301(i).coordinate;
%     orbitNum=double(CP2_A1301_D1301(i).orbitNum);
%     coor(i,:)=[coordinate,orbitNum];
% end
% 
% A=inross(coor(:,1),coor(:,2),adjustBoundary);
% CP2_A1301_D1301=CP2_A1301_D1301(find(A==1),:);

% coor2=coor(find(A==1),:);
% 
% coor2=coor2(:,3:4);
% B=ismember(AMT,coor2,'rows');
% C=AMT(find(B==0),:);       %AMT多出固定值5的点


%% 对ROSS边界数据进行稀释
% boundary=adjustBoundary;
% 
% i=find(round(adjustBoundary(:,2),4)==-74.8235);
% FilchneBoundary(i,:);
% 
% ind=[1:50:size(adjustBoundary,1)];
% 
% temp=ind(5500:end);
% ind=ind(1:5496);
% ind=[ind,192342:3:192460,temp];


% 为了增加拐角处的几个点，需要对ind进行调整

% boundary=adjustBoundary(ind,:);
% %绘制稀释前后边界数据的对比图
% figure;
% plot(adjustBoundary(:,1),adjustBoundary(:,2),'k','MarkerSize',0.01,'HandleVisibility','off'); 
% hold on;
% plot(boundary(:,1),boundary(:,2),'r','MarkerSize',0.01,'HandleVisibility','off'); 

%% 绘制龙尼冰架交叉点分布图
% figure;
% load('FilchneBoundary.mat');
% plot(FilchneBoundary(:,1),FilchneBoundary(:,2),'k');  %绘制冰架的边界图
% hold on;
% plot(boundary(:,1),boundary(:,2),'r','MarkerSize',0.01); 
% % 绘制升轨
% 
% for i=1:149
%    cor_A=FIL_A201101(i).coordinate;
%    scatter(cor_A(:,1),cor_A(:,2),2,[241 64 64]/255,'filled');
% end
% 
% for i=1:149
%    cor_D=FIL_D201101(i).coordinate;
%    scatter(cor_D(:,1),cor_D(:,2),2,[26 111 223]/255,'filled');
% end
% 
% cor=zeros(size(AllCrossOverPoint,1),2);
% for i=1:size(AllCrossOverPoint,1)
%     cor(i,:)=AllCrossOverPoint(i).coordinate;
% end
% 
% scatter(cor(:,1),cor(:,2)); 
%%  寻找相交但是未求解到交点的情况
% for i=1:size(FIL_D201101,1)
%        cor_A=FIL_D201101(i).coordinate;
%        cor_A=cor_A(:,1:2);
%        d=abs(cor_A(:,1)-276.419)+abs(cor_A(:,2)-(-78.4929));
%        if min(d)<=0.001
%            a=1;
%        end
% end

% orbitCom=zeros(size(Combine,1),2);
% for i=1:size(Combine,1)
%        orbitCom(i,:)=[Combine(i,1).orbitNum,Combine(i,2).orbitNum];
% end

%% 同一轨道号出现两条轨迹的原因
% 
% longtitude=raw(52).longtitude;
% longtitude(longtitude<0)=180+(180-abs(longtitude(longtitude<0)));  %对经度进行归化，西经改为正方向上的东经
% coor=RIS_A201303(44).coordinate;
% figure;
% % adjustBoundary(adjustBoundary(:,1)>180)=-(360-adjustBoundary(adjustBoundary(:,1)>180));
% plot(adjustBoundary(:,1),adjustBoundary(:,2),'k','MarkerSize',0.01,'HandleVisibility','off'); 
% hold on;
% scatter(coor(:,1),coor(:,2));
% 
% coor=RIS_D201303(49).coordinate;
% hold on;
% scatter(coor(:,1),coor(:,2)); 
% scatter(coor(91400:216000,1),coor(91400:216000,2)); 
% 
% longtitude=raw(51).longtitude;
% longtitude(longtitude<0)=180+(180-abs(longtitude(longtitude<0)));  %对经度进行归化，西经改为正方向上的东经
% coor=[longtitude,raw(51).latitude,raw(51).time];
% hold on;
% scatter(coor(:,1),coor(:,2),10); 
% 
% % time=raw(52).time;
% % day=time(216000)/60/60/24-(365*13+4)-59;
% % b=(day-floor(day))*24;
% % c=(b-floor(b))*60;
% longtitude=raw(53).longtitude;
% longtitude(longtitude<0)=180+(180-abs(longtitude(longtitude<0)));  %对经度进行归化，西经改为正方向上的东经
% coor=[longtitude,raw(53).latitude,raw(53).time];
% hold on;
% scatter(coor(:,1),coor(:,2),2); 

%% 数据的预处理测试

% coorA=RIS_A201306(5,1).coordinate;
% 
% disA=zeros(size(coorA,1),2);
% 
% 
% for i=1:size(coorA,1)
%     if i==1
%        disA(i,:)=SphereDist([coorA(1,1),coorA(1,2)],[coorA(2,1),coorA(2,2)])*1000;
%     elseif i==size(coorA,1)
%        disA(i,:)=SphereDist([coorA(i,1),coorA(i,2)],[coorA(i-1,1),coorA(i-1,2)])*1000;
%     else 
%        disA(i,1)=SphereDist([coorA(i,1),coorA(i,2)],[coorA(i-1,1),coorA(i-1,2)])*1000;   %与前一点的距离
%        disA(i,2)=SphereDist([coorA(i,1),coorA(i,2)],[coorA(i+1,1),coorA(i+1,2)])*1000;   %与后一点的距离
%     end
% end
% sd=std(disA(2:end,1));
% meanVal=mean(disA(2:end,1));

%尝试一下两点
% disA=zeros(size(coorA,1),4);
% for i=1:size(coorA,1)
%     if i==1
%        disA(i,1:2)=SphereDist([coorA(1,1),coorA(1,2)],[coorA(2,1),coorA(2,2)])*1000;
%        disA(i,3:4)=SphereDist([coorA(1,1),coorA(1,2)],[coorA(3,1),coorA(3,2)])*1000;
%     elseif i==2
%       disA(i,1:2)=SphereDist([coorA(1,1),coorA(1,2)],[coorA(2,1),coorA(2,2)])*1000;
%       disA(i,3)=SphereDist([coorA(i,1),coorA(i,2)],[coorA(i+1,1),coorA(i+1,2)])*1000;
%       disA(i,4)=SphereDist([coorA(i,1),coorA(i,2)],[coorA(i+2,1),coorA(i+2,2)])*1000;
%     elseif i==size(coorA,1)-1
%       disA(i,1)=SphereDist([coorA(i,1),coorA(i,2)],[coorA(i-2,1),coorA(i-2,2)])*1000;
%       disA(i,2)=SphereDist([coorA(i,1),coorA(i,2)],[coorA(i-1,1),coorA(i-1,2)])*1000;
%       disA(i,3:4)=SphereDist([coorA(i,1),coorA(i,2)],[coorA(i+1,1),coorA(i+1,2)])*1000;
%     elseif i==size(coorA,1)
%       disA(i,1:2)=SphereDist([coorA(i,1),coorA(i,2)],[coorA(i-2,1),coorA(i-2,2)])*1000;
%       disA(i,3:4)=SphereDist([coorA(i,1),coorA(i,2)],[coorA(i-1,1),coorA(i-1,2)])*1000;
%     else 
%       disA(i,1)=SphereDist([coorA(i,1),coorA(i,2)],[coorA(i-2,1),coorA(i-2,2)])*1000;
%       disA(i,2)=SphereDist([coorA(i,1),coorA(i,2)],[coorA(i-1,1),coorA(i-1,2)])*1000;
%       disA(i,3)=SphereDist([coorA(i,1),coorA(i,2)],[coorA(i+1,1),coorA(i+1,2)])*1000;
%       disA(i,4)=SphereDist([coorA(i,1),coorA(i,2)],[coorA(i+2,1),coorA(i+2,2)])*1000;
%     end
% end
% disA1=mean(disA(:,1:2),2);
% disA2=mean(disA(:,3:4),2);
% disA=[disA1,disA2];
% sd=std(disA(:));
% meanVal=mean(disA(:));
% % % 

% [i]=find(disA(:,1)>=(meanVal+3*sd)&disA(:,2)>=(meanVal+3*sd));
% coorA_errol=coorA(i,:);
% coorA(i,:)=[];
% figure;
% plot(boundary(:,1),boundary(:,2),'k','MarkerSize',0.01,'HandleVisibility','off'); 
% hold on;
% scatter(coorA(:,1),coorA(:,2),4,[241 64 64]/255,'filled','HandleVisibility','off');
% hold on;
% scatter(coorA_errol(:,1),coorA_errol(:,2),20,[26 111 223]/255,'filled');
% scatter(res.',coorA(:,2),5,[26 111 223]/255,'filled');

% function res = MovingAverage(input,N)
% %% input为平滑前序列(列向量和行向量均可)；N为平滑点数（奇数）；res返回平滑后的序列(默认行向量)。
% sz = max(size(input));
% n = (N-1)/2;
% res = [];
% for i = 1:length(input)
%     if i <= n
%         res(i) = sum(input(1:2*i-1))/(2*i-1);
%     elseif i < length(input)-n+1
%         res(i) = sum(input(i-n:i+n))/(2*n+1);
%     else
%         temp = length(input)-i+1;
%         res(i) = sum(input(end-(2*temp-1)+1:end))/(2*temp-1);
%     end
% end
% end

%绘制

% [i,j] = find(repmat(min(x1(1:end-1),x1(2:end)),1,n2) <= ...
%     
% coorD=Combine(486,2).coordinate;


%% 对比AMT方法数据预处理后减少的5个点

%数据预处理前
% AMTNum=zeros(size(AMT,1),2);
% for i=1:size(AMT,1)
%     AMTNum(i,:)=AMT(i).orbitNum;
% end

% 数据预处理后
% AMTProNum=zeros(size(AMTPro,1),2);
% for i=1:size(AMTPro,1)
%     AMTProNum(i,:)=AMTPro(i).orbitNum;
% end
% 
% C=unique([AMTNum;AMTProNum],'rows'); 
% Lia = ismember(C,AMTProNum,'rows');
% d=C(find(Lia==0),:);

% % 将combine组合的轨道号提取出来，便于查找
% sizeOfCombine=size(Combine,1);
% orbitNumCom=zeros(sizeOfCombine,2);
% for i=1:sizeOfCombine
%     orbitNumCom(i,1)=Combine(i,1).orbitNum;
%     orbitNumCom(i,2)=Combine(i,2).orbitNum;
% end

% cor_A=Combine(1177,1).coordinate;
% cor_D=Combine(1177,2).coordinate;
% figure;
% plot(boundary(:,1),boundary(:,2),'k','MarkerSize',0.01,'HandleVisibility','off'); 
% hold on;
% scatter(afCoor(652,1),afCoor(652,2),100,'p','k','filled');
% scatter(cor_A(:,1),cor_A(:,2),4,[241 64 64]/255,'filled','HandleVisibility','off');
% scatter(cor_D(:,1),cor_D(:,2),4,[26 111 223]/255,'filled');

%%
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

%% 固定值迭代示意图
% figure;
% box on; 
% hold on;
% Combine=JudgeCrossPoint(RIS_A201301,RIS_D201301);
% sizeOfCrossCombinations=size(Combine,1);

% for j=20:20
%     CrossOverPoint= MyCrossOver(Combine(j,1),Combine(j,2),AdjustBoundary);
%     AllCrossOverPoint=[AllCrossOverPoint;CrossOverPoint];
% end
% set(gca,'fontsize',15);
% xlabel('经度/(°)','FontSize',16);
% ylabel('纬度/(°)','FontSize',16);

%% CryoSat-2 Coordinate read
% figure;
% plot(boundary(:,1),boundary(:,2),'k','MarkerSize',0.01,'HandleVisibility','off'); 
% hold on;
% for i=1:90
%     coor=FIL_A201301(i).coordinate;
%     scatter(coor(:,1),coor(:,2),2,[26 111 223]/255,'filled');
% end
% 
% coorA=[];
% for i=1:90
%     coor=FIL_D201301(i).coordinate;
%     coorA=[coorA;coor(:,1:2)];
% end
% ind=[1:2:size(coorA,1)];
% coorA=coorA(ind,:);
% scatter(coorA(:,1),coorA(:,2),2,[26 111 223]/255,'filled');

%% Location deviation 
% figure;
% plot(boundary(:,1),boundary(:,2),'k','MarkerSize',0.01,'HandleVisibility','off'); 
% hold on;
% % Combine=JudgeCrossPoint(RIS_A201301,RIS_D201301);
% sizeOfCrossCombinations=size(Combine,1);   
% AllCrossOverPoint=[];
% for j=1500:1500
%    CrossOverPoint= MyCrossOver(Combine(j,1),Combine(j,2),AdjustBoundary);
%    AllCrossOverPoint=[AllCrossOverPoint;CrossOverPoint];
% end
% 
% set(gca,'fontsize',15);
% xlabel('经度/(°)','FontSize',16);
% ylabel('纬度/(°)','FontSize',16);
%% Extra points relative to the fixed 5
% orbitNumSet=[];
% year=2013;
% for i=1:1
%     
%     if i<10
%         month=strcat('0',num2str(i));
%     else 
%          month=num2str(i);
%     end 
%    AscendPeriod=strcat(num2str(year),month);
%    DescendPeriod=strcat(num2str(year),month);
%   variateName=strcat('CP2', '_A',AscendPeriod(3:6),'_D',DescendPeriod(3:6));  %最后生成的交叉点集合的命名
%   CP=eval(variateName);
%   orbitNum=[];
%   for j=1:size(CP,1)
%       orbitNum=[orbitNum;CP(j).orbitNum];
%   end
%   orbitNumSet=[orbitNumSet;orbitNum];
% end

% C=unique([orbitNumSet_AMTPro;orbitNumSet_Fixed35],'rows'); 
% Lia = ismember(C,orbitNumSet_Fixed35,'rows');
% d=C(find(Lia==0),:);

% % Pick extra points
% coor=[];
% year=2013;
% for i=1:12
%     if i<10
%         month=strcat('0',num2str(i));
%     else 
%          month=num2str(i);
%     end 
%    AscendPeriod=strcat(num2str(year),month);
%    DescendPeriod=strcat(num2str(year),month);
%   variateName=strcat('CP2', '_A',AscendPeriod(3:6),'_D',DescendPeriod(3:6));  %最后生成的交叉点集合的命名
%   CP=eval(variateName);
%   for j=1:size(CP,1)
%       orbitNum=CP(j).orbitNum;
%      a= ismember(orbitNum,d,'rows');
%     if ismember(orbitNum,d,'rows')
%            coor=[coor;CP(j).coordinate];
%     end
%   end
% end
% plot extra points
% figure;
% plot(FilchneBoundary(:,1),FilchneBoundary(:,2),'k','MarkerSize',0.01,'HandleVisibility','off'); 
% hold on;
% scatter(coor(:,1),coor(:,2),20,[127 140 141]/255,'filled');

%% Plot cursory position solution process
% figure;
% % plot(boundary(:,1),boundary(:,2),'k','MarkerSize',0.01,'HandleVisibility','off'); 
% hold on;
% box on;
% % Combine=JudgeCrossPoint(RIS_A201301,RIS_D201301);
% sizeOfCrossCombinations=size(Combine,1);   
% AllCrossOverPoint=[];
% for j=666:666
%    CrossOverPoint= MyCrossOver(Combine(j,1),Combine(j,2),AdjustBoundary);
%    AllCrossOverPoint=[AllCrossOverPoint;CrossOverPoint];
% end
% set(gca,'fontsize',15);
% xlabel('经度/(°)','FontSize',16);
% ylabel('纬度/(°)','FontSize',16);

%% Plot cursory position solution process
% ncread('X:\Xiao\Master\Project\Crossover\Plot\gmtDraw\ExtraPointsDistribute\antarctic_DEM.nc','x_range');
% a=ncinfo('X:\Xiao\Master\Project\Crossover\Plot\gmtDraw\ExtraPointsDistribute\antarctic_DEM.nc');   %文件头信息
% 
% nc=ncinfo('Y:\DEM\Slater DEM\Antarctica_Cryosat2_1km_DEMv1.0.nc');
% x=ncread('Y:\DEM\Slater DEM\Antarctica_Cryosat2_1km_DEMv1.0.nc','x');

%% plot ClipTrace of Ronne 
% figure;
% plot(RonneBoundary(:,1),RonneBoundary(:,2),'k','MarkerSize',0.01,'HandleVisibility','off'); 
% hold on;
% for i=1:size(Cut201302,1)
%     cor=Cut201302(i).coordinate;
%     scatter(cor(:,1),cor(:,2),5,[127 140 141]/255,'filled');
% end
%% Clip Region Of Roone 
% figure;  
% plot(RonneBoundary(:,1),RonneBoundary(:,2),'k','MarkerSize',0.01,'HandleVisibility','off'); 
% hold on;
% for i=1:size(Cut201302,1)
%     cor=Cut201302(i).coordinate;
%     scatter(cor(:,1),cor(:,2),5,[127 140 141]/255,'filled');
% end

%% 绘制拟合曲线及概略位置图
figure;
hold on;
box on;
set(gca,'fontsize',14);
xlabel('Longitude[ ° ]','FontSize',14);
ylabel('Latitude[ ° ]','FontSize',14);
sizeOfCrossCombinations=size(Combine,1);
for j=310:310
%     str=[month,'正在计算交叉点',num2str(j/sizeOfCrossCombinations*100),'%'];
%     waitbar(j/sizeOfCrossCombinations,bar,str);
    CrossOverPoint= MyCrossOver(Combine(j,1),Combine(j,2),AdjustBoundary);
    AllCrossOverPoint=[AllCrossOverPoint;CrossOverPoint];
end
