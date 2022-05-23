%% 1. preprocessing 

coor=Ross_A201308(1).coordinate;
figure; 
% plot(Boundary(:,1),Boundary(:,2),'LineWidth',2);
hold on;
scatter(coor(:,1),coor(:,2),12,'filled');
box on;
set(gca,'fontsize',14);