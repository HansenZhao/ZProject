function [ velocity ] = xy2vel( XY,deltaT)
    velocity = zeros(size(XY,1),1);
    velocity(2:end) = bsxfun(@(x,y,t)sqrt(sum((x-y).*(x-y),2))/deltaT,XY(2:end,:),XY(1:(end-1),:));
end

