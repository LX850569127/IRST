


%% 推导间接平差方法的标准差
% format rat
% dhMeanMat=zeros(8,8);
% 
% numOfEquation=0;
% for i=1:size(dhMeanMat,2)-1
%     numOfEquation=numOfEquation+i;
% end
% 
% numOfX=size(dhMeanMat,1)-1;     % 参数个数
% B=zeros(numOfEquation,numOfX);
% L=zeros(numOfEquation,1);
% 
% index=1;     
% for i=1:size(dhMeanMat,1)-1                       % 行数循环
%      numOfObservations=size(dhMeanMat,2)-i;       % 行数与该行所对应的观测值个数的关系
%      startingColum=1+i;                           % 每行的起始循环列
%      for j=startingColum:size(dhMeanMat,2)        % 列数循环
%          if i==1
%              B(index,j-1)=1;
%          else
%              B(index,i-1)=-1;
%              B(index,j-1)=1;     
%          end
%          index=index+1;
%      end
% end
% 
% P=diag(ones(numOfEquation,1));
% 
% Q=inv(B.'*P*B);

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
% figure;
% hold on;
% box on;
% set(gca,'fontsize',14);
% xlabel('Longitude[ ° ]','FontSize',14);
% ylabel('Latitude[ ° ]','FontSize',14);
% sizeOfCrossCombinations=size(Combine,1);
% for j=310:310
% %     str=[month,'正在计算交叉点',num2str(j/sizeOfCrossCombinations*100),'%'];
% %     waitbar(j/sizeOfCrossCombinations,bar,str);
%     CrossOverPoint= MyCrossOver(Combine(j,1),Combine(j,2),AdjustBoundary);
%     AllCrossOverPoint=[AllCrossOverPoint;CrossOverPoint];
% end

%% 数据预处理优化测试

% cor=Cut201301(100).coordinate;
% figure;
% scatter(cor(:,1),cor(:,2),6,'filled');
% cor1=preprocess(cor);       %数据预处理，剔除偏离较大的轨迹点 
% hold on;
% 
% C=unique([cor;cor1],'rows'); 
% Lia = ismember(C,cor1,'rows');
% d=C(find(Lia==0),:);
% scatter(d(:,1),d(:,2),25,'r','filled');

% tic 
% n=200;
% A=500;
% a=zeros(n);
% parfor i=1:n
%     a(i)=max(abs(eig(rand(A))));
% end 
% toc


%%
% figure;
% hold on;
% for i=1:size(Cut201101,1)
%   temp=Cut201101(i).coordinate;
%   scatter(temp(:,1),temp(:,2),1,'r','filled');
% end    
% plot(Boundary(:,1),Boundary(:,2),'k','MarkerSize',0.01,'HandleVisibility','off'); 
% hold on;
% for i=1:size(CP2_A1101_D1101,1)
%   temp=CP2_A1101_D1101(i).coordinate;
%   scatter(temp(:,1),temp(:,2),10 ,'b','filled');
% end
% %%
% All_CP=load('CP_2013.txt');
% figure;
% colormap(CustomColormap) 
% plot(Boundary(:,1),Boundary(:,2),'k','MarkerSize',0.01,'HandleVisibility','off'); 
% hold on;
% scatter(All_CP(:,1),All_CP(:,2),15,abs(All_CP(:,3)),'filled'); 
% % a=load('Ross_5km_Grid_EDIT.dat');
% % scatter(a(:,1),a(:,2),20,'filled'); 
% %格网点绘制
% All_CP(:,3)=abs(All_CP(:,3));
% 
% 
% 
% 
% %% 计算平差有效次数
% CP=Ross_A201101_D201101;
% [altitude_A]={CP(:).altitude_A};
% [altitude_D]={CP(:).altitude_D};
% 
% % beforeAdjust=abs(cell2mat(altitude_A)-cell2mat(altitude_D));
% % afterAdjust=abs(cell2mat(altitude_A)-cell2mat(altitude_D));
% % success=find(afterAdjust<beforeAdjust);
% % failure=find(afterAdjust>beforeAdjust);
% % unchanged=find(afterAdjust==beforeAdjust);

%% grid test 
% rossGrid=load('Ross_5km_Grid_EDIT.dat');
% % load('RossBoundary');
% % 
% % figure;
% % plot(Boundary(:,1),Boundary(:,2));
% % hold on;
% 
% latitudeRow=sort(unique(rossGrid(:,2)),'descend');
% longitudeColumn=sort(unique(rossGrid(:,1)),'ascend');
% rows=size(latitudeRow,1);
% column=size(longitudeColumn,1);
% gridCell=cell(rows,column);
% for i=1:rows
%     for j=1:column
%         cor=[longitudeColumn(j),latitudeRow(i)];
%         if inpolygon(cor(1),cor(2),boundary(:,1),boundary(:,2))
%            gridCell{i,j}=[longitudeColumn(j),latitudeRow(i)];
%         else
%            gridCell{i,j}=[0,0];
%         end
%     end
% end
% 
% 
% for i=1:rows
%     for j=1:column
%         cor=[longitudeColumn(j),latitudeRow(i)];
%     end
% end
% 
% %% 生成格网边界数据
% 
% 
% a=load('Ross_5km_Grid_EDIT.dat');
% westS=min(longitudeColumn)-0.28/2;  % west starting point 
% eastE=max(longitudeColumn)+0.28/2;  % east ending point 
% southEnd=min(latitudeRow)-0.045/2;
% northEnd=max(latitudeRow)+0.045/2;    
% lat=(southEnd:0.045:northEnd);
% 
% Ax=ones(1,179)*westS;
% Ay=lat;
% Bx=ones(1,179)*eastE;
% By=lat;
% X=[Ax;Bx];
% Y=[Ay;By];
% 
% long=westS:0.28:eastE;
% X1=[long;long];
% Y1=[ones(1,195)*southEnd;ones(1,195)*northEnd];
% 
% figure;
% line(X,Y,'color','k','linewidth',0.01);     % 经度划分线
% hold on;
% line(X1,Y1,'color','k','linewidth',0.01);   % 纬度划分线
% plot(boundary(:,1),boundary(:,2));
% scatter(a(:,1),a(:,2));
% 


%% picking up the required grid cell 
% for i=1:size(rossGrid,1)
%     disp(i);
%     pickedGrid=[];
%     long=rossGrid(i).long;
%     lat=ones(size(long))*rossGrid(i).lat;
%     logicIndex=inpolygon(long,lat,Boundary(:,1),Boundary(:,2));
%     long1=long(logicIndex).';
%     
%     P1=[long1,ones(size(long1))*rossGrid(i).lat;];
%     pickedGrid=[pickedGrid;P1];
%     
%     long3=[];
%     long2=long(~logicIndex).';
%     P2=[long2,ones(size(long2))*rossGrid(i).lat];   
%     if ~isempty(P2)    
%         for j=1:size(P2,1)
%           d=distance(boundary(:,2),boundary(:,1),P2(j,2),P2(j,1))*pi/180*6367.5;
%           d=min(d);
%           if d<2.5^0.5*1.5
%               a=1;
%               long3=[long3;P2(j,1)];
%           end
%         end
%     end
%   
%     rossGrid(i).long=sort([P1(:,1);long3],1);
% end
% % % 
% % % 画格子网
% % 
% rossGridEdited = struct('lat',[], 'long',[],'longInterval',[]);    
% rossGridEdited=repmat(rossGridEdited,[179 1]);
% for i=1:size(rossGrid,1)   
%      rossGridEdited(i).lat=rossGrid(i).lat;
%      rossGridEdited(i).long=rossGrid(i).long;
%      rossGridEdited(i).longInterval=intervalLong(i);
% end

% 画格子网
% figure;
% plot(boundary(:,1),boundary(:,2));
% hold on;
% % 
% for i=1:size(rossGridEdited,1)   
%      disp(i);
%      long=rossGridEdited(i).long;
%      lat=ones(size(long))*rossGridEdited(i).lat;
%      scatter(long,lat,4,'filled');
%      w=rossGridEdited(i).longInterval;
%      h=0.045;
%      for j=1:size(long)      
%          x=long(j)-w/2;
%          y=lat(1)-h/2;
%          hold on;
%          rectangle('Position',[x,y,w,h])  %从点(x,y)开始绘制一个宽w高h的矩形，
%      end
% end
% a=rossGridEdited(94).long;
% rossGridEdited(94).long=a(1:139);

%   d=distance(Boundary(:,2),Boundary(:,1),-81.27,211.024)*pi/180*6367.5;
%   min(d);
% 
% 
% coor=cell2mat({Ross_2011_2012(:).coordinate}).';
% scatter(coor(1:2:67177,:),coor(2:2:67178,:));



%% 
% figure;
% Region='Ross'
% load(strcat(strcat('.\Variate\',Region,'\'),Region,'Boundary.mat'));
% load('E:\Sync\BaiduSyncdisk\Master\Data\Ronne\Ronne_inside_grid_5km.txt');
% plot(Boundary(1:end,1),Boundary(1:end,2),'k','MarkerSize',0.01,'HandleVisibility','off'); 
% 
% figure;
% scatter(Boundary(:,1),Boundary(:,2));
% hold on;
% scatter(output(:,1),output(:,2));
% 
% in=inpolygon(output(:,1),output(:,2),Boundary(:,1),Boundary(:,2));
% insideGrid=output(in,:);
% 
% max(boundary_stereographic(:,2));
% 
% lon=-1500000:5000:-470000;
% lat=130000:5000:1045000;
% 
% Ronne_grid_5km=zeros(207*184,2);
% index=1;
% for i=1:207
%     for j=1:184
%         Ronne_grid_5km(index,:)=[lon(i),lat(j)];
%         index=index+1;
%     end  
% end
% 
% 
% % 
% 
% RonneGrid5_5km= struct('long',[], 'lat',[], 'longGap',[]); 
% RonneGrid5_5km=repmat(RonneGrid5_5km,[17858 1]);
% 
% for i=1:17858
%     RonneGrid5_5km(i).long=Ronne_inside_grid_5km(i,1);
%     RonneGrid5_5km(i).lat=Ronne_inside_grid_5km(i,2);
%     RonneGrid5_5km(i).longGap=Ronne_inside_grid_5km(i,3);
% end 

% 给结构体数组加一列
 temp_A= struct('coordinate',[], 'orbitNum',[],'flag_AD',[], 'correctionPar',[]);   
  temp_A=repmat(temp_A,[12 1]);
  for i=1:12
     temp_A(i).coordinate= Amery_D201310(i).coordinate;
      temp_A(i).orbitNum= Amery_D201310(i).orbitNum;
       temp_A(i).flag_AD= Amery_D201310(i).flag_AD;

  end