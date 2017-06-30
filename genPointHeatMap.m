function [X,Y,Z] = genPointHeatMap(haxes,type,resolution,points,k,r,power,varargin)
    Xstep = (range(points(:,1))+2*r)/(resolution-1);
    Ystep = (range(points(:,2))+2*r)/(resolution-1);
    [X,Y] = meshgrid((min(points(:,1))-r):Xstep:(max(points(:,1))+r),...
                     (min(points(:,2))-r):Ystep:(max(points(:,2)))+r);
    Z = zeros(resolution,resolution);
    for x_index = 1:1:resolution
        Z(:,x_index) = pos2value2([X(:,x_index),Y(:,x_index)],points,type,k,r,power);
    end
    if isempty(varargin)
        h = pcolor(haxes,X,Y,Z);
        %h = surf(haxes,X,Y,Z);
%         set(h,'EdgeColor','none');       
    else
        h = pcolor(haxes,X,Y,imfilter(Z,fspecial(varargin{1})));
        %h = surf(haxes,X,Y,imfilter(Z,fspecial(varargin{1})));
%         set(h,'EdgeColor','none');
        %h = surf(haxes,X,Y,imfilter(Z,fspecial(varargin{1})));
    end
    set(h,'EdgeColor','none');
%     hold on;
%     scatter3(points(:,1),points(:,2),points(:,3),10,points(:,3),'filled','MarkerEdgeColor','k');
%     hold off;
end


function [ values ] = pos2value2(pos,pointsData,type,K,r,power)
    % pos2value(pos,pointsData,r,k,naMethods)
    % pointsData : X,Y,Value
    L = size(pos,1);
    values = zeros(L,1);
    if strcmp(type,'value')
        [D,I] = pdist2(pointsData(:,1:2),pos,'euclidean','Smallest',K);
        ground_Line = min(pointsData(:,3));
        for m = 1:1:L      
            NNDistance = D(1:K,m);
            NNIndex = I(1:K,m);
            if sum(NNDistance<=r) <= 0
                values(m) = ground_Line;
                continue;
            end
            %values(m) = disFun(NNDistance,pointsData(NNIndex,3),r,0.5);
            v = guassianFun(NNDistance,pointsData(NNIndex,3)-ground_Line,r,power);
            if isnan(v)
                disp('d');
            end
            values(m) = v + ground_Line;
            %v = disFunc2(NNDistance,pointsData(NNIndex,3)-min(pointsData(:,3)),r);
    %         if v < 0.1*min(pointsData(:,3))
    %             values(m) = nan;
    %         else
    %             values(m) = v;
    %         end     
        end
    else
        [D,I] = pdist2(pointsData(:,1:2),pos,'euclidean','Smallest',1);
        filter = (D<=r);
        values(filter) = pointsData(I(filter),3);
        values(~filter) = nan;
    end
end

function v = disFun(d,v0,r,param)
    tmp = v0 .* (max(0,1-(d./r).^param));
    v = sum(tmp);
end

function v = guassianFun(d,v0,r,param)
    %tmp = (v0./(sigma*sqrt(2*pi))).*exp(-d.^2./(2*sigma^2));
    b = r^param./(log(100*v0));
    tmp = v0.*exp(-d.^param./b);
    v = max(tmp);
    return;
%     w = exp(-d.^(param*2));
%     w = w./sum(w);
%     v = tmp' * w;
%     if v>max(v0)
%         disp(v);
%     end
end

function v = disFunc2(distance,values,r)
    weights = max(1 - (1/r).*distance,0);
    if sum(weights) > 1
        weights = weights./sum(weights);
    end
    v = sum(weights.*values);
end


