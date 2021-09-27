function [Tangent] = SolveTangent(RoughPosition,coefficient)
%Function：求拟合的升降轨曲线在概略位置处的切线
%Input：RoughPosition(概略位置)、coefficient(二次拟合曲线的系数)
%Output：Tangent分别包含Q1(第一次概略位置)、Q2_A(升轨切线上的一点)、Q2_D(降轨切线上的一点) 
%Note：输出的三个点即可决定两条切线 

%% 一、求曲线在该点的斜率及切线

% 只求拟合的升降轨在概略位置处的切线
% 只有第一次迭代时需要求切线

x0=RoughPosition(2);   %切点的纬度
y0=RoughPosition(1);   %切点的经度
x = linspace(x0-1,x0+1,101); 
h = x(2)-x(1);  
y1 = coefficient(1,1).*x.*x+coefficient(1,2).*x+coefficient(1,3);  %升轨拟合曲线
y2 = coefficient(2,1).*x.*x+coefficient(2,2).*x+coefficient(2,3);  %降轨拟合曲线
slopeA=diff(y1)/h;
slopeD=diff(y2)/h;

%求概略位置分别在升轨和降轨上的斜率
k_A=slopeA(51);
k_D=slopeD(51);
b_A=y0-k_A*x0;
b_D=y0-k_D*x0;    %常数项
TangentLine_A=k_A*x+b_A;     %升轨切线的方程  
TangentLine_D=k_D*x+b_D;     %降轨切线的方程 

Q1=RoughPosition;
Q2_A=[TangentLine_A(1), x(1)]; %升轨切线上一点
Q2_D=[TangentLine_D(1), x(1)]; %降轨切线上一点
Tangent=[Q1;Q2_A;Q2_D];


% plot(y1,x);
% plot(TangentLine_A,x);
% plot(y2,x);
% plot(TangentLine_D,x);


% syms x;
% f1(x)=coefficient(1,1)*x*x+coefficient(1,2)*x+coefficient(1,3);  %升轨拟合曲线
% f2(x)=coefficient(2,1)*x*x+coefficient(2,2)*x+coefficient(2,3);  %降轨拟合曲线
% 
% %求升轨曲线和降轨曲线的斜率函数
% slopeA(x)=diff(f1,1);slopeD(x)=diff(f2,1);
% 
% %求概略位置分别在升轨点和降轨点上的斜率
% slopeA=vpa(slopeA(RoughPosition(2)),5);
% slopeD=vpa(slopeD(RoughPosition(2)),5);
% 
% k_A=slopeA;k_D=slopeD; %升降轨拟合曲线在概略点出的切线的斜率
% 
% x0=RoughPosition(2);   %切点的纬度
% y0=RoughPosition(1);   %切点的经度
% 
% b_A=y0-k_A*x0;
% b_D=y0-k_D*x0;    %常数项
% 
% TangentLine_A(x)=k_A*x+b_A;  %升轨切线的方程  x为纬度  
% TangentLine_D(x)=k_D*x+b_D;  %降轨切线的方程 
% 
% Q1=RoughPosition;
% Q2_A=[double(vpa(TangentLine_A(RoughPosition(2)+0.5),5)), RoughPosition(2)+0.5]; %升轨切线上一点
% Q2_D=[double(vpa(TangentLine_D(RoughPosition(2)+0.5),5)), RoughPosition(2)+0.5]; %降轨切线上一点
% Tangent=[Q1;Q2_A;Q2_D];

% 调试 绘制切线
% x1=[-82.7;-82.4];y_A=k_A*x1+b_A;
% plot(y_A,x1,'K','LineWidth',2,'HandleVisibility','off');   %绘制升轨切线
% y_D=k_D*x1+b_D;
% plot(y_D,x1,'K','LineWidth',2);   %绘制降轨切线


end

