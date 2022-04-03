Region='Ross';     

% 1) gathering crossovers within the same interval period

% year1=2011;
% year2=2012;
% 
% if ~exist('name_TotalCP','var')
%     name_TotalCP=strcat(Region,'_',num2str(year1),'_',num2str(year2));
% end
% 
% if ~exist('totalCP','var')
%    totalCP=[];
% end
% 
% year_A=2012;   year_D=2011;   
% startMonth=1;  endMonth=12;
% Ascend=strings([endMonth-startMonth+1,1]);
% Descend=strings([endMonth-startMonth+1,1]);
% 
% for i=startMonth:endMonth
%     month=zerosFill(i);
%     ym_A=strcat(num2str(year_A),month);
%     ym_D=strcat(num2str(year_D),month);
%     Ascend(i-startMonth+1)=ym_A;
%     Descend(i-startMonth+1)=ym_D;
%     name_CP=strcat(Region,'_A',Ascend(i),'_D',Descend(i));
%     CP=eval(name_CP);
%     totalCP=[totalCP;CP];
% end
% eval(strcat(name_TotalCP,'=totalCP'));

%2) searching for the crossovers in the grid 
% elevationChange=zeros(10,2);

% centralPoint=[178.6864,-82.485]; 
% longInterval=0.34394; latInterval=0.045;
% 
% year1=2014; year2=2015;
% name_TotalCP=strcat(Region,'_',num2str(year1),'_',num2str(year2));
% totalCP=eval(name_TotalCP);
% 
% coor=cell2mat({totalCP(:).coordinate});
% long=coor(1:2:size(coor,2)-1).';
% lat=coor(2:2:size(coor,2)).';
% coordinate=[long,lat];
% 
% delta_long=abs(long-centralPoint(1));
% delta_lat=abs(lat-centralPoint(2));
% index=(delta_long<longInterval/2)&(delta_lat<latInterval/2);
% coordinate=coordinate(index,:);
% gridCP=totalCP(index,:);      % crossovers in the grid
% 
% dh=zeros(size(gridCP,1),1);
% for i=1:size(gridCP,1)
%     if gridCP(i).orbitNum_A<gridCP(i).orbitNum_D
%         dh(i)=gridCP(i).altitude_D-gridCP(i).altitude_A;
%     else
%         dh(i)=gridCP(i).altitude_A-gridCP(i).altitude_D;
%     end
% end
% 
% 
% 
% % 格网内多个交叉点求其平均高程变化的方式
% % 1、利用中误差进行剔除
% % rmse=sqrt(sum((dh-mean(dh)).^2)/(size(dh,1)-1));
% % dh(abs(dh-mean(dh))>=2*rmse,:)=[]; 
% % 2、取中间几个变化值的平均值
% dh=sort(dh);
% numOfdh=size(dh,1);
% 
% if numOfdh>=4 
%     rejectNum=floor(numOfdh/4);
%     startingNum=1+rejectNum;
%     endingNum=numOfdh-rejectNum;
%     ec=mean(dh(startingNum:endingNum)); 
% end
% 
% elevationChange(10,1)=ec;
% elevationChange(10,2)=size(dh,1);
% figure;
% scatter(coordinate(:,1),coordinate(:,2),4,'filled');
% hold on; 
% scatter(centralPoint(1),centralPoint(2),10);
% w=longInterval;
% h=latInterval;
% x=centralPoint(1)-w/2;
% y=centralPoint(2)-h/2;
% hold on;
% rectangle('Position',[x,y,w,h])  %从点(x,y)开始绘制一个宽w高h的矩形，

%3) saving the change of elevations for every period

% eleChange(1,1)=mean(dh);
% eleChange(1,2)=size(dh,1);


%% 当格网中得某个delta_H存在多个交叉点时，利用中误差进行剔除并选取最佳值
delta_h=zeros(5,5);
delta_h(1,2:5)=elevationChange(1:4,1);
delta_h(2,3:5)=elevationChange(5:7,1);
delta_h(3,4:5)=elevationChange(8:9,1);
delta_h(4,5:5)=elevationChange(10:10,1);

% 观测方程个数
numOfEquation=0;

for i=1:size(delta_h,2)-2
    numOfEquation=numOfEquation+i;
end

% 建立系数矩阵B，矩阵L
numOfX=size(delta_h,1)-1;     %未知数个数,等于矩阵对角线元素减1
B=zeros(numOfEquation,numOfX);
L=zeros(numOfEquation,1);
% 从矩阵第一行从左往右的观测值开始建立观测方程
index=1;      
for i=1:size(delta_h,1)-2                       % 行数循环
     numOfObservations=size(delta_h,2)-i-1;     % 行数与该行所对应的观测值个数的关系
     startingColum=2+i;                         % 每行的起始循环列
     for j=startingColum:size(delta_h,2)        % 列数循环
          B(index,i:j-1)=1;                     % 确定每个观测方程的系数     
          row=i:j-1;
          column=i+1:j;
          for k=1:size(row,2)
            L(index)=L(index)+delta_h(row(k),column(k));
          end
            L(index)=L(index)-delta_h(i,j);
          index=index+1;
     end
end
L=-L;
P=diag(ones(numOfEquation,1));

% 求解未知参数的最小二乘解,并添加到
x=inv(B.'*P*B)*B.'*P*L; 
adjusted_delta_h=zeros(size(delta_h));
for i=1:size(x,1)   
      adjusted_delta_h(i,i+1)=delta_h(i,i+1)-x(i);
end


%% 挑选一个单独的格网作为试验区

specificGrid=[178.6864,-82.485]; 

% plotting the distribution of crossovers and gird points 
coordinate=cell2mat({Ross_2011_2012(:).coordinate}).';
longitude=coordinate(1:2:size(coordinate,1)-1);
latitude=coordinate(2:2:size(coordinate,1));
figure('color','w');
scatter(longitude,latitude,5,[241 64 64]/255,'filled');
hold on;
scatter(178.6864,-82.485,20,'b','filled');
