Region='Amery'; 
Baseline='D';                              
StoragePath=strcat('.\Variate\',Region,'\','baseline_',Baseline,'\');   
load(strcat(strcat('.\Variate\',Region,'\'),Region,'Boundary.mat'));
%% 1.某格网中两周期数据计算得到多个交叉点的情况，利用中误差进行剔除并选取最佳值

% 1)利用中误差进行剔除
% rmse=sqrt(sum((dh-mean(dh)).^2)/(size(dh,1)-1));
% dh(abs(dh-mean(dh))>=2*rmse,:)=[]; 

% 2)取中间几个变化值的平均值
% dh=sort(dh);
% numOfdh=size(dh,1);
 
% if numOfdh>=4 

%     rejectNum=floor(numOfdh/4);
%     startingNum=1+rejectNum;
%     endingNum=numOfdh-rejectNum;

%     ec=mean(dh(startingNum:endingNum)); 
% end
 
% elevationChange(10,1)=ec;
% elevationChange(10,2)=size(dh,1);
% figure;
% scatter(coordinate(:,1),coordinate(:,2),4,'filled');
% hold on; % scatter(centralPoint(1),centralPoint(2),10);
% w=longInterval;
% h=latInterval;
% x=centralPoint(1)-w/2;
% y=centralPoint(2)-h/2;
% hold on;
% rectangle('Position',[x,y,w,h])  %从点(x,y)开始绘制一个宽w高h的矩形，

%3) saving the change of elevations for every period

% eleChange(1,1)=mean(dh);
% eleChange(1,2)=size(dh,1);

%% 2.绘图 选择一个交叉点较多的格网进行实验

% 1.Plotting the distribution of crossovers and gird points 

% temp=[];
% dhMat=cell(30,30,2);
% for ii=1:size(dhMat,1)
%     for jj=ii+1
%         ym1=string(ym1Mat(ii,jj));
%         ym2=string(ym2Mat(ii,jj));
%         name_Total_CP=strcat(Region,'_',ym1,'_',ym2); 
%         load(name_Total_CP);
%         temp=[temp;eval(name_Total_CP)];
%         clear(name_Total_CP);
%     end 
% end 
% 
% coordinate=cell2mat({temp(:).coordinate});
% longitude=coordinate(1:2:size(coordinate,2)-1);
% latitude=coordinate(2:2:size(coordinate,2));
% figure;
% scatter(longitude,latitude,10,'filled');
% hold on;
% scatter(178.6864,-82.485,20,'r','filled');
% 
% w=2;
% h=1;
% long=178.6864;
% lat=-82.485;
% x=long-w/2;
% y=lat-h/2;
% hold on;
% rectangle('Position',[x,y,w,h])  %从点(x,y)开始绘制一个宽w高h的矩形，

 %% 3.计算交叉点
  
% 1) 建立矩阵

yearNum=10;
matSize=yearNum*12;
ym1Mat=zeros(matSize,matSize);
for i=1:matSize-1
    for j=i+1:matSize
        if mod(i,12)==0
          ym1Mat(i,j)=201000+ceil(i/12)*100+12;        
        else
          ym1Mat(i,j)=201000+ceil(i/12)*100+mod(i,12);        
        end
   end
end

ym2Mat=zeros(matSize,matSize);
for i=1:matSize-1
    for j=i+1:matSize
         if mod(j,12)==0
             ym2Mat(i,j)=201000+ceil(j/12)*100+12;
         else
             ym2Mat(i,j)=201000+ceil(j/12)*100+mod(j,12);
         end     
    end
end

% 2) 计算交叉点

