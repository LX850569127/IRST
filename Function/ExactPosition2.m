function [ExactPosition] = ExactPosition2(AscendData,DescendData,RoughPosition,Boundary)
%Function：在交叉点粗略位置的基础上求解交叉点的精确位置
%Input：AscendData(升轨数据)、DescendData(降轨数据)、RoughPosition(粗略位置)、Boundary(边界数据)
%Output：ExactPosition(交叉点的精确位置)

if size(AscendData,1)<=9||size(DescendData,1)<=9
    ExactPosition=[];
    return;
end
%% 如果概略位置在边界外且距离边界过远时不进行计算
[in]= inpolygon(RoughPosition(1),RoughPosition(2),Boundary(:,1),Boundary(:,2));
if(not(in))       %粗略位置不在边界中时才进行判断
    %挑选经度范围更接近的边界值，减少计算量
    Bound=Boundary(find(abs(Boundary(:,1)-RoughPosition(1))<5),:);
    boundDis=zeros(size(Bound,1),1);
    for i=1:size(Bound)
        boundDis(i)=SphereDist(RoughPosition,Bound(i,1:2));
    end
    % 小于12km时候继续计算精确点的位置
        if min(boundDis)>12
            ExactPosition=[];
             return;
        elseif min(boundDis)<8.2
            count1=14;  %计算次数 距离边界接近时数据点分布离散，增加判断点的个数
        end
end
      
%     调试 绘制裁筛选后的边界点
%     plot(Bound(:,1),Bound(:,2),'.r','MarkerSize',0.3 );  %绘制冰架的边界图
%     scatter(DescendData(P1_D_row,1),DescendData(P1_D_row,2),10,'b','d');




%% 1、寻找距离精确位置最近的数据点所在的升轨行和降轨行
rowA=SearchClosestValue(AscendData(:,2),RoughPosition(2));   %最近的升轨行
if size(rowA,1)>1
    rowA=rowA(2,:);
end


rowD=SearchClosestValue(DescendData(:,2),RoughPosition(2));  %最近的降轨行
if size(rowD,1)>1
    rowD=rowD(2,:);
end





%调试 画出升轨最近点和降轨最近点
% scatter(AscendData(rowA,1),AscendData(rowA,2),10,'r','d');
% scatter(DescendData(rowD,1),DescendData(rowD,2),10,'b','d');

%如果升降轨中有一条过短不利于判断相对位置方向时任意指定一个方向
if size(AscendData,1)<=20||size(DescendData,1)<=20
      direction='up';
    
elseif rowA+15>size(AscendData,1)&&rowD+15>size(DescendData,1)  %升轨末端与降轨末端十分接近的情况
    rowD=size(DescendData,1);
    rowA=SearchClosestValue(AscendData(:,2),DescendData(rowD,2));   
    direction='up';
else
%% 2、判断精确位置位于概略位置的方向 
dis1=SphereDist(AscendData(rowA,1:2),DescendData(rowD,1:2)); 
if dis1<0.65  %升轨点和降轨点距离已经十分接近的情况下，调整初始的判断点位
    %防止数组越界 
    if  rowA-10<=0||rowD+10>size(DescendData,1)
        if rowD+10>size(DescendData,1)
          rowA=rowA-(size(DescendData,1)-rowD);
          rowD=size(DescendData,1);
        else     
          rowD=rowD+rowA;  
          rowA=1;
        end
    else 
        rowD=rowD+10;  
        rowA=rowA-10;
    end
     count=7;  %平移点数
else 
     count=7;
end
%利用更多的点计算第一段距离，防止出现判断错误的情况
dis1=0;
if exist('count1')
    it=count1;
else
    it=7;
end
%防止出现数组越界的情况，越界的情况下向上做平均
if rowA-it<=0||rowD+it>size(DescendData,1)
    
    for i=1:it
    dis1_1=SphereDist(AscendData(rowA+i,1:2),DescendData(rowD-i,1:2));    %向上做平均
    dis1=dis1+dis1_1;
    end
else
    for i=1:it
    dis1_1=SphereDist(AscendData(rowA-i,1:2),DescendData(rowD+i,1:2));    %向下做平均
    dis1=dis1+dis1_1;
    end
end
dis1=dis1/i;


