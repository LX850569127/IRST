% 误差处理 
% All_CP=[];   %用于保存所有的经过误差处理后的点 
% BiasStatistics=[];
% for j=1:12
%     month=num2str(j);
%     if j<10
%     VariateName_CP=strcat('CP2', '_A130',month,'_D130',month); 
%     else
%           VariateName_CP=strcat('CP2', '_A13',month,'_D13',month); 
%     end
%     CP=eval(VariateName_CP);
%     ADBias=[];
%     DABias=[];
% 
%     for i=1:size(CP,1)
%         
%             cor=CP(i).coordinate;
%             altitude_A=CP(i).altitude(1,1);
%             altitude_D=CP(i).altitude(2,1);
%             time_A=CP(i).altitude(1,2);
%             time_D=CP(i).altitude(2,2);
%             if time_A<time_D        
%                 ADBias=[ADBias;cor,altitude_D-altitude_A];       
%             else 
%                 DABias=[DABias;cor,altitude_A-altitude_D];
%             end    
%         
%     end
%     
%     Bias=[ADBias;DABias];
%     meanBias_BP=mean(abs(Bias(:,3)))*100;  %处理前不符值均值
%     size_BP=size(Bias,1);           %处理前数据量
%     RMS_BP=sqrt(sum(Bias(:,3).*Bias(:,3))/size_BP)*100;  %处理前均方根
%     
%     %调试
%     Bias(:,3)=abs(Bias(:,3));
%     %数据剔除
%     Bias(abs(Bias(:,3))>2,:)=[];  %5m粗差剔除  换成3m粗差剔除试试
%     std_Bias=std(Bias(:,3));
%     Bias(abs(Bias(:,3)-mean(Bias(:,3)))>=3*std_Bias,:)=[];  %3倍中误差剔除
%     
%     All_CP=[All_CP;Bias];
%     
%     meanBias_AP=mean(abs(Bias(:,3)))*100;  %处理后不符值均值
%     size_AP=size(Bias,1);           %处理前数据量
%     RMS_AP=sqrt(sum(Bias(:,3).*Bias(:,3))/size_AP)*100;  %处理后均方根
%     reject_Ratio=(1-(size_AP/size_BP))*100; %数据剔除率
%     
%     Output= struct('meanBias_BP',meanBias_BP,'size_BP',size_BP,'RMS_BP',RMS_BP ...
%      ,'meanBias_AP',meanBias_AP,'size_AP',size_AP,'RMS_AP',RMS_AP,'reject_Ratio',reject_Ratio);
%     BiasStatistics=[BiasStatistics;Output]
% end

%% 换一种误差处理方式  
% 先集合1年的数据再进行处理 且把误差认定阈值调低
% CP2_A1301_D1301=AllCrossOverPoint;
All_CP=[];   %用于保存所有的经过误差处理后的点 
BiasStatistics=[];
for j=1:12
    month=num2str(j);
    if j<10
    VariateName_CP=strcat('CP', '_A110',month,'_D110',month); 
    else
          VariateName_CP=strcat('CP', '_A11',month,'_D11',month); 
    end
    CP=eval(VariateName_CP);
    ADBias=[];
    DABias=[];
    for i=1:size(CP,1)        
            cor=CP(i).coordinate;
            altitude_A=CP(i).altitude(1,1);
            altitude_D=CP(i).altitude(2,1);
            time_A=CP(i).altitude(1,2);
            time_D=CP(i).altitude(2,2);
            PDOP=CP(i).PDOP;
            if time_A<time_D        
                ADBias=[ADBias;cor,altitude_D-altitude_A,PDOP];       
            else 
                DABias=[DABias;cor,altitude_A-altitude_D,PDOP];
            end           
    end    
    Bias=[ADBias;DABias];
    All_CP=[All_CP;Bias];
 
      meanBias_PDOP=mean(All_CP(:,4));
      All_CP(abs(All_CP(:,3))>2,:)=[];      %认定超过2m的不符值为粗差，进行剔除
      All_CP(:,3)=abs(All_CP(:,3));  
      std_Bias=std(All_CP(:,3));
             
      All_CP(abs(All_CP(:,3)-mean(All_CP(:,3)))>=3*std_Bias,:)=[];  %3倍中误差剔除
      All_CP(abs(All_CP(:,3))>1,:)=[];
      RMS=sqrt(sum(All_CP(:,3).*All_CP(:,3))/size(All_CP,1))*100;   %处理后均方根
      meanBias=mean(All_CP(:,3))*100; 
      
end    
%%

% 误差处理以及处理后的点进行保存
% for j=1:12
%     month=num2str(j);
%     if j<10
%     VariateName_CP=strcat('CP2', '_A130',month,'_D130',month); 
%     else
%           VariateName_CP=strcat('CP2', '_A13',month,'_D13',month); 
%     end
%     CP=eval(VariateName_CP);   %结构体形式
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
% end






% meanBias=mean(Bias(:,3));
% stdBias=std(Bias(:,3),0);
% Bias(abs(Bias(:,3)-meanBias)>3*std(Bias(:,3),0),:)=[];
% mean(Bias(:,3));
% end

% a=zeros(1258,3);
% for i=1:1258
%     cor=ADBias201301(i).coordinate;
%     changeRate=ADBias201301(i).changeRate;
%     a(i,1:2)=cor;
%       a(i,3)=changeRate;
% end


% for i=1:1258
%     if  abs(Bias(i,3))<2.5
%   if Bias(i,2)>-80
%       BiasMoreNe80=[BiasMoreNe80;Bias(i,:)];
%   elseif Bias(i,2)>-82
%       BiasMoreNe82=[BiasMoreNe82;Bias(i,:)];
%   elseif Bias(i,2)>-84
%       BiasMoreNe84=[BiasMoreNe84;Bias(i,:)];
%   else
%       BiasMoreNe88=[BiasMoreNe88;Bias(i,:)];  
%   end
%     end
% end

% PDOP=zeros(size(CP2_A1301_D1301,1),1);
% for i=1:size(CP2_A1301_D1301,1)
%     PDOP(i)=CP2_A1301_D1301(i).PDOP;
% end
%     std_Bias=std(PDOP(:,1));
% %     PDOP(abs(PDOP(:,1)-mean(PDOP(:,1)))>=3*std_Bias,:)=[];  %3倍中误差剔除
%   
% %     RMS_AP=sqrt(sum(All_CP(:,3).*All_CP(:,3))/size(All_CP,1))*100;  %处理后均方根
%     meanBias_PDOP=mean(PDOP);