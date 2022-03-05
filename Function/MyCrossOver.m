function [ CrossOverPointOutput ] = PrecisePositionOfCrossOver( Ascending_data,Descending_data,AdjustBoundary)
%Function：求相互交叉的升降轨之间的交叉点的精确位置以及两个不同时间的高程值
%Input：ascending_data(升轨数据)、Descending_data(降轨数据)
%Output：CrossOverPoint(交叉点的位置以及两个不同时间的高程值)

% hold on;   %保持在原有图像上绘图
%% 一、求粗略位置
cor_A=Ascending_data.coordinate;
cor_D=Descending_data.coordinate;
coefficient=[];           %拟合得到的二次曲线的系数
%升轨拟合
cor=Ascending_data.coordinate;
cor=cor(:,1:2);
xA=cor(:,2);    %纬度
yA=cor(:,1);    %经度
p=polyfit(xA,yA,2);
yA=p(1).*xA.*xA+p(2).*xA+p(3);  %拟合后的经度
coefficient=[coefficient;p];

%降轨拟合
cor=Descending_data.coordinate;
cor=cor(:,1:2);
xD=cor(:,2);    %纬度
yD=cor(:,1);    %经度

p=polyfit(xD,yD,2);
yD=p(1).*xD.*xD+p(2).*xD+p(3);  %拟合后的经度
coefficient=[coefficient;p];


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

% 调试 画出升降轨的卫星脚点的原始分布
% scatter(cor_A(:,1),cor_A(:,2),10,[127 140 141]/255,'filled','HandleVisibility','off');  
% scatter(cor_D(:,1),cor_D(:,2),10,[127 140 141]/255,'filled');  %color [0 140 141]/255
%  调试 画出拟合后的升轨曲线和降轨曲线
% plot1 = plot(yA,xA,'-.','Color',[0 0 0]/255,'LineWidth',2,'HandleVisibility','off');
% plot2 =plot(yD,xD,'-.','Color',[0 0 0]/255,'LineWidth',2);
% 调试 画出拟合后的概略点位置
% scatter(CursoryCrossPoint(1),CursoryCrossPoint(2),80,'r','d','filled');



%判断3
%若粗略位置是因为曲线过短导致的错误解，通过该点与升降轨的纬度差进行剔除
min1=min(abs(cor_A(:,2)-CursoryCrossPoint(2)))+min(abs(cor_D(:,2)-CursoryCrossPoint(2)));
if min1>0.1  %纬度差的最小值
    CrossOverPointOutput=[];
    return;
end
% 



%% 二、求精确位置

%方法一 迭代法
% CrossOverPoint=IterationOfCursoryLocation(cor_A,cor_D,CursoryCrossPoint,AdjustBoundary,10,35);
% scatter(CrossOverPoint(1),CrossOverPoint(2),200,'p','k','filled');

