Region='Ross';     

% 1) gathering crossovers within the same interval period

% year1=2011;
% year2=2012;
% 
% if ~exist('name_TotalCP','var')
%     name_TotalCP=strcat(Region,'_',num2str(year1),'_',num2str(year2));
% end
% 
% if ~exist('totalCP','var')
%    totalCP=[];
% end
% 
% year_A=2012;   year_D=2011;   
% startMonth=1;  endMonth=12;
% Ascend=strings([endMonth-startMonth+1,1]);
% Descend=strings([endMonth-startMonth+1,1]);
% 
% for i=startMonth:endMonth
%     month=zerosFill(i);
%     ym_A=strcat(num2str(year_A),month);
%     ym_D=strcat(num2str(year_D),month);
%     Ascend(i-startMonth+1)=ym_A;
%     Descend(i-startMonth+1)=ym_D;
%     name_CP=strcat(Region,'_A',Ascend(i),'_D',Descend(i));
%     CP=eval(name_CP);
%     totalCP=[totalCP;CP];
% end
% eval(strcat(name_TotalCP,'=totalCP'));

%2) searching for the crossovers in the grid 
% elevationChange=zeros(10,2);

% centralPoint=[178.6864,-82.485]; 
% longInterval=0.34394; latInterval=0.045;
% 
% year1=2014; year2=2015;
% name_TotalCP=strcat(Region,'_',num2str(year1),'_',num2str(year2));
% totalCP=eval(name_TotalCP);
% 
% coor=cell2mat({totalCP(:).coordinate});
% long=coor(1:2:size(coor,2)-1).';
% lat=coor(2:2:size(coor,2)).';
% coordinate=[long,lat];
% 
% delta_long=abs(long-centralPoint(1));
% delta_lat=abs(lat-centralPoint(2));
% index=(delta_long<longInterval/2)&(delta_lat<latInterval/2);
% coordinate=coordinate(index,:);
% gridCP=totalCP(index,:);      % crossovers in the grid
% 
% dh=zeros(size(gridCP,1),1);
% for i=1:size(gridCP,1)
%     if gridCP(i).orbitNum_A<gridCP(i).orbitNum_D
%         dh(i)=gridCP(i).altitude_D-gridCP(i).altitude_A;
%     else
%         dh(i)=gridCP(i).altitude_A-gridCP(i).altitude_D;
%     end
% end
% 
% 
% 
% % 格网内多个交叉点求其平均高程变化的方式
% % 1、利用中误差进行剔除
% % rmse=sqrt(sum((dh-mean(dh)).^2)/(size(dh,1)-1));
% % dh(abs(dh-mean(dh))>=2*rmse,:)=[]; 
% % 2、取中间几个变化值的平均值
% dh=sort(dh);
% numOfdh=size(dh,1);
% 
% if numOfdh>=4 
%     rejectNum=floor(numOfdh/4);
%     startingNum=1+rejectNum;
%     endingNum=numOfdh-rejectNum;
%     ec=mean(dh(startingNum:endingNum)); 
% end
% 
% elevationChange(10,1)=ec;
% elevationChange(10,2)=size(dh,1);
% figure;
% scatter(coordinate(:,1),coordinate(:,2),4,'filled');
% hold on; 
% scatter(centralPoint(1),centralPoint(2),10);
% w=longInterval;
% h=latInterval;
% x=centralPoint(1)-w/2;
% y=centralPoint(2)-h/2;
% hold on;
% rectangle('Position',[x,y,w,h])  %从点(x,y)开始绘制一个宽w高h的矩形，

%3) saving the change of elevations for every period

% eleChange(1,1)=mean(dh);
% eleChange(1,2)=size(dh,1);


