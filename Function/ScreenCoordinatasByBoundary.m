function [ OutputTrackInfo ] = ScreenCoordinatasByBoundary(InputTrackInfo,Boundary)
%Function：筛选出位于不规则边界内的数据
%Input：1、InputTrackInfo(待筛选的轨道数据)2、Boundary(边界的经纬度数据，第一位为经度，第二位为纬度)
%Output：OutputTrackInfo(筛选完的轨道数据)

OutputTrackInfo=[];  %用于输出筛选完后的数据，每行代表一个轨道的截取数据  

 h = waitbar(0,'Please wait...');    
for i=1:size(InputTrackInfo,1)
   s=sprintf('Simulation in process:%d',i);
     waitbar(i/size(InputTrackInfo,1),h,s );
  % computation here %
            
neededCor=[];
temp=InputTrackInfo(i);
cor=getfield(temp,'coordinate');   

% hold on;
% plot(cor(:,1),cor(:,2));

rectangleCor=ScreenCoordinatasRegularly(cor,[166,199.7],[-82.6,-78.75]);
if (size(rectangleCor)~=0)
logc1 = ismember(cor,rectangleCor,'rows')
index=find(logc1==1);
cor(index,:)=[];
end
longtitude=cor(:,1);      %该轨道所有的经度数据
latitude=cor(:,2);        %该轨道所有的纬度数据
height=cor(:,3);
time=cor(:,4);
%%
  for  j=1:size(longtitude)       %逐点判断是否位于边界内，保留在边界内的点
    %为了增加程序的执行速度，先判断是否在矩形框内
%       if(longtitude(j)>=166&&longtitude(j)<=199.7&&latitude(j)>=-82.6&&latitude(j)<=-78.75)
%            neededCor=[neededCor;longtitude(j),latitude(j),height(j),time(j)];   %逐点添加筛选完同一轨道的数据
%       else 

        [in,on]= inpolygon(longtitude(j),latitude(j),Boundary(:,1),Boundary(:,2));
        if (in==1||on==1)
        neededCor=[neededCor;longtitude(j),latitude(j),height(j),time(j)];   %逐点添加筛选完同一轨道的数据
        end
        
%       end
  end 
%%  
  if (size(neededCor)~=0|size(rectangleCor)~=0)
      neededCor=[neededCor;rectangleCor];
      neededCor=sortrows(neededCor,4); %按时间升序排序后再保存
    trackInfo = struct('coordinate',neededCor);
    OutputTrackInfo=[OutputTrackInfo;trackInfo];
  end 
      %判断程序的执行速度
end


