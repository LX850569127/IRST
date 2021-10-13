function [OutCoor] = preprocess(Coor)

sizeOfCoor=size(Coor,1);
dis=zeros(sizeOfCoor,2);

for i=1:sizeOfCoor
    if i==1
       dis(i,:)=SphereDist([Coor(i,1),Coor(i,2)],[Coor(i+1,1),Coor(i+1,2)])*1000;
    elseif i==sizeOfCoor
       dis(i,:)=SphereDist([Coor(i,1),Coor(i,2)],[Coor(i-1,1),Coor(i-1,2)])*1000;
    else 
       dis(i,1)=SphereDist([Coor(i,1),Coor(i,2)],[Coor(i-1,1),Coor(i-1,2)])*1000;   %与前一点的距离
       dis(i,2)=SphereDist([Coor(i,1),Coor(i,2)],[Coor(i+1,1),Coor(i+1,2)])*1000;   %与后一点的距离
    end
end
sd=std(dis(2:end,1));
meanVal=mean(dis(2:end,1));
threshold=meanVal+3*sd;

[i]=find(dis(:,1)>=threshold&dis(:,2)>=threshold);
Coor(i,:)=[];
OutCoor=Coor;
end