%% 当格网中得某个delta_H存在多个交叉点时，利用中误差进行剔除并选取最佳值
% delta_h=zeros(5,5);
% delta_h(1,2:5)=elevationChange(1:4,1);
% delta_h(2,3:5)=elevationChange(5:7,1);
% delta_h(3,4:5)=elevationChange(8:9,1);
% delta_h(4,5:5)=elevationChange(10:10,1);
% 
% % 观测方程个数
% numOfEquation=0;
% 
% for i=1:size(delta_h,2)-2
%     numOfEquation=numOfEquation+i;
% end
% 
% % 建立系数矩阵B，矩阵L
% numOfX=size(delta_h,1)-1;     %未知数个数,等于矩阵对角线元素减1
% B=zeros(numOfEquation,numOfX);
% L=zeros(numOfEquation,1);
% % 从矩阵第一行从左往右的观测值开始建立观测方程
% index=1;      
% for i=1:size(delta_h,1)-2                       % 行数循环
%      numOfObservations=size(delta_h,2)-i-1;     % 行数与该行所对应的观测值个数的关系
%      startingColum=2+i;                         % 每行的起始循环列
%      for j=startingColum:size(delta_h,2)        % 列数循环
%           B(index,i:j-1)=1;                     % 确定每个观测方程的系数     
%           row=i:j-1;
%           column=i+1:j;
%           for k=1:size(row,2)
%             L(index)=L(index)+delta_h(row(k),column(k));
%           end
%             L(index)=L(index)-delta_h(i,j);
%           index=index+1;
%      end
% end
% L=-L;
% P=diag(ones(numOfEquation,1));

