function [X,Y,Z] = genPointHeatMap(haxes,resolution,points,k,r,varargin)
    Xstep = range(points(:,1))/(resolution-1);
    Ystep = range(points(:,2))/(resolution-1);
    [X,Y] = meshgrid(min(points(:,1)):Xstep:max(points(:,1)),...
                     min(points(:,2)):Ystep:max(points(:,2)));
    Z = zeros(resolution,resolution);
    for x_index = 1:1:resolution
        Z(:,x_index) = pos2value2([X(:,x_index),Y(:,x_index)],points,k,r);
    end
    if isempty(varargin)
        h = pcolor(haxes,X,Y,Z);
    else
        h = pcolor(haxes,X,Y,imfilter(Z,fspecial(varargin{1})));
    end
    set(h,'EdgeColor','none');
%     hold on;
%     scatter(points(:,1),points(:,2),points(:,3),10,points(:,3),'filled');
%     hold off;
end

% function [ values ] = pos2value(pos,pointsData,r,NNRange,naMethods)
%     % pos2value(pos,pointsData,r,k,naMethods)
%     % pointsData : X,Y,Value
%     L = size(pos,1);
%     values = zeros(L,1);
%     [D,I] = pdist2(pointsData(:,1:2),pos,'euclidean','Smallest',NNRange(2));
%     for m = 1:1:L
%         NNDistance = D(:,m);
%         NNIndex = I(:,m);
%         validNum = sum(NNDistance <= r);
%         if validNum >= NNRange(1)
%             validNum = min(NNRange(2),validNum);
%             validDis = NNDistance(1:validNum);
%             validIndex = NNIndex(1:validNum);
%             values(m) = disFunc(validDis,pointsData(validIndex,3));
%         else
%             switch(naMethods)
%                 case 'zeros'
%                     values(m) = 0;
%                 case 'min'
%                     values(m) = min(pointsData(:,3));
%                 case 'max'
%                     values(m) = max(pointsData(:,3));
%                 case 'nan'
%                     values(m) = nan;
%             end
%         end
%     end 
% end

function [ values ] = pos2value2(pos,pointsData,K,r)
    % pos2value(pos,pointsData,r,k,naMethods)
    % pointsData : X,Y,Value
    L = size(pos,1);
    values = zeros(L,1);
    [D,I] = pdist2(pointsData(:,1:2),pos,'euclidean','Smallest',K);
    for m = 1:1:L
        NNDistance = D(1:K,m);
        NNIndex = I(1:K,m);
        v = disFunc2(NNDistance,pointsData(NNIndex,3)-min(pointsData(:,3)),r);
        if v < 0.01 * range(pointsData(:,3))
            values(m) = nan;
        else
            values(m) = min(pointsData(:,3)) + v;
        end
        
    end 
end

% function v = disFunc(distance,values)
%     weights = exp(-distance);
%     weights = weights./sum(weights);
%     v = sum(weights.*values);
% end
function v = disFunc2(distance,values,r)
    weights = max(1 - (1/r).*distance,0);
    if sum(weights) > 1
        weights = weights./sum(weights);
    end
    v = sum(weights.*values);
end

