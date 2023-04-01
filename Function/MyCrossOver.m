function [ CrossOverPointOutput ] = PrecisePositionOfCrossOver( Ascending_data,Descending_data,AdjustBoundary,bof_flag)
%Function：求相互交叉的升降轨之间的交叉点的精确位置以及两个不同时间的高程值
%Input：ascending_data(升轨数据)、Descending_data(降轨数据)
% bof_flag 是否使用平差后的改正参数
%Output：CrossOverPoint(交叉点的位置以及两个不同时间的高程值)

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
%若粗略位置是因为曲线过短导致的错误解，通过该点与升降轨的纬度差进行剔除
min1=min(abs(cor_A(:,2)-CursoryCrossPoint(2)))+min(abs(cor_D(:,2)-CursoryCrossPoint(2)));
if min1>0.1  %纬度差的最小值
    CrossOverPointOutput=[];
    return;
end

%% 二、求精确位置

CrossOverPoint= AMT(cor_A,cor_D,CursoryCrossPoint,AdjustBoundary);

if isempty(CrossOverPoint)
    CrossOverPointOutput=[];
    return;
end 

%% 三、求交叉点的两个高程以及对应的时间

% 线性插值 
 
    x=CrossOverPoint(1);  %longitude of the crossover 
    y=CrossOverPoint(2);  %latitude of the crossover 

    ind=find(cor_A(:,2)>=y);
    Top_Cor_A=cor_A(ind,:);       %上方的所有升轨点
    ind=find(cor_A(:,2)<y);
    Bot_Cor_A=cor_A(ind,:);       %下方的所有升轨点

    ind=find(cor_D(:,2)>=y);
    Top_Cor_D=cor_D(ind,:);       %上方的所有降轨点
    ind=find(cor_D(:,2)<y);
    Bot_Cor_D=cor_D(ind,:);       %下方的所有降轨点 
    
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

%     A( A(:,3)>2000| A(:,3)<-55.5|A(:,5)>2,:)=[];
%     B( B(:,3)>2000| B(:,3)<-55.5|B(:,5)>2,:)=[];
   
    A( A(:,5)>2,:)=[];
    B( B(:,5)>2,:)=[];
    
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
    
    %时间任取一个即可，两个点之间的时间差距为0.1s
    
    time_A=A(1,4);
    time_D=B(1,4);   
    
     % caculating the correction value based on 验后条件平差  
     
    if strcmp(bof_flag,'AA')
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
    end
    
%% 四、结果导出
% 调试 绘制交叉点的精确位置
% 为方便比较 导出形成交叉点的升轨轨道号与降轨轨道号 
orbitNum_A=Ascending_data.orbitNum;    %升轨轨道号
orbitNum_D=Descending_data.orbitNum;   %降轨轨道号

CrossOverPointOutput= struct('coordinate',CrossOverPoint, 'orbitNum_A',orbitNum_A, 'orbitNum_D',orbitNum_D,...
'altitude_A',altitude_A,'altitude_D',altitude_D,'time_A',time_A,'time_D',time_D,...
  'PDOP',PDOP); 

end

