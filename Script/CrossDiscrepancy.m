
%% Error Processing 
% Process Monthly/Every period 
% meanBias=zeros(12,1);
% for j=1:12
%     month=num2str(j);
%     if j<10
%       VariateName_CP=strcat('Ross', '_A20110',month,'_D20110',month); 
%     else
%       VariateName_CP=strcat('Ross', '_A2011',month,'_D2011',month); 
%     end
%     CP=eval(VariateName_CP);
%     Bias=zeros(size(CP,1),3);
%     
%     for i=1:size(CP,1)        
%             cor=CP(i).coordinate;
%             altitude_A=CP(i).altitude_A;
%             altitude_D=CP(i).altitude_D;
%             time_A=CP(i).time_A;
%             time_D=CP(i).time_D;          
%           
%             if time_A<time_D   
%                 Bias(i,:)=[cor,altitude_D-altitude_A];       
%             else 
%                 Bias(i,:)=[cor,altitude_A-altitude_D];
%             end      
%     end    
%          
%       Bias(:,3)=abs(Bias(:,3));
%       CP(Bias(:,3)>1.5,:)=[]; 
%       Bias(Bias(:,3)>1.5,:)=[];            % exceeding 1.5m is a gross error, 
%       
%       std_Bias=std(Bias(:,3));  
%       CP(Bias(:,3)-mean(Bias(:,3))>=2*std_Bias,:)=[];     %2 times RMSE
%       Bias(Bias(:,3)-mean(Bias(:,3))>=2*std_Bias,:)=[]; 
%     
%       eval(strcat(VariateName_CP,'=CP'));
%       meanBias(j)=mean(Bias(:,3))*100; 
% end    


% Process Yearly
% All_CP=[];   
% BiasStatistics=[];
% for j=1:12
%     month=num2str(j);
%     if j<10
%       VariateName_CP=strcat('Ross', '_A20110',month,'_D20110',month); 
%     else
%       VariateName_CP=strcat('Ross', '_A2011',month,'_D2011',month); 
%     end
%     CP=eval(VariateName_CP);
%     ADBias=[];
%     DABias=[];
%     for i=1:size(CP,1)        
%             cor=CP(i).coordinate;
%             altitude_A=CP(i).altitude_A;
%             altitude_D=CP(i).altitude_D;
%             time_A=CP(i).time_A;
%             time_D=CP(i).time_D;
%             PDOP=CP(i).PDOP;
%             if time_A<time_D        
%                 ADBias=[ADBias;cor,altitude_D-altitude_A,PDOP];       
%             else 
%                 DABias=[DABias;cor,altitude_A-altitude_D,PDOP];
%             end           
%     end    
%     Bias=[ADBias;DABias];
%     All_CP=[All_CP;Bias];
%  
%       meanBias_PDOP=mean(All_CP(:,4));
%       All_CP(abs(All_CP(:,3))>2,:)=[];      %认定超过2m的不符值为粗差，进行剔除
%       All_CP(:,3)=abs(All_CP(:,3));  
%       std_Bias=std(All_CP(:,3));
%              
%       All_CP(abs(All_CP(:,3)-mean(All_CP(:,3)))>=3*std_Bias,:)=[];  %3倍中误差剔除
%       All_CP(abs(All_CP(:,3))>1,:)=[];
%       RMS=sqrt(sum(All_CP(:,3).*All_CP(:,3))/size(All_CP,1))*100;   %处理后均方根
%       meanBias=mean(All_CP(:,3))*100; 
%       
% end    

%% Adjustment of Crossovers
Ross_A=Ross_A201101;
Ross_D=Ross_D201101;
CP=Ross_A201101_D201101;

% read the orbitNum and the starting time of it because the the delta_t
% caculated by the starting time.
Ross_A1=zeros(size(Ross_A,1),2);
Ross_D1=zeros(size(Ross_D,1),2);
for i=1:size(Ross_A)  
    Ross_A1(i,1)=Ross_A(i).orbitNum;   % column 1 is the orbitNum
    Ross_A1(i,2)=min(Ross_A(i).time);  % column 2 is the starting time of the orbitNum in column 1
end
for i=1:size(Ross_D)  
    Ross_D1(i,1)=Ross_D(i).orbitNum;   % column 1 is the orbitNum
    Ross_D1(i,2)=min(Ross_D(i).time);  % column 2 is the starting time of the orbitNum in column 1
end
clear coor;

% Counting the number of parameters based on the num of ascend and descend 
% orbit.
orbitNum_A=zeros(size(CP,1),1);   
orbitNum_D=zeros(size(CP,1),1);

