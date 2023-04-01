function [OutCoor] = preprocess(Coor)
% Function: Eliminate points deviating from the track. 
% Input：
% Coor:Coordinate before processing
% Output：
% OutCoor:Coordinate after processing 
%%
% 计算轨道中所有点与其前面1点及前面2点的平均距离作为前距离，后1点及后2点的平均距离作为后距离，
% 若前距离与后距离均大于其3倍中误差，则认定该点偏离轨道较远，作为粗差点进行剔除。

% Calculate the distance between the point and the first point in front of it 
% and the distance between the point and the second point in front of it.
% The average value of two distances is the front-distance, and the back-distance is caculated with the same way.

% If both the front-distance and theback-distance are greater than 3 RMSE, 
% this point deviates far from the track and is removed as a gross error.
%%
deletedPoint=[];         %用于记录剔除后的点，存储剔除后的点在原坐标中的索引
OutCoor=[];
sizeOfCoor=size(Coor,1);

numOfSegs=4;                                 % number of the segments after segmentation.
numOfPoints=floor(sizeOfCoor/numOfSegs);     % number of the points of every segment.
coorCell=cell(numOfSegs,1);
outCoorCell=cell(numOfSegs,1);               % output coordinate cell. 

coorCell{numOfSegs,1}=Coor((numOfSegs-1)*numOfPoints+1:end,:);
for i=1:numOfSegs-1
    coorCell{i,1}=Coor((i-1)*numOfPoints+1:i*numOfPoints,:);
end


for i=1:numOfSegs
    tempCoor=coorCell{i};
    sizeOfTempCoor=size(tempCoor,1);
    dis=zeros(sizeOfTempCoor,2);

    % The distance between the point and its previous point.      adjDis(adjacent distance)
    adjDis=distance(tempCoor(2:end,2),tempCoor(2:end,1),tempCoor(1:end-1,2),tempCoor(1:end-1,1))*pi/180*6371.393*1000;
    % The distance between the point and its front second point . frsDis
    frsDis=distance(tempCoor(3:end,2),tempCoor(3:end,1),tempCoor(1:end-2,2),tempCoor(1:end-2,1))*pi/180*6371.393*1000;

%% method 1 
    refDis=mean([adjDis(1:end-1),frsDis],2);
    sd=std(refDis);
    meanVal=mean(refDis);    
    threshold=meanVal+3*sd;
    
    dis(1,:)=[adjDis(1),adjDis(1)];
    dis(2,1)=adjDis(1);
    dis(2,2)=mean([adjDis(2),frsDis(2)]);
    dis(end,:)=[adjDis(end),adjDis(end)];
    dis(end-1,1)=mean([adjDis(end-1),frsDis(end-1)]);
    dis(end-1,2)=adjDis(end);

    dis(3:end-2,1)=mean([adjDis(2:end-2),frsDis(1:end-2)],2); 
    dis(3:end-2,2)=mean([adjDis(3:end-1),frsDis(3:end)],2);
%% method 2 
% Calculate the distance between the point and the first point in front of it only.
%     sd=std(adjDis);
%     meanVal=mean(adjDis);    
%     threshold=meanVal+3*sd;
% 
%     dis(1,:)=[adjDis(1),adjDis(1)];
%     dis(end,:)=[adjDis(end),adjDis(end)];
%     dis(2:end-1,:)=[adjDis(1:end-1),adjDis(2:end)];
%%
    [j]=find(dis(:,1)>=threshold&dis(:,2)>=threshold);
    deletedPoint=[deletedPoint;tempCoor(j,:)];% 输出被剔除掉的点 
    tempCoor(j,:)=[];
    outCoorCell{i,1}=tempCoor;
end
 
for i=1:numOfSegs
    OutCoor=[OutCoor;outCoorCell{i,1}];
end 

% 调试
figure('color','w')
hold on;
box on;
scatter(OutCoor(:,1),OutCoor(:,2),12,'filled','b');
scatter(deletedPoint(:,1),deletedPoint(:,2),40,'filled','r');
legend('Data Points','Deleted Points');
xlabel('Longitude');
ylabel('Latitude');
set(gca,'fontsize',14);
close all;

end

