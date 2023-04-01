function [ CrossOverPointOutput ] = PrecisePositionOfCrossOver( Ascending_data,Dscending_data,AdjustBoundary)
%Function：求相互交叉的升降轨之间的交叉点的精确位置以及两个不同时间的高程值
%Input：ascending_data(升轨数据)、descending_data(降轨数据)
%Output：CrossOverPoint(交叉点的位置以及两个不同时间的高程值)

% hold on;   %保持在原有图像上绘图
%% 一、求粗略位置
coefficient=[];           %拟合得到的二次曲线的系数
cor_A=Ascending_data.coordinate;
cor_D=Dscending_data.coordinate;

%升轨拟合
cor=Ascending_data.coordinate;
cor=cor(:,1:2);
xA=cor(:,2);    %纬度
yA=cor(:,1);    %经度
p=polyfit(xA,yA,2);
yA=p(1).*xA.*xA+p(2).*xA+p(3);  %拟合后的经度
coefficient=[coefficient;p];

%降轨拟合
cor=Dscending_data.coordinate;
cor=cor(:,1:2);
xD=cor(:,2);    %纬度
yD=cor(:,1);    %经度

p=polyfit(xD,yD,2);
yD=p(1).*xD.*xD+p(2).*xD+p(3);  %拟合后的经度
coefficient=[coefficient;p];


% 调试 画出升降轨的卫星脚点的原始分布
% scatter(cor_A(:,1),cor_A(:,2),4,[241 64 64]/255,'filled','HandleVisibility','off');
% scatter(cor_D(:,1),cor_D(:,2),4,[26 111 223]/255,'filled');
%  调试 画出拟合后的升轨曲线和降轨曲线
% plot(yA,xA,'Color',[241 64 64]/255,'LineWidth',3);
% plot(yD,xD,'Color',[26 111 223]/255,'LineWidth',3);

%调试 绘制拟合的升轨曲线和降轨曲线的一部分
% yA1=yA(find(yA>204&yA<207));
% xA1=xA(find(yA>204&yA<207));
% plot(yA1,xA1,'Color',[241 64 64]/255,'LineWidth',2);
% yD1=yD(find(yD>204&yD<207));
% xD1=xD(find(yD>204&yD<207));
% plot(yD1,xD1,'Color',[241 64 64]/255,'LineWidth',2);

%求拟合后曲线的交点
func1=@(x)coefficient(1,1).*x.*x+coefficient(1,2).*x+coefficient(1,3);
func2=@(x)coefficient(2,1).*x.*x+coefficient(2,2).*x+coefficient(2,3);
func=@(x)func1(x)-func2(x);

latOfCrossPoint=fsolve(func,[-80 -83.5]);  %-80、-83是设定的两个初值，一般设定在解附近
longofCrossPoint=coefficient(1,1).*latOfCrossPoint.*latOfCrossPoint+coefficient(1,2).*latOfCrossPoint+coefficient(1,3);

%判断1 
%当交点出现两个不同的解时，进行判断，通过升轨和降轨与两个解的纬度的最小差值
if(latOfCrossPoint(1)~=latOfCrossPoint(2))
    min1=min(abs(cor_A(:,2)-latOfCrossPoint(1)))+min(abs(cor_D(:,2)-latOfCrossPoint(1)));
    min2=min(abs(cor_A(:,2)-latOfCrossPoint(2)))+min(abs(cor_D(:,2)-latOfCrossPoint(2)));
    if(min1<min2)
          CursoryCrossPoint=[longofCrossPoint(1),latOfCrossPoint(1)];  
    else
          CursoryCrossPoint=[longofCrossPoint(2),latOfCrossPoint(2)];  
    end 
else
    CursoryCrossPoint=[longofCrossPoint(1),latOfCrossPoint(1)];  
end

%判断2
%判断粗略位置是否位于边界范围内，不在边界内时舍弃该交叉点
% [in]= inpolygon(CursoryCrossPoint(1),CursoryCrossPoint(2),AdjustBoundary(:,1),AdjustBoundary(:,2));
% if(not(in))       %粗略位置不在边界中时直接返回空
% %    CrossOverPointOutput=[];
% %    return;
% end

%判断3
%若粗略位置是因为曲线过短导致的错误解，通过该点与升降轨的纬度差进行剔除
 min1=min(abs(cor_A(:,2)-CursoryCrossPoint(2)))+min(abs(cor_D(:,2)-CursoryCrossPoint(2)));
if min1>0.06  %纬度差的最小值
    CrossOverPointOutput=[];
    return;
end

%调试 画出拟合后的概略点位置
% scatter(CursoryCrossPoint(1),CursoryCrossPoint(2),100,'d','k','filled','HandleVisibility','off');



