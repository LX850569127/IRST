%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% make cpt from other paper  %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% （1）将colorbar截图存储成jpg或png格式文件。
imread('color_test.png');  % 得到了一个8*428*3的矩阵，其中23是宽（高），189-long是长，3是RGB的维数
color=ans(15,:,:);    %  得到中间一条的颜色信息
all_long =  size(ans,2);
colorfinal=reshape(color,493,3);   %  最后得到中间一条每个点的RGB
colormap(double(colorfinal)/255)    %  需要转化成双精度，0-1之间的数值
colorbar

%（3）将得到的colormap中的rgb[0,1]数值转换为255进制；并参考gmt中cpt的格式进行格式变换。
colormap(CustomColormap);
a=CustomColormap*255;
grav=colormap*255;
gr1=grav(1:2:end,1:3);
gr2=grav(2:2:end,1:3);
long = 256 - 2;
x=[-long:4:long];x=x';
y=[-(long-4):4:(long+4)];y=y';
g=[x gr1 y gr2];

% 保存colorbar以后使用
colorsave = double(colorfinal)/255;
% save colorsave colorsave -ASCII
% save('colorsave','colorsave');

% (4) 将g矩阵复制参考其他cpt格式保存成mygrav.cpt。
% 
% mygrav.cpt末尾加上
% % 
% B    0 0 0
% 
% F    255 255 255
% 
% N    128 128 128

% %%%   available for matlab to adjust cpt file and you can modify colormap
cpt=[g(:,2)/255 g(:,3)/255 g(:,4)/255];
colormap(cpt);
colorbar

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% plot vertical shear wave speed slice
[x y z] = textread('slice1_Vs.txt','%f %f %f%*[^\n]');
dep = max(y);
long = length(x)/dep;
Vs = zeros(long,dep);
for i = 1:long
   for j = 1:dep
       ind = (i-1)*dep+j;
      Vs(i,j) =  z(ind);
   end
end
% imagesc(Vs');
pcolor(Vs);
shading interp
% Vs = griddata(x,y,z,linspace(min(x),max(x),200),linspace(min(y),max(y),200),'v4'); %interpolation
% pcolor(Vs);
colormap(cpt);
colorbar
set(gca,'YDir','reverse');
axis equal
xlim([1 670])
ylim([0 300])
xlabel('Distance (km)')
ylabel('Depth (km)')
title('Vs slice (km/s)')
% (5) 把g矩阵写入用于画gmt的cpt文件中
fid = fopen('mycpt.cpt','w');
len = length(g);

Vs = [3 5.1];
vs_interval = (Vs(2)-Vs(1))/len;
Va = Vs(1);
for i = 1:len
   
%     Vb = Vs(2);
    fprintf(fid,'%f %d %d %d %f %d %d %d\n',Va,g(i,2),g(i,3),g(i,4),Va+vs_interval,g(i,6),g(i,7),g(i,8));
    Va = Va+vs_interval;
end
fprintf(fid,'B %d %d %d\n',0,0,0);
fprintf(fid,'F %d %d %d\n',255,255,255);
fprintf(fid,'N %d %d %d\n',128,128,128);
fclose(fid);