dis2=0;
%利用更多的点计算升降轨向上平移后的距离，防止出现判断错误的情况
%如果距离边界比较近，则大概率数据点分布十分离散，增加求均值的点数的数量

if exist('count1')
    it=count1;
else
    it=7;
end
%防止数组越界的情况
if rowA+count+it>size(AscendData,1)||rowD-count-i<=0
    for i=1:3      %若往上方向越界，则用下方3个点的平均距离与下方7个点的平均距离比较
    dis2_1=SphereDist(AscendData(rowA-i,1:2),DescendData(rowD+i,1:2));  
    dis2=dis2+dis2_1;
    end
    dis2=dis2/i;
else
    for i=1:it
    dis2_1=SphereDist(AscendData(rowA+count+i,1:2),DescendData(rowD-count-i,1:2));  
    dis2=dis2+dis2_1;
    end
    dis2=dis2/i;
end





    if dis1<dis2      %精确点位置位于概略点位置之下
       direction='down';
    else              %精确点位置位于概略点位置之上
          direction='up';     
    end
end


%% 3、从具体方向寻找交叉点精确位置

for it=1:2
    P1_A_row=rowA;
    P1_D_row=rowD;

%进行循环判断   第一个循环的目的：寻找距离小于2km的升轨点和降轨点
for i=1:100
    %防止发生数组越界的保护
    if  strcmp(direction,'down')==1   
        if P1_A_row<=0||P1_D_row>size(DescendData,1)
            break;
        end   
    end
    
     if  strcmp(direction,'up')==1   
        if P1_A_row+1>size(AscendData,1)||P1_D_row<=0   %加1是升轨点不能向上平移的情况
            break;
        end   
    end
    
    P1_A=AscendData(P1_A_row,1:2);    
    P1_D=DescendData(P1_D_row,1:2);
    dis=SphereDist(P1_A,P1_D);
    
    if dis <3  %3km内才进行是否相交的判断
        


        latitudeDif=abs(P1_A(2)-P1_D(2));
        if latitudeDif>0.02
         if  strcmp(direction,'up')==1    %向上寻找的重置情况 
            if P1_A(2)>P1_D(2)    %降轨点的纬度值更低，升轨点重置
                P1_A_row=SearchClosestValue(AscendData(:,2),P1_D(2));   %最近的升轨行
                   P1_A=AscendData(P1_A_row,1:2); 

            else                   %升轨点的纬度值更低，降轨点重置
                 P1_D_row=SearchClosestValue(DescendData(:,2),P1_A(2));   %最近的升轨行
                   P1_D=DescendData(P1_D_row,1:2); 
            end
         else                             %向下寻找的重置情况
              if P1_A(2)>P1_D(2)    %降轨点的纬度值更低，降轨点重置
               P1_D_row=SearchClosestValue(DescendData(:,2),P1_A(2));   %最近的升轨行
                   P1_D=DescendData(P1_D_row,1:2); 
              else                  %升轨点的纬度值更低，升轨点重置
                    P1_A_row=SearchClosestValue(AscendData(:,2),P1_D(2));   %最近的升轨行
                   P1_A=AscendData(P1_A_row,1:2);   
              end
           end
        end
             %调试 画出距离小于2km的升轨点和降轨点
        scatter(AscendData(P1_A_row,1),AscendData(P1_A_row,2),10,'r','d');
        scatter(DescendData(P1_D_row,1),DescendData(P1_D_row,2),10,'b','d');

        P1_D_row_start=P1_D_row;  %记录开始的降轨移动点，方便复位        
        
         %防止升轨点移动的过程中越界
          if  strcmp(direction,'up')==1 
            if (P1_A_row+50)>size(AscendData,1)
                maxK=size(AscendData,1)-P1_A_row;
            else
                 maxK=50;
            end
        else
            if (P1_A_row-50)<=0
                maxK=P1_A_row-1;
            else
                 maxK=50;
            end
          end
        
        %以升轨点位基础判断是否相交，第二个循环的目的：升轨点移动(在降轨点移动一个序列移动完成后)
        for k=1:maxK
        
        P1_A=AscendData(P1_A_row,1:2); %第一个升轨点移动
        %建立第二个升轨点
        if  strcmp(direction,'up')==1   
            P2_A=AscendData(P1_A_row+1,1:2);
            P1_A_row=P1_A_row+1;
        else                         
            P2_A=AscendData(P1_A_row-1,1:2);
            P1_A_row=P1_A_row-1;
        end
     