%% 二、求精确位置

%方法一 迭代法
% Tangent=SolveTangent(CursoryCrossPoint,coefficient);    %求第一次粗略位置的两条切线
% [NumOfIterativePoints]=DetermineNumberOfIterations(cor_A,cor_D,CursoryCrossPoint,Tangent);  %求第一次迭代的迭代点数
CrossOverPoint5=IterationOfCursoryLocation(cor_A,cor_D,CursoryCrossPoint,AdjustBoundary,10,5);
CrossOverPoint35=IterationOfCursoryLocation(cor_A,cor_D,CursoryCrossPoint,AdjustBoundary,10,35);
% %调试 为了对比两种不同方法的精确位置结果
% if ~isempty(CrossOverPoint)
%     scatter(CrossOverPoint(1),CrossOverPoint(2),150,'p','k','filled');
%     CrossOverPoint=IterationOfCursoryLocation(cor_A,cor_D,CursoryCrossPoint,AdjustBoundary,10,5);
%     scatter(CrossOverPoint(1),CrossOverPoint(2),150,'p','b','filled');
% end
%方法二 跨立交叉法
CrossOverPoint=ExactPosition2(cor_A,cor_D,CursoryCrossPoint,AdjustBoundary);

%方法三 改进的迭代法
% Tangent=SolveTangent(CursoryCrossPoint,coefficient);    %求第一次粗略位置的两条切线
% [NumOfIterativePoints]=DetermineNumberOfIterations(cor_A,cor_D,CursoryCrossPoint,Tangent);  %求第一次迭代的迭代点数
% CrossOverPoint=IterationOfCursoryLocation(cor_A,cor_D,CursoryCrossPoint,AdjustBoundary,10,NumOfIterativePoints,Tangent);


%如果返回交叉点位置的矩阵为空，说明该交叉点位于边界之外，直接返回
if isempty(CrossOverPoint)
    CrossOverPointOutput=[];
    return;
end 

if ~isempty(CrossOverPoint)&&~isempty(CrossOverPoint5)
   PDOP1=distance([CrossOverPoint(2),CrossOverPoint(1)],[CrossOverPoint5(2),CrossOverPoint5(1)])*pi/180*6371.393;
else 
    PDOP1=0;
end

if ~isempty(CrossOverPoint)&&~isempty(CrossOverPoint35)
   PDOP2=distance([CrossOverPoint(2),CrossOverPoint(1)],[CrossOverPoint35(2),CrossOverPoint35(1)])*pi/180*6371.393;
   else 
    PDOP2=0;
end

%模拟轨道的调试
CrossOverPointOutput= struct('coordinate',CrossOverPoint,'PDOP1',PDOP1,'PDOP2',PDOP2);
return;

