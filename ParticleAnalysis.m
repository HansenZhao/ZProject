classdef ParticleAnalysis < handle
    properties
        pData;
        deltaT;
    end
    
    properties(Access=private)
        idx;
    end
    
    methods
        function obj = ParticleAnalysis(theData,timeInterval)
            obj.pData = theData;
            obj.deltaT = timeInterval;
        end
        
        function result = getMSD(obj,tau,varargin)
            if tau > obj.pData.minLength
                warning('MSD time Lag is bigger than the min particle trace length!');
            end
            if isempty(varargin)
                L = obj.pData.particleNum;
                result = zeros(L,tau);
                ids = obj.pData.getIds();
                for m = 1:1:L
                    id = ids(m);
                    tmp = obj.pData.getParticle(id);
                    result(m,:) = msd(tmp(:,2:3),tau);
                end
                return;
            end
            tmp = obj.pData.getParticle(varargin{1});
            result = msd(tmp(:,2:3),tau);
        end
        
        function h = plotMSD(obj,tau,varargin)
            if isempty(varargin)
                r = obj.getMSD(tau);
                plot(0:1:tau,[0,r(1,:)],'Color',lines(1),'DisplayName','particle MSD');
                hold on;
                h = plot(0:1:tau,[zeros(1,obj.pData.particleNum-1);r(2:obj.pData.particleNum,:)'],'Color',lines(1));
                for m = 1:1:(obj.pData.particleNum - 1)
                    set(get(get(h(m),'Annotation'),'LegendInformation'),'IconDisplayStyle','off'); 
                end
                return;
            end
            h = plot(obj.getMSD(tau)',varargin{1});        
        end
        
        function mapIndexTrace(obj,isTextID)
            if isempty(obj.idx)
                disp('Empty index!')
                return;
            end
            obj.pData.idx = obj.idx;
            obj.pData.plotParticle(isTextID);
        end
        
        function velocityVec = scatterVel(obj,isShow)
            velocityVec = zeros(obj.pData.particleNum,2);
            ids = obj.pData.getIds;
            for m = 1:1:obj.pData.particleNum
                parData = obj.pData.getParticle(ids(m));
                xy = parData(:,2:3);
                vel = xy2vel(xy,obj.deltaT);
                velocityVec(m,:) = [ids(m),mean(vel)];
            end
            if isShow
                scatter(velocityVec(:,1),velocityVec(:,2),10,'filled','DisplayName','Mean velocity of particle');
                xlabel('Particle ID');
                ylabel('Mean Velocity (\mum/s)');
                box on;
            end
        end
        
        function setIdx(obj,theIndex)
            if length(theIndex) == obj.pData.particleNum
                obj.idx = theIndex;
                return;
            end
            disp('Error: Unmatch assignment');
        end
        
        function tag = getIdx(obj)
            tag = obj.idx;
        end
        
        function asymVec = getAsym(obj,isShow,varargin)
            ids = obj.pData.getIds();
            if isempty(varargin)
                asymVec = zeros(obj.pData.particleNum,1);
                for m = 1:1:obj.pData.particleNum
                    trace = obj.pData.getParticle(ids(m));
                    asymVec(m) = xy2asym(trace(:,2:4));
                end
                if isShow
                    scatter(1:1:obj.pData.particleNum,asymVec,15,'filled');
                    box on;
                    xlabel('Index');
                    ylabel('Asym');
                end
            else
                trace = obj.pData.getParticle(ids(varargin{1}));
                asymVec = xy2asym(trace(:,2:3));
            end
            
        end
        
        function indexMSD(obj,maxD,k,varargin)
            if nargin == 3
                method = 'E';
            else
                method = varargin{1};
            end
            [obj.idx,C] = optKMeans(obj.getMSD(maxD),k,method,0,50);
            plot(0:1:maxD,[zeros(k,1),C]','--','LineWidth',1.5);
            for m = 1:1:k
                fprintf(1,'Group: %d has %d samples\n',m,sum(obj.idx==m));
            end
        end
        
        function plotIndexMSD(obj,tau)
            if isempty(obj.index)
                disp('Empty index!')
                return;
            end
            figure;
            hold on;
            numParticle = obj.pData.particleNum;
            ids = obj.pData.getIds();
            c = lines;
            for m = 1:1:numParticle
                id = ids(m);
                msd = obj.getMSD(tau,id);
                plot(0:1:tau,[0;msd],'Color',c(obj.idx(m),:));
            end
            hold off;
            box on;
        end
        
        function h = plotAveMSD(obj,tau)
            if tau > obj.pData.minLength
                warning('MSD time Lag is bigger than the min particle trace length!');
            end
            r = obj.getMSD(tau);
            h = plot(mean(r,1),'r--','LineWidth',2,'DisplayName','average MSD');
        end
        
        function [msdV,coefV,mssV] = plotMSA(obj,isShow)
            msdV = zeros(obj.pData.particleNum,1);
            mssV = zeros(obj.pData.particleNum,1);
            coefV = zeros(obj.pData.particleNum,1);
            ids = obj.pData.getIds();
            for m = 1:1:obj.pData.particleNum
                trace = obj.pData.getParticle(ids(m));
                d = floor(length(trace)/3);
                msdTmp = msd(trace(:,2:3),d);
                [~,mssTmp,~,~] = xy2MSS(trace(:,2:3),6);
                tmp = polyfit(log((1:1:d)*obj.deltaT),log(msdTmp'),1);
                msdV(m) = tmp(1);
                coefV(m) = exp(tmp(2)) * 0.25;
                tmp = polyfit(0:1:6,mssTmp',1);
                mssV(m) = tmp(1);
            end
            if isShow
                scatter3(msdV,coefV,mssV,'filled');
                box on;
                grid on;
                xlabel('Alpha of MSD');
                ylabel('Diffuse Coef');
                zlabel('MSS');
            end
        end
        
        function [visualCell,frames] = collectiveVelDir(obj,comd,backLength,isRef)
            if strcmp(comd,'vel')
                isVel = 1;
            else
                isVel = 0;
            end
            frames = obj.pData.getFrames();
            frames = frames((backLength+1):end);
            L = length(frames);
            visualCell = cell(L,1);
            tDir = zeros(L,1);
            aveV = zeros(L,1);
            tDV = zeros(L,1);
            for m = 1:1:L
                [ids,pos,data] = obj.pData.velocityAtFrame(frames(m),backLength,isRef,1);
                pSTD = ParticleSTData(frames(m),length(ids));
                %id,posX,posY,colorValue,groupTag
                if isVel
                    pSTD.addNewList([ids,pos,data(:,1)./obj.deltaT,zeros(length(ids),1)]);
                else
                    pSTD.addNewList([ids,pos,ParticleAnalysis.vec2angle(data(:,2:3)),zeros(length(ids),1)]);
                end             
                tDir(m) = ParticleAnalysis.vec2angle(sum(data(:,2:3)));
                aveV(m) = mean(data(:,1)./obj.deltaT);
                tDV(m) = ParticleAnalysis.vec2angle(sum(data(:,2:3).*(data(:,1)./obj.deltaT))); 
                pSTD.addInfo(tDir(1:m)); % total sum of normalized dir
                pSTD.addInfo(aveV(1:m)); % average scalar velocity
                pSTD.addInfo(tDV(1:m)); % total sum of vector velocity
                visualCell{m} = pSTD;
            end
%             c = CMVController(frames,visualCell,obj.pData,[0,2*pi]);
%             c.show(isBg);
        end
        
        function [visualCell,frames] = collectiveMSD(obj,backLength,tau,k,methods)
            frames = obj.pData.getFrames();
            frames = frames((backLength+1):end);
            L = length(frames);
            visualCell = cell(L,1);
            local_capacity = 1000;
            local_count = 0;
            all_msd = zeros(local_capacity,tau+1);
            for m = 1:1:L
                [ids,pos,msdMat] = obj.pData.msdAtTime(frames(m),backLength,tau);
                pSTD = ParticleSTData(frames(m),length(ids));
                %id,posX,posY,colorValue,groupTag
                pNum = length(ids);
                pSTD.addNewList([ids,pos,zeros(pNum,1),zeros(pNum,1)],cell(pNum,tau+1));
                pSTD.set(msdMat,'obj');
                visualCell{m} = pSTD;
                if (local_count+pNum) > local_capacity
                    all_msd = [all_msd;zeros(max(local_capacity,pNum),tau+1)];
                    local_capacity = size(all_msd,1);
                end
                all_msd((local_count+1):(local_count+pNum)) = msdMat;
                local_count = local_count + pNum;
            end
            all_msd = all_msd(1:local_count,:);
            [tags,C] = kmeans(all_msd,k,'Distance',methods,'Replicates',10);
            counter = 0;
            for m = 1:1:L
                pNum = visualCell{m}.count;
                visualCell{m}.set(tags((counter+1):(counter+pNum)),'tag');
                visualCell{m}.addInfo(C);
                counter = counter+pNum;
            end        
        end
        
        function [visualCell,frames] = collectiveAsym(obj,backLength)
            frames = obj.pData.getFrames();
            frames = frames((backLength+1):end);
            L = length(frames);
            visualCell = cell(L,1);
            for m = 1:1:L
                [ids,pos,asym] = obj.pData.asymAtFrame(frames(m),backLength);
                pSTD = ParticleSTData(frames(m),length(ids));
                %id,posX,posY,colorValue,groupTag
                pSTD.addNewList([ids,pos,asym,zeros(length(ids),1)]);           
                visualCell{m} = pSTD;
            end
        end
    end
    
    methods(Static)
        function v = vec2angle(vec)
            L = size(vec,1);
            v = zeros(L,1);
            filter = or(vec(:,1),vec(:,2));
            v(filter) = acos(dot(vec(filter,:),repmat([1,0],sum(filter),1),2)./sqrt(sum(vec(filter,:).^2,2)));
            filter2 = vec(:,2)<0;
            v(filter2) = 2*pi - v(filter2);        
        end
    end
    
end

