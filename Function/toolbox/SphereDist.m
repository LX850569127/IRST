function dis  = SphereDist(P1,P2,R)
%根据两点的经纬度计算大圆距离(基于球面余弦公式)
%P1为A点[经度, 纬度], P2为B点[经度, 纬度]
if nargin < 3
    R = 6371.393;
end
dis=distance(P2(2),P2(1),P1(2),P1(1))*pi/180*R;
end