function [PreciseCorssPoint] = IterationOfCursoryLocation(cor_A,cor_D,CursoryCrossPoint,AdjustBoundary,Iterations,NumOfIterativePoints,Tangent,varargin)
%Function：通过迭代求解交叉点的精确位置
%Input：cor_A(升轨数据)、cor_D(降轨数据)、CursoryCrossPoint(交叉点初始迭代位置,粗略位置)
%Input：AdjustBoundary(用于判断的边界数据)、Iterations(迭代次数)、NumOfIterativePoints(迭代过程所选取的点的个数)
%Input：Tangent(初始概略位置处的两条升降轨切线，用于计算数据点到切线距离)
%Output：PreciseCorssPoint(交叉点的精确位置)

%% Set defaults: 

Update=false;      %默认不在迭代过程中更新迭代点数
limit=30;          %设置二次拟合与一次拟合的分界线


%% Parse inputs: 

if ~isempty(varargin)   
    Update=varargin{1};   %设置是否更新迭代点数的参数
end

for i=1:Iterations                %确定迭代次数
 
cursoryLocation=[CursoryCrossPoint(1),CursoryCrossPoint(2)];       %更改下一次迭代的概略点参考位置

%% 一、寻找用于二次拟合的升降轨数据

%1.1 升轨数据延伸
difference=cor_A(:,2)-cursoryLocation(1,2);                        %升轨纬度差值  
minValue=min(abs(difference));                                     %最小差值
rowOfMin=find(minValue==abs(difference)) ;                         %纬度最接近值所在的行

% 防止多个点纬度接近的情况出现
if size(rowOfMin,1)>1
    rowOfMin=rowOfMin(2,:);
end

% 防止延伸后超出矩阵范围的情况出现
if rowOfMin-NumOfIterativePoints<=0 
    floor=1;
    top=min(NumOfIterativePoints*4,size(cor_A,1));
elseif rowOfMin+NumOfIterativePoints>size(cor_A,1)
    top=size(cor_A,1);
    floor=max(1,top-NumOfIterativePoints*4);
else
    floor=rowOfMin-NumOfIterativePoints;
    top=rowOfMin+NumOfIterativePoints; 
end

% 延伸后得到的升轨数据
extendData_A=[cor_A(floor:top,1),cor_A(floor:top,2)];
x_A=extendData_A(:,2);    %纬度
y_A=extendData_A(:,1);    %经度

if NumOfIterativePoints<limit
%1.2.1 利用延申后的数据进行一次拟合
    coefficient1=polyfit(x_A,y_A,1);
    y_A=coefficient1(1).*x_A+coefficient1(2);  %拟合后的经度
    else
    %1.2.2 利用延伸后得到的升轨数据进行二次拟合
    coefficient1=polyfit(x_A,y_A,2);
    y_A=coefficient1(1).*x_A.*x_A+coefficient1(2).*x_A+coefficient1(3);  %拟合后的经度
end

%1.3 降轨数据延伸
difference=cor_D(:,2)-CursoryCrossPoint(1,2);   %纬度差值    
minValue=min(abs(difference));
rowOfMin=find(minValue==abs(difference));  %纬度最接近值所在的行

% 防止多个点纬度接近的情况出现
if size(rowOfMin,1)>1
    rowOfMin=rowOfMin(2,:);
end

%防止延伸后超出矩阵范围的情况出现

if rowOfMin-NumOfIterativePoints<=0 
    floor=1;
    top=min(NumOfIterativePoints*4,size(cor_D,1));
elseif rowOfMin+NumOfIterativePoints>size(cor_D,1)
    top=size(cor_D,1);
    floor=max(1,top-NumOfIterativePoints*4);
else
    floor=rowOfMin-NumOfIterativePoints;
    top=rowOfMin+NumOfIterativePoints; 
end

% 延伸后得到的降轨数据
extendData_D=[cor_D(floor:top,1),cor_D(floor:top,2)];
x_D=extendData_D(:,2);    %纬度
y_D=extendData_D(:,1);    %经度



if NumOfIterativePoints<limit
    %1.4.1  利用延伸后得到的降轨数据进行一次拟合
    coefficient2=polyfit(x_D,y_D,1);
    y_D=coefficient2(1).*x_D+coefficient2(2);  %拟合后的经度
    else 
    %1.4.2  利用延伸后得到的降轨数据进行二次拟合
    coefficient2=polyfit(x_D,y_D,2);
    y_D=coefficient2(1).*x_D.*x_D+coefficient2(2).*x_D+coefficient2(3);  %拟合后的经度
end

%     直线拟合
%     y_A=coefficient1(1).*x_A+coefficient1(2);  %拟合后的经度
%     曲线拟合
%     y_A=coefficient1(1).*x_A.*x_A+coefficient1(2).*x_A+coefficient1(3);  %拟合后的经度
  

   
%     
%     x_D=linspace(-81,-78,20);
%         直线拟合
%     y_D=coefficient2(1).*x_D+coefficient2(2);  %拟合后的经度
%     曲线拟合
%     y_D=coefficient2(1).*x_D.*x_D+coefficient2(2).*x_D+coefficient2(3);  %拟合后的经度






%% 二、求交叉点的精确位置

