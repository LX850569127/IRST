
%% 1.平差前需对同一周期的数据进行误差处理
clear;
Region='Ross';
StoragePath=strcat('.\Variate\',Region,'\');

% 1) 以每月为时间段对同一周期的交叉点不符值进行处理

meanBias=zeros(1,12); 
meanOfAbs=zeros(12,1);
numOfCP=zeros(1,12);
standard=zeros(1,12);

AllBias=[];
Year=2016;
StartMonth=1;
EndMonth=12;

for j=StartMonth:EndMonth
    
    month=j;
    ym=strcat(num2str(Year),num2str(month,'%02d'));
    name_CP=strcat(Region, '_A',ym, '_D',ym);
    path=strcat(StoragePath,num2str(Year),'\CP\',name_CP);
    load(path);
    CP=eval(name_CP);
    Bias=zeros(size(CP,1),4);
    
    for i=1:size(CP,1)        
            cor=CP(i).coordinate;
            altitude_A=CP(i).altitude_A;
            altitude_D=CP(i).altitude_D;
            time_A=CP(i).time_A;
            time_D=CP(i).time_D;          
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
     
      CP(abs(Bias(:,3))>threshold,:)=[]; 
      Bias(abs(Bias(:,3))>threshold,:)=[];                
      
      rmse=sqrt(mean((Bias(:,3)-0).^2));              % root mean square error
        
      CP(abs(Bias(:,3))>=2*rmse,:)=[]; 
      Bias(abs(Bias(:,3))>=2*rmse,:)=[]; 
      
      meanBias(j)=mean(Bias(:,3))*100; 
      absMeanBias=mean(abs(Bias(:,3)))*100; 
      standard(j)=std(Bias(:,3))*100;
      rms=sqrt(mean((Bias(:,3)).^2));

      meanOfAbs(j)=mean(abs(Bias(:,3)))*100; 
      numOfCP(j)=size(CP,1);
      AllBias=[AllBias;Bias];
     
      eval(strcat(name_CP,'=CP'));   
end    

%% Way2  验后条件平差 

%1) 进行简单条件平差，假设测高轨迹上的各个测点均为独立观测量，
% 且不符值受升降轨的影响相同，对升降轨赋予相同权重值。

% Distributing crossover error evenly to the ascend orbit and descend
% orbit. Saving the corrected Value 'V' to every orbit. 

for k=StartMonth:EndMonth
    
