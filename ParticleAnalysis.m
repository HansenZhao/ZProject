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
        
        function visualCell = plotTransientDir(obj,isRef,isBg,backLength)
            frames = obj.pData.getFrames();
            frames = frames((backLength+1):end);
            L = length(frames);
            visualCell = cell(L,1);
            for m = 1:1:L
                [ids,pos,dir,tDir] = obj.pData.getParticleDirAtTime(frames(m),isRef,backLength);
                pSTD = ParticleSTData(frames(m),length(ids));
                %id,posX,posY,colorValue,groupTag
                pSTD.addNewList([ids,pos,dir,zeros(length(ids),1)]);
                pSTD.addInfo(tDir);
                %visualCell{m} = [ids,pos,dir]; % ID,X,Y,Value  
                visualCell{m} = pSTD;
            end
            c = CMVController(frames,visualCell,obj.pData,[0,2*pi]);
            c.show(isBg);
        end
    end
    
end

