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
%% AMT方法比固定值5迭代多出来的点

% Fixed5=Fixed5;
% 
orbitNum_AMT=zeros(size(AMT,1),2);

for i=1:size(AMT,1)
    Num=AMT(i).orbitNum; 
    orbitNum_AMT(i,:)=Num;
end

orbitNum_AMTPro=zeros(size(AMTPro,1),2);
for i=1:size(AMTPro,1)
    Num=AMTPro(i).orbitNum; 
    orbitNum_AMTPro(i,:)=Num;
end

U=unique([orbitNum_AMT;orbitNum_AMTPro],'rows');   %非重复的值

Lia = ismember(U,orbitNum_AMTPro,'rows');       
%  
d=U(find(Lia==0),:);       %AMT多出固定值5的点

% 找出坐标不一致的点以及原因
% coor_AMT=zeros(size(AMT,1),1);
% 
% for i=1:size(AMT,1)
%     Num=AMT(i).PDOP; 
%     coor_AMT(i,:)=Num;
% end
% 
% coor_AMTPro=zeros(size(AMTPro,1),1);
% for i=1:size(AMTPro,1)
%     Num=AMTPro(i).PDOP; 
%     coor_AMTPro(i,:)=Num;
% end
% U=unique([coor_AMTPro;coor_AMT],'rows');   %非重复的值
% 
% Lia = ismember(U,coor_AMTPro,'rows');       
% %  
% d=U(find(Lia==0),:);       %AMT多出固定值5的点
% 
% 
% 
% find(roundn(coor_AMT,-4)==10.8443);
% coor_AMTPro(111)=[];
% f = ismember(orbitNum_AMT,d,'rows');       
% 
% cor=zeros(size(d,1),2);
%     j=1;
% for i=1:size(AMT,1)
%     if f(i)
%         cor(j,:)=AMT(i).coordinate;
%         j=j+1;
%     end
% end
% 
% figure;
% plot(adjustBoundary(:,1),adjustBoundary(:,2),'k','MarkerSize',0.01); 
% hold on;
% scatter(cor(:,1),cor(:,2),20,[241 64 64]/255,'filled');

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
%% 寻找AMT时间优化后损失的交叉点

cor_A=zeros(size(AMT,1),2);
for i=1:size(AMT,1)
   cor_A(i,:)=AMT(i).orbitNum;
end

cor_D=zeros(size(AMTRE,1),2);
for i=1:size(AMTRE,1)
   cor_D(i,:)=AMTRE(i).orbitNum;
end


U=unique([cor_A;cor_D],'rows');   %非重复的值

Lia = ismember(U,cor_A,'rows');       
%  
d=U(find(Lia==0),:);       %AMT多出固定值5的点

% orbitCom=zeros(size(Combine,1),2);
% for i=1:size(Combine,1)
%        orbitCom(i,:)=[Combine(i,1).orbitNum,Combine(i,2).orbitNum];
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
coor=RIS_A201303(44).coordinate;
figure;
% adjustBoundary(adjustBoundary(:,1)>180)=-(360-adjustBoundary(adjustBoundary(:,1)>180));
plot(adjustBoundary(:,1),adjustBoundary(:,2),'k','MarkerSize',0.01,'HandleVisibility','off'); 
hold on;
scatter(coor(:,1),coor(:,2));

coor=RIS_D201303(49).coordinate;
hold on;
scatter(coor(:,1),coor(:,2)); 
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