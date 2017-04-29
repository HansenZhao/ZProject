function [indexTag,C,D] = optKMeans(raw,k,comd,p,optTime)
    disp('Optimization begin...');
    disp(strcat('Total trial: ',num2str(optTime)));
    [indexTag,C,D] = kMeans(raw,k,comd,p);
    if optTime > 1
        for m = 2:1:optTime
            [I,c,d] = kMeans(raw,k,comd,p);
            if(d<D)
                indexTag = I;
                C = c;
                D = d;
            end
        end
        disp(strcat('The optimized distance is: ',num2str(D)));
    end    
end

