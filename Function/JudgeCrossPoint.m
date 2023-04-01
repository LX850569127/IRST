function [ cross_data ] = JudgeCrossPoint( ascending_data,descending_data )
%Function：判断升轨数据和降轨数据间是否存在交叉点
%Input：ascending_data(升轨数据)、descending_data(降轨数据)
%Output：cross_data(具有交叉点的升轨和降轨数据,同一行的两个结构体)

index=1;   % counting the number of the combinations of CP

if isfield(ascending_data(1),'correctionPar')
  cross_data = struct('coordinate',[],'flag_AD',[],'orbitNum',[],'correctionPar',[]);
else
  cross_data = struct('coordinate',[],'flag_AD',[],'orbitNum',[]);
end

cross_data=repmat(cross_data,[size(ascending_data,1)*size(descending_data,1) 2]);

for i=1:size(ascending_data,1)
    cor_A=getfield(ascending_data(i),'coordinate');
    AMinX=min(cor_A(:,1));    %上升弧段最小经度
    AMaxX=max(cor_A(:,1));    %上升弧段最大经度
    AMinY=min(cor_A(:,2));    %上升弧段最小纬度
    AMaxY=max(cor_A(:,2));    %上升弧段最大纬度
    for j=1:size(descending_data,1)
        cor_D=getfield(descending_data(j),'coordinate');
        DMinX=min(cor_D(:,1));    %下降弧段最小经度
        DMaxX=max(cor_D(:,1));    %下降弧段最大经度
        DMinY=min(cor_D(:,2));    %下降弧段最小纬度
        DMaxY=max(cor_D(:,2));    %下降弧段最大纬度
                
      %矩形相交的情况
      if  AMinX <= DMaxX && AMaxX >= DMinX && AMinY <= DMaxY && AMaxY >= DMinY
         temp_data=[ascending_data(i,:),descending_data(j,:)];
         cross_data(index,:)=temp_data; %建立一个新的存储交叉轨道数据的结构体
         index=index+1;
      end 
    end
end

cross_data=cross_data(1:index-1,:);
end



