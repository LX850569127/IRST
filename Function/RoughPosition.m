function [RoughPosition] = RoughPosition(Ascending_data,Dscending_data)
%Function：求解具有交叉点的升轨和降轨之间的交叉点的粗略位置
%Input：ascending_data(升轨数据)、descending_data(降轨数据)
%Output：RoughPosition(交叉点的大概位置)


%% 一、求粗略位置
coefficient=[];           %拟合得到的二次曲线的系数
cor_A=Ascending_data.coordinate;
cor_D=Dscending_data.coordinate;
% 调试 画出升降轨的卫星脚点的原始分布
% hold on;
% scatter(cor_D(:,1),cor_D(:,2),0.5,'b');
% hold on;
% scatter(cor_A(:,1),cor_A(:,2),0.5,'r');
%升轨拟合
cor=Ascending_data.coordinate;
cor=cor(:,1:2);
x=cor(:,2);    %纬度
y=cor(:,1);    %经度
p=polyfit(x,y,2);
y=p(1).*x.*x+p(2).*x+p(3);  %拟合后的经度
coefficient=[coefficient;p];
% % 调试  画出拟合后的升轨
% hold on;
% plot(y,x,'r');
%降轨拟合
cor=Dscending_data.coordinate;
cor=cor(:,1:2);
x=cor(:,2);    %纬度
y=cor(:,1);    %经度

p=polyfit(x,y,2);
y=p(1).*x.*x+p(2).*x+p(3);  %拟合后的经度
coefficient=[coefficient;p];
%调试 画出拟合后的降轨
% hold on;
% plot(y,x,'b');

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
[in]= inpolygon(CursoryCrossPoint(1),CursoryCrossPoint(2),AdjustBoundary(:,1),AdjustBoundary(:,2));
if(not(in))       %粗略位置不在边界中时直接返回空
%    CrossOverPointOutput=[];
%    return;
end

%判断3
%若粗略位置是因为曲线过短导致的错误解，通过该点与升降轨的纬度差进行剔除
 min1=min(abs(cor_A(:,2)-CursoryCrossPoint(2)))+min(abs(cor_D(:,2)-CursoryCrossPoint(2)));
if min1>1
    RoughPosition=[];
    return;
end
RoughPosition=CursoryCrossPoint;
%调试 画出拟合后的概略点位置
% hold on;
% scatter(CursoryCrossPoint(1),CursoryCrossPoint(2),50,'x','k');
end