if NumOfIterativePoints<limit
%% 直线拟合
    func1=@(x)coefficient1(1).*x+coefficient1(2);
    func2=@(x)coefficient2(1).*x+coefficient2(2);
    func=@(x)func1(x)-func2(x);
    latOfCrossPoint=fsolve(func,[CursoryCrossPoint(2) CursoryCrossPoint(2)]);
    longofCrossPoint=coefficient1(1).*latOfCrossPoint+coefficient1(2);
    CrossOverPoint=[longofCrossPoint(1),latOfCrossPoint(1)];
    else 
%% 曲线拟合
    func1=@(x)coefficient1(1).*x.*x+coefficient1(2).*x+coefficient1(3);
    func2=@(x)coefficient2(1).*x.*x+coefficient2(2).*x+coefficient2(3);
    func=@(x)func1(x)-func2(x);
    latOfCrossPoint=fsolve(func,[CursoryCrossPoint(2) CursoryCrossPoint(2)]);
    %防止二次拟合的过程中卫星脚点过于离散出现多解的情况
    if(latOfCrossPoint(1)~=latOfCrossPoint(2))
       difference=abs(latOfCrossPoint-CursoryCrossPoint(2));
       [~,ind] =min(difference);
       latOfCrossPoint=latOfCrossPoint(ind);
    end
    longofCrossPoint=coefficient1(1).*latOfCrossPoint.*latOfCrossPoint+coefficient1(2).*latOfCrossPoint+coefficient1(3);
    CrossOverPoint=[longofCrossPoint(1),latOfCrossPoint(1)];

end
%% plot for debugging

% Extend coordinates
% x_A=linspace(min(x_A)-0.06,max(x_A)+0.01,10);
% x_D=linspace(min(x_D)-0.06,max(x_D)+0.01,10);
% y_A=coefficient1(1).*x_A+coefficient1(2); 
% y_D=coefficient2(1).*x_D+coefficient2(2); 

% Clip raw data
% rowA=SearchClosestValue(cor_A(:,2),CursoryCrossPoint(2));
% rowD=SearchClosestValue(cor_D(:,2),CursoryCrossPoint(2));

% Plot 
% scatter(CursoryCrossPoint(1),CursoryCrossPoint(2),80,'d','k','filled');
% scatter(CrossOverPoint(1),CrossOverPoint(2),100,'p','k','filled','HandleVisibility','off');
% scatter(cor_A(rowA-30:rowA+30,1),cor_A(rowA-30:rowA+30,2),8,[127 140 141]/255,'filled','HandleVisibility','off');
% scatter(cor_D(rowD-30:rowD+30,1),cor_D(rowD-30:rowD+30,2),8,[127 140 141]/255,'filled');
% scatter(extendData_D(:,1),extendData_D(:,2),20,'MarkerFaceColor','k','MarkerEdgeColor','k','HandleVisibility','off');
% scatter(extendData_A(:,1),extendData_A(:,2),20,'MarkerFaceColor','k','MarkerEdgeColor','k');
% plot(y_A,x_A,'--','Color',[0 0 0]/255,'LineWidth',1,'HandleVisibility','off');
% plot(y_D,x_D,'--','Color',[0 0 0]/255,'LineWidth',1,'HandleVisibility','off');

% Set
% set(gca,'fontsize',16);
% xlabel('经度/(°)','FontSize',16);
% ylabel('纬度/(°)','FontSize',16);
% legend('概略位置','数据点','拟合点');

%% 
% 迭代过程中是否每一次迭代都重新确定迭代点数的开关 
% if Update && rem(i,3)==0
 if Update
    NumOfIterativePoints=DetermineNumberOfIterations(cor_A,cor_D,CursoryCrossPoint,Tangent);  %确定迭代点数的固定值
end

%调试
% hold on;
% scatter(CrossOverPoint(1),CrossOverPoint(2),80,'d','k','filled','HandleVisibility','off');

%%

%判断前后两次迭代得到的点的位置的距离
if i>3
  dis=distance(CursoryCrossPoint(2),CursoryCrossPoint(1),CrossOverPoint(2),CrossOverPoint(1))*pi/180*6371.393; %单位km
%   判断迭代前后两次之间的距离是否小于60m
  if dis<0.04 %km 40m
      PreciseCorssPoint=CrossOverPoint;
%       判断最后一次的精确位置是否位于边界范围内，不在边界内时舍弃该交叉点
      [in]= inross(CrossOverPoint(1),CrossOverPoint(2),AdjustBoundary);
      if(not(in))   
          %        调试
%             scatter(CrossOverPoint(1),CrossOverPoint(2),88,'p','c','filled');
          PreciseCorssPoint=[];
      end
      return;
  end
end

CursoryCrossPoint=CrossOverPoint;    %设置下一次迭代的初始位置

%达到最大迭代次数但是仍然不满足前面的距离判断条件时输出最后一次的结果
if i==Iterations
    PreciseCorssPoint=CrossOverPoint;
    %判断最后一次迭代得到的精确位置是否位于边界范围内，不在边界内时舍弃该交叉点
%    [in]= inpolygon(CrossOverPoint(1),CrossOverPoint(2),AdjustBoundary(:,1),AdjustBoundary(:,2));
     [in]= inross(CrossOverPoint(1),CrossOverPoint(2),AdjustBoundary);
   if(not(in))   
%          scatter(CrossOverPoint(1),CrossOverPoint(2),88,'p','c','filled');
       PreciseCorssPoint=[];
   end
end 
end