%          调试 画出移动的升轨点        
         scatter(P2_A(1),P2_A(2),15,'r','d');
           plot([P1_A(1),P2_A(1)],[P1_A(2),P2_A(2)],'linewidth',3,'color','r');
           
                    P1_D_row=P1_D_row_start;  % 降轨点复位
                P1_D=DescendData(P1_D_row,1:2);
                %建立第二个降轨点
       if  strcmp(direction,'up')==1   
            P2_D=DescendData(P1_D_row-1,1:2);
        else                         
            P2_D=DescendData(P1_D_row+1,1:2);
       end
       
%            %调试 画出相交的升降轨点
           scatter(P1_A(1),P1_A(2),15,'r','d');
           scatter(P2_A(1),P2_A(2),15,'r','d');
           scatter(P1_D(1),P1_D(2),15,'b','d');
           scatter(P2_D(1),P2_D(2),15,'b','d');
                
            
        %防止降轨点移动越界
        if  strcmp(direction,'down')==1 
            if (P1_D_row_start+50)>size(DescendData,1)
                maxIt=size(DescendData,1)-P1_D_row_start;
            else
                 maxIt=50;
            end
        else
            if (P1_D_row_start-50)<=0
                maxIt=P1_D_row_start-1;
            else
                 maxIt=50;
            end
        end
            for j=1:maxIt   %第三个循环的目的：降轨点移动
                
                if IsCross(P1_A,P2_A,P1_D,P2_D)==1  %找到了交叉点的情况
                    
                    
                    
%                  调试 画出产生交叉点的两条线段                            
                 plot([P1_A(1),P2_A(1)],[P1_A(2),P2_A(2)],'linewidth',3);
                 plot([P1_D(1),P2_D(1)],[P1_D(2),P2_D(2)],'linewidth',3);
%                   
                    CP=getCrossOverPoint(P1_A,P2_A,P1_D,P2_D);
                    %判断所求交叉点是否在边界内
                   [in]= inpolygon(CP(1),CP(2),Boundary(:,1),Boundary(:,2));
                   if (in)
                    ExactPosition=CP;
                   else   %不再边界内时返回空值
                    ExactPosition=[];   
                   end
                    
%                     调试 画出交叉点的精确位置
                    scatter(CP(1),CP(2),88,'b','s');
                    return;
                else 
                    
%                调试 画出移动的降轨点
 scatter(P2_D(1),P2_D(2),15,'b','d');
 plot([P1_D(1),P2_D(1)],[P1_D(2),P2_D(2)],'linewidth',3,'color','b');   %降轨点移动
                    P1_D=P2_D;
                    if  strcmp(direction,'up')==1
                        P1_D_row=P1_D_row-1;
                        P2_D=DescendData(P1_D_row,1:2);
                    else
                         P1_D_row=P1_D_row+1;
                        P2_D=DescendData(P1_D_row,1:2);
                    end                               
                end
            end

%               
%             %升轨点移动
%                P1_A=P2_A;
%                 if  strcmp(direction,'up')==1
%                      P1_A_row=P1_A_row+1;
%                     P2_A=AscendData(P1_A_row,1:2);
%                 else
%                      P1_A_row=P1_A_row-1;
%                     P2_A=AscendData(P1_A_row,1:2);
%                 end
                               
        end 
        
        
        break;
      
    else            %大于1km时往更接近的点靠近
        if dis>5    %距离过大时减少迭代的次数
              epsilon=3;    %最小递增值
        else 
              epsilon=1;
        end
        
        if  strcmp(direction,'up')==1   %向上寻找
            P1_D_row=P1_D_row-epsilon;
            P1_A_row=P1_A_row+epsilon;
        else                            %向下寻找
            P1_D_row=P1_D_row+epsilon;
            P1_A_row=P1_A_row-epsilon;
        end   
    end
end
       if  strcmp(direction,'up')==1   
             direction='down';
        else                         
             direction='up';
       end
end
ExactPosition=[];
end