for ii=1:matSize-1
    for jj=ii+1:matSize
       path=strcat(StoragePath,'CP\row_',num2str(ii,'%03d'),'\');   %CurrentPath is "..\Crossover"
       ym1=string(ym1Mat(ii,jj));
       ym2=string(ym2Mat(ii,jj));
       Ascend=[ym1,ym2];
       Descend=[ym2,ym1];
       disp([ii,jj]);
       name_Total_CP=strcat(Region,'_',ym1,'_',ym2);
       fclose('all');
       
       if(fopen(strcat(path,name_Total_CP,'.mat'))~=-1)  % No determination if the file already exists 
                continue;             
       end       

       for i=1:2
        name_A=strcat(Region,'_A',Ascend(i));
        name_D=strcat(Region,'_D',Descend(i));
        name_CP=strcat(Region,'_A',Ascend(i),'_D',Descend(i));       
        char_a=char(Ascend(i));
        char_d=char(Descend(i));
        load(strcat(StoragePath,char_a(1:4),'\Ascend\',name_A));  
        load(strcat(StoragePath,char_d(1:4),'\Descend\',name_D));  
        
        couple=JudgeCrossPoint(eval(name_A),eval(name_D));
        sizeOfCouple=size(couple,1);
        corssOver= struct('coordinate',[], 'orbitNum_A',[], 'orbitNum_D',[],...
            'altitude_A',[],'altitude_D',[], 'time_A',[],'time_D',[],'PDOP',[]); 
        CP=repmat(corssOver,[sizeOfCouple 1]);
        ind=1;
        for j=1:sizeOfCouple
            out= MyCrossOver(couple(j,1),couple(j,2),Boundary,'AA');
            if ~isempty(out)
                CP(ind)=out;
                ind = ind+1;
            end
               close all;
        end
        CP=CP(1:ind-1);   
        eval(strcat(name_CP,'=CP;'));     
       end

         % merging crossovers in the same period

         AD=strcat(Region,'_A',ym1,'_D',ym2);
         DA=strcat(Region,'_A',ym2,'_D',ym1);
         Set=[eval(AD);eval(DA)];
         eval(strcat(name_Total_CP,'=Set;'));
         fileName=strcat(name_Total_CP,'.mat');
         if ~exist(path,'dir')
               mkdir(path); 
         end
         save(strcat(path,fileName),name_Total_CP); 
         clear -regexp ^Amery
    end
end


%% 4. 寻找格网内的交叉点并建立高程变化时间矩阵

% 格网中心点坐标和格网大小


SpecificGrid=[195,-80.5]; 
longInterval=1; latInterval=0.5;
dhMat=cell(matSize,matSize,2);

% 1) 寻找该格网内所有周期的交叉点

for ii=1:matSize-1
     disp(ii);
     path=strcat(StoragePath,'CP\','row_',num2str(ii,'%03d'),'\');
    for jj=ii+1:matSize
       
        ym1=string(ym1Mat(ii,jj));
        ym2=string(ym2Mat(ii,jj));
        name_Total_CP=strcat(Region,'_',ym1,'_',ym2); 
                
        load(strcat(path,name_Total_CP));
        
        eval(strcat('CP=',name_Total_CP,';'));
        coor=cell2mat({CP(:).coordinate});
        long=coor(1:2:size(coor,2)-1).';
        lat=coor(2:2:size(coor,2)).';
        coordinate=[long,lat];    
        delta_long=abs(long-SpecificGrid(1));
        delta_lat=abs(lat-SpecificGrid(2));
        index=(delta_long<longInterval/2)&(delta_lat<latInterval/2);
        pickedPoints=CP(index,:);       % crossovers in the grid
              
        % remove inaccurate data 
        ele_dif=abs(cell2mat({pickedPoints(:).altitude_A}).'-cell2mat({pickedPoints(:).altitude_D}).');
        pickedPoints(ele_dif>=15)=[];
        
        orbitNum_A=Get_filed_val(pickedPoints,'orbitNum_A');
        orbitNum_D=Get_filed_val(pickedPoints,'orbitNum_D');     
        nAD=sum(orbitNum_A<orbitNum_D);
        nDA=sum(orbitNum_A>orbitNum_D);
        adEleDif=zeros(nAD,1);  %  height diference formed by a descending track minus an ascending track 
        daEleDif=zeros(nDA,1);  %  height diference formed by an ascending track minus an descending track 
        k=1;m=1;
        for i=1:size(pickedPoints,1)    % calculating the elevetion changes of each point.
                altitude_A=pickedPoints(i).altitude_A;
                altitude_D=pickedPoints(i).altitude_D;
                time_A=pickedPoints(i).time_A;
                time_D=pickedPoints(i).time_D;
                dm=abs(time_A-time_D)/60/60/24/30;  % 间隔月份 
                PDOP=CP(i).PDOP;
                if time_A<time_D        
                    elevationChange=altitude_D-altitude_A;     
                    adEleDif(k)=elevationChange/dm*(jj-ii);    % 准确规划到月份
                    k=k+1;                        
                else 
                    elevationChange=altitude_A-altitude_D;   
                    daEleDif(m)=elevationChange/dm*(jj-ii);
                    m=m+1;
                end         
%                 if elevationChange>=5
%                     a=1;
%                 end
        end
          dhMat(ii,jj,1)= {adEleDif};
          dhMat(ii,jj,2)= {daEleDif};
          clear(name_Total_CP);
    end
end

% % 2) 利用升-降交叉点和降-升交叉点计算高程变化的平均值
dhMat1=dhMat(:,:,1);
dhMat2=dhMat(:,:,2);
dhMeanMat=zeros(matSize,matSize);
for ii=1:matSize-1
    for jj=ii+1:matSize
        adEleDif= cell2mat(dhMat(ii,jj,1));
        daEleDif= cell2mat(dhMat(ii,jj,2));
        nAD=size(adEleDif,1);
        nDA=size(daEleDif,1);
        if nAD==0||nDA==0
          dhMeanMat(ii,jj)=mean([adEleDif;daEleDif]);
        else
          dhMeanMat(ii,jj)=mean(adEleDif)*nAD/(nAD+nDA)+mean(daEleDif)*nDA/(nAD+nDA);
        end 
    end
end

%% 利用不同的方法建立高程变化时间序列

% 1) 只选择矩阵第一行
ORM=dhMeanMat(1,:).';

% 2) 选择矩阵次对角线
DIA=zeros(matSize,1);
for ii=1:matSize-1
       jj=ii+1;
       dia(ii)=dhMeanMat(ii,jj);
       DIA(ii+1)=DIA(ii)+dhMeanMat(ii,jj);
end
% 
% % 3) FFM方法
% FFM方法需要对矩阵进行处理，补全下三角矩阵 
% 该方法的总路线数为N-1, N为周期数，
% 可调整参数：
FFMat=zeros(matSize,matSize);

for i=1:matSize       %row 
    for j=1:matSize   %column 
        if i>j&&j~=1
            FFMat(i,j)=dhMeanMat(1,i)-dhMeanMat(j,i);
        else
           FFMat(i,j)=dhMeanMat(i,j);
        end
    end 
end

FFM=zeros(1,matSize);
for j=2:matSize  % column
    eledif=0;
    for i=1:matSize  % row
        if i<j && i==1
            eledif=eledif+FFMat(i,j);  % 第一行元素直接为相对于第一月的高程变化
        elseif i<j && i~=1
            temp=FFMat(i,j)+FFMat(1,i);
            eledif=eledif+temp;
        elseif i>j
            eledif=eledif+FFMat(i,j);
        end
    end
    FFM(j)=eledif/(matSize-1);   
end
FFM=FFM.';


% % 4) 对次对角矩阵进行平差的方法
numOfEquation=0;