%方法二 跨立交叉法
%1) 自己写的
% CrossOverPoint1=ExactPosition2(cor_A,cor_D,CursoryCrossPoint,AdjustBoundary);
%     scatter(CrossOverPoint1(1),CrossOverPoint1(2),88,'p','k','filled');
%2) AMT工具的交叉法
% [lat,lon]=crossovers([cor_A(:,2);cor_D(:,2)],[cor_A(:,1);cor_D(:,1)],'SizeA',size(cor_A,1),'tile','off');
% if lon<0
%     lon=180+180-abs(lon);
% end
% CrossOver_AMT=[lon,lat];
% CrossOverPoint=[];
%   
% if ~isempty(CrossOver_AMT)   %输出多个交叉点的情况，选择距离升降轨最近的交叉点
%     [in]= inross(CrossOver_AMT(:,1),CrossOver_AMT(:,2),AdjustBoundary);
%  
%     if sum(in)==1   %只有一个点在边界内时直接赋值
%         CrossOverPoint=CrossOver_AMT(in,:);
%     elseif sum(in)>1   %有多个点在边界内时选取距离插值点最接近的一个点
%         CrossOver_AMT=CrossOver_AMT(in,:);
%         
%        hold on;
%        scatter(CrossOver_AMT(:,1),CrossOver_AMT(:,2),88,'p','b','filled');
%       
%         dis=zeros(size(CrossOver_AMT,1),1);
%         for i=1:size(CrossOver_AMT,1)
%             x=CrossOver_AMT(i,1);  
%             y=CrossOver_AMT(i,2);  %经纬度
%                         
%             ind=find(cor_A(:,2)>=y);
%             Top_Cor_A=cor_A(ind,:);        %上方的升轨点
%             ind=find(cor_A(:,2)<y);
%             Bot_Cor_A=cor_A(ind,:);       %下方的升轨点
%             
%             ind=find(cor_D(:,2)>=y);
%             Top_Cor_D=cor_D(ind,:);        %上方的降轨点
%             ind=find(cor_D(:,2)<y);
%             Bot_Cor_D=cor_D(ind,:);       %下方的降轨点 
%             
%             [dis1,row1]=min(distance([x,y],Top_Cor_A(:,1:2)));
%             [dis2,row2]=min(distance([x,y],Bot_Cor_A(:,1:2)));
%             [dis3,row3]=min(distance([x,y],Top_Cor_D(:,1:2)));
%             [dis4,row4]=min(distance([x,y],Bot_Cor_D(:,1:2)));  
%             
%             A1=Top_Cor_A(row1,1:2);
%             A2=Bot_Cor_A(row2,1:2);
%             B1=Top_Cor_D(row3,1:2);
%             B2=Bot_Cor_D(row4,1:2);
%             
%             list=[A1;A2;B1;B2];
%             if i==4
%             scatter(list(:,1),list(:,2),30,'r');
%             end          
%             dis(i)=mean([dis1,dis2,dis3,dis4]);                            
%         end
%         CrossOverPoint=CrossOver_AMT(find(sum(dis,2)==min(sum(dis,2))),:);
%     end
% end

% 
%  debug
% hold on;
% scatter(CrossOverPoint(:,1),CrossOverPoint(:,2),88,'p','k','filled');

% % 优化后的AMT方法
CrossOverPoint= AMT(cor_A,cor_D,CursoryCrossPoint,AdjustBoundary);
% scatter(CrossOverPoint(:,1),CrossOverPoint(:,2),200,'p','b','filled');

%方法三 改进的迭代法
% Tangent=SolveTangent(CursoryCrossPoint,coefficient);    %求第一次粗略位置的两条切线
% [NumOfIterativePoints]=DetermineNumberOfIterations(cor_A,cor_D,CursoryCrossPoint,Tangent);  %求第一次迭代的迭代点数
% CrossOverPoint=IterationOfCursoryLocation(cor_A,cor_D,CursoryCrossPoint,AdjustBoundary,10,NumOfIterativePoints,Tangent,true);

%  scatter(CrossOverPoint(1),CrossOverPoint(2),88,'p','k','filled');
% %调试 为了对比两种不同方法的精确位置结果
% if ~isempty(CrossOverPoint)

%     hold on;
%     scatter(CrossOverPoint1(1),CrossOverPoint1(2),88,'p','r','filled');
% end
%如果返回交叉点位置的矩阵为空，说明该交叉点位于边界之外，直接返回
% if ~isequal(CrossOverPoint1,CrossOverPoint)
%      a=1;
% end
if isempty(CrossOverPoint)
    CrossOverPointOutput=[];
    return;
end 



%% 三、求交叉点的两个高程以及对应的时间

%% 反距离加权插值
% %3.1 交叉点升轨高程计算
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
% % scatter(interpolationPointOfA(:,1),interpolationPointOfA(:,2),30,'r');
% %剔除距离过大的点
% interpolationPointOfA(interpolationPointOfA(:,5)>2,:)=[];
% 
% %剔除高程值异常的点，高程>2000&&<-55
% interpolationPointOfA(interpolationPointOfA(:,3)>2000,:)=[];
% interpolationPointOfA(interpolationPointOfA(:,3)<-55.5,:)=[];
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
% % scatter(interpolationPointOfD(:,1),interpolationPointOfD(:,2),30,'b');
% %剔除距离过大的点
% interpolationPointOfD(interpolationPointOfD(:,5)>2,:)=[];
% 
% %剔除高程值异常的点，高程>2000&&<-55
% interpolationPointOfD(interpolationPointOfD(:,3)>2000,:)=[];
% interpolationPointOfD(interpolationPointOfD(:,3)<-55.5,:)=[];
% 
% %如果在升轨或者降轨中用于对交叉点高程进行插值的点距离交叉点的位置均过远，舍弃该交叉点
% if isempty(interpolationPointOfD)
%     CrossOverPointOutput=[];
%     return;
% end 
% 
% % 调试 画出用于高程插值的升轨点和降轨点
% % hold on;
% % scatter(interpolationPointOfA(:,1),interpolationPointOfA(:,2),30,'r');
% % scatter(interpolationPointOfD(:,1),interpolationPointOfD(:,2),30,'b');
% 
% 
% % 通过距离加权得到高程
% % 权重计算
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
% time_D=cor_D(rowOfCloset,4);

