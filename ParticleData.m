classdef ParticleData < handle
    %standard particle data |particleID|frame|X|Y|Z|
    properties
        idx;
    end
    
    properties (Access = private)
        particleData;     
    end
    
    properties (Dependent)
        particleNum;
        minLength;
    end
    
    methods
        function obj = ParticleData(raw)
            obj.particleData = raw;
            obj.idx = [];
        end
        
        function num = get.particleNum(obj)
            ids = obj.particleData(:,1);
            num = length(unique(ids));
        end
        
        function mL = get.minLength(obj)
            ids = obj.getIds();
            mL = inf;
            for id = ids
                len = sum(obj.particleData(:,1)==id);
                if len < mL
                    mL = len;
                end
            end
        end
        
        function data = getParticle(obj,varargin)
            if isempty(varargin)
                data = obj.particleData;
                return;
            end
            data = obj.particleData(obj.particleData(:,1)==varargin{1},2:5);
        end
        
        function delShort(obj,lowLength)
            ids = obj.getIds();
            for m = ids
                if sum(obj.particleData(:,1)==m) < lowLength
                    obj.particleData(obj.particleData(:,1)==m,:)=[];
                end
            end
        end
                   
        function plotParticle(obj,varargin)
            figure;
            if nargin > 1
                isText = varargin{1};
            else
                isText = false;
            end
            hold on;
            numParticle = obj.particleNum;
            ids = obj.getIds();
            if isText
                Xoffset = range(obj.particleData(:,3))/100;
                Yoffset = range(obj.particleData(:,4))/100;
            end
            for m = 1:1:numParticle
                id = ids(m);
                trace = obj.getParticle(id);
                if ~isempty(obj.idx)
                    c = lines;
                    plot(trace(:,2),trace(:,3),'Color',c(obj.idx(m),:));
                    if isText
                        text(mean(trace(:,2))+Xoffset,mean(trace(:,3))+Yoffset,...
                            num2str(id),'Color',c(obj.idx(m),:));
                    end
                else
                    plot(trace(:,2),trace(:,3));
                end
            end
            hold off;
            box on;
        end
              
        function zeroPlot(obj,varargin)
            if nargin == 1
                style = '2D';
            else
                style = varargin{1};
            end
            figure;
            hold on;
            box on;
            numParticle = obj.particleNum;
            ids = obj.getIds();
            for m = 1:1:numParticle
                id = ids(m);
                trace = obj.getParticle(id);
                L = size(trace,1);
                trace = trace - repmat(trace(1,:),[L,1]);
                if strcmp(style,'3D')
                    plot3(trace(:,2),trace(:,3),1:1:L,'Color',lines(1));
                    grid on;
                else
                    plot(trace(:,2),trace(:,3),'Color',lines(1));
                end
            end
            hold off;
            box on;
        end
        
        function ids = getIds(obj)
            ids = unique(obj.particleData(:,1)');
        end
        
        function particleNum = getParticleNumAtFrame(obj,frameIndex)
            if frameIndex > max(obj.particleData(:,2))
                fprintf(1,'frame index: %d is higher than the max index: %d',...
                           frameIndex,max(obj.particleData(:,2)));
            end
            particleNum = sum(obj.particleData(:,2) == frameIndex);
        end
        
        function parId = getParticleIDAtTime(obj,frameIndex)
            filter = obj.particleData(:,2) == frameIndex;
            parId = obj.particleData(filter,1);
        end
        
        function [ids,pos,dir,tDir] = getParticleDirAtTime(obj,frameIndex,isRef,backLength)
            ids = intersect(obj.getParticleIDAtTime(frameIndex-backLength),...
                            obj.getParticleIDAtTime(frameIndex));
            L = length(ids);
            pos = zeros(L,2);
            dir = zeros(L,1);
            tDir = zeros(1,2);
            for m = 1:1:L
                data = obj.getParticle(ids(m)); %frame,x,y,z
                pos(m,:) = data(data(:,1)==frameIndex,2:3);
                v2 = pos(m,:) - data(data(:,1)==(frameIndex-backLength),2:3);
                tDir = tDir + v2/norm(v2);
                if isRef
                    v1 = data(2,2:3) - data(1,2:3);             
                else
                    v1 = [1,0];
                end
                if or(v2(1),v2(2))
                    tmp = dot(v1,v2)/(norm(v1)*norm(v2));
                    if isRef
                        dir(m) = tmp;
                    else if v2(2) > 0
                            dir(m) = acos(tmp);
                        else
                            dir(m) = 2*pi - acos(tmp);
                        end
                    end
                else % in case v2 = [0,0]
                    dir(m) = nan;
                end
            end
            tmp = dot(tDir,[1,0])/norm(tDir);
            if tDir(2) > 0
                tDir = acos(tmp);
            else
                tDir = 2*pi - acos(tmp);
            end
        end
        
        function frames = getFrames(obj)
            frames = unique(obj.particleData(:,2));
        end
    end
    
    methods (Access = private)
        function L = getLength(obj,index)
            [L,~] = size(obj.getParticle(index));
        end
    end
    
end