for i=1:size(CP,1)         
   orbitNum_A(i)=CP(i).orbitNum_A;
   orbitNum_D(i)=CP(i).orbitNum_D;  
end    

orbitNum_A=unique(orbitNum_A,'rows');   %Nonredundant ascend orbitNum; 
orbitNum_D=unique(orbitNum_D,'rows');   %Nonredundant descend orbitNum; 

% Set up the X matrix
orbitNum_X=zeros((size(orbitNum_A,1)+size(orbitNum_D,1))*2,2);   % The orbitNum of the Xmatrix, column 2 is the starting time of the orbitNum in column 1
matriX=strings((size(orbitNum_A,1)+size(orbitNum_D,1))*2,1);     % Description of the elements of X matrix  
for i=1:size(orbitNum_A,1)
    orbitNum_X(i*2-1,1)=orbitNum_A(i);
    orbitNum_X(i*2-1,2)=Ross_A1(find(Ross_A1(:,1)==orbitNum_A(i)),2);  %the starting time of the orbitNum in column 1
    orbitNum_X(i*2,1)=orbitNum_A(i);
    matriX(i*2-1)=strcat('a0_',num2str(orbitNum_A(i)),'_A');
    matriX(i*2)=strcat('a1_',num2str(orbitNum_A(i)),'_A');
end
for j=1:size(orbitNum_D,1)
    i=i+1;
    orbitNum_X(i*2-1,1)=orbitNum_D(j);
    orbitNum_X(i*2-1,2)=Ross_D1(find(Ross_D1(:,1)==orbitNum_D(j)),2);   %the starting time of the orbitNum in column 1
    orbitNum_X(i*2,1)=orbitNum_D(j);
    matriX(i*2-1)=strcat('a0_',num2str(orbitNum_D(j)),'_D');
    matriX(i*2)=strcat('a1_',num2str(orbitNum_D(j)),'_D');
end

% Set up the A,L,P matrixes. 
A=zeros(size(CP,1),size(matriX,1));
L=zeros(size(CP,1),1);
P=diag(ones(size(CP,1),1));
Px=diag(ones(size(orbitNum_X,1),1));
for i=1:size(CP,1)
    num_A=CP(i).orbitNum_A;
    num_D=CP(i).orbitNum_D;
    colunmA=find(orbitNum_X==num_A,1);               % the column of the coefficients of Ascend orbit in matrix A
    colunmD=find(orbitNum_X==num_D,1);               % the column of the coefficients of Descend orbit in matrix A
    delta_Ta=CP(i).time_A-orbitNum_X(colunmA,2);
    delta_Td=CP(i).time_D-orbitNum_X(colunmD,2);
    A(i,colunmA)=1;
    A(i,colunmA+1)=delta_Ta;
    A(i,colunmD)=-1;
    A(i,colunmD+1)=delta_Td;
    L(i)=CP(i).altitude_A-CP(i).altitude_D;
end

X=inv(A.'*P*A+Px)*A.'*P*L;

% Save the coefficients in the orbital matrix
% if the orbitNum didn't be adjusted because its crossover is remobved in
% the process of error processing. 

    orbitNum_X=[orbitNum_X,X];
    orbitalInfo_Pro= struct('coordinate',[], 'height',[], 'time',[],...
        'orbitNum',[],'flag_AD',[], 'correctionPar',[]);      % orbital information with correction parameters. 
    orbitalInfo_Pro=repmat(orbitalInfo_Pro,[size(Ross_A,1) 1]);
    
% for i=1:size(Ross_A,1)
%     orbitNum=double(Ross_A(i).orbitNum);
%     temp=Ross_A(i);
%     if  any(ismember(orbitNum_X(:,1),orbitNum))  
%         column=find(orbitNum_X==orbitNum);  % search for the the location of orbital parameters in the matrix X.
%         temp.correctionPar=[orbitNum_X(column(1),3),orbitNum_X(column(2),3)];   % a0 & a1
%     else
%         temp.correctionPar=[0,0];           % the orbit without correction parameters. 
%     end 
%     orbitalInfo_Pro(i)=temp;
% end

for i=1:size(Ross_D,1)
    orbitNum=double(Ross_D(i).orbitNum);
    temp=Ross_D(i);
    if  any(ismember(orbitNum_X(:,1),orbitNum))  
        column=find(orbitNum_X==orbitNum);  % search for the the location of orbital parameters in the matrix X.
        temp.correctionPar=[orbitNum_X(column(1),3),orbitNum_X(column(2),3)];   % a0 & a1
    else
        temp.correctionPar=[0,0];           % the orbit without correction parameters. 
    end 
    orbitalInfo_Pro(i)=temp;
end

