function [in] = inross(lon,lat,boundary)
% 判断一组点是否位于Ross冰架内

%% Syntax
% [in]=inross(lon,lat,boundary)

%% 针对罗斯冰架绘制的几个矩形
% A1=[166.539,-78.719];
% A2=[166.539,-82.755];
% A3=[199.961,-82.755];
% A4=[199.961,-78.719]; 
% 
% B1=[175.206,-82.755];
% B2=[175.206,-83.866];
% B3=[185.619,-83.866];
% B4=[185.619,-82.755];
% 
% C1=[199.961,-81.050];
% C2=[208.970,-81.050];
% C3=[208.970,-79.474];
% C4=[199.961,-79.474];
% 
% n=size(lon,1);
% in=false(n,1);
% polygon=[A1;A2;B1;B2;B3;B4;A3;C1;C2;C3;C4;A4;A1];
% point=[lon,lat];
% 
% inside=inpolygon(lon,lat,polygon(:,1),polygon(:,2));
% in(find(inside==1))=1;
% 
% 
% if sum(in)~=n
%    p=point(find(inside==0),:);
%    inside1=inpolygon(p(:,1),p(:,2),boundary(:,1),boundary(:,2));
%    in(find(inside==0))=inside1;
% end

%% 
point=[lon,lat];
in=inpolygon(point(:,1),point(:,2),boundary(:,1),boundary(:,2));

% plot(polygon(:,1),polygon(:,2));
%     for i=1:n
%         if inpolygon(lon(i),lat(i),polygon(:,1),polygon(:,2))
%             in(i)=true;
%         else
%             inside = inpolygon(lon(i),lat(i),boundary(:,1),boundary(:,2));
%             if inside
%                 in(i)=true;
%             end
%         end
%     end
end

