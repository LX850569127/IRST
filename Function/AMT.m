function [OutputPoint] = AMT(CorA,CorD,InputPoint,Boundary)
% AMT工具求解交叉点调用及优化
% CorA:升轨的所有数据点,CorD:降轨的所有数据点，InputPoint:交叉点概略位置
% OutputPoint:交叉点精确位置，不存在时输出为空
%% 
%对升、降轨进行裁切，以提高运行速度


% 
LonRange=[InputPoint(1)-1.5,InputPoint(1)+1.5];       %经度范围   
LatRange=[InputPoint(2)-0.51,InputPoint(2)+0.51];       %纬度范围

A=ScreenCoordinatasRegularly(CorA,LonRange,LatRange);
D=ScreenCoordinatasRegularly(CorD,LonRange,LatRange);

% Clipped region
% scatter(A(:,1),A(:,2),10,[127 140 141]/255,'filled');
% scatter(D(:,1),D(:,2),10,[127 140 141]/255,'filled');
% rectangle('Position' ,[InputPoint(1)-1.5,InputPoint(2)-0.51,3,1.02],'Linewidth' ,2,'LineStyle','-','EdgeColor','k')


if size(A,1)<=1 || size(D,1)<=1 
    OutputPoint=[];
    return;
end

[lat,lon]=crossovers([A(:,2);D(:,2)],[A(:,1);D(:,1)],'SizeA',size(A,1),'tile','off');
if lon<0
    lon=180+180-abs(lon);
end
CrossOver_AMT=[lon,lat];
OutputPoint=[];

%        hold on;
%        scatter(CrossOver_AMT(:,1),CrossOver_AMT(:,2),88,'p','b','filled');
       
if ~isempty(CrossOver_AMT)   %输出多个交叉点的情况，选择距离升降轨最近的交叉点
    [in]= inross(CrossOver_AMT(:,1),CrossOver_AMT(:,2),Boundary);
%       hold on;
%        scatter(CrossOver_AMT(:,1),CrossOver_AMT(:,2),88,'p','b','filled');
%    
    if sum(in)==1   %只有一个点在边界内时直接赋值
        OutputPoint=CrossOver_AMT(in,:);
    elseif sum(in)>1   %有多个点在边界内时选取距离插值点最接近的一个点
        CrossOver_AMT=CrossOver_AMT(in,:);
% %      
        dis=zeros(size(CrossOver_AMT,1),1);
        for i=1:size(CrossOver_AMT,1)
            x=CrossOver_AMT(i,1);  
            y=CrossOver_AMT(i,2);  %经纬度
            
            
            ind=find(CorA(:,2)>=y);
            Top_Cor_A=CorA(ind,:);        %上方的升轨点
            ind=find(CorA(:,2)<y);
            Bot_Cor_A=CorA(ind,:);       %下方的升轨点
            
            ind=find(CorD(:,2)>=y);
            Top_Cor_D=CorD(ind,:);        %上方的降轨点
            ind=find(CorD(:,2)<y);
            Bot_Cor_D=CorD(ind,:);       %下方的降轨点 
            
            [dis1,row1]=min(distance([x,y],Top_Cor_A(:,1:2)));
            [dis2,row2]=min(distance([x,y],Bot_Cor_A(:,1:2)));
            [dis3,row3]=min(distance([x,y],Top_Cor_D(:,1:2)));
            [dis4,row4]=min(distance([x,y],Bot_Cor_D(:,1:2)));  
            
%             A1=Top_Cor_A(row1,1:2);
%             A2=Bot_Cor_A(row2,1:2);
%             B1=Top_Cor_D(row3,1:2);
%             B2=Bot_Cor_D(row4,1:2);
%             
%             list=[A1;A2;B1;B2];
%             if i==4
%             scatter(list(:,1),list(:,2),30,'r');
%             end
            dis(i)=mean([dis1,dis2,dis3,dis4]);       
                       
        end
        OutputPoint=CrossOver_AMT(find(sum(dis,2)==min(sum(dis,2))),:);
        end
end

end

