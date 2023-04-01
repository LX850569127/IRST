
function [Output_Coordinates] = ScreenCoordinatasRegularly(Input_Coordinates,Longtitude_Range,Latitude_Range)
%Function：筛选规则范围的经纬度坐标 
%Input：1.Input_Coordinates(待筛选的坐标, the first column is longitude, the secend column is latitude.)、2.Longtitude_Range(经度筛选范围,[min,max])3.Latitude_Range(纬度筛选范围[min,max])
%Output：Output_Coordinates(筛选完成后的坐标,没有满足条件的坐标时输出空矩阵)

Output_Coordinates=[];

%截取指定纬度
temp=find(Input_Coordinates(:,2)>=Latitude_Range(:,1) & Input_Coordinates(:,2)<=Latitude_Range(:,2));  
if size(temp)~=0
  range_Coordinate=zeros(size(temp,1),size(Input_Coordinates,2));
  for i=1:size(temp,1)
     range_Coordinate(i,:)=Input_Coordinates(temp(i,:),:);
  end 
else
    return
end 

 %截取指定经度(需要特别注意东经与西经的问题)
 if (Longtitude_Range(:,2)>180)  %如果输入的截止经度大于180度，说明截取范围是西经
     longtitude=range_Coordinate(:,1);
     longtitude(longtitude<0)=180+(180-abs(longtitude(longtitude<0)));  %对经度进行归化，西经改为正方向上的东经
     range_Coordinate(:,1)=longtitude;
 end 
 
temp1=find(range_Coordinate(:,1)>=Longtitude_Range(:,1) & range_Coordinate(:,1)<=Longtitude_Range(:,2));  
if size(temp1)~=0
  range_Coordinate1=zeros(size(temp1,1),size(Input_Coordinates,2));
  for i=1:size(temp1,1)
     range_Coordinate1(i,:)=range_Coordinate(temp1(i,:),:);
  end 
  Output_Coordinates=range_Coordinate1;  
end 
end