for i=1:size(dhMeanMat,2)-1
    numOfEquation=numOfEquation+i;
end

% 建立系数矩阵B，矩阵L
numOfX=size(dhMeanMat,1)-1;     % 参数个数
B=zeros(numOfEquation,numOfX);
L=zeros(numOfEquation,1);

% 从矩阵第一行从左往右的观测值开始建立观测方程
index=1;      

for i=1:size(dhMeanMat,1)-1                       % 行数循环
     numOfObservations=size(dhMeanMat,2)-i;        % 行数与该行所对应的观测值个数的关系
     startingColum=1+i;                           % 每行的起始循环列
     for j=startingColum:size(dhMeanMat,2)        % 列数循环
         if i==1
             B(index,j-1)=1;
             L(index)=0;
         else
             B(index,i-1)=-1;
             B(index,j-1)=1;
             L(index)=dhMeanMat(1,j)-dhMeanMat(1,i)-dhMeanMat(i,j);
         end
         index=index+1;
     end
end
L=-L;
% P=diag(ones(numOfEquation,1));
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


% 是
index=1;
for i=1:size(dhMeanMat,1)-1                       % 行数循环
     startingColum=1+i;                           % 每行的起始循环列
     for j=startingColum:size(dhMeanMat,2)        % 列数循环
       if size(cell2mat(dhMat1(i,j)),1)+size(cell2mat(dhMat2(i,j)),1)==0
          L(index)=[];
          B(index,:)=[];
          P(index,:)=[];
          P(:,index)=[];
          index=index-1;
       end  
       index=index+1;
     end
end
% 求解未知参数的最小二乘解,并添加到
x=inv(B.'*P*B)*B.'*P*L; 

V=B*x+L;
Qxx=inv(B.'*P*B);
sigma_0_ad=sqrt(V.'*P*V)/(sum(1:matSize-1)-(matSize-1));
sigma_x_ad=sigma_0_ad*sqrt(Qxx);

DIA_ad=zeros(matSize,1);
for jj=2:matSize  
       dia=dhMeanMat(1,jj)+x(jj-1);
       DIA_ad(jj)=DIA_ad(jj)+dia;
end

%% illustrate 
% temp=[];
% dhMat=cell(60,60,2);
% for ii=1:59
%                                                                                                                                            for jj=ii+1
%         ym1=string(ym1Mat(ii,jj));
%         ym2=string(ym2Mat(ii,jj));
%         name_Total_CP=strcat(Region,'_',ym1,'_',ym2); 
%         load(name_Total_CP);
%         temp=[temp;eval(name_Total_CP)];
%         clear(name_Total_CP);
%     end 
% end 
% 
% coordinate=cell2mat({temp(:).coordinate});
% longitude=coordinate(1:2:size(coordinate,2)-1);
% latitude=coordinate(2:2:size(coordinate,2));
% figure;
% scatter(longitude,latitude,10,'filled');


