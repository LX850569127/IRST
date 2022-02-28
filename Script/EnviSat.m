
%% 一、读取N1文件中的坐标和高程数据并保存成变量形式
for j=1:1   %月份
    year=2011;  %年份
    FolderPath=strcat('G:\Postgraduate Career\EnviSat\原始数据\',num2str(year),'\',num2str(j),'\结果');     %文件路径
    filesPath = dir(fullfile(FolderPath,'*.N1'));  
    fileNumber=size(filesPath);
    Output_TrackInfo=[]; %定义输出坐标、高程以及时间信息的矩阵
    %1)读取经纬度坐标、高程信息、时间并进行存储
    bar=waitbar(0,'正在读取数据');
parfor i=1:fileNumber(1)
        str=['正在读取数据',num2str(i/fileNumber(1)*100),'%'];
        Inpath=strcat(FolderPath,'\',filesPath(i,:).name);
        fileName= filesPath(i,:).name;
        absOrbit=str2num(fileName(50:54));
        tempData=load(Inpath);
        if ~isempty(tempData)
            lon=tempData(:,1);
            lat=tempData(:,2);
            height=tempData(:,3);
            time=tempData(:,5);
            waitbar(i/fileNumber(1),bar,str);
            trackInfo=struct('longtitude',lon,'latitude',lat,'height',height, ...
                'time',time,'orbitNum',absOrbit);  %存储该轨道对应的所有坐标、高程以及时间信息
            Output_TrackInfo=[Output_TrackInfo;trackInfo];
        end
    end
    variate=strcat('Raw',num2str(year), num2str(j));
    eval([variate '=Output_TrackInfo']);
    
    StoragePath=strcat('G:\Postgraduate Career\EnviSat\读取后数据\',num2str(year),'\');   %存储路径
    fileName=strcat(variate,'.mat');                              %文件名
    save([StoragePath, fileName],variate);
    close(bar);
end

%%  二、绘制2013年EnviSat所有卫星轨迹图
% figure;
% load('FilchneBoundary.mat');
% % plot(FilchneBoundary(:,1),FilchneBoundary(:,2),'k');  %绘制冰架的边界图
% hold on;
% for i=1:1
%     str_Cut=strcat('Raw2003', num2str(i));  
%     tempData=eval(str_Cut);
%     for j=1:1
%        lon=tempData(j).longtitude;
% 
%         lon2=lon(10966:19717,:);
%        lat=tempData(j).latitude;
%        lat1=lat(1:10965,:);
%        lat2=lat(10966:19717,:);
%        scatter(lon1,lat1,2,[26 111 223]/255,'filled');
% figure;
%        scatter(lon2,lat2,2,[26 111 223]/255,'filled');
%     end
% end

%% 三、对EnviSat数据进行裁剪
for j=1:1               %月份
    year=2011;           %年份    
    Output_TrackInfo=[];
    Str_Raw=strcat('Raw',num2str(year),num2str(j));
    Raw=eval(Str_Raw);
    for i=1:size(Raw,1)
        coordinate=[Raw(i).longtitude, Raw(i).latitude,Raw(i).height,Raw(i).time];
        range_Coordinate=ScreenCoordinatasRegularly(coordinate,[274.5,335.2],[-84,-74]);  %筛选出符合经纬度要求的数据
        if (size(range_Coordinate)~=0)
        trackInfo=struct('longtitude',range_Coordinate(:,1),'latitude',range_Coordinate(:,2),'height',range_Coordinate(:,3), ...
        'time',range_Coordinate(:,4),'orbitNum',Raw(i).orbitNum   );  %存储该轨道对应的所有坐标、高程
        Output_TrackInfo=[Output_TrackInfo;trackInfo];
        end
    end
    variate=strcat('Cut',num2str(year),num2str(j));
    eval([variate '=Output_TrackInfo']); 
    StoragePath=strcat('G:\Postgraduate Career\EnviSat\裁剪后数据\',num2str(year),'\');   %存储路径
    fileName=strcat(variate,'.mat');                              %文件名
    save([StoragePath, fileName],variate);
end

%%  四、升降轨分离 
% for m=1:1                 %月份
%     year=2011;            %年份 
%     FIL_A=[];
%     FIL_D=[];
%     Str_Cut=strcat('Cut',num2str(year),num2str(m));   
%     Cut=eval(Str_Cut);
%     for j=1:size(Cut,1)
%         lat=Cut(j).latitude;
%         if size(lat,1)>5   %剔除点数较少的轨迹
%         %     判断轨道的升降轨(第一点的纬度与最后一点的纬度进行比较)
%                 if(lat(1)<lat(end))
%                     ascending_flag='A';
%                     trackInfo= struct('coordinate',[Cut(j).longtitude,Cut(j).latitude,Cut(j).height,Cut(j).time], ...
%                     'ascending_flag',{ascending_flag},'orbitNum',Cut(j).orbitNum);
%                     FIL_A=[FIL_A;trackInfo];
%                 else 
%                    ascending_flag='D';
%                           trackInfo= struct('coordinate',[Cut(j).longtitude,Cut(j).latitude,Cut(j).height,Cut(j).time], ...
%                     'ascending_flag',{ascending_flag},'orbitNum',Cut(j).orbitNum);
%                     FIL_D=[FIL_D;trackInfo]; 
%                 end
%         end
%     end   
%     
%     if m>10
%         variate_FILA=strcat('FIL_A',num2str(year),num2str(m));
%         variate_FILD=strcat('FIL_D',num2str(year),num2str(m));
%     else
%         variate_FILA=strcat('FIL_A',num2str(year),'0',num2str(m));
%         variate_FILD=strcat('FIL_D',num2str(year),'0',num2str(m));
%     end
%     
%     eval([variate_FILA '=FIL_A']);
%     eval([variate_FILD '=FIL_D']);
%     
%     StoragePathA=strcat('G:\Postgraduate Career\EnviSat\裁剪后数据\',num2str(year),'\升轨\');   %升轨存储路径
%     StoragePathD=strcat('G:\Postgraduate Career\EnviSat\裁剪后数据\',num2str(year),'\降轨\');   %降轨存储路径
%     
%     fileNameA=strcat(variate_FILA,'.mat');
%     save([StoragePathA, fileNameA],variate_FILA);
%     fileNameD=strcat(variate_FILD,'.mat');
%     save([StoragePathD, fileNameD],variate_FILD);
% end

%% 以半年为一个周期 汇总半年内的升轨与降轨
% A20111_3=[];
% for i=1:3
%     variate_FILA=strcat('FIL_A2011', num2str(i));
%     FILA=eval(variate_FILA);
%     A20111_3=[A20111_3;FILA];
% end
% 
% D20111_3=[];
% for i=1:3
%     variate_FILA=strcat('FIL_D2011', num2str(i));
%     FILA=eval(variate_FILA);
%     D20111_3=[D20111_3;FILA];
% end

% 绘制升降轨分离后的曲线
% figure;
% plot(FilchneBoundary(:,1),FilchneBoundary(:,2),'.k','MarkerSize',0.2 );  %绘制冰架的边界图
% hold on;
% %绘制升轨
% for i=1:size(FIL_A20031,1)
%     lon=FIL_A20031(i).longtitude;
%     lat=FIL_A20031(i).latitude;
%     scatter(lon,lat,2,[241 64 64]/255,'filled');
%     hold on;
% end
% %绘制降轨
% for i=1:size(D20031_6,1)
%     lon=D20031_6(i).longtitude;
%     lat=D20031_6(i).latitude;
%     scatter(lon,lat,2,[26 111 223]/255,'filled');
%     hold on;
% end

%% 五、计算交叉点

% 输入升轨数据
% ascending_data=[];
% yearA=2003;
% monthA=1;
% variate_FILA=strcat('FIL_A',num2str(yearA),num2str(monthA));
% FILA=eval(variate_FILA);
% for i=1:size(FILA,1)
%      cor=[FILA(i).longtitude,FILA(i).latitude,FILA(i).height];
%      trackInfo= struct('coordinate',cor);
%      ascending_data=[ascending_data;trackInfo];
% end
% 
% % 输入降轨数据
% descending_data=[];
% yearD=2011;
% monthD=1;
% variate_FILD=strcat('FIL_D',num2str(yearD),num2str(monthD));
% FILD=eval(variate_FILD);
% for i=1:size(FILD,1)
%      cor=[FILD(i).longtitude,FILD(i).latitude,FILD(i).height];
%      trackInfo= struct('coordinate',cor);
%      descending_data=[descending_data;trackInfo];
% end
% 
% Combine=JudgeCrossPoint(ascending_data,descending_data);
% 
figure;
% plot(FilchneBoundary(:,1),FilchneBoundary(:,2),'.k','MarkerSize',0.2 );  %绘制冰架的边界
hold on;
% 
AllCrossOverPoint=[];
% bar=waitbar(0,'正在计算交叉点');
sizeOfCombine=size(Combine,1);
for m=400:400
     str=['计算交叉点',num2str(m/sizeOfCombine*100),'%'];
%     waitbar(i/sizeOfCombine,bar,str);
    CrossOverPoint=PrecisePositionOfCrossOver(Combine(m,1),Combine(m,2),FilchneBoundary);
    AllCrossOverPoint=[AllCrossOverPoint;CrossOverPoint];
end

variate_CP=strcat('CP_A',num2str(yearA),num2str(monthA),'_D',num2str(yearD),num2str(monthD));
eval([variate_CP '=AllCrossOverPoint']);
% close(bar);

%% 验证1月份所计算的交叉点的位置 
% figure;
% plot(FilchneBoundary(:,1),FilchneBoundary(:,2),'.k','MarkerSize',0.2 );  %绘制冰架的边界图
% hold on;
% for i=1:129     %升轨绘制   
%     longtitude=FIL_A20031(i).longtitude;
%     latitude=FIL_A20031(i).latitude;
%     scatter(longtitude,latitude,2,[26 111 223]/255,'filled');
% end
%  
% for i=1:129     %降轨绘制  
%     longtitude=FIL_D20111(i).longtitude;
%     latitude=FIL_D20111(i).latitude;
%     scatter(longtitude,latitude,2,[26 111 223]/255,'filled');
% end
% 
% for i=1:4211     %交叉点绘制  
%     cor=AllCrossOverPoint(i).coordinate;
%     scatter(cor(1),cor(2),100,'p','k','filled');
% end


%% 对6个月的结果进行误差处理

% All_CP=[];  %存储前6个月所有的交叉点并且计算出高程差
% for j=1:6
%     month=num2str(j);
%     VariateName_CPAD=strcat('CP', '_A2003',month,'_D2011',month); 
%     VariateName_CPDA=strcat('CP', '_A2011',month,'_D2003',month);  
%     
%     CP1=eval(VariateName_CPAD); 
%     CP2=eval(VariateName_CPDA);
%     
%     for i=1:size(CP1,1)
%        altitude=CP1(i).altitude;
%        diff_H=altitude(2,1)-altitude(1,1);
%        CP1(i).altitude=diff_H;
%     end
%    
%      for i=1:size(CP2,1)
%        altitude=CP2(i).altitude;
%        diff_H=altitude(1,1)-altitude(2,1);
%        CP2(i).altitude=diff_H;
%      end     
%      
%      All_CP=[All_CP;CP1;CP2];
% end

%整合6个月所有的交叉点
% All_CP1=zeros(size(All_CP,1),3);
% bar=waitbar(0,'正在计算交叉点');
% for i=1:size(All_CP,1)
%     All_CP1(i,:)=[All_CP(i).coordinate,All_CP(i).altitude];
%     waitbar(i/47812,bar);
% end
% close(bar);

%进行误差处理      
% All_CP1(abs(All_CP1(:,3))>6,:)=[];  %5m粗差剔除
% std_Bias=std(All_CP1(:,3));
% All_CP1(abs(All_CP1(:,3)-mean(All_CP1(:,3)))>=3*std_Bias,:)=[];  %3倍中误差剔除

%绘制6个月所有的交叉点分布图
% figure;
% plot(FilchneBoundary(:,1),FilchneBoundary(:,2),'.k','MarkerSize',0.2 );  %绘制冰架的边界图
% hold on;
% scatter(All_CP1(:,1),All_CP1(:,2),3,[26 111 223]/255,'filled');
% scatter(CrossOverPoint(1),CrossOverPoint(2),100,'p','k','filled');
% for i=1:size(All_CP1,1)     %升轨绘制   
%     longtitude=All_CP1(i,1);
%     latitude=All_CP1(i,2);
%     scatter(longtitude,latitude,2,[26 111 223]/255,'filled');
% end
% meanH=mean(All_CP1(:,3));

% for i=1:size(All_CP,1)  %高程值转化为高程变化率
%     altitude=All_CP(i).altitude;
%     diff_H=altitude;
%     All_CP(i).altitude=
% end
% 
%     ADBias=[];
%     DABias=[];
%     for i=1:size(CP,1)
%         cor=CP(i).coordinate;
%         altitude_A=CP(i).altitude(1,1);
%         altitude_D=CP(i).altitude(2,1);
%         
%         time_A=CP(i).altitude(1,2);
%         time_D=CP(i).altitude(2,2);
%         if time_A<time_D        
%         ADBias=[ADBias;cor,altitude_D-altitude_A];
%         else 
%         DABias=[DABias;cor,altitude_A-altitude_D];
%         end      
%     end
%     Bias=[ADBias;DABias];
%     meanBias_BP=mean(abs(Bias(:,3)))*100;  %处理前不符值均值
%     size_BP=size(Bias,1);           %处理前数据量
%     RMS_BP=sqrt(sum(Bias(:,3).*Bias(:,3))/size_BP)*100;  %处理前均方根
%     
%     %数据剔除
%     Bias(abs(Bias(:,3))>5,:)=[];  %5m粗差剔除
%     std_Bias=std(Bias(:,3));
%     Bias(abs(Bias(:,3)-mean(Bias(:,3)))>=3*std_Bias,:)=[];  %3倍中误差剔除
%     
%     meanBias_AP=mean(abs(Bias(:,3)))*100;  %处理前不符值均值
%     size_AP=size(Bias,1);           %处理前数据量
%     RMS_AP=sqrt(sum(Bias(:,3).*Bias(:,3))/size_AP)*100;  %处理后均方根
%  
%     reject_Ratio=(1-(size_AP/size_BP))*100; %数据剔除率
%     
%     Output= struct('meanBias_BP',meanBias_BP,'size_BP',size_BP,'RMS_BP',RMS_BP ...
%      ,'meanBias_AP',meanBias_AP,'size_AP',size_AP,'RMS_AP',RMS_AP,'reject_Ratio',reject_Ratio);
%     BiasStatistics=[BiasStatistics;Output]
% end

%% 对最终数据进行存储和保存 存储成txt格式
% longtitude=All_CP1(:,1);
% longtitude(longtitude>180)=-(360-(longtitude(longtitude>180)));
% crossPoints=[longtitude,All_CP1(:,2:3)];

%% 将EnviSat数据读取出来使用gmt绘图
% Coordinate=[];    %用于存储经纬度信息的变量
% for i=1:1
%     VariableName=strcat('Cut2011',num2str(i));   
%     Variate=eval(VariableName);
%     for j=1:size(Variate,1)
%         lon=Variate(j).longtitude;
%         lat=Variate(j).latitude;
%         Coordinate=[Coordinate;lon,lat];
%     end
% end

% 实验绘制几个月轨迹点可表示出规则的EnviSat轨迹分布
% figure;
% scatter(FilchneBoundary(:,1),FilchneBoundary(:,2),20,'p','k','filled');
% hold on;
% Coordinate=[];
% for i=1:1
%     VariableName=strcat('Cut2011',num2str(i));   
%     Variate=eval(VariableName);
%     for j=1:297
%         lon=Variate(j).longtitude;
%         lat=Variate(j).latitude;
%         Coordinate=[Coordinate;lon,lat];
%     end
%     scatter(Coordinate(:,1),Coordinate(:,2),10,'p','k','filled');
% end