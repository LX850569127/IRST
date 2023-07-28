%% 
% 1. 将原有的1_1000类型的格网高程变化转化为单一存储形式
% 2. 绘制Amery冰架升降轨
% 3. 导出绘制Amery冰架轨道及交叉点信息所需文件

% %% 1. 将原有的1_1000类型的格网高程变化转化为单一存储形式
% matSize=120;
% Mat=cell(matSize,matSize,1);   
% GridCro= struct('long',[], 'lat',[], 'longGap',[],'AD_Crossovers',[],'DA_Crossovers',[]); 
% GridCro.AD_Crossovers=Mat;
% GridCro.DA_Crossovers=Mat;
% 
% for j=1:1 
%     
% %     startGrid=1+(j)*1000; endGrid=startGrid+1000-1;
%     
%      startGrid=17001; endGrid=17858;
%     
%     fileStoragePath=strcat('.\Variate\Ronne\所有5_5km格网交叉点数据\Grid_',num2str(startGrid),'_',num2str(endGrid),'\');
%     
%     load(strcat('.\Variate\Ronne\所有5_5km格网交叉点数据\GridCro',num2str(startGrid),'_',num2str(endGrid),'.mat'));
%     
%     grid=eval(strcat('GridCro',num2str(startGrid),'_',num2str(endGrid)));
%     
%     if ~exist(fileStoragePath,'dir')
%         mkdir(fileStoragePath)
%     end  
%         for i=startGrid:endGrid 
%             disp(i);
%             
%             GridCro.lat=RonneGrid5_5km(i).lat;
%             GridCro.long=RonneGrid5_5km(i).long;
%             GridCro.longGap=RonneGrid5_5km(i).longGap;
%             temp=grid(i-startGrid+1).Crossovers;
%             GridCro.AD_Crossovers=temp(:,:,1);   
%             GridCro.DA_Crossovers=temp(:,:,2);   
%             
%             
%             nameGridCro=strcat('GridCro_',num2str(i));
%             fileName=strcat(nameGridCro,'.mat');
%             eval(strcat(nameGridCro ,'=GridCro;'));
%                 
%             save([fileStoragePath,fileName],nameGridCro);
%             clear(nameGridCro);        
%         end
%        clear(strcat('GridCro',num2str(startGrid),'_',num2str(endGrid)));
% end
% 
% %% 2. 绘制Amery冰架升降轨情况
% 
% figure;
% hold on;
% 
% load('E:\Sync\BaiduSyncdisk\Master\Project\Crossover\Variate\Amery\边界数据\AmeryBoundary.txt');
% plot(AmeryBoundary(:,1),AmeryBoundary(:,2));
% 
% for i=1:16
% 
%     cor_A = Amery_A201101(i).coordinate; 
%     cor_D = Amery_D201101(i).coordinate; 
% 
%     scatter(cor_A(:,1),cor_A(:,2),4,[241 64 64]/255,'filled','HandleVisibility','off');
%     scatter(cor_D(:,1),cor_D(:,2),4,[26 111 223]/255,'filled');
% 
% end
% 
% hold on;
% for i=1:21
%   coor_CP=Amery_A201101_D201101(i).coordinate;
%   scatter(coor_CP(:,1),coor_CP(:,2),100,'filled');
% end
%   
%%  3. 导出绘制Amery冰架轨道及交叉点信息所需文件
% 
% % 假设该结构体的名称为s，包含10个元素，每个元素包含coordinate字段
% coor = [Amery_201101_201102.coordinate]';  % 读取所有元素中的经度信息
% lon = coor (1:2:end);
% lat = coor (2:2:end);
% coordinates = [lon, lat];  % 组合经纬度信息为Nx2矩阵
% 
% Cut=Amery_D201102;
% 
% for i = 1 : size(Cut,1)
%     coor = Cut(i).coordinate;  % 读取所有元素中的经度信息
% 
%     coordinates = coor (:,1:2);
%     orbitNum=Cut(i).orbitNum;
%     
%        % 保存coordinates 到txt文件 文件名为轨道号
%     filename = strcat('Amery_OrbitNum_',num2str(orbitNum), '.txt');  % 根据轨道号构造文件名
%     dlmwrite(filename, coordinates, 'delimiter', '\t', 'precision', 9);  % 保存矩阵到txt文件
%  
% end 

%% 4. 求Ross/Ronne冰架所有格网平均的高程变化

% rawSize=size(Grid_EC,1);
% 
% dh=zeros(size(Grid_EC,1),1)*nan;   
% 
% for i=2:120
%       disp(i);
%      for j=1:rawSize   % j 格网编号
%        
%         eleChange=Grid_EC(j).eleChange; 
%         if ~isempty(eleChange)
%             dh(j)=eleChange(i);   
%         end
%         
%      end
%      dh(isnan(dh))=[];
%      stdDev=std(dh);
%      meanVal=mean(dh);
%      
%      for j=1:rawSize   % j 格网编号
%         
%         eleChange=Grid_EC(j).eleChange;      
%         if ~isempty(eleChange)
%             temp=eleChange(i);    
%             
%                 if  temp>meanVal+3*stdDev||temp<meanVal-3*stdDev
%                        eleChange(i)=nan;
%                       Grid_EC(j).eleChange=eleChange;
%                 end      
%         end 
%          
%      end
% 
% end
% 
% 
% averaged_dh=zeros(size(Grid_EC,1),3)*nan;
% for i=1:size(Grid_EC)
% %     disp(i);
%     averaged_dh(i,1)=Grid_EC(i).long;
%     averaged_dh(i,2)=Grid_EC(i).lat;
%     ec=Grid_EC(i).eleChange;
%      if sum(sum(~isnan(ec)))>5
%         x = 1:numel(ec);
%         x(isnan(ec)) = [];
%         ec(isnan(ec)) = [];
%         p = polyfit(x, ec, 1);
%         yrChange= p(1)*12;
%         averaged_dh(i,3)=yrChange;
%      else 
%          a=1;
%      end
% end
% 
% averaged_dh(isnan(averaged_dh(:,3)),:) = [];
% 
% % std=std(averaged_dh(:,3));
% 
% 
% mean(averaged_dh(:,3));
% 
% averaged_dh(abs(averaged_dh(:,3))>120,:)=[];
% % 
% [a,b]=min(averaged_dh(:,3));
% % 
% load(".\variate\colorBar\LowBlue_HighRed_ColorMap.mat"); 
% figure;
% colormap(CustomColormap) ;
% h=scatter(averaged_dh(:,1),averaged_dh(:,2),12,averaged_dh(:,3),'filled');
% caxis([-15 15]);
% hold on;
% plot(Boundary(:,1),Boundary(:,2));
%% 求每年每个格网的平均高程变化


% grid_annual_ec = struct('long',[], 'lat',[],'annual_ec',[]); 
% grid_annual_ec = repmat(grid_annual_ec,[size(Grid_EC,1) 1]);
% 
% annual_ec_grid=zeros(10,1)*nan;
% 
% for i=1:size(Grid_EC,1) 
%     
%     grid_annual_ec(i).long=Grid_EC(i).long;
%     grid_annual_ec(i).lat=Grid_EC(i).lat;
%     annual_ec=zeros(10,1)*nan;
%     all_ec=Grid_EC(i).eleChange;
%  
%       if sum(sum(~isnan(all_ec)))>2
%             for j=1:10
%                 ec=all_ec((j-1)*12+1:(j-1)*12+12);
%                      if sum(sum(~isnan(ec)))>2
%                         x = 1:numel(ec);
%                         x(isnan(ec)) = [];
%                         ec(isnan(ec)) = [];
%                         p = polyfit(x, ec, 1);
%                         yrChange= p(1)*12;
%                         annual_ec(j)=yrChange;
%                      end   
%             end
%             grid_annual_ec(i).annual_ec = annual_ec;
%       end   
% end	


% for j=1:10
%     
%     averaged_dh=zeros(size(Grid_EC,1),3)*nan;
%     for i=1:size(Grid_EC)
%         averaged_dh(i,1)=grid_annual_ec(i).long;
%         averaged_dh(i,2)=grid_annual_ec(i).lat;
%         annual_ec=grid_annual_ec(i).annual_ec;
%         
%             if ~isempty(annual_ec)&&~isnan(annual_ec(j))
%                averaged_dh(i,3)=annual_ec(j);
%             end
%     end
%     
%     averaged_dh(isnan(averaged_dh(:,3)),:) = [];
    
    % Construct file name with year suffix
%     file_name = strcat(num2str(2010+j), '.txt');
% 
%     % Save averaged_dh to text file
%     dlmwrite(file_name, averaged_dh, 'delimiter', '\t', 'precision', '%.6f');
%     
%    
% end

% for i=1:size(Grid_EC)
%     
%     long=Grid_EC(i).long;
%     if abs(long-196.026)<=0.001
%         a=1;
%         lat=Grid_EC(i).lat;
%     end
% end

 %%  
 load('E:\Sync\BaiduSyncdisk\Master\Project\Crossover\Variate\Ronne\边界数据\RonneBoundaryInside.txt');
 figure;
 plot(RonneBoundaryInside(1:1090,1),RonneBoundaryInside(1:1090,2));
 
 for i=1:size(RonneBoundaryInside,1)
    
    long=RonneBoundaryInside(i,1);
    if abs(long--60.1267)<=0.001
        a=1;
        lat=Grid_EC(i).lat;
    end
end
 