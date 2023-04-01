function crossOverPoint= getCrossOverPoint( X1,Y1,X2,Y2 )
%Function：求解X1与Y1确定的线段，X2与Y2确定的线段的交点
%Input：X1、Y1、X2、Y2四点的坐标[x,y]，
%Output：crossOverPoint=[X,Y]，交点的X、Y坐标

if X1(1)==Y1(1)
   X=X1(1);
   k2=(Y2(2)-X2(2))/(Y2(1)-X2(1));
   b2=X2(2)-k2*X2(1); 
   Y=k2*X+b2;
end
if X2(1)==Y2(1)
   X=X2(1);
   k1=(Y1(2)-X1(2))/(Y1(1)-X1(1));
   b1=X1(2)-k1*X1(1);
   Y=k1*X+b1;
end
if X1(1)~=Y1(1)&X2(1)~=Y2(1)
   k1=(Y1(2)-X1(2))/(Y1(1)-X1(1));
   k2=(Y2(2)-X2(2))/(Y2(1)-X2(1));
   b1=X1(2)-k1*X1(1);
   b2=X2(2)-k2*X2(1);
    if k1==k2
      X=[];
      Y=[];
   else
   X=(b2-b1)/(k1-k2);
   Y=k1*X+b1;
    end
   crossOverPoint=[X,Y];
end