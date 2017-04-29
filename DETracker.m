classdef DETracker < handle
    %DETracker Summary of this class goes here
    % Based on Daniel Blair and Eric Dufresne code
    % http://site.physics.georgetown.edu/matlab/index.html#contact
    % "Methods of Digital Video Microscopy for Colloidal Studies", 
    % John C. Crocker and David G. Grier, J. Colloid Interface Sci. 179, 298 (1996).
    properties
        imSeq;
        traceNum;
        showId;
    end
    
    properties(Access = private)
        particleTrace;
        param;
        pSize;
        intensRatio;
        maxVelocity;
    end
    
    methods
        function obj = DETracker()
            obj.imSeq = imageSeq();
            obj.imSeq.listenUpdate(@(src,eventdata)obj.updateTrace(src,eventdata));
            obj.traceNum = 0;
            obj.particleTrace = [];
            obj.param = struct();
            obj.param.mem = 0;
            obj.param.dim = 2;
            obj.param.good = 0;
            obj.param.quiet = 0;
        end
        
        function setPData(obj,data)
            obj.particleTrace = data;
            obj.traceNum = max(data(:,1)) - min(data(:,1)) + 1;
            obj.showId = [];
            obj.imSeq.curImageIndex = 1;
        end
       
        function p = getParticle(obj,varargin)
            if obj.traceNum
                if isempty(varargin)
                    p = obj.particleTrace;
                else
                    p = obj.particleTrace(obj.particleTrace(:,1)==varargin{1},2:4);
                end
            else
                p = 0;
            end
        end
        
        function setShowId(obj,varargin)
            
            if isempty(varargin)
                ids = 1:1:obj.traceNum;
            else
                ids = varargin{1};
            end
            
            if ids <= obj.traceNum
                obj.showId = ids;
            else
                disp('ERROR:particle ID not found!');
            end
        end
        
        function show(obj)
            obj.imSeq.show();
        end
        
    end
    
    methods(Access = private)
        function updateTrace(obj,varargin)
            if ~isempty(obj.showId)
                set(varargin{1}.getAxes(),'NextPlot','add');
                for m = 1:1:length(obj.showId)
                    tmpTrace = obj.getParticle(m - 1);
                    plot(varargin{1}.getAxes(),tmpTrace(:,2),tmpTrace(:,3),'r');
                    text(varargin{1}.getAxes(),tmpTrace(1,2)+1,tmpTrace(1,3)+1,num2str(m),'Color','y','FontSize',8);
                    curPoint = tmpTrace(tmpTrace(:,1)==varargin{1}.curImageIndex,:);
                    if ~isempty(curPoint)
                        scatter(curPoint(:,2),curPoint(:,3),20,'b','filled');
                    end
                end
                set(varargin{1}.getAxes(),'NextPlot','replacechildren');
            end
        end
    end
    
end

