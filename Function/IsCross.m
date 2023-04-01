function [ res ] = IsCross(A1,A2,B1,B2)
%Function：判断P1,P2两点构成的线段和Q1、Q2两点构成的线段是否存在交点
%Input：P1、P2、Q1、Q2四点的坐标[x,y]，
%Output：res,存在交点则输出1，不存在交点则输出0
res=0;
A1A2=A2-A1; A1B2=B2-A1; A1B1=B1-A1;
A1A2(:,3) = 0; A1B2(:,3) = 0; A1B1(:,3) = 0;  %由于是二维平面，把向量的Z置0
cross_product1 = cross(A1A2,A1B2);cross_product2 = cross(A1A2,A1B1);

if cross_product1(3)*cross_product2(3)<=0        %叉积的方向相反,说明B1B2点在直线A1A2两侧，等于0是有端点位于A1A2线段上的情况
    B1B2=B2-B1; B1A2=A2-B1; B1A1=A1-B1;
    B1B2(:,3) = 0; B1A2(:,3) = 0; B1A1(:,3) = 0;  %由于是平面，把向量的Z置0
    cross_product3 = cross(B1B2,B1A2);cross_product4 = cross(B1B2,B1A1);
    if cross_product3(3)*cross_product4(3)<=0  
        res=1;
    end   
end
end

