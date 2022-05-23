
Region='Ross';
StoragePath=strcat('.\Variate\',Region,'\');

%% 轨道质量计算

% 通过该轨道与其他所有轨道产生的交叉点的高程变化值的大小来判断该轨道的质量

meanBias=zeros(1,12); 
meanOfAbs=zeros(12,1);
numOfCP=zeros(1,12);
standard=zeros(1,12);
AllBias=[];

Year=2016;
StartMonth=8;
EndMonth=8;

for j=StartMonth:EndMonth
    
    month=j;
    ym=strcat(num2str(Year),num2str(month,'%02d'));
    name_A=strcat(Region,'_A',ym);
    name_D=strcat(Region,'_D',ym);
    name_CP=strcat(Region, '_A',ym, '_D',ym);
    path=strcat(StoragePath,num2str(Year),'\CP\',name_CP);

    load(name_A);  
    load(name_D); 
    load(path);
    asc=eval(name_A);
    des=eval(name_D);
    CP1=eval(name_CP);
    CP2=eval(name_CP);
    
    orbitNum_A=cell2mat({CP2(:).orbitNum_A}).';
    orbitNum_D=cell2mat({CP2(:).orbitNum_D}).';
    unique_orbitNum_A=unique(orbitNum_A,'rows');   %Nonredundant ascend orbitNum; 
    unique_orbitNum_D=unique(orbitNum_D,'rows');   %Nonredundant descend orbitNum; 
        
    Bias=zeros(size(CP2,1),4);
    for i=1:size(CP2,1)        
            cor=CP2(i).coordinate;
            altitude_A=CP2(i).altitude_A;
            altitude_D=CP2(i).altitude_D;
            time_A=CP2(i).time_A;
            time_D=CP2(i).time_D;          
            dy=abs(time_A-time_D)/60/60/24;    %间隔天数
            if time_A<time_D   
                Bias(i,:)=[cor,altitude_D-altitude_A,dy];       
            else 
                Bias(i,:)=[cor,altitude_A-altitude_D,dy];
            end      
    end   
    
     % 通过不符值排序来确定粗差阈值大小    
        temp=sort(abs(Bias(:,3)));
        threshold=temp(ceil(size(temp,1)-(size(temp,1)*0.05)));  % bias从小到大排序，较大的5%作为粗差阈值
     
      CP2(abs(Bias(:,3))>threshold,:)=[]; 
      Bias(abs(Bias(:,3))>threshold,:)=[];            % exceeding 2m is a gross error,          
      
      rmse=sqrt(mean((Bias(:,3)-0).^2));              % root mean square error
        
      CP2(abs(Bias(:,3))>=2*rmse,:)=[]; 
      Bias(abs(Bias(:,3))>=2*rmse,:)=[]; 
      
      meanBias(j)=mean(Bias(:,3))*100; 
      absMeanBias=mean(abs(Bias(:,3)))*100; 
      standard(j)=std(Bias(:,3))*100;
      meanOfAbs(j)=mean(abs(Bias(:,3)))*100; 
      eval(strcat(name_CP,'=CP2'));   
  
        % 2. 提取每条轨道上的交叉点
        orbitNum_A=cell2mat({CP2(:).orbitNum_A}).';
        orbitNum_D=cell2mat({CP2(:).orbitNum_D}).';
    
        % 2.1 提取升轨上的交叉点
          % coe: crossover error ;% absmeancoe: absolute mean value of coe
        a_Orbital_CP= struct('orbitNum',[], 'coe',[],'absmeancoe',[]); 
        a_Orbital_CP= repmat(a_Orbital_CP,[size(unique_orbitNum_A,1) 1]);

        for i=1:size(unique_orbitNum_A,1)  
            currentOrbitalNum=unique_orbitNum_A(i);
            a_Orbital_CP(i).orbitNum=unique_orbitNum_A(i);
            ind=find(orbitNum_A==unique_orbitNum_A(i));
            
%             if sum(ind)==0
%                  ind=find(cell2mat({CP1(:).orbitNum_A}).'==unique_orbitNum_A(i));
%                  coe=(cell2mat({CP1(ind,:).altitude_A})-cell2mat({CP1(ind,:).altitude_D})).';
%             else
%                  coe=(cell2mat({CP2(ind,:).altitude_A})-cell2mat({CP2(ind,:).altitude_D})).';
%             end
           coe=(cell2mat({CP2(ind,:).altitude_A})-cell2mat({CP2(ind,:).altitude_D})).';
            a_Orbital_CP(i).coe=coe;
            a_Orbital_CP(i).absmeancoe=mean(abs(coe));
        end
        
        d_Orbital_CP=struct('orbitNum',[], 'coe',[],'absmeancoe',[]); 
        d_Orbital_CP= repmat(d_Orbital_CP,[size(unique_orbitNum_D,1) 1]);

        for i=1:size(unique_orbitNum_D,1)  
            currentOrbitalNum=unique_orbitNum_D(i);
            d_Orbital_CP(i).orbitNum=unique_orbitNum_D(i);
            ind=find(orbitNum_D==unique_orbitNum_D(i));
            coe=(cell2mat({CP2(ind,:).altitude_A})-cell2mat({CP2(ind,:).altitude_D})).';
            d_Orbital_CP(i).coe=coe;
            d_Orbital_CP(i).absmeancoe=mean(abs(coe));
        end
        
end    