%% 三、求交叉点的两个高程以及对应的时间
%3.1 交叉点升轨高程计算
% rowOfCloset=SearchClosestValue(cor_A(:,2),CrossOverPoint(2));
% 
% %计算EnviSat数据的时候由于纬度接近的值太多使用经度进行计算
% % rowOfCloset=SearchClosestValue(cor_A(:,1),CrossOverPoint(1));
% 
% %找到高程插值点
%  % 防止延伸后超出矩阵范围的情况出现
%         if(rowOfCloset-2<=0)  
%             floor=1;
%         else
%             floor=rowOfCloset-2;
%         end
%         if(rowOfCloset+2>size(cor_A))
%             top=size(cor_A);
%         else
%             top=rowOfCloset+2;
%         end
% interpolationPointOfA=cor_A(floor:top,:);
% % hold on;
% % scatter(interpolationPointOfA(:,1),interpolationPointOfA(:,2),30,'r');
% 
% %进行反距离加权计算精确交叉点的高程插值
% %计算距离
% for i=1:size(interpolationPointOfA,1)
% dis=distance([interpolationPointOfA(i,2),interpolationPointOfA(i,1)],[CrossOverPoint(2),CrossOverPoint(1)])*pi/180*6371.393;
% interpolationPointOfA(i,5)=dis;   %距离(单位为km)
% end
% 
% %剔除距离过大的点
% interpolationPointOfA(interpolationPointOfA(:,5)>2,:)=[];
% 
% %剔除高程值异常的点，高程>2000&&<-55
% interpolationPointOfA(interpolationPointOfA(:,3)>2000,:)=[];
% interpolationPointOfA(interpolationPointOfA(:,3)<-55,:)=[];
% 
% 
% %如果在升轨或者降轨中用于对交叉点高程进行插值的点距离交叉点的位置均过远，舍弃该交叉点
% if isempty(interpolationPointOfA)
%     CrossOverPointOutput=[];
%     return;
% end 
% 
% %通过距离加权得到高程
% %权重计算
% denominator=0;
% for i=1:size(interpolationPointOfA,1)
%     denominator=denominator+interpolationPointOfA(i,5)^-2;
% end 
% 
% for i=1:size(interpolationPointOfA,1)
%     weightFactor=interpolationPointOfA(i,5)^-2/denominator;
%     interpolationPointOfA(i,6)=weightFactor; 
% end 
% 
% 
% 
% %高程插值计算
% altitude_A=0;
% for i=1:size(interpolationPointOfA,1)
%     altitude_A=altitude_A+interpolationPointOfA(i,3)*interpolationPointOfA(i,6);
% end 
% 
% time_A=0;
% % time_A=cor_A(rowOfCloset,4);
% 
% 
% %3.2 交叉点降轨高程计算
% rowOfCloset=SearchClosestValue(cor_D(:,2),CrossOverPoint(2));
% 
% 
% % %计算EnviSat数据的时候由于纬度接近的值太多使用经度进行计算
% % rowOfCloset=SearchClosestValue(cor_D(:,1),CrossOverPoint(1));
% 
% %找到高程插值点
%  % 防止延伸后超出矩阵范围的情况出现
%         if(rowOfCloset-2<=0)
%             floor=1;
%         else
%             floor=rowOfCloset-2;
%         end
%         if(rowOfCloset+2>size(cor_D))
%             top=size(cor_D);
%         else
%             top=rowOfCloset+2;
%         end
% interpolationPointOfD=cor_D(floor:top,:);
% 
% %进行反距离加权计算精确交叉点的高程插值
% 
% %计算距离
% for i=1:size(interpolationPointOfD,1)
% dis=distance(interpolationPointOfD(i,2),interpolationPointOfD(i,1),CrossOverPoint(2),CrossOverPoint(1))*pi/180*6371.393;
% interpolationPointOfD(i,5)=dis;   %距离(单位为km)
% end
% 
% %剔除距离过大的点
% interpolationPointOfD(interpolationPointOfD(:,5)>2,:)=[];
% 
% %剔除高程值异常的点，高程>2000&&<-55
% interpolationPointOfD(interpolationPointOfD(:,3)>2000,:)=[];
% interpolationPointOfD(interpolationPointOfD(:,3)<-55,:)=[];
% 
% %如果在升轨或者降轨中用于对交叉点高程进行插值的点距离交叉点的位置均过远，舍弃该交叉点
% if isempty(interpolationPointOfD)
%     CrossOverPointOutput=[];
%     return;
% end 
% 
% %调试 画出用于高程插值的升轨点和降轨点
% % hold on;
% % scatter(interpolationPointOfA(:,1),interpolationPointOfA(:,2),30,'r');
% % scatter(interpolationPointOfD(:,1),interpolationPointOfD(:,2),30,'b');
% 
% 
% %通过距离加权得到高程
% %权重计算
% denominator=0;
% for i=1:size(interpolationPointOfD,1)
%     denominator=denominator+interpolationPointOfD(i,5)^-2;
% end 
% 
% for i=1:size(interpolationPointOfD,1)
%     weightFactor=interpolationPointOfD(i,5)^-2/denominator;
%     interpolationPointOfD(i,6)=weightFactor; 
% end 
% 
% %高程插值计算
% altitude_D=0;
% for i=1:size(interpolationPointOfD,1)
%     altitude_D=altitude_D+interpolationPointOfD(i,3)*interpolationPointOfD(i,6);
% end 
% time_D=0;
% % time_D=cor_D(rowOfCloset,4);
% 
% % hold on;
% % scatter(CrossOverPoint(1),CrossOverPoint(2),100,'p','k','filled');
% %% 调试
% 
% %分别找到升轨和降轨中与交叉点精确位置距离最接近的两个点
% A=sortrows(interpolationPointOfA,5);
% D=sortrows(interpolationPointOfD,5);
% if size(A,1)>=2&&size(D,1)>=2
%    PDOP=A(2,5)-A(1,5)+D(2,5)-D(1,5);
% else 
%    PDOP=-1;  
% end
% % scatter(A(1:2,1),A(1:2,2),30,'r');
% % scatter(D(1:2,1),D(1:2,2),30,'b');
% %% 
% 
% 
% 
% %% 四、结果导出
% 
% % 调试 绘制交叉点的精确位置
% altitude=[altitude_A,time_A;altitude_D,time_D];
% CrossOverPointOutput= struct('coordinate',CrossOverPoint,'altitude',altitude,'PDOP',PDOP);
% 
%%
end

