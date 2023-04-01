function [NumOfIterativePoints,std_Dev] = DetermineNumberOfIterations(cor_A,cor_D,RoughPosition,Tangent)
%Function：根据概略点周围数据点的离散程度确定曲线拟合过程中用到的迭代点数
%Input：AscendData(升轨数据)、DescendData(降轨数据)、RoughPosition(当前概略位置)
%Input：coefficient(升轨曲线和降轨曲线的二次拟合系数矩阵)、Tangent(第一次概略位置的升降轨切线的三个点)
%Output：NumOfIterativePoints(迭代过程中选取的用于曲线拟合的点的个数)

%% 初始判断
% 升轨或者降轨点数过少时只选用5个点进行迭代
if size(cor_A,1)<=50||size(cor_D,1)<=50
  NumOfIterativePoints=8;
  std_Dev=-0.1;
  return ;
end


%% 二、求概略点附近升降轨点到该店的距离的标准差

%寻找距离概略点最近的50个升轨点和降轨道点
closetRow_A=SearchClosestValue(cor_A(:,2),RoughPosition(2));   %升轨点最接近行
closetRow_D=SearchClosestValue(cor_D(:,2),RoughPosition(2));   %降轨点最接近行

%防止升轨数组溢出
size_A=size(cor_A,1);
if closetRow_A+25>size_A
    adjacent_A=cor_A(size_A-50:size_A,:);
elseif  closetRow_A-25<=0
    adjacent_A=cor_A(1:50,:);
else
    adjacent_A=cor_A(closetRow_A-25:closetRow_A+25,:);
end

%防止降轨数组溢出
size_D=size(cor_D,1);
if closetRow_D+25>size_D
    adjacent_D=cor_D(size_D-50:size_D,:);
elseif  closetRow_D-25<=0
    adjacent_D=cor_D(1:50,:);
else
    adjacent_D=cor_D(closetRow_D-25:closetRow_D+25,:);
end

%调试 画出与切线求距离的所有点
% scatter(adjacent_A(:,1),adjacent_A(:,2),20,'r','filled','MarkerFaceColor',[241 64 64]/255,'MarkerEdgeColor', 'K' ... 
%  ,'LineWidth',0.5 );  %升轨点
% scatter(adjacent_D(:,1),adjacent_D(:,2),20,'b','filled','MarkerFaceColor',[26 111 223]/255,'MarkerEdgeColor', 'K' ...
%  , 'LineWidth',0.5);  %降轨点



%调试 画出切线上的两点
% scatter(Q1(1),Q1(2),20,'b');scatter(Q2(1),Q2(2),20,'b');

Q1=Tangent(1,:);Q2_A=Tangent(2,:);Q2_D=Tangent(3,:); %能形成两条相交切线的三个点

%计算升轨点距离切线的距离
for i=1:size(adjacent_A,1)   
P=adjacent_A(i,1:2);
d=abs(det([Q2_A-Q1;P-Q1]))/norm(Q2_A-Q1)*pi/180*6371.393;  %距离 km
adjacent_A(i,5)=d;
end

%计算降轨点距离切线的距离
for i=1:size(adjacent_D,1)   
P=adjacent_D(i,1:2);
d=abs(det([Q2_D-Q1;P-Q1]))/norm(Q2_D-Q1)*pi/180*6371.393;  %距离 km
adjacent_D(i,5)=d;
end

std_A=std(adjacent_A(:,5));  %概略点附近升轨点到切线距离的标准差
std_D=std(adjacent_D(:,5));  %概略点附近降轨点到切线距离的标准差
std_Dev=(std_A+std_D)/2;         %求标准差的平均值



%% 三、根据标准差设置对应的迭代点数

NumOfIterativePoints=ceil(std_Dev/0.5)*2;   
% switch fix(std_Dev/0.5)
%     case 0  
%         NumOfIterativePoints=2;
%     case 1
%         NumOfIterativePoints=4;
%     case 2 
%         NumOfIterativePoints=7;
%     case 3 
%         NumOfIterativePoints=11;
%     case 4 
%         NumOfIterativePoints=16;
%     case 5
%         NumOfIterativePoints=22;
%     case 6
%            NumOfIterativePoints=30;
%     otherwise
%         NumOfIterativePoints=100;
% end
end

