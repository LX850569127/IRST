%%  Way1
% Region='Ross';    
% Year=2011;
% StartMonth=1;
% EndMonth=12;
% StoragePath=strcat('.\Variate\',Region,'\');
% 
% for k=StartMonth:EndMonth
% 
%     yearMonth=strcat(num2str(Year),zerosFill(k));
%     name_A=strcat(Region,'_A',yearMonth);
%     name_D=strcat(Region,'_D',yearMonth);
%     name_CP=strcat(Region,'_A',yearMonth,'_D',yearMonth);
% 
%     load(name_A);  
%     load(name_D); 
% 
%     eval(strcat('Ascend=',name_A));    
%     eval(strcat('Descend=',name_D));    
%     eval(strcat('CP=',name_CP));       %crossover point 
% 
%     % read the orbitNum and the starting time of it because the the delta_t
%     % caculated by the starting time.
%     ST_A=zeros(size(Ascend,1),2);       %starting time of ascend orbit 
%     ST_D=zeros(size(Descend,1),2);      %starting time of descend orbit 
%     for i=1:size(Ascend)   
%         ST_A(i,1)=Ascend(i).orbitNum;   % column 1 is the orbitNum
%         tempCoor=Ascend(i).coordinate;
%         time=tempCoor(:,4);
%         ST_A(i,2)=min(time);  % column 2 is the starting time of the orbitNum in column 1
%     end
%     for i=1:size(Descend)  
%         ST_D(i,1)=Descend(i).orbitNum;   % column 1 is the orbitNum
%         tempCoor=Descend(i).coordinate;
%         time=tempCoor(:,4);
%         ST_D(i,2)=min(time);  % column 2 is the starting time of the orbitNum in column 1
%     end
%     clear coor;
% 
%     % Counting the number of parameters based on the num of ascend and descend 
%     % orbit.
%     orbitNum_A=zeros(size(CP,1),1);   
%     orbitNum_D=zeros(size(CP,1),1);
% 
%     for i=1:size(CP,1)         
%        orbitNum_A(i)=CP(i).orbitNum_A;
%        orbitNum_D(i)=CP(i).orbitNum_D;  
%     end    

%     orbitNum_A=unique(orbitNum_A,'rows');   %Nonredundant ascend orbitNum; 
%     orbitNum_D=unique(orbitNum_D,'rows');   %Nonredundant descend orbitNum; 
% 
%     % Set up the X matrix
%     orbitNum_X=zeros((size(orbitNum_A,1)+size(orbitNum_D,1))*2,2);   % The orbitNum of the Xmatrix, column 2 is the starting time of the orbitNum in column 1
%     matriX=strings((size(orbitNum_A,1)+size(orbitNum_D,1))*2,1);     % Description of the elements of X matrix  
% 
%     for i=1:size(orbitNum_A,1)
%         orbitNum_X(i*2-1,1)=orbitNum_A(i);
%         orbitNum_X(i*2-1,2)=ST_A(find(ST_A(:,1)==orbitNum_A(i)),2);  %the starting time of the orbitNum in column 1
%         orbitNum_X(i*2,1)=orbitNum_A(i);
%         matriX(i*2-1)=strcat('a0_',num2str(orbitNum_A(i)),'_A');
%         matriX(i*2)=strcat('a1_',num2str(orbitNum_A(i)),'_A');
%     end
% 
%     for j=1:size(orbitNum_D,1)
%         i=i+1;
%         orbitNum_X(i*2-1,1)=orbitNum_D(j);
%         orbitNum_X(i*2-1,2)=ST_D(find(ST_D(:,1)==orbitNum_D(j)),2);   %the starting time of the orbitNum in column 1
%         orbitNum_X(i*2,1)=orbitNum_D(j);
%         matriX(i*2-1)=strcat('a0_',num2str(orbitNum_D(j)),'_D');
%         matriX(i*2)=strcat('a1_',num2str(orbitNum_D(j)),'_D');
%     end
% 
%     % Set up the A,L,P matrixes. 
%     A=zeros(size(CP,1),size(matriX,1));
%     L=zeros(size(CP,1),1);
%     P=diag(ones(size(CP,1),1));
%     Px=diag(ones(size(orbitNum_X,1),1));
%     for i=1:size(CP,1)
%         num_A=CP(i).orbitNum_A;
%         num_D=CP(i).orbitNum_D;
%         colunmA=find(orbitNum_X==num_A,1);               % the column of the coefficients of Ascend orbit in matrix A
%         colunmD=find(orbitNum_X==num_D,1);               % the column of the coefficients of Descend orbit in matrix A
%         delta_Ta=CP(i).time_A-orbitNum_X(colunmA,2);
%         delta_Td=CP(i).time_D-orbitNum_X(colunmD,2);
%         A(i,colunmA)=1;
%         A(i,colunmA+1)=delta_Ta;
%         A(i,colunmD)=-1;
%         A(i,colunmD+1)=-delta_Td;
%         L(i)=-(CP(i).altitude_A-CP(i).altitude_D);
%     end
% 
%     X=inv(A.'*P*A+Px)*A.'*P*L;
% 
%     % Save the coefficients in the orbital matrix
%     % if the orbitNum didn't be adjusted because its crossover is removed in
%     % the process of error processing. 
% 
%     orbitNum_X=[orbitNum_X,X];
% 
% 
%     orbitalInfo_A= struct('coordinate',[], 'orbitNum',[],'flag_AD',[], 'correctionPar',[]);      % orbital information with correction parameters. 
%     orbitalInfo_A=repmat(orbitalInfo_A,[size(Ascend,1) 1]);
% 
%     for i=1:size(Ascend,1)
%         orbitNum=double(Ascend(i).orbitNum);
%         temp=Ascend(i);
%         if  any(ismember(orbitNum_X(:,1),orbitNum))  
%             column=find(orbitNum_X==orbitNum);  % search for the the location of orbital parameters in the matrix X.
%             temp.correctionPar=[orbitNum_X(column(1),3),orbitNum_X(column(2),3)];   % a0 & a1
%         else
%             temp.correctionPar=[0,0];           % the orbit without correction parameters. 
%         end ...

%         orbitalInfo_A(i)=temp;
%     end
% 
%     orbitalInfo_D= struct('coordinate',[], 'orbitNum',[],'flag_AD',[], 'correctionPar',[]);      % orbital information with correction parameters. 
%     orbitalInfo_D=repmat(orbitalInfo_D,[size(Descend,1) 1]);
% 
%     for i=1:size(Descend,1)
%         orbitNum=double(Descend(i).orbitNum);
%         temp=Descend(i);
%         if  any(ismember(orbitNum_X(:,1),orbitNum))  
%             column=find(orbitNum_X==orbitNum);  % search for the the location of orbital parameters in the matrix X.
%             temp.correctionPar=[orbitNum_X(column(1),3),orbitNum_X(column(2),3)];   % a0 & a1
%         else
%             temp.correctionPar=[0,0];           % the orbit without correction parameters. 
%         end 
%         orbitalInfo_D(i)=temp;
%     end
% 
%     eval(strcat(name_A,'=orbitalInfo_A'));    
%     eval(strcat(name_D,'=orbitalInfo_D'));    
% 
%     fileNameA=strcat(name_A,'.mat');
%     fileNameD=strcat(name_D,'.mat');
%     storagePathA=strcat(StoragePath,num2str(Year),'\Ascend\');
%     storagePathD=strcat(StoragePath,num2str(Year),'\Descend\');
%     if ~exist(storagePathA,'dir')|| ~exist(storagePathD,'dir')
%        mkdir(storagePathA); 
%        mkdir(storagePathD); 
%     end
% 
%     save([char(storagePathA),char(fileNameA)],name_A);
%     save([char(storagePathD),char(fileNameD)],name_D);
% end

%% Way2  验后条件平差 

%1) 进行简单条件平差，假设测高轨迹上的各个测点均为独立观测量，
% 且不符值受升降轨的影响相同，对升降轨赋予相同权重值。

% Distributing crossover error evenly to the ascend orbit and descend
% orbit. Saving the corrected Value 'V' to every orbit. 

Region='Ross';    
Year=2011;
StartMonth=1;
EndMonth=12;
StoragePath=strcat('.\Variate\',Region,'\');

for k=StartMonth:EndMonth
    
yearMonth=strcat(num2str(Year),zerosFill(k));
name_A=strcat(Region,'_A',yearMonth);
name_D=strcat(Region,'_D',yearMonth);
name_CP=strcat(Region,'_A',yearMonth,'_D',yearMonth);

% load(name_A);  
% load(name_D); 

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
for i=1:size(ascend,1)
    orbitNum=double(ascend(i).orbitNum);
    temp=ascend(i);
    if  any(ismember(orbitNum_CP(:,1),orbitNum))  
        row=find(orbitNum_CP==orbitNum);  
        temp.correctionPar=Orbital_CP(row).modelParameter;   
    else
        temp.correctionPar=[];           % the orbit without correction parameters. 
    end 
    ascend(i)=temp;
end

for i=1:size(descend,1)
    orbitNum=double(descend(i).orbitNum);
    temp=descend(i);
    if  any(ismember(orbitNum_CP(:,1),orbitNum))  
        row=find(orbitNum_CP==orbitNum);  
        temp.correctionPar=Orbital_CP(row).modelParameter;   
    else
        temp.correctionPar=[];           % the orbit without correction parameters. 
    end 
    descend(i)=temp;
end

eval(strcat(name_A,'=ascend'));    
eval(strcat(name_D,'=descend'));    

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

% % 通过频率分布直方图确定交叉点个数于模型待定系数m的关系组合
% numOfCPOfOrbit=zeros(size(Orbital_CP,1),1);
% for i=1:size(Orbital_CP,1)
%     numOfCPOfOrbit(i)=size(Orbital_CP(i).v_tOfCP,1);
% end
% figure;
% h2 = histogram(numOfCPOfOrbit);