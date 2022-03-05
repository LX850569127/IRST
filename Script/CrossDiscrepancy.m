
%% Error Processing 
% Process Monthly/Every period 

meanBias=zeros(1,12); 
meanOfAbs=zeros(1,12);
numOfCP=zeros(1,12);
standard=zeros(1,12);

AllBias=[];

for j=1:12
    month=num2str(j);
    if j<10
      VariateName_CP=strcat('Ross', '_A20110',month,'_D20110',month); 
    else
      VariateName_CP=strcat('Ross', '_A2011',month,'_D2011',month); 
    end

    CP=eval(VariateName_CP);
    Bias=zeros(size(CP,1),3);
    
    for i=1:size(CP,1)        
            cor=CP(i).coordinate;
            altitude_A=CP(i).altitude_A;
            altitude_D=CP(i).altitude_D;
            time_A=CP(i).time_A;
            time_D=CP(i).time_D;          
          
            if time_A<time_D   
                Bias(i,:)=[cor,altitude_D-altitude_A];       
            else 
                Bias(i,:)=[cor,altitude_A-altitude_D];
            end      
    end          
   
      CP(abs(Bias(:,3))>1.5,:)=[]; 
      Bias(abs(Bias(:,3))>1.5,:)=[];            % exceeding 1.5m is a gross error,          
      
      rmse=sqrt(mean((Bias(:,3)-0).^2));        % root mean square error
      
      CP(abs(Bias(:,3))>=2*rmse,:)=[]; 
      Bias(abs(Bias(:,3))>=2*rmse,:)=[]; 
      
      rms=sqrt(mean((Bias(:,3)).^2));
      eval(strcat(VariateName_CP,'=CP'));
      
      meanBias(j)=mean(Bias(:,3))*100; 
      standard(j)=std(Bias(:,3))*100;
      meanOfAbs(j)=mean(abs(Bias(:,3)))*100; 
      numOfCP(j)=size(CP,1);
      AllBias=[AllBias;Bias];
      
end    


adj=max(AllBias(:,3));
mean(standard)

raw=AllBias;
figure;
mean(abs(Bias(:,3)));

figure;
box on;
hold on;
edges = (-1.15:0.05:1.15);
h1 = histogram(AllBias(:,3),edges);
h2 = histogram(aji1(:,3),edges);
h3 = histogram(aji2(:,3),edges);
% h1.FaceColor = [251 197 49]/255;
% h2.FaceColor = [232 65 24]/255;
h3.FaceColor = [190 190 190]/255;
h2.FaceAlpha = 0.8;
h3.FaceAlpha = 0.7;
legend('平差前','整体平差','验后平差');


ylabel('频率');

figure;
hold on ;
box on;
a1=histfit(AllBias(:,3),30);
set(a1(1),'Visible','Off');
set(a1(2),'Color',[0 0.4470 0.7410]); %曲线为绿色
 set(a1(1),'handlevisibility','off');
a2=histfit(aji1(:,3),30);
set(a2(1),'Visible','Off');
set(a2(2),'Color',[0.8500 0.3250 0.0980]); %曲线为绿色
 set(a2(1),'handlevisibility','off');
a3=histfit(aji2(:,3),30);
set(a3(1),'Visible','Off');
 set(a3(1),'handlevisibility','off');
set(a3(2),'Color',[190 190 190]/255); %曲线为绿色
legend('平差前','整体平差','验后平差');
xlabel('不符值/m');

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
% end    



%% 