%% 线性插值 

    
    x=CrossOverPoint(1);  %经度
    y=CrossOverPoint(2);  %纬度

    ind=find(cor_A(:,2)>=y);
    Top_Cor_A=cor_A(ind,:);       %上方的升轨点
    ind=find(cor_A(:,2)<y);
    Bot_Cor_A=cor_A(ind,:);       %下方的升轨点

    ind=find(cor_D(:,2)>=y);
    Top_Cor_D=cor_D(ind,:);       %上方的降轨点
    ind=find(cor_D(:,2)<y);
    Bot_Cor_D=cor_D(ind,:);       %下方的降轨点 
    
 
    f=pi/180*6371.393;
    [dis1,row1]=min(distance([y,x],[Top_Cor_A(:,2),Top_Cor_A(:,1)]));
    [dis2,row2]=min(distance([y,x],[Bot_Cor_A(:,2),Bot_Cor_A(:,1)]));
    [dis3,row3]=min(distance([y,x],[Top_Cor_D(:,2),Top_Cor_D(:,1)]));
    [dis4,row4]=min(distance([y,x],[Bot_Cor_D(:,2),Bot_Cor_D(:,1)]));  
   
    
    A1=[Top_Cor_A(row1,:),dis1*f];
    A2=[Bot_Cor_A(row2,:),dis2*f];
    B1=[Top_Cor_D(row3,:),dis3*f];
    B2=[Bot_Cor_D(row4,:),dis4*f];
    
    A=[A1;A2];
    B=[B1;B2];
    
%     useful for debugging        
%     scatter(A(:,1),A(:,2),50,'k','filled');
%     scatter(B(:,1),B(:,2),50,'k','filled','HandleVisibility','off');  

%     A( A(:,3)>2000| A(:,3)<-55.5|A(:,5)>2,:)=[];
%     B( B(:,3)>2000| B(:,3)<-55.5|B(:,5)>2,:)=[];
    
   if sum(A(:,5)>25)+ sum(B(:,5)>25)>0
        CrossOverPointOutput=[];
        return;
   end
   
    A( A(:,5)>2,:)=[];
    B( B(:,5)>2,:)=[];

%     if size(A,1)<=1||size(B,1)<=1
%         CrossOverPointOutput=[];
%         return;
%     end
    
    if isempty(A)||isempty(B)
        CrossOverPointOutput=[];
        return;
    end
    
    PDOP=mean([ A(:,5);B(:,5)]);   %位置偏差
    
    % 升轨插值
    if size(A,1)>1
        altitude_A=A1(3)+(A2(3)-A1(3))*(y-A1(2))/(A2(2)-A1(2));   %根据纬度
    else
        altitude_A=A(3);  %唯一值
    end
    
    % 降轨插值
     if size(B,1)>1
        altitude_D=B1(3)+(B2(3)-B1(3))*(y-B1(2))/(B2(2)-B1(2));   %根据纬度
    else
        altitude_D=B(3);  %唯一值
     end
    
    
    % useful for debugging     
%     scatter(A(:,1),A(:,2),30,'b');
%     scatter(B(:,1),B(:,2),30,'b');  
    
    %时间任取一个即可，两个点之间的时间差距为0.1s
    
    time_A=A(1,4);
    time_D=B(1,4);   

    
    % caculating the correction value based on the lineal model

