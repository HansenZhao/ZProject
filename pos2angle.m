% pos2angle : calculate motion angle from position
% [ sita ] = pos2angle( XY,isRadian = true )
function [ sita ] = pos2angle( XY,varargin )
    fun = @(x,y)sum(x.*y,2)./sqrt(sum(x.*x,2));
    V = bsxfun(@minus,XY(2:end,:),XY(1:(end-1),:));
    cosV = fun(V,repmat([1,0],size(V,1),1));

    p = isnan(cosV);
    cosV(p) = 1; 
    V(p,2) = 0;
    
    sita = zeros(size(cosV,1),1);
    for m = 1:1:size(cosV,1)
        if V(m,2) >= 0
            sita(m) = acos(cosV(m));
        else
            sita(m) = 2*pi - acos(cosV(m));
        end
    end
    
    if nargin == 2
        isRadian = varargin{1};
    else
        isRadian = true;
    end
    
    if ~isRadian
        sita = sita.*180./pi;
    end
    sita = [0;sita];
end