% 求解未知参数的最小二乘解,并添加到
% x=inv(B.'*P*B)*B.'*P*L; 
% adjusted_delta_h=zeros(size(delta_h));
% for i=1:size(x,1)   
%       adjusted_delta_h(i,i+1)=delta_h(i,i+1)-x(i);
% end

%% 挑选一个单独的格网作为试验区
Region='Ross';
StoragePath=strcat('E:\Sync\Master\Project\Crossover\Variate\',Region,'\');  
load(strcat(Region,'Boundary.mat'));

% 1.Plotting the distribution of crossovers and gird points 
% 
% coordinate=cell2mat({Ross_201101_201102(:).coordinate}).';
% longitude=coordinate(1:2:size(coordinate,1)-1);
% latitude=coordinate(2:2:size(coordinate,1));
% figure('color','w');
% scatter(longitude,latitude,5,[241 64 64]/255,'filled');
% hold on;
% scatter(178.6864,-82.485,20,'b','filled');

% for i=1:size(rossGridEdited,1)   
%      long=rossGridEdited(i).long;
%      lat=ones(size(long))*rossGridEdited(i).lat;
%      scatter(long,lat,4,'filled');
%      w=rossGridEdited(i).longInterval;
%      h=0.045;
%      for j=1:size(long)      
%          x=long(j)-w/2;
%          y=lat(1)-h/2;
%          hold on;
%          rectangle('Position',[x,y,w,h])  %从点(x,y)开始绘制一个宽w高h的矩形，
%      end
% end

% 2.Determining crossovers 

% different array of periods
ym1Mat=zeros(60,60);
for i=1:59
    for j=i+1:60
        if mod(i,12)==0
          ym1Mat(i,j)=201000+ceil(i/12)*100+12;        
        else
          ym1Mat(i,j)=201000+ceil(i/12)*100+mod(i,12);        
        end
   end
end

ym2Mat=zeros(60,60);
for i=1:59
    for j=i+1:60
         if mod(j,12)==0
             ym2Mat(i,j)=201000+ceil(j/12)*100+12;
         else
             ym2Mat(i,j)=201000+ceil(j/12)*100+mod(j,12);
         end     
    end
end
 
% for ii=1:71
%     for jj=ii+1:72
%        storagePath=strcat('.\Variate\',Region,'\CP\Row',string(ii),'\');   %CurrentPath is "..\Crossover"
%        ym1=string(ym1Mat(ii,jj));
%        ym2=string(ym2Mat(ii,jj));
%        Ascend=[ym1,ym2];
%        Descend=[ym2,ym1];
%        disp([ii,jj]);
%        name_Total_CP=strcat(Region,'_',ym1,'_',ym2);
%        fclose('all');
%        if(fopen(strcat(storagePath,name_Total_CP,'.mat'))~=-1)  % No determination if the file already exists 
%                 continue;
%              
%        end       
%        
%        for i=1:2
%         name_A=strcat(Region,'_A',Ascend(i));
%         name_D=strcat(Region,'_D',Descend(i));
%         name_CP=strcat(Region,'_A',Ascend(i),'_D',Descend(i));       
%         load(name_A);  
%         load(name_D);  
%         couple=JudgeCrossPoint(eval(name_A),eval(name_D));
%         sizeOfCouple=size(couple,1);
%         corssOver= struct('coordinate',[], 'orbitNum_A',[], 'orbitNum_D',[],...
%             'altitude_A',[],'altitude_D',[], 'time_A',[],'time_D',[],'PDOP',[]); 
%         CP=repmat(corssOver,[sizeOfCouple 1]);
%         ind=1;
%         for j=1:sizeOfCouple
%             out= MyCrossOver(couple(j,1),couple(j,2),Boundary);
%             if ~isempty(out)
%                 CP(ind)=out;
%                 ind = ind+1;
%             end
%                close all;
%         end
%         CP=CP(1:ind-1);   
%         eval(strcat(name_CP,'=CP'));     
%        end
%     
%          % merging crossovers in the same period
%       
%          AD=strcat(Region,'_A',ym1,'_D',ym2);
%          DA=strcat(Region,'_A',ym2,'_D',ym1);
%          Set=[eval(AD);eval(DA)];
%          eval(strcat(name_Total_CP,'=Set'));
%          fileName=strcat(name_Total_CP,'.mat');
%          if ~exist(storagePath,'dir')
%                mkdir(storagePath); 
%          end
%          save(strcat(storagePath,fileName),name_Total_CP); 
%          clear -regexp ^Ross
%     end
% end


% 3. Searching for the crossover in the specific grid

% SpecificGrid=[178.0114,-82.62]; 
% longInterval=0.5; latInterval=0.25;
% 
% yms1=ones(1,12)*201101;
% yms2=zeros(1,12); 
% for i=1:12
%     yms2(i)=strcat("2012",zerosFill(i));
% end
% 
% gridCP=cell(1,12); 
% 
% for m=1:12
% 
%     ym1=string(yms1(m));
%     ym2=string(yms2(m));
%     
%     name_Total_CP=strcat(Region,'_',ym1,'_',ym2); 
%     eval(strcat('CP=',name_Total_CP));
%     coor=cell2mat({CP(:).coordinate});
%     long=coor(1:2:size(coor,2)-1).';
%     lat=coor(2:2:size(coor,2)).';
%     coordinate=[long,lat];    
%     delta_long=abs(long-SpecificGrid(1));
%     delta_lat=abs(lat-SpecificGrid(2));
%     index=(delta_long<longInterval/2)&(delta_lat<latInterval/2);
%     pickedPoints=CP(index,:);       % crossovers in the grid
%     eleDif=zeros(size(pickedPoints,1),1);
%     for i=1:size(pickedPoints,1)    % calculating the elevetion changes of each point.
%             altitude_A=pickedPoints(i).altitude_A;
%             altitude_D=pickedPoints(i).altitude_D;
%             time_A=pickedPoints(i).time_A;
%             time_D=pickedPoints(i).time_D;
%             PDOP=CP(i).PDOP;
%             if time_A<time_D        
%                 elevationChange=altitude_D-altitude_A;        
%             else 
%                 elevationChange=altitude_A-altitude_D;   
%             end      
%             eleDif(i)=elevationChange;
%     end
%      
%     if ~isempty(eleDif)
%       gridCP(m)={eleDif};      
%     end
% end
% 

%% 4. forming the matrix of elevation diferences in the bin.

% 1.
SpecificGrid=[178.0114,-82.62]; 
longInterval=1; latInterval=0.5;

% dhMat=cell(60,60,2);
% for ii=1:59
%     for jj=ii+1:60
%         ym1=string(ym1Mat(ii,jj));
%         ym2=string(ym2Mat(ii,jj));
%         name_Total_CP=strcat(Region,'_',ym1,'_',ym2); 
%         load(name_Total_CP);
%         eval(strcat('CP=',name_Total_CP));
%         coor=cell2mat({CP(:).coordinate});
%         long=coor(1:2:size(coor,2)-1).';
%         lat=coor(2:2:size(coor,2)).';
%         coordinate=[long,lat];    
%         delta_long=abs(long-SpecificGrid(1));
%         delta_lat=abs(lat-SpecificGrid(2));
%         index=(delta_long<longInterval/2)&(delta_lat<latInterval/2);
%         pickedPoints=CP(index,:);       % crossovers in the grid
%         orbitNum_A=cell2mat({pickedPoints(:).orbitNum_A});
%         orbitNum_D=cell2mat({pickedPoints(:).orbitNum_D});
%         nAD=sum(orbitNum_A<orbitNum_D);
%         nDA=sum(orbitNum_A>orbitNum_D);
%         adEleDif=zeros(nAD,1);  %  height diference formed by a descending track minus an ascending track 
%         daEleDif=zeros(nDA,1);  %  height diference formed by an ascending track minus an descending track 
%         k=1;m=1;
%         for i=1:size(pickedPoints,1)    % calculating the elevetion changes of each point.
%                 altitude_A=pickedPoints(i).altitude_A;
%                 altitude_D=pickedPoints(i).altitude_D;
%                 time_A=pickedPoints(i).time_A;
%                 time_D=pickedPoints(i).time_D;
%                 PDOP=CP(i).PDOP;
%                 if time_A<time_D        
%                     elevationChange=altitude_D-altitude_A;    
%                     adEleDif(k)=elevationChange;
%                     k=k+1;
%                 else 
%                     elevationChange=altitude_A-altitude_D;   
%                     daEleDif(m)=elevationChange;
%                     m=m+1;
%                 end           
%         end
%           dhMat(ii,jj,1)= {adEleDif};
%           dhMat(ii,jj,2)= {daEleDif};
%           clear(name_Total_CP);
%     end
% end
% 
% dhMat1=dhMat(:,:,1);
% dhMat2=dhMat(:,:,2);
% dhMeanMat=zeros(60,60);
% for ii=1:size(dhMeanMat,1)-1
%     for jj=ii+1:size(dhMeanMat,1)
%         adEleDif= cell2mat(dhMat(ii,jj,1));
%         daEleDif= cell2mat(dhMat(ii,jj,2));
%         nAD=size(adEleDif,1);
%         nDA=size(daEleDif,1);
%         if nAD==0||nDA==0
%           dhMeanMat(ii,jj)=mean([adEleDif;daEleDif]);
%         else
%           dhMeanMat(ii,jj)=mean(adEleDif)*nAD/(nAD+nDA)+mean(daEleDif)*nDA/(nAD+nDA);
%         end 
%     end
% end
% 
ORM=dhMeanMat(1,:).';
DIA=zeros(60,1);
for ii=1:59
       jj=ii+1;
       dia(ii)=dhMeanMat(ii,jj);
       DIA(ii+1)=DIA(ii)+dhMeanMat(ii,jj);
end


%% 对高程变化矩阵的对角元素(相邻期的高程变化)进行平差

numOfEquation=0;

for i=1:size(dhMeanMat,2)-2
    numOfEquation=numOfEquation+i;
end

% 建立系数矩阵B，矩阵L
numOfX=size(dhMeanMat,1)-1;     %未知数个数,等于矩阵对角线元素减1
B=zeros(numOfEquation,numOfX);
L=zeros(numOfEquation,1);

% 从矩阵第一行从左往右的观测值开始建立观测方程
index=1;      

for i=1:size(dhMeanMat,1)-2                       % 行数循环
     numOfObservations=size(dhMeanMat,2)-i-1;     % 行数与该行所对应的观测值个数的关系
     startingColum=2+i;                           % 每行的起始循环列
     for j=startingColum:size(dhMeanMat,2)        % 列数循环
          B(index,i:j-1)=1;                       % 确定每个观测方程的系数     
          row=i:j-1;
          column=i+1:j;
          for k=1:size(row,2)
            L(index)=L(index)+dhMeanMat(row(k),column(k));
          end
            L(index)=dhMeanMat(i,j)-L(index);
          index=index+1;
     end
end

P=diag(ones(numOfEquation,1));
% 根据交叉点数量重新确定权矩阵
P=zeros(numOfEquation,numOfEquation);
index=1;
for i=1:size(dhMeanMat,1)-2                       % 行数循环
     startingColum=2+i;                           % 每行的起始循环列
     for j=startingColum:size(dhMeanMat,2)        % 列数循环
        P(index,index)=size(cell2mat(dhMat1(i,j)),1)+size(cell2mat(dhMat2(i,j)),1);
        index=index+1;
     end
end

% 求解未知参数的最小二乘解,并添加到
x=inv(B.'*P*B)*B.'*P*L; 
DIA_ad=zeros(60,1);
for ii=1:59
       jj=ii+1;
       dia=dhMeanMat(ii,jj)+x(ii);
       DIA_ad(ii+1)=DIA_ad(ii)+dia;
end

%% illustrate 
temp=[];
dhMat=cell(60,60,2);
for ii=1:59
    for jj=ii+1
        ym1=string(ym1Mat(ii,jj));
        ym2=string(ym2Mat(ii,jj));
        name_Total_CP=strcat(Region,'_',ym1,'_',ym2); 
        load(name_Total_CP);
        temp=[temp;eval(name_Total_CP)];
        clear(name_Total_CP);
    end 
end 

coordinate=cell2mat({temp(:).coordinate});
longitude=coordinate(1:2:size(coordinate,2)-1);
latitude=coordinate(2:2:size(coordinate,2));
figure;
scatter(longitude,latitude,10,'filled');