%     if isfield(Ascending_data,'correctionPar')
%         correctionPar_A=Ascending_data.correctionPar;
%         if sum(correctionPar_A)~=0
%             a0_A=correctionPar_A(1);
%             a1_A=correctionPar_A(2);
%             delta_h_A=a0_A+a1_A*(time_A-min(cor_A(:,4)));
%             altitude_A=altitude_A+delta_h_A;
%         end 
% 
%         correctionPar_D=Descending_data.correctionPar;
%         if sum(correctionPar_D)~=0
%             a0_D=correctionPar_D(1);
%             a1_D=correctionPar_D(2);
%             delta_h_D=a0_D+a1_D*(time_D-min(cor_D(:,4)));
%             altitude_D=altitude_D+delta_h_D;
%         end 
%     end

     % caculating the correction value based on 验后条件平差  
     
     A=altitude_A-altitude_D;
    if isfield(Ascending_data,'correctionPar')
    par=Ascending_data.correctionPar;   % parameters of the error model 
    sizeOfPar=size(par,2);
    s_t=min(cor_A(:,4));
    e_t=max(cor_A(:,4));
    d_t=time_A-s_t;
    w=2*pi/(e_t-s_t);
    if ~isempty(par)
        switch sizeOfPar
            case 1
                ft_a=par;
            case 2
                ft_a=par(1)+par(2)*d_t;
            case 4
                ft_a=par(1)+par(2)*d_t+par(3)*cos(w*d_t)+par(4)*sin(w*d_t);
            case 6 
                ft_a=par(1)+par(2)*d_t+par(3)*cos(w*d_t)+par(4)*sin(w*d_t)...
                   +par(5)*cos(2*w*d_t)+par(6)*sin(2*w*d_t);
            case 8
                ft_a=par(1)+par(2)*d_t+par(3)*cos(w*d_t)+par(4)*sin(w*d_t)...
                   +par(5)*cos(2*w*d_t)+par(6)*sin(2*w*d_t)...
                   +par(7)*cos(3*w*d_t)+par(8)*sin(3*w*d_t);
        end
        altitude_A=altitude_A-ft_a;
    end
 
    par=Descending_data.correctionPar;   % parameters of the error model 
    sizeOfPar=size(par,2);
    s_t=min(cor_D(:,4));
    e_t=max(cor_D(:,4));
    d_t=time_D-s_t;
    w=2*pi/(e_t-s_t);
    if ~isempty(par)
        switch sizeOfPar
            case 1
                ft_d=par;
            case 2
                ft_d=par(1)+par(2)*d_t;
            case 4
                ft_d=par(1)+par(2)*d_t+par(3)*cos(w*d_t)+par(4)*sin(w*d_t);
            case 6 
                ft_d=par(1)+par(2)*d_t+par(3)*cos(w*d_t)+par(4)*sin(w*d_t)...
                   +par(5)*cos(2*w*d_t)+par(6)*sin(2*w*d_t);
            case 8
                ft_d=par(1)+par(2)*d_t+par(3)*cos(w*d_t)+par(4)*sin(w*d_t)...
                   +par(5)*cos(2*w*d_t)+par(6)*sin(2*w*d_t)...
                   +par(7)*cos(3*w*d_t)+par(8)*sin(3*w*d_t);
        end
        altitude_D=altitude_D-ft_d;
    end
 
   A=altitude_A-altitude_D;
%% 
% hold on;
% scatter(CrossOverPoint(1),CrossOverPoint(2),100,'p','k','filled');
% if ~isequal(CrossOverPoint1,CrossOverPoint)
%      a=1;
% end

% 四、结果导出
% 调试 绘制交叉点的精确位置
% 为方便比较 导出形成交叉点的升轨轨道号与降轨轨道号 
orbitNum_A=Ascending_data.orbitNum;    %升轨轨道号
orbitNum_D=Descending_data.orbitNum;   %降轨轨道号

CrossOverPointOutput= struct('coordinate',CrossOverPoint, 'orbitNum_A',orbitNum_A, 'orbitNum_D',orbitNum_D,...
'altitude_A',altitude_A,'altitude_D',altitude_D,'time_A',time_A,'time_D',time_D,...
  'PDOP',PDOP); 
%%
end