ym=strcat(num2str(Year),num2str(k,'%02d'));
name_A=strcat(Region,'_A',ym);
name_D=strcat(Region,'_D',ym);
name_CP=strcat(Region,'_A',ym,'_D',ym);
load(strcat(StoragePath,num2str(Year),'\Ascend\',name_A));  
load(strcat(StoragePath,num2str(Year),'\Descend\',name_D));  
    
eval(strcat('ascend=',name_A));    
eval(strcat('descend=',name_D));    
eval(strcat('CP=',name_CP));       %crossover point     

T_A=zeros(size(ascend,1),3);       %starting time & ending time of ascend orbit, column 2 is starting time, column 3 is ending time 
T_D=zeros(size(descend,1),3);      %starting time & ending time of descend orbit, column 2 is starting time, column 3 is ending time 
for i=1:size(ascend)   
    T_A(i,1)=ascend(i).orbitNum;   % column 1 is the orbitNum
    tempCoor=ascend(i).coordinate;
    time=tempCoor(:,4);
    T_A(i,2)=min(time);  % column 2 is the starting time of the orbitNum in column 1
    T_A(i,3)=max(time);  % column 3 is the ending time of the orbitNum in column 1
end

%% Edited 
for i=1:size(descend)  
    T_D(i,1)=descend(i).orbitNum;   % column 1 is the orbitNum
    tempCoor=descend(i).coordinate;
    time=tempCoor(:,4);
    T_D(i,2)=min(time);  % column 2 is the starting time of the orbitNum in column 1
    T_D(i,3)=max(time);  % column 3 is the ending time of the orbitNum in column 1
end

orbitNum_A=cell2mat({CP(:).orbitNum_A}).';
orbitNum_D=cell2mat({CP(:).orbitNum_D}).';

nonredundant_orbitNum_A=unique(orbitNum_A,'rows');   %Nonredundant ascend orbitNum; 
nonredundant_orbitNum_D=unique(orbitNum_D,'rows');   %Nonredundant descend orbitNum; 

% searching  for the crossovers of every orbit. 

a_Orbital_CP= struct('orbitNum',[],'starting_time',[],'ending_time',[], 'v_tOfCP',[],'modelParameter',[]);  
a_Orbital_CP= repmat(a_Orbital_CP,[size(nonredundant_orbitNum_A,1) 1]);

for i=1:size(nonredundant_orbitNum_A,1)  
    currentOrbitalNum=nonredundant_orbitNum_A(i);
    a_Orbital_CP(i).orbitNum=nonredundant_orbitNum_A(i);
    ind=find(orbitNum_A==nonredundant_orbitNum_A(i));
    v=(cell2mat({CP(ind,:).altitude_A})-cell2mat({CP(ind,:).altitude_D}))*1/2;
    t=cell2mat({CP(ind,:).time_A});
    a_Orbital_CP(i).v_tOfCP=[v;t].';
    row=T_A(:,1)==currentOrbitalNum;
    a_Orbital_CP(i).starting_time=T_A(row,2);
    a_Orbital_CP(i).ending_time=T_A(row,3);
end

d_Orbital_CP= struct('orbitNum',[],'starting_time',[],'ending_time',[], 'v_tOfCP',[],'modelParameter',[]);   
d_Orbital_CP= repmat(d_Orbital_CP,[size(nonredundant_orbitNum_D,1) 1]);

for i=1:size(nonredundant_orbitNum_D,1)  
    currentOrbitalNum=nonredundant_orbitNum_D(i);

    d_Orbital_CP(i).orbitNum=nonredundant_orbitNum_D(i);
    ind=find(orbitNum_D==nonredundant_orbitNum_D(i));
    v=(cell2mat({CP(ind,:).altitude_A})-cell2mat({CP(ind,:).altitude_D}))*-1/2;
    t=cell2mat({CP(ind,:).time_D});
    d_Orbital_CP(i).v_tOfCP=[v;t].';
    row=T_D(:,1)==currentOrbitalNum;
    d_Orbital_CP(i).starting_time=T_D(row,2);
    d_Orbital_CP(i).ending_time=T_D(row,3);
end

% Building the error model of every orbit.
% Determining which model to use based on the number of crossovers of this orbit.
Orbital_CP=[a_Orbital_CP;d_Orbital_CP];
for i=1:size(Orbital_CP,1)
    numOfCP=size(Orbital_CP(i).v_tOfCP,1);    
    s_t=Orbital_CP(i).starting_time;
    e_t=Orbital_CP(i).ending_time;
    v_t=Orbital_CP(i).v_tOfCP;
    t=v_t(:,2);
    w=2*pi/(e_t-s_t);
    V=v_t(:,1);  
    if size(s_t,1)~=1
           error('There are Duplicate data in these tracks');
    end
    d_t=t-s_t;
    if  numOfCP>=1&&numOfCP<=1
        A=ones(numOfCP,1);
    elseif numOfCP>=2&&numOfCP<=5
        A=[ones(numOfCP,1),d_t];
    elseif  numOfCP>=6&&numOfCP<=9
        A=[ones(numOfCP,1),d_t,cos(w*d_t),sin(w*d_t)];
    elseif  numOfCP>=10&&numOfCP<=13
        A=[ones(numOfCP,1 ),d_t,cos(w*d_t),sin(w*d_t),cos(2*w*d_t),sin(2*w*d_t)];
    else
        A=[ones(numOfCP,1 ),d_t,cos(w*d_t),sin(w*d_t),cos(2*w*d_t),sin(2*w*d_t),cos(3*w*d_t),sin(3*w*d_t)];
    end
    P=diag(ones(size(V,1),1));
    X=inv(A.'*P*A)*A.'*P*V;
    Orbital_CP(i).modelParameter=X.';
end

orbitNum_CP=cell2mat({Orbital_CP(:).orbitNum}).';
temp_A= struct('coordinate',[], 'orbitNum',[],'flag_AD',[], 'correctionPar',[]);    
temp_A=repmat(temp_A,[size(ascend,1) 1]);

for i=1:size(ascend,1)
    orbitNum=double(ascend(i).orbitNum);
    temp=ascend(i);
    if  any(ismember(orbitNum_CP(:,1),orbitNum))  
        row=find(orbitNum_CP==orbitNum);  
        temp.correctionPar=Orbital_CP(row).modelParameter;   
    else
        temp.correctionPar=[];           % the orbit without correction parameters. 
    end 
    temp_A(i)=temp;
end

temp_D= struct('coordinate',[], 'orbitNum',[],'flag_AD',[], 'correctionPar',[]);    
temp_D=repmat(temp_D,[size(descend,1) 1]);
for i=1:size(descend,1)
    orbitNum=double(descend(i).orbitNum);
    temp=descend(i);
    if  any(ismember(orbitNum_CP(:,1),orbitNum))  
        row=find(orbitNum_CP==orbitNum);  
        temp.correctionPar=Orbital_CP(row).modelParameter;   
    else
        temp.correctionPar=[];           % the orbit without correction parameters. 
    end 
    temp_D(i)=temp;
end

eval(strcat(name_A,'=temp_A'));    
eval(strcat(name_D,'=temp_D'));    

fileNameA=strcat(name_A,'.mat');
fileNameD=strcat(name_D,'.mat');
storagePathA=strcat(StoragePath,num2str(Year),'\Ascend\');
storagePathD=strcat(StoragePath,num2str(Year),'\Descend\');

if ~exist(storagePathA,'dir')|| ~exist(storagePathD,'dir')
   mkdir(storagePathA); 
   mkdir(storagePathD); 
end

save([char(storagePathA),char(fileNameA)],name_A);
save([char(storagePathD),char(fileNameD)],name_D);

